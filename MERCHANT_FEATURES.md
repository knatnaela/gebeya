# Merchant Features Documentation (Gebeya)

This document lists **every merchant-facing feature** found in the codebase (frontend pages, navigation items, shared components that affect merchant behavior, and the backend APIs they use).

## Merchant access model (applies to all merchant features)

- **User roles (JWT `role`)**
  - `MERCHANT_ADMIN`: can manage merchant users (create staff) and operate the merchant workspace.
  - `MERCHANT_STAFF`: can operate the merchant workspace (subject to feature permissions).
  - `PLATFORM_OWNER`: can access merchant workspace too (and can impersonate a tenant via `?merchantId=...` on many endpoints).

- **Tenant / merchant scoping**
  - Merchant requests are scoped by `merchantId` (aka tenant).
  - Merchant users are automatically scoped to their own merchant.
  - Platform owners can specify `merchantId` via query param on many routes (backend middleware: `requireTenant`).

- **Subscription gating**
  - Most merchant operational endpoints are blocked when trial is expired (backend middleware: `checkSubscriptionStatus`).
  - Frontend listens for `403` with error `"Trial subscription has expired"` and shows an always-on banner.
  - Subscription status is still queryable even when expired: `GET /api/subscriptions/status`.

- **Password-change gating**
  - If backend marks `requiresPasswordChange`, the frontend forces users to `/change-password`.

## Merchant navigation (Sidebar) and required permission slugs

These are the merchant nav entries and the **feature slugs** the UI checks for visibility:

- **Dashboard**: `/merchant` (no `requiredFeature`)
- **Products**: `/merchant/products` (`products.view`)
- **Inventory**: `/merchant/inventory` (`inventory.view`)
  - **Overview**: `/merchant/inventory` (`inventory.view`)
  - **Stock Management**: `/merchant/inventory/stock` (`inventory.view`)
  - **Debt & Credit**: `/merchant/inventory/debt` (`inventory.view`)
  - **Low Stock**: `/merchant/inventory/low-stock` (`inventory.view`)
- **Locations**: `/merchant/locations` (`inventory.view`)
- **Sales**: `/merchant/sales` (`sales.view`)
- **Expenses**: `/merchant/expenses` (`sales.view`) *(note: UI currently gates Expenses by `sales.view`)*
- **Analytics**: `/merchant/analytics` (`analytics.view`)
- **Users**: `/merchant/users` (`users.view`)
- **Settings**: `/merchant/settings` (`settings.view`) *(note: nav exists, but no `/merchant/settings` page exists in `frontend/src/app/(merchant)/merchant/`)*

## Feature-by-feature documentation (merchant)

### 1) Merchant Dashboard

- **UI route**: `frontend/src/app/(merchant)/merchant/page.tsx`
- **Purpose**: business overview and quick actions (new sale, add product), plus trial/subscription banners.
- **Key capabilities**
  - View inventory summary (total products, low stock count, etc.).
  - View sales analytics (revenue, profit metrics, totals) with optional date range.
  - View subscription status (trial active/expired, days remaining).
- **Backend APIs used**
  - `GET /api/inventory/summary`
  - `GET /api/sales/analytics?startDate=&endDate=`
  - `GET /api/subscriptions/status`

---

### 2) Products (Catalog Management)

- **UI route**: `frontend/src/app/(merchant)/merchant/products/page.tsx`
- **Related UI components**
  - `frontend/src/components/products/product-form-dialog.tsx`
  - `frontend/src/components/products/bulk-actions.tsx`
- **Required feature slug (UI)**: `products.view`
- **Key capabilities**
  - List products with pagination and filters:
    - Search, brand, size, price range, stock state (in/out/low), active/inactive.
  - Create product (with cost price + selling price).
  - Edit product (including `isActive`).
  - “Delete” product (backend typically marks inactive; UI treats inactive as deleted).
  - Reactivate product (`isActive: true`).
  - Low-stock list.
  - Bulk select:
    - Bulk “delete” (calls delete per id).
    - Bulk export to CSV.
  - Show current stock per product (computed stock), using the default location.
- **Backend APIs used**
  - `GET /api/products?search=&brand=&size=&minPrice=&maxPrice=&lowStock=&inStock=&outOfStock=&minStock=&maxStock=&isActive=&page=&limit=`
  - `GET /api/products/low-stock`
  - `POST /api/products`
  - `PUT /api/products/:id`
  - `DELETE /api/products/:id`
  - `GET /api/locations/default`
  - `GET /api/inventory/stock/:productId?locationId=...`
- **Request body: create product (`POST /api/products`)**
  - `name` (string, required)
  - `brand` (string, optional)
  - `size` (string, optional)
  - `price` (number, > 0, required)
  - `costPrice` (number, > 0, required)
  - `sku` (string, optional)
  - `barcode` (string, optional)
  - `description` (string, optional)
  - `lowStockThreshold` (int, >= 0, optional)
  - `imageUrl` (url string or empty string, optional)
- **Request body: update product (`PUT /api/products/:id`)**
  - Any of the above fields, plus `isActive` (boolean, optional)
- **Image handling (important)**
  - **Current UI behavior**: image upload is effectively **URL-based**; file upload shows “coming soon”.
  - **Backend capability exists**: Cloudinary wrapper lives in `backend/src/services/image.service.ts`, but there is **no exposed upload endpoint** in routes/controllers yet.

---

### 3) Inventory Overview (Summary + Stock Adjustments)

- **UI route**: `frontend/src/app/(merchant)/merchant/inventory/page.tsx`
- **Required feature slug (UI)**: `inventory.view`
- **Key capabilities**
  - View inventory summary.
  - View recent inventory transactions.
  - Export inventory transaction history to CSV.
  - Perform quick “Adjust Stock” which creates an inventory transaction:
    - UI supports “Restock (Add)” and “Adjustment (Remove)”.
    - Quantity is sent as positive for restock and negative for adjustment.
- **Backend APIs used**
  - `GET /api/inventory/summary`
  - `GET /api/inventory/transactions?limit=...`
  - `GET /api/products`
  - `GET /api/locations`
  - `POST /api/inventory/transactions`
- **Request body: create transaction (`POST /api/inventory/transactions`)**
  - `productId` (string, required)
  - `locationId` (string, optional)
  - `type` (enum `InventoryTransactionType`, required)
  - `quantity` (int, non-zero; can be negative)
  - `reason` (string, optional)
  - `referenceId` (string, optional)
  - `referenceType` (string, optional)

---

### 4) Stock Management (Inventory Entries + Transfers + Payment Tracking)

- **UI route**: `frontend/src/app/(merchant)/merchant/inventory/stock/page.tsx`
- **Required feature slug (UI)**: `inventory.view`
- **Key capabilities**
  - View “inventory entries” (stock-in records; treated as immutable ledger entries).
  - Filter entries by product and location.
  - Add stock entries with:
    - optional batch/expiry info
    - optional supplier info
    - **payment tracking** (PAID / CREDIT / PARTIAL), total cost, paid amount, due date
  - Transfer stock between locations.
- **Backend APIs used**
  - `GET /api/locations`
  - `GET /api/products?isActive=true`
  - `GET /api/inventory/entries?productId=&locationId=`
  - `POST /api/inventory/stock`
  - `POST /api/inventory/transfer`
- **Request body: add stock (`POST /api/inventory/stock`)**
  - `productId` (string, required)
  - `locationId` (string, optional)
  - `quantity` (int, > 0, required)
  - `batchNumber` (string, optional)
  - `expirationDate` (ISO datetime string, optional)
  - `receivedDate` (ISO datetime string, optional)
  - `notes` (string, optional)
  - Payment tracking (all optional):
    - `paymentStatus`: `PAID | CREDIT | PARTIAL`
    - `supplierName`, `supplierContact`
    - `totalCost`, `paidAmount`
    - `paymentDueDate` (ISO datetime string)
- **Request body: transfer stock (`POST /api/inventory/transfer`)**
  - `productId` (string, required)
  - `fromLocationId` (string, required)
  - `toLocationId` (string, required)
  - `quantity` (int, > 0, required)
  - `notes` (string, optional)
- **Backend inventory endpoints available (not currently used by merchant UI)**
  - `GET /api/inventory/transactions/:id`
  - `GET /api/inventory/stock/:productId/history`
  - `PUT /api/inventory/products/:id/threshold` *(update product low-stock threshold via inventory route)*

---

### 5) Debt & Credit (Outstanding supplier payments)

- **UI route**: `frontend/src/app/(merchant)/merchant/inventory/debt/page.tsx`
- **Required feature slug (UI)**: `inventory.view`
- **Key capabilities**
  - View aggregate debt/credit totals and counts.
  - Breakdown by supplier.
  - List unpaid inventory items and record payments.
- **Backend APIs used**
  - `GET /api/inventory/debt-summary`
  - `PATCH /api/inventory/entries/:inventoryId/mark-paid`
- **Request body: mark paid (`PATCH /api/inventory/entries/:inventoryId/mark-paid`)**
  - `paidAmount` (number, optional)
    - UI text says “leave empty to mark fully paid”, but the current UI initializes a value; behavior depends on backend implementation.

---

### 6) Low Stock

- **UI route**: `frontend/src/app/(merchant)/merchant/inventory/low-stock/page.tsx`
- **Required feature slug (UI)**: `inventory.view`
- **Key capabilities**
  - Show products at/below their threshold.
  - Fetch computed stock at the default location.
  - Deep links to stock management and product page.
- **Backend APIs used**
  - `GET /api/products/low-stock`
  - `GET /api/locations/default`
  - `GET /api/inventory/stock/:productId?locationId=...`

---

### 7) Locations (Warehouses / Stores)

- **UI route**: `frontend/src/app/(merchant)/merchant/locations/page.tsx`
- **Required feature slug (UI)**: `inventory.view`
- **Key capabilities**
  - Create / edit / delete locations.
  - Set a default location.
  - Mark location active/inactive (backend supports `isActive`; UI sends it on update only if implemented).
- **Backend APIs used**
  - `GET /api/locations`
  - `GET /api/locations/default`
  - `POST /api/locations`
  - `PUT /api/locations/:id`
  - `PATCH /api/locations/:id/set-default`
  - `DELETE /api/locations/:id`
- **Request body: create location**
  - `name` (string, required)
  - `address` (string, optional)
  - `phone` (string, optional)
- **Request body: update location**
  - `name`, `address`, `phone` (optional)
  - `isActive` (boolean, optional)

---

### 8) Sales (List, Create, Detail, Receipt)

#### 8.1 Sales List
- **UI route**: `frontend/src/app/(merchant)/merchant/sales/page.tsx`
- **Required feature slug (UI)**: `sales.view`
- **Key capabilities**
  - List sales with date filter + search.
  - Export sales to CSV (via `ExportButton`).
  - Open sale detail page.
  - View/print receipt dialog (client-side).
- **Backend APIs used**
  - `GET /api/sales?startDate=&endDate=&...`

#### 8.2 New Sale
- **UI route**: `frontend/src/app/(merchant)/merchant/sales/new/page.tsx`
- **Required feature slug (UI)**: `sales.view`
- **Key capabilities**
  - Add products to a sale; auto-uses product default selling price, but allows overriding (“Discount” / “Over Price”).
  - Check stock availability at a selected location before adding items.
  - Select a location (defaults to default location).
  - Add sale date, optional customer name/phone, optional notes.
  - Record sale; shows receipt dialog after success.
  - Create a product inline (opens product form dialog).
- **Backend APIs used**
  - `GET /api/products?isActive=true`
  - `GET /api/locations`
  - `GET /api/inventory/stock/:productId?locationId=...`
  - `POST /api/sales`
  - `POST /api/products` *(inline product creation)*
- **Request body: create sale (`POST /api/sales`)**
  - `items`: array of:
    - `productId` (string, required)
    - `quantity` (int, > 0, required)
    - `unitPrice` (number, > 0, required)
  - `locationId` (string, optional; defaults to default location)
  - `saleDate` (date / datetime string; optional)
  - `notes` (string, optional)
  - `customerName` (string, optional)
  - `customerPhone` (string, optional)

#### 8.3 Sale Detail
- **UI route**: `frontend/src/app/(merchant)/merchant/sales/[id]/page.tsx`
- **Required feature slug (UI)**: `sales.view`
- **Key capabilities**
  - Detailed breakdown of each line item:
    - sold price vs default price, cost price, profit and margin.
  - Print via browser print.
- **Backend APIs used**
  - `GET /api/sales/:id`

#### 8.4 Sales Analytics
- **UI routes**
  - `frontend/src/app/(merchant)/merchant/analytics/page.tsx`
  - `frontend/src/app/(merchant)/merchant/page.tsx` (dashboard analytics cards)
- **Required feature slug (UI)**: `analytics.view`
- **Backend APIs used**
  - `GET /api/sales/analytics?startDate=&endDate=`

---

### 9) Expenses (List, Create, Edit, Delete)

- **UI routes**
  - List: `frontend/src/app/(merchant)/merchant/expenses/page.tsx`
  - Create: `frontend/src/app/(merchant)/merchant/expenses/new/page.tsx`
  - Edit/View: `frontend/src/app/(merchant)/merchant/expenses/[id]/page.tsx`
- **Required feature slug (UI)**: `sales.view` *(current sidebar gate)*
- **Key capabilities**
  - Filter by category and date range.
  - Create expense (amount, category, description, date).
  - Edit expense.
  - Delete expense.
- **Backend APIs used**
  - `GET /api/expenses?category=&startDate=&endDate=&minAmount=&maxAmount=&page=&limit=`
  - `POST /api/expenses`
  - `GET /api/expenses/:id`
  - `PUT /api/expenses/:id`
  - `DELETE /api/expenses/:id`
- **Request body: create expense**
  - `category` (enum `ExpenseCategory`, required)
  - `amount` (number, > 0, required)
  - `description` (string, optional)
  - `expenseDate` (date/datetime string, optional)
- **Backend expense endpoint available (not used by merchant UI)**
  - `GET /api/expenses/analytics?startDate=&endDate=`

---

### 10) Merchant Users (Staff management)

- **UI route**: `frontend/src/app/(merchant)/merchant/users/page.tsx`
- **Required feature slug (UI)**: `users.view`
- **Key capabilities**
  - List users for the current merchant.
  - Merchant admin can create staff users:
    - Backend forces created users to `MERCHANT_STAFF`.
    - Temporary password is generated and (attempted) sent via email; UI may also display it.
  - Edit user (name, active status, assigned roleIds).
  - Assign role(s) from the “MERCHANT” role type list.
- **Backend APIs used**
  - `GET /api/users?merchantId=...`
  - `POST /api/users`
  - `PUT /api/users/:id`
  - `GET /api/roles?type=MERCHANT`
- **Request body: create user (merchant admin path)**
  - UI sends:
    - `email`, `firstName`, `lastName` (optional)
    - `role`: `MERCHANT_STAFF` *(merchant admin UI hard-codes this)*
    - `merchantId`
    - `roleIds` (optional array of role ids)
  - Backend overrides/enforces:
    - merchant admin can only create staff and only for own merchant.

---

### 11) Subscription Status Banner (merchant-wide behavior)

- **UI component**: `frontend/src/components/subscription/subscription-banner.tsx` (rendered inside `MainLayout`)
- **Behavior**
  - Queries `GET /api/subscriptions/status` (merchant-only; disabled for platform owners).
  - Also listens for API interceptor event `subscription-expired` when any API returns 403 expired-trial error.
  - Displays a sticky “Trial Subscription Expired” banner.

---

### 12) Authentication for merchant users

These aren’t “merchant pages” but are required to access merchant features.

#### 12.1 Login

- **UI route**: `frontend/src/app/(auth)/login/page.tsx` (`/login`)
- **Purpose**: authenticate a user and establish a session in the browser.
- **Backend APIs used**
  - `POST /api/auth/login`
  - `GET /api/auth/me` *(fetched after login to hydrate permissions/roles)*
- **Session storage**
  - JWT is stored in `localStorage` under key: `auth_token` (`frontend/src/lib/auth.ts`).
  - Axios interceptor attaches `Authorization: Bearer <token>` (`frontend/src/lib/api.ts`).
- **Global auth failure behavior**
  - Any API `401` triggers token removal + hard redirect to `/login` (Axios response interceptor).

#### 12.2 Merchant Signup / Registration (Business registration)

- **UI route**: `frontend/src/app/register/page.tsx` (`/register`)
- **Purpose**: register a new merchant business + initial admin user, pending approval by platform owner.
- **Backend APIs used**
  - `POST /api/merchants/register`
- **User journey**
  - Merchant submits registration → sees success toast “Awaiting platform owner approval” → redirected to `/login`.
  - Platform owner later approves in company dashboard → trial subscription is created and merchant becomes active (platform owner action, not merchant UI).
- **Request body: merchant registration (`POST /api/merchants/register`)**
  - Business fields:
    - `name` (string, required)
    - `email` (string, required)
    - `phone` (string, optional)
    - `address` (string, optional)
  - Admin user fields:
    - `firstName` (string, required)
    - `lastName` (string, optional)
    - `password` (string, required; UI enforces min 6 chars)

#### 12.3 Change Password (forced)

- **UI route**: `frontend/src/app/(auth)/change-password/page.tsx` (`/change-password`)
- **Purpose**: enforce a password reset when a user has a temporary password / requires password change.
- **Backend APIs used**
  - `POST /api/auth/change-password`
- **UX behavior**
  - The app redirects to `/change-password` when `user.requiresPasswordChange === true` (via `ProtectedRoute`).
  - On success: user is logged out and redirected to login.

#### 12.4 Logout

- **Where implemented**: `AuthProvider.logout()` (`frontend/src/contexts/auth-context.tsx`) + Sidebar “Sign Out”
- **Behavior**
  - Remove `auth_token` and redirect to `/login`.

#### 12.5 Backend endpoints present but not used by merchant UI

- `POST /api/auth/register` exists, but the merchant web UI uses `POST /api/merchants/register` instead.

---

## Merchant-accessible backend features that have no merchant UI yet

These routes exist and are merchant-accessible (subject to auth/tenant/subscription middleware), but there is no dedicated merchant UI page wired up.

- **Audit logs**
  - Backend: `GET /api/audit`
  - Note: backend comment indicates platform owners can see all logs; others see only their merchant logs.

- **Notifications (manual trigger / testing)**
  - Backend: `POST /api/notifications/trigger/daily-summary`
  - No merchant UI is currently calling this.

- **Merchant Settings page**
  - The sidebar links to `/merchant/settings` and requires `settings.view`,
  - but there is **no** `frontend/src/app/(merchant)/merchant/settings/page.tsx` file currently.

---

## Quick API map (merchant UI → backend endpoints)

- `/merchant` → `GET /inventory/summary`, `GET /sales/analytics`, `GET /subscriptions/status`
- `/merchant/products` → `GET /products`, `POST /products`, `PUT /products/:id`, `DELETE /products/:id`, `GET /products/low-stock`, `GET /locations/default`, `GET /inventory/stock/:productId`
- `/merchant/inventory` → `GET /inventory/summary`, `GET /inventory/transactions`, `POST /inventory/transactions`, `GET /products`, `GET /locations`
- `/merchant/inventory/stock` → `GET /inventory/entries`, `POST /inventory/stock`, `POST /inventory/transfer`, `GET /products`, `GET /locations`
- `/merchant/inventory/debt` → `GET /inventory/debt-summary`, `PATCH /inventory/entries/:inventoryId/mark-paid`
- `/merchant/inventory/low-stock` → `GET /products/low-stock`, `GET /locations/default`, `GET /inventory/stock/:productId`
- `/merchant/locations` → `GET /locations`, `POST /locations`, `PUT /locations/:id`, `DELETE /locations/:id`, `PATCH /locations/:id/set-default`
- `/merchant/sales` → `GET /sales`
- `/merchant/sales/new` → `GET /products`, `GET /locations`, `GET /inventory/stock/:productId`, `POST /sales`, `POST /products`
- `/merchant/sales/:id` → `GET /sales/:id`
- `/merchant/analytics` → `GET /sales/analytics`
- `/merchant/expenses` → `GET /expenses`, `DELETE /expenses/:id`
- `/merchant/expenses/new` → `POST /expenses`
- `/merchant/expenses/:id` → `GET /expenses/:id`, `PUT /expenses/:id`
- `/merchant/users` → `GET /users?merchantId=...`, `POST /users`, `PUT /users/:id`, `GET /roles?type=MERCHANT`
- `/login` → `POST /auth/login`, then `GET /auth/me`
- `/register` → `POST /merchants/register`
- `/change-password` → `POST /auth/change-password`

