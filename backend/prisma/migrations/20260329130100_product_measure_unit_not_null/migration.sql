-- Backfill existing rows before NOT NULL. Customize the WHERE clause in production
-- if not all products should become ML (see MANUAL_MIGRATION.md).
UPDATE "products" SET "measureUnit" = 'ML' WHERE "measureUnit" IS NULL;

-- AlterTable
ALTER TABLE "products" ALTER COLUMN "measureUnit" SET NOT NULL;
