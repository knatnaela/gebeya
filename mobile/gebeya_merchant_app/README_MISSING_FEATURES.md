# Gebeya Merchant (mobile) — missing work vs merchant web

This document tracks **what is not implemented yet** in the Flutter app compared to the merchant web (`frontend/src/app/(merchant)/merchant/`) and the blueprint in `MOBILE_MERCHANT_APP_SPEC.md` at the repo root.

**Canonical references**

- Feature inventory (web): `MERCHANT_FEATURES.md`
- Mobile implementation blueprint: `MOBILE_MERCHANT_APP_SPEC.md`

---

## Summary

The app already covers **auth**, **dashboard** (KPIs + date filters + subscription fetch), **products** (list, filters, create/edit, CSV export, bulk deactivate), **core inventory** (overview, transactions + CSV, adjust stock, stock entries, add stock, transfer), and **sales** (list, new sale, detail, CSV export, text share / receipt). Everything below is **still missing or placeholder** relative to web parity.

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

## 2. Expenses

| Web | Mobile status |
|-----|----------------|
| List with category + date filters | Missing |
| Create / edit / delete | Missing |

**Endpoints:** `GET/POST /api/expenses`, `GET/PUT/DELETE /api/expenses/:id`  
(Web gates the nav item with `sales.view`, same as today.)

---

## 3. Analytics (dedicated screen)

| Web | Mobile status |
|-----|----------------|
| `/merchant/analytics` page | No dedicated screen; dashboard already uses `GET /sales/analytics` for KPIs only |

Optional: charts and deeper breakdowns depending on API payload (`MOBILE_MERCHANT_APP_SPEC.md` §8.4).

**Permission (web):** `analytics.view`

---

## 4. Locations (CRUD)

| Web | Mobile status |
|-----|----------------|
| List, create, edit, delete, set default | **No** management UI; locations are only fetched for stock/sale flows |

**Endpoints:** `GET/POST /api/locations`, `GET /api/locations/default`, `PUT/PATCH/DELETE` as in `MERCHANT_FEATURES.md` §7.

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
| `MoreScreen` | **Placeholder** — should host shortcuts to Expenses, Analytics, Locations, Users, Settings, Logout, etc. |
| Feature-based nav (e.g. hide Products if no `products.view`) | `CurrentUser.permissions` exists but **no route/tab gating** like web sidebar |
| Inventory search (app bar) | Handler not implemented (commented as “later”) |

---

## 9. Shared gap (web and mobile)

- **Merchant Settings:** Web sidebar links to `/merchant/settings` with `settings.view`, but **no settings page exists** in the web app yet. Mobile can ship a minimal screen (account, change password, subscription read-only) per `MOBILE_MERCHANT_APP_SPEC.md` §5.

---

## Suggested implementation order

Aligned with `MOBILE_MERCHANT_APP_SPEC.md` §7:

1. ~~Sales~~ **done**
2. Locations management  
3. Expenses  
4. Debt and credit  
5. Merchant users  
6. Dedicated analytics / low-stock polish  
7. Permissions + “More” hub  

---

## How to update this file

When a feature ships, remove or check off its section here and keep `MERCHANT_FEATURES.md` / `MOBILE_MERCHANT_APP_SPEC.md` accurate if behavior changes.
