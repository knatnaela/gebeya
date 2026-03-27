# Flutter Merchant Mobile App Specification (Gebeya)

This document describes **how to implement the merchant mobile app in Flutter** for every merchant feature documented in `MERCHANT_FEATURES.md`.

It is written as an implementation blueprint: **screens, navigation, state/data, API endpoints, permission gates, and UX behaviors** for each feature.

---

## 0) Scope & assumptions

- **Target users**: Merchants (Merchant Admin + Merchant Staff). Platform owner access is optional for mobile; assume **merchant-only** in v1.
- **Backend**: reuse the existing REST API (same endpoints as web). Base URL: `NEXT_PUBLIC_API_URL` equivalent (e.g. `https://.../api`).
- **Auth**: JWT bearer token in `Authorization: Bearer <token>`.
- **Permissions**: use `user.permissions` returned by `GET /api/auth/me` to gate UI.
- **Subscription**: show an always-on banner when trial is expired (same semantics as web).
- **Platform owner tenant override** (`?merchantId=`): not required for merchant-only app; can be added later.

---

## 1) Proposed Flutter architecture

### 1.1 Recommended packages

- **Networking**: `dio`
- **Serialization**: `freezed`, `json_serializable`
- **State management**: `flutter_riverpod` (or `bloc`; Riverpod recommended)
- **Storage**: `flutter_secure_storage` (JWT), plus `shared_preferences` (non-sensitive flags)
- **Navigation**: `go_router`
- **UI**:
  - `flutter/material.dart` (Material 3)
  - Icons: `lucide_icons_flutter` or `flutter_lucide` (or standard Material icons)
- **Charts**: `fl_chart` (or `syncfusion_flutter_charts`)
- **Date range picker**: `syncfusion_flutter_datepicker` or `showDateRangePicker`
- **CSV export/share**: `csv`, `share_plus`, `path_provider`
- **Loading skeletons**: `shimmer`

### 1.2 App folder structure (suggested)

```
lib/
  app.dart
  router/
  core/
    api/
      api_client.dart
      dio_interceptors.dart
      endpoints.dart
    auth/
      auth_repository.dart
      auth_state.dart
    permissions/
      permission_service.dart
    ui/
      widgets/ (shared)
      theme/ (colors, typography)
    utils/
  features/
    dashboard/
    products/
    inventory/
    sales/
    expenses/
    locations/
    users/
    subscription/
  models/
```

### 1.3 Cross-cutting UX rules (global)

- **Loading**: show skeletons (Shimmer) for primary content; avoid blocking spinners except for short actions.
- **Errors**:
  - If API returns 401 → log out + redirect to Login.
  - If API returns 403 with `error == "Trial subscription has expired"` → set global “expired” state and show subscription banner across app.
  - For other errors → show page-level error widget with retry.
- **Toasts/snackbars**:
  - Success: SnackBar (green) or toast.
  - Error: SnackBar (red) with a concise message.
- **Pagination**:
  - Prefer infinite scroll on mobile (page/limit), fall back to “Load more”.
- **Filtering**:
  - Use filter bottom sheets with clear/reset actions.
- **Accessibility**:
  - Large tap targets (>= 48dp), semantic labels, readable contrast.

---

## 2) Auth, permissions, subscription (foundation)

### 2.1 Auth flows

#### Login
- **Screen**: `LoginScreen`
- **API**: `POST /api/auth/login` with `{ email, password }`
- **UI/UX (mobile)**
  - Gradient background + centered auth card (see `FLUTTER_UI_UX_STYLE_GUIDE.md`).
  - Email + password fields with clear validation and a full-width primary CTA.
  - Secondary link: “Register as Merchant” → `MerchantSignupScreen`.
- **On success**:
  - Save JWT to secure storage.
  - Immediately fetch user profile: `GET /api/auth/me`
  - Route to `HomeShell` (bottom nav) if allowed.
- **On `requiresPasswordChange`**:
  - Route to `ChangePasswordScreen` and block other routes.

#### Merchant Signup / Registration (Business registration)

- **Screen**: `MerchantSignupScreen`
- **API**: `POST /api/merchants/register`
- **Purpose**: register a new merchant business + initial admin user (pending approval by platform owner).
- **UI/UX (mobile)**
  - Same auth shell styling as login (gradient + card), but scrollable and sectioned:
    - Business info section
    - Admin user section
  - Primary CTA: “Register”
  - Secondary link: “Already have an account? Sign in”
- **Fields**
  - Business:
    - `name` (required)
    - `email` (required)
    - `phone` (optional)
    - `address` (optional)
  - Admin user:
    - `firstName` (required)
    - `lastName` (optional)
    - `password` (required; enforce min length 6 to match current web UI)
    - `confirmPassword` (client-only validation)
- **On success**
  - Show success message: “Registration submitted. Awaiting platform owner approval.”
  - Route to `LoginScreen`
- **Notes**
  - The platform owner must approve the merchant before full access; after approval, a trial subscription is created (platform-owner flow).

#### Change Password (forced)
- **Screen**: `ChangePasswordScreen`
- **API**: `POST /api/auth/change-password` with `{ oldPassword, newPassword }`
- **On success**: clear token, route back to login (same as web).

#### Logout
- Clear token + cached user; route to Login.

### 2.2 Current user + permissions

- **Bootstrap**:
  - On app start, read token.
  - If token exists → call `GET /api/auth/me`.
- **Permissions model**:
  - Store `user.permissions` array (featureSlug + actions) in memory.
  - Utility: `canAccess(featureSlug, [action])`.
- **UI gating**:
  - Hide navigation items user cannot access.
  - Route guards in `go_router` should redirect to an `UnauthorizedScreen` (or hide the route entirely).

### 2.3 Subscription state (global)

- **Provider**: `SubscriptionStateNotifier`
- **API**: `GET /api/subscriptions/status`
- **Behavior**:
  - Fetch on app entry and periodically (e.g. on resume).
  - If expired → show banner on all tabs + block actions that will fail.
  - Still allow viewing subscription status details.

---

## 3) Navigation model (mobile)

### 3.1 Bottom navigation (recommended)

Use a 4–5 tab bottom bar:

- **Dashboard**
- **Products**
- **Inventory**
- **Sales**
- **More** (drawer-like tab containing: Expenses, Locations, Users, Analytics, Settings, Logout)

### 3.3 Auth routes (outside bottom nav)

- `/login` → `LoginScreen`
- `/signup` → `MerchantSignupScreen`
- `/change-password` → `ChangePasswordScreen` (forced when required)

### 3.2 Route patterns

- List pages → detail pages via push.
- Create/edit flows as full-screen pages or modal bottom sheets (depending on complexity).

---

## 4) Feature-by-feature implementation plan (merchant)

Each feature below maps to the corresponding section in `MERCHANT_FEATURES.md`.

---

### Feature 1 — Merchant Dashboard

**Goal**: Provide an at-a-glance overview + quick actions.

- **Screens**
  - `DashboardScreen`
  - Optional: `DashboardFiltersSheet` (date range)
- **Key UI**
  - KPI cards: Revenue, Gross Profit, Expenses, Net Profit, Margin, Total Sales, Total Products, Low Stock count.
  - Quick actions: “New Sale”, “Add Product”, “Adjust Stock”.
  - Subscription banner (global component).
- **APIs**
  - `GET /api/inventory/summary`
  - `GET /api/sales/analytics?startDate=&endDate=`
  - `GET /api/subscriptions/status`
- **States**
  - `DashboardState { inventorySummary, salesAnalytics, subscriptionStatus }`
- **Edge cases**
  - If subscription expired: still show subscription status section; other calls may 403 → show `SubscriptionExpiredCard`.

---

### Feature 2 — Products (Catalog)

**Goal**: Create, browse, filter, update, deactivate/reactivate products + stock visibility.

- **Screens**
  - `ProductsListScreen`
  - `ProductCreateEditScreen` (create/edit)
  - Optional: `ProductDetailScreen` (v1 can skip; web uses list+dialog)
- **Permission**
  - Gate entire module with `products.view`.
  - Actions (optional, if backend enforces): `products.create`, `products.edit`, `products.delete`.
- **Key UI**
  - Search bar + filter chips (“In stock”, “Low stock”, “Out of stock”, “Active/Inactive”, Brand, Size, Price range).
  - Product list item:
    - Name/brand/size, price, badge for stock, badge for active/inactive, thumbnail if `imageUrl`.
  - Bulk actions:
    - On mobile, implement multi-select mode (long press to start) with “Deactivate” and “Export CSV”.
    - Export: generate CSV in-app and share via `share_plus`.
- **APIs**
  - `GET /api/products` (with filters, pagination)
  - `GET /api/products/low-stock`
  - `POST /api/products`
  - `PUT /api/products/:id`
  - `DELETE /api/products/:id`
  - `GET /api/locations/default`
  - `GET /api/inventory/stock/:productId?locationId=...`
- **Data model**
  - `Product { id, name, brand, size, price, costPrice, sku, barcode, description, lowStockThreshold, imageUrl, isActive }`
  - `StockMap { productId -> quantity }` (computed per default location)
- **Image UX**
  - v1: allow “Image URL” input only (to match current backend/UI reality).
  - v2: add upload endpoint and implement native upload.

---

### Feature 3 — Inventory Overview (Summary + Transactions + Quick Adjust)

**Goal**: Show inventory summary + recent transactions and allow quick adjustments.

- **Screens**
  - `InventoryOverviewScreen`
  - `AdjustStockSheet` (modal/bottom sheet)
  - `InventoryTransactionsScreen` (optional separate page with paging/filters)
- **Permission**
  - `inventory.view`
- **Key UI**
  - Summary cards: total products, stock value, low stock count, out of stock count.
  - Recent transactions list/table (mobile list):
    - Date, product, location, type, quantity (+/-), user.
  - Export transactions CSV (share).
  - Quick adjust:
    - Product picker, location picker (default), type (RESTOCK / ADJUSTMENT), quantity, reason.
- **APIs**
  - `GET /api/inventory/summary`
  - `GET /api/inventory/transactions?limit=...&page=...`
  - `POST /api/inventory/transactions`
  - Supporting lookups:
    - `GET /api/products`
    - `GET /api/locations`

---

### Feature 4 — Stock Management (Entries + Add Stock + Transfer + Payment Tracking)

**Goal**: Manage stock-in ledger entries and location transfers.

- **Screens**
  - `StockEntriesScreen`
  - `AddStockScreen` (or sheet)
  - `TransferStockScreen` (or sheet)
- **Permission**
  - `inventory.view`
- **Key UI**
  - Entries list:
    - Date received, product, location, quantity, payment status, supplier, cost, batch, expiry, added by.
  - Filters:
    - Product filter, location filter.
  - Add stock form:
    - Required: product, quantity, received date (default today)
    - Optional: location, batch, expiry, notes
    - Payment tracking section:
      - paymentStatus (PAID/CREDIT/PARTIAL)
      - supplierName/contact
      - totalCost, paidAmount (if PARTIAL), dueDate (if CREDIT/PARTIAL)
  - Transfer form:
    - product, fromLocation, toLocation, quantity, notes
- **APIs**
  - `GET /api/inventory/entries?productId=&locationId=`
  - `POST /api/inventory/stock`
  - `POST /api/inventory/transfer`
  - Lookups:
    - `GET /api/products?isActive=true`
    - `GET /api/locations`
- **Nice-to-have (later)**
  - Support transaction detail: `GET /api/inventory/transactions/:id`
  - Stock history chart: `GET /api/inventory/stock/:productId/history`

---

### Feature 5 — Debt & Credit (Supplier payments)

**Goal**: Track unpaid inventory purchases and record payments.

- **Screens**
  - `DebtCreditDashboardScreen`
  - `RecordPaymentSheet`
- **Permission**
  - `inventory.view`
- **Key UI**
  - Summary cards: total debt, full credit, partial payments.
  - Supplier breakdown list.
  - Unpaid items list:
    - Received date, product, supplier, qty, total cost, paid, outstanding, due date, status.
  - Record payment:
    - Input paid amount; quick “Mark fully paid”.
- **APIs**
  - `GET /api/inventory/debt-summary`
  - `PATCH /api/inventory/entries/:inventoryId/mark-paid`

---

### Feature 6 — Low Stock

**Goal**: Dedicated view of products needing restock, with fast actions.

- **Screens**
  - `LowStockScreen`
- **Permission**
  - `inventory.view`
- **Key UI**
  - List low stock products with badges:
    - current stock (computed at default location), threshold, price.
  - Actions:
    - “Add Stock” → deep link to `AddStockScreen` with product preselected.
    - “View Product” → open product edit/detail.
- **APIs**
  - `GET /api/products/low-stock`
  - `GET /api/locations/default`
  - `GET /api/inventory/stock/:productId?locationId=...`

---

### Feature 7 — Locations

**Goal**: Manage warehouses/stores and default location.

- **Screens**
  - `LocationsListScreen`
  - `LocationCreateEditScreen` (or dialog/sheet)
- **Permission**
  - Web gates Locations using `inventory.view`; replicate for v1.
- **Key UI**
  - List locations with “Default” badge and active/inactive status.
  - Actions:
    - Set default
    - Edit
    - Delete (confirm dialog; block delete if default if backend disallows)
- **APIs**
  - `GET /api/locations`
  - `GET /api/locations/default`
  - `POST /api/locations`
  - `PUT /api/locations/:id`
  - `PATCH /api/locations/:id/set-default`
  - `DELETE /api/locations/:id`

---

### Feature 8 — Sales (List + New Sale + Detail/Receipt + Analytics)

#### 8.1 Sales List
- **Screens**
  - `SalesListScreen`
- **Permission**
  - `sales.view`
- **Key UI**
  - Date filter (preset chips + range picker)
  - Search (optional; backend currently supports limited filters—search can be client-side if needed)
  - Sale list item:
    - sale date/time, items count, customer, revenue, net income, margin, sold by
  - Export CSV (share).
- **API**
  - `GET /api/sales?startDate=&endDate=&page=&limit=`

#### 8.2 New Sale
- **Screens**
  - `NewSaleScreen`
  - `AddSaleItemSheet`
  - `ReceiptScreen` (after save)
- **Permission**
  - `sales.view` (and optionally `sales.create`)
- **Key UI**
  - Item builder:
    - Pick product, quantity, sold price (default = product price), allow override.
  - Stock check before adding:
    - Call computed stock endpoint for chosen location.
  - Sale info:
    - Location (default), sale date, customer name/phone (optional), notes.
  - Summary:
    - Total revenue, COGS, net income, margin.
  - Post-success receipt:
    - Show line items, totals, print/share (mobile share, not print).
- **APIs**
  - `GET /api/products?isActive=true`
  - `GET /api/locations`
  - `GET /api/inventory/stock/:productId?locationId=...` (stock check)
  - `POST /api/sales`
  - Optional inline product creation:
    - `POST /api/products`

#### 8.3 Sale Detail
- **Screens**
  - `SaleDetailScreen`
- **Permission**
  - `sales.view`
- **Key UI**
  - Similar to web detail page:
    - revenue, COGS, net income, margin
    - each item: sold vs default, cost price, profit
  - Share/print:
    - Mobile v1: “Share receipt” as text or generated PDF.
- **API**
  - `GET /api/sales/:id`

#### 8.4 Sales Analytics
- **Screens**
  - `AnalyticsScreen` (merchant)
  - Optionally “Charts” subsections: revenue over time, top products, etc. (dependent on backend payload)
- **Permission**
  - `analytics.view`
- **API**
  - `GET /api/sales/analytics?startDate=&endDate=`

---

### Feature 9 — Expenses (List + Create + Edit + Delete)

**Goal**: Track business expenses and reflect them in profit metrics.

- **Screens**
  - `ExpensesListScreen`
  - `ExpenseCreateScreen`
  - `ExpenseEditScreen`
- **Permission**
  - Web gates Expenses using `sales.view` (current behavior). Replicate for v1, or introduce `expenses.view` later.
- **Key UI**
  - Filters:
    - Category, date range.
  - List:
    - Date, category badge, description, amount, recorded by, actions.
  - Create/edit:
    - Category, amount, date, description.
  - Delete:
    - Confirm dialog.
- **APIs**
  - `GET /api/expenses?category=&startDate=&endDate=&page=&limit=`
  - `POST /api/expenses`
  - `GET /api/expenses/:id`
  - `PUT /api/expenses/:id`
  - `DELETE /api/expenses/:id`
  - Optional analytics:
    - `GET /api/expenses/analytics?startDate=&endDate=` (backend exists, web not using)

---

### Feature 10 — Merchant Users (Staff management)

**Goal**: Merchant Admin can create/manage merchant staff and assign roles.

- **Screens**
  - `MerchantUsersListScreen`
  - `MerchantUserCreateScreen` (or dialog)
  - `MerchantUserEditScreen`
- **Permission**
  - `users.view`
  - Create/edit buttons gated by `users.create` / `users.edit` if present in permissions.
- **Key UI**
  - User list with role badges and active/inactive status.
  - Create:
    - email, firstName, lastName
    - assign roleIds (checkbox list)
    - note: backend forces created users to `MERCHANT_STAFF`.
  - Edit:
    - firstName/lastName, active toggle, roleIds.
  - Temporary password:
    - Mobile should show “Password sent via email”.
    - If backend returns `temporaryPassword` in response, show it once in a secure dialog (optional).
- **APIs**
  - `GET /api/users?merchantId=...`
  - `POST /api/users`
  - `PUT /api/users/:id`
  - `GET /api/roles?type=MERCHANT`

---

### Feature 11 — Subscription expired banner (global)

**Goal**: Always inform merchant when trial is expired and prevent confusion.

- **UI component**
  - `SubscriptionBanner` (Flutter widget at top of every tab page / in app scaffold)
- **Behavior**
  - Driven by subscription provider + API interceptor logic.
  - On expired:
    - show red warning card with trial end date (if provided).
    - disable mutation buttons (optional) and show tooltip/snackbar “Subscription expired”.
- **API**
  - `GET /api/subscriptions/status`

---

### Feature 12 — Error/empty states & shared UX components

Implement these shared widgets once and reuse:

- `AppScaffold` (responsive, handles banners)
- `AppErrorView` (message + retry)
- `AppEmptyView` (icon + message + optional CTA)
- `AppLoadingSkeleton` (shimmer templates)
- `ConfirmDialog` (delete confirmations)
- `FilterBottomSheet` (common pattern for filters)
- `CsvExporter` (build CSV + share)

---

## 5) “Merchant Settings” (parity note)

`MERCHANT_FEATURES.md` notes that the web sidebar links to `/merchant/settings` but a page does not exist yet.

For mobile:

- **Option A (recommended)**: Do not include Settings in v1 until backend + web define merchant settings.
- **Option B**: Provide a minimal Settings screen:
  - Account info (email, role, merchant name if available)
  - Change password shortcut
  - Logout
  - Subscription status section (read-only)

---

## 6) API client rules (Flutter)

- Attach token on every request: `Authorization: Bearer ...`
- Global interceptor behaviors:
  - **401**: clear token → route to Login
  - **403 + "Trial subscription has expired"**: set subscriptionExpired=true → show banner
- Parse backend response shape:
  - Most endpoints respond `{ success: boolean, data: ..., pagination?: ... }`
  - Error responses may be `{ success: false, error: string, details?: any }`

---

## 7) Feature implementation order (practical)

1. Auth + Me + Subscription status banner
2. Dashboard
3. Products (list + create/edit)
4. Inventory overview + Stock entries + Add stock
5. Sales (list + create + detail)
6. Locations
7. Expenses
8. Debt & Credit
9. Merchant Users
10. Analytics charts refinements

