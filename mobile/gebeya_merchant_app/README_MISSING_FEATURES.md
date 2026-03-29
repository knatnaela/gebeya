# Gebeya Merchant (mobile) — missing work vs merchant web

This document tracks **what is not implemented yet** in the Flutter app compared to the merchant web (`frontend/src/app/(merchant)/merchant/`) and the blueprint in `MOBILE_MERCHANT_APP_SPEC.md` at the repo root.

**Canonical references**

- Feature inventory (web): `MERCHANT_FEATURES.md`
- Mobile implementation blueprint: `MOBILE_MERCHANT_APP_SPEC.md`

---

## Summary

The app already covers **auth** (login, merchant signup, **forgot password**, **reset password**, **Account** for name; **change password** under **More**), **dashboard** (KPIs + date filters + subscription fetch), **products** (list, filters, create/edit, CSV export, bulk deactivate), **core inventory** (overview, transactions + CSV, adjust stock, stock entries, add stock, transfer), **sales** (list, new sale, detail, CSV export, text share / receipt), **locations** (list, CRUD, set default, deactivate), **expenses** (list with category + date filters, create/edit/delete, load more), a **More** hub (locations/expenses shortcuts, account, change password, logout), **feature-based nav** (bottom tabs + stack routes gated by `products.view` / `inventory.view` / `sales.view` like web), and **subscription UX** (proactive `/subscriptions/status`, trial warning banner, full-screen expired state with change password + logout). Everything below is **still missing or placeholder** relative to web parity.

---

## 1. Sales — **done (mobile v1)**

| Area | Status |
|------|--------|
| List, date filters, client-side search, load more, CSV export | Shipped via `GET /sales`, `SalesScreen`, `sales_controller` |
| New sale (lines, location, stock check, customer/notes, link to create product) | `NewSaleScreen`, `POST /sales` |
| Sale detail (margins, line profit) | `SaleDetailScreen`, `GET /sales/:id` |
| Receipt / share | Success sheet + `SharePlus` text share |

**Endpoints in app:** `lib/core/api/endpoints.dart` — `sales`, `sale(id)`; repository: `lib/features/sales/sales_repository.dart`.

**Not in v1 (optional later):** permission tab gating `sales.view`, PDF receipt (spec allows text share).

---

## 2. Expenses — **done (mobile v2)**

| Web | Mobile status |
|-----|----------------|
| List with category + date filters | `ExpensesScreen`, `expenses_controller`, `GET /expenses` |
| Create / edit / delete | `ExpenseFormScreen`, `POST/PUT/DELETE /expenses/:id` |

**Endpoints in app:** `lib/core/api/endpoints.dart` — `expenses`, `expense(id)`; repository: `lib/features/expenses/expenses_repository.dart`.

**Not in v1 (optional later):** permission gating `sales.view` (same as web).

---

## 3. Analytics (dedicated screen)

| Web | Mobile status |
|-----|----------------|
| `/merchant/analytics` page | No dedicated screen; dashboard already uses `GET /sales/analytics` for KPIs only |

Optional: charts and deeper breakdowns depending on API payload (`MOBILE_MERCHANT_APP_SPEC.md` §8.4).

**Permission (web):** `analytics.view`

---

## 4. Locations (CRUD) — **done (mobile v2)**

| Web | Mobile status |
|-----|----------------|
| List, create, edit, delete, set default | `LocationsListScreen`, `LocationFormScreen`; `locations_repository` (also used by stock/sale flows) |

**Endpoints in app:** `locations`, `location(id)`, `locationsDefault`, `locationSetDefault(id)` in `endpoints.dart`.

---

## 5. Debt and credit (supplier payments)

| Web | Mobile status |
|-----|----------------|
| Debt summary, supplier breakdown, mark paid | Missing |

**Endpoints:** `GET /api/inventory/debt-summary`, `PATCH /api/inventory/entries/:inventoryId/mark-paid`

---

## 6. Low stock (dedicated view)

| Web | Mobile status |
|-----|----------------|
| `/merchant/inventory/low-stock` with links to stock/product actions | No dedicated screen (dashboard may show counts; products can filter low stock in places) |

**Endpoints:** `GET /api/products/low-stock`, `GET /api/locations/default`, `GET /api/inventory/stock/:productId`

---

## 7. Merchant users (staff)

| Web | Mobile status |
|-----|----------------|
| List users, create staff, edit roles/status | Missing |

**Endpoints:** `GET /api/users?merchantId=...`, `POST/PUT /api/users`, `GET /api/roles?type=MERCHANT`

**Permission (web):** `users.view`

---

## 8. “More” tab and global parity

| Area | Mobile status |
|------|----------------|
| `MoreScreen` | **Hub shipped:** Locations / Expenses tiles respect `inventory.view` / `sales.view`; Account (name), change password, logout; account header. Still missing: Analytics, Users, web-style Settings page. |
| Feature-based nav (e.g. hide Products if no `products.view`) | **Shipped:** `merchantPermissionsProvider` + `route_permission.dart` redirects; `HomeShell` filters bottom tabs by feature slug (same slugs as web sidebar). |
| Subscription / trial | **Shipped:** refresh after login via `GET /subscriptions/status`; trial warning (≤7 days); expired → `/subscription-expired` (no main shell); change password + logout; 403 interceptor still sets expired. |
| Inventory search (app bar) | Handler not implemented (commented as “later”) |

---

## 9. Shared gap (web and mobile)

- **Merchant Settings:** Web `/merchant/settings` supports **name**, **change password** link, read-only email. Mobile **Account** (`/app/account`) is name only; **change password** is on **More**.

---

## Suggested implementation order

Aligned with `MOBILE_MERCHANT_APP_SPEC.md` §7:

1. ~~Sales~~ **done**
2. ~~Locations management~~ **done**
3. ~~Expenses~~ **done**
4. Debt and credit  
5. Merchant users  
6. Dedicated analytics / low-stock polish  
7. ~~Permissions + subscription shell UX~~ **done** (remaining: Analytics, Users, Settings in More)  

---

## How to update this file

When a feature ships, remove or check off its section here and keep `MERCHANT_FEATURES.md` / `MOBILE_MERCHANT_APP_SPEC.md` accurate if behavior changes.
