# API & database performance findings

This document consolidates two passes over the Gebeya backend (`backend/`) and merchant mobile app (`mobile/gebeya_merchant_app/`): a **domain-heavy** pass (hot endpoints and app call patterns) and a **cross-cutting** pass (per-request overhead, redundant queries, jobs). Use it as a baseline before deeper profiling (APM, `EXPLAIN ANALYZE`, timing middleware).

**Last updated:** 2026-03-27 (third wave: summary caps, stock-filter guard, sales list trim)

### Implemented fixes (same day)

| Finding | Change |
|--------|--------|
| `getExpensesAnalytics` unused `findMany` | Removed; only `aggregate` + `groupBy` remain. |
| `createSale` per-line stock | Uses `getCurrentStockForProducts` for distinct product IDs at the location. |
| `getPlatformAnalytics` top merchants | Single `merchants.findMany({ id: { in } })` instead of 5× `findUnique`. |
| Auth duplicate RBAC queries | `permissionService.getAuthContext()` loads assignments once; middleware uses it + `requiresPasswordChange` in parallel (2 queries instead of 3). |
| `getStockHistory` unbounded | Each of inventory + transactions lists uses `take` (default 100, max 500 via `?limit=`). |
| Batch stock API | `POST /api/inventory/stock/batch` body `{ productIds, locationId? }` → `{ stockByProduct }`. |
| Composite DB indexes | Migration `20260327120000_composite_indexes_sales_expenses`: `(merchantId, saleDate)` on `sales`, `(merchantId, expenseDate)` on `expenses`. Apply with `npx prisma migrate deploy` (done when you’ve run it). |
| Mobile products list stock | `ProductsRepository.fetchProductStockBatch` + `products_controller` uses one POST instead of N GETs. |
| New sale screen load | `Future.wait` on products + locations. |

### Second wave (after migrate deploy)

| Finding | Change |
|--------|--------|
| **`getSalesAnalytics` heavy `findMany`** | COGS and top-10 products use **SQL aggregates** (`$queryRaw`) on `sale_items` + joins; no full sale graph load. `count` + `aggregate` unchanged. |
| **`getDailySales` row scan** | Replaced per-sale loop with **GROUP BY day** in SQL (`to_char` UTC date keys). |
| **Scheduler daily / weekly sales** | `getMerchantSalesSummaryForCreatedRange`: `sales.aggregate` + one grouped `sale_items` query for top products (no nested `findMany`). Weekly report still loads all products for low-stock section. |
| **`home_shell` subscription prefetch** | Removed extra `/subscriptions/status` on shell init; **403 trial-expired** interceptor + first API calls still drive `subscriptionController`. |

### Third wave

| Finding | Change |
|--------|--------|
| **Inventory summary huge arrays** | `lowStockProducts` / `outOfStockProducts` capped at **100** items each; **counts unchanged** (mobile/web rely on `lowStockCount` / `outOfStockCount`). |
| **`getProducts` + stock filters** | **Count** before scan; if **> 8,000** matching products → `400` with message to narrow filters. Stock-filter path uses **`select`** (scalar columns only, smaller rows). |
| **`getLowStockProducts`** | Same **`select`** as list endpoint (no relation hydration). |
| **`getSales` list payload** | Dropped **`imageUrl`** from embedded products; added **`size`** for consistency with detail. |

**Still optional / larger refactors:** inventory summary still loads all product rows for **totals** (unavoidable without materialized stock); weekly job still loads all products for low-stock email; true `getSales` list without line items would need a mobile/web contract change.

---

## Part 1 — Domain hotspots (business logic & mobile traces)

### Backend

| Area | Issue | Notes |
|------|--------|------|
| **`sales.service.ts` — `getSalesAnalytics`** | Loads **all** sales in the date range with nested `sale_items` → `products`, plus `count` and `aggregate`. | COGS and top products are computed in memory. Cost scales with **rows + line items** in range, not with “summary size.” Also calls `getDailySales`, which runs **another** `findMany` over sales in a similar window. |
| **`inventory.service.ts` — `getInventorySummary`** | Loads **every** active product for the merchant, then `getCurrentStockForProducts` (two `groupBy` queries — batching is good). | Stock query cost is reasonable; **full product list** still scales with catalog size. Dashboard calls `/inventory/summary`. |
| **`product.service.ts` — `getLowStockProducts`** | All active products + stock map, then filter. | Same “all products” pattern as summary for low-stock derivation. |
| **`product.service.ts` — `getProducts` with stock filters** | When `lowStock` / `inStock` / `outOfStock` / stock min/max are set: `findMany` **without** pagination, compute stock for **all**, filter, **then** `slice` for page. | Expensive when many products match base filters. |
| **`sales.service.ts` — `createSale`** | Stock validation loops line items and calls `getCurrentStock` **per item** (each = two aggregates). | Should batch with `getCurrentStockForProducts` for the distinct product IDs at that location. |
| **`merchant.service.ts` — `getPlatformAnalytics`** | Top merchants: up to **5** sequential `merchants.findUnique` after `groupBy`. | Could be one `findMany({ where: { id: { in: [...] } } })`. Lower priority than analytics/summary. |

### Indexes (schema)

- `sales` has separate indexes on `merchantId` and `saleDate`. Range analytics often filter **`merchantId` + `saleDate`** together — a **composite** `(merchantId, saleDate)` may help at scale; validate with `EXPLAIN ANALYZE` on production-like data.

### Merchant app (Flutter)

| Area | Issue | Notes |
|------|--------|------|
| **Dashboard** (`dashboard_controller.dart`) | Fetches inventory summary and sales analytics; both futures start before `await` (parallel). | Slowness is mostly **server time + payload**, not sequential client delay. |
| **Products** (`products_controller.dart`) | After each product page load: default location + **`Future.wait` of N × `fetchProductStock`** (one HTTP GET per product, e.g. up to 20). | Many parallel small requests; duplicates work the API could batch server-side. |
| **New sale** (`new_sale_screen.dart`) | `fetchProducts(..., limit: 500)` then `fetchLocations()` **sequentially**; each add-line calls `fetchProductStock`. | Large initial payload; extra round-trip between products and locations; per-add stock API. |

---

## Part 2 — Cross-cutting & deeper findings

### Per-request overhead (authenticated routes)

1. **`authenticate` middleware** (`auth.middleware.ts`)  
   - Runs `getUserPermissions` and `getUserRoles` in parallel.  
   - Both paths load **`user_role_assignments`** with nested `roles → role_features → features` (same graph loaded **twice** for overlapping concerns).  
   - Plus `requiresPasswordChange` → `users.findUnique`.  

2. **Subscription middleware** (`subscription.middleware.ts` on product, inventory, sales, expense, location, user routes)  
   - `checkSubscriptionStatus` → `subscriptions.findFirst` (+ possible `update` when trial is expired).  

**Effect:** Typical merchant API calls pay for **auth + subscription + handler** — often **several DB round trips** before business logic.

### Redundant / wasted queries

| Location | Issue |
|----------|--------|
| **`expense.service.ts` — `getExpensesAnalytics`** | `Promise.all` includes `expenses.findMany` for all rows in range, but the **return value does not use** that result — only `aggregate` and `groupBy` are needed. |

### Unbounded reads

| Location | Issue |
|----------|--------|
| **`inventory-stock.service.ts` — `getStockHistory`** | Two `findMany` (inventory + transactions) for a product with **no pagination** — can grow without bound for active SKUs. |

### Background jobs

| Location | Issue |
|----------|--------|
| **`scheduler.service.ts`** (daily summary, weekly report) | Loops **all active merchants**; per merchant, full `sales.findMany` with nested `sale_items` → `products`. **N merchants × heavy query**; can spike DB at cron time. |

### Other backend notes

- **`getSales` (list):** Paginated, but each page still joins `sale_items` → `products` and `users` — expected for UI, but payload grows with lines per sale.  
- **`notification.controller.ts` — `triggerDailySummary`:** Similar “load all today’s sales with joins” pattern for admin-triggered summary.

### Mobile — duplicate subscription checks (client vs server)

- **`home_shell.dart`** fetches subscription status on init while many routes already run **`checkSubscriptionStatus`** on the server. Not a DB issue on the device, but **redundant client work** if the goal is minimal calls.

---

## Suggested next steps (deeper work)

1. **Measure:** Request timing middleware (auth vs subscription vs handler), or APM; sample slow routes (`/sales/analytics`, `/inventory/summary`, `/products` with stock filters).  
2. **SQL:** `EXPLAIN ANALYZE` on heavy Prisma-generated SQL; consider composite indexes for `sales` / `expenses` date-range + merchant filters.  
3. **Refactors (prioritize by measured impact):**  
   - Slim `getSalesAnalytics` (SQL aggregates / fewer full-table reads).  
   - Batch stock in list APIs or add `POST /inventory/stock/batch`.  
   - Deduplicate auth role/permission loading.  
   - Remove unused `findMany` in `getExpensesAnalytics`.  
   - Paginate `getStockHistory`.  
   - Batch `createSale` stock checks.  
   - Optimize scheduler to fewer/lighter queries per merchant.

---

## File index (quick reference)

| Topic | Primary files |
|--------|----------------|
| Sales analytics & daily breakdown | `backend/src/services/sales.service.ts` |
| Inventory summary & transactions list | `backend/src/services/inventory.service.ts` |
| Products, low stock, stock filters | `backend/src/services/product.service.ts` |
| Stock aggregation helpers | `backend/src/services/inventory-stock.service.ts` |
| Platform merchant analytics | `backend/src/services/merchant.service.ts` |
| Auth + permissions | `backend/src/middleware/auth.middleware.ts`, `backend/src/services/permission.service.ts`, `backend/src/services/role.service.ts` |
| Subscription gate | `backend/src/middleware/subscription.middleware.ts`, `backend/src/services/subscription.service.ts` |
| Expense analytics | `backend/src/services/expense.service.ts` |
| Cron jobs | `backend/src/services/scheduler.service.ts` |
| Dashboard & products (mobile) | `mobile/gebeya_merchant_app/lib/features/dashboard/`, `.../products/products_controller.dart` |
| New sale flow | `mobile/gebeya_merchant_app/lib/features/sales/screens/new_sale_screen.dart` |

This doc is a **static snapshot** of code review findings, not benchmark results.
