-- Composite indexes for common merchant + date range filters (analytics, lists).
CREATE INDEX IF NOT EXISTS "sales_merchantId_saleDate_idx" ON "sales"("merchantId", "saleDate");

CREATE INDEX IF NOT EXISTS "expenses_merchantId_expenseDate_idx" ON "expenses"("merchantId", "expenseDate");
