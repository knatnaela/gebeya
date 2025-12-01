-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PAID', 'CREDIT', 'PARTIAL');

-- AlterTable
ALTER TABLE "inventory" ADD COLUMN     "paymentStatus" "PaymentStatus" NOT NULL DEFAULT 'PAID',
ADD COLUMN     "supplierName" TEXT,
ADD COLUMN     "supplierContact" TEXT,
ADD COLUMN     "totalCost" DECIMAL(10,2),
ADD COLUMN     "paidAmount" DECIMAL(10,2),
ADD COLUMN     "paymentDueDate" TIMESTAMP(3),
ADD COLUMN     "paidAt" TIMESTAMP(3);

-- CreateIndex
CREATE INDEX "inventory_paymentStatus_idx" ON "inventory"("paymentStatus");

-- CreateIndex
CREATE INDEX "inventory_paymentDueDate_idx" ON "inventory"("paymentDueDate");

