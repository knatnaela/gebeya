-- CreateEnum
CREATE TYPE "ProductMeasureUnit" AS ENUM ('PCS', 'ML', 'L', 'G', 'KG');

-- AlterTable
ALTER TABLE "products" ADD COLUMN "measureUnit" "ProductMeasureUnit";
