-- AlterTable
ALTER TABLE "inventory" ADD COLUMN "unitCost" DECIMAL(10,2),
ADD COLUMN "remainingQuantity" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "sale_items" ADD COLUMN "cogsAmount" DECIMAL(10,2);

-- CreateTable
CREATE TABLE "sale_item_consumption" (
    "id" TEXT NOT NULL,
    "saleItemId" TEXT NOT NULL,
    "inventoryId" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unitCost" DECIMAL(10,2) NOT NULL,
    "totalCost" DECIMAL(10,2) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sale_item_consumption_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "sale_item_consumption_saleItemId_idx" ON "sale_item_consumption"("saleItemId");

-- CreateIndex
CREATE INDEX "sale_item_consumption_inventoryId_idx" ON "sale_item_consumption"("inventoryId");

-- AddForeignKey
ALTER TABLE "sale_item_consumption" ADD CONSTRAINT "sale_item_consumption_saleItemId_fkey" FOREIGN KEY ("saleItemId") REFERENCES "sale_items"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sale_item_consumption" ADD CONSTRAINT "sale_item_consumption_inventoryId_fkey" FOREIGN KEY ("inventoryId") REFERENCES "inventory"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
