-- CreateEnum
CREATE TYPE "SaleStatus" AS ENUM ('COMPLETED', 'VOIDED');

-- AlterTable
ALTER TABLE "sale_item_consumption" ADD COLUMN "reversedAt" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "sales" ADD COLUMN "locationId" TEXT,
ADD COLUMN "status" "SaleStatus" NOT NULL DEFAULT 'COMPLETED',
ADD COLUMN "voidedAt" TIMESTAMP(3),
ADD COLUMN "voidReason" TEXT,
ADD COLUMN "voidedByUserId" TEXT;

-- CreateIndex
CREATE INDEX "sales_locationId_idx" ON "sales"("locationId");

-- CreateIndex
CREATE INDEX "sales_merchantId_locationId_idx" ON "sales"("merchantId", "locationId");

-- CreateIndex
CREATE INDEX "sales_status_idx" ON "sales"("status");

-- AddForeignKey
ALTER TABLE "sales" ADD CONSTRAINT "sales_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "locations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales" ADD CONSTRAINT "sales_voidedByUserId_fkey" FOREIGN KEY ("voidedByUserId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- Backfill locationId from first consumption row per sale (when table exists)
UPDATE sales s
SET "locationId" = x.loc
FROM (
  SELECT DISTINCT ON (si."saleId")
    si."saleId" AS sid,
    i."locationId" AS loc
  FROM sale_items si
  INNER JOIN sale_item_consumption sic ON sic."saleItemId" = si.id
  INNER JOIN inventory i ON i.id = sic."inventoryId"
  ORDER BY si."saleId", sic."createdAt" ASC
) x
WHERE s.id = x.sid AND s."locationId" IS NULL;
