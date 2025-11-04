/*
  Warnings:

  - Added the required column `costPrice` to the `products` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
-- First add the column as nullable
ALTER TABLE "products" ADD COLUMN     "costPrice" DECIMAL(10,2);

-- Set default value for existing rows (use price as cost price for existing products)
UPDATE "products" SET "costPrice" = "price" WHERE "costPrice" IS NULL;

-- Now make it NOT NULL
ALTER TABLE "products" ALTER COLUMN "costPrice" SET NOT NULL;
