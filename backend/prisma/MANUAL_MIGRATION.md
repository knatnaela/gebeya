# Product `measureUnit` migration notes

## Nullable → NOT NULL

Migration `20260329130000_add_product_measure_unit_nullable` adds `measureUnit` with **no default** (nullable column).

Migration `20260329130100_product_measure_unit_not_null` runs:

```sql
UPDATE "products" SET "measureUnit" = 'ML' WHERE "measureUnit" IS NULL;
ALTER TABLE "products" ALTER COLUMN "measureUnit" SET NOT NULL;
```

## Custom backfill before NOT NULL

If only some rows should be `ML` (e.g. perfume) and others `PCS`, **between** the two migrations run targeted SQL, for example:

```sql
UPDATE "products" SET "measureUnit" = 'ML' WHERE "merchantId" = '<merchant_id>';
-- or
UPDATE "products" SET "measureUnit" = 'PCS' WHERE "measureUnit" IS NULL AND <condition>;
```

Then apply migration `20260329130100` (or adjust its `UPDATE` line to match your rules).

## Verify row counts

Before `SET NOT NULL`:

```sql
SELECT "measureUnit", COUNT(*) FROM "products" GROUP BY "measureUnit";
SELECT COUNT(*) FROM "products" WHERE "measureUnit" IS NULL;
```

The last query must return `0` before the NOT NULL migration succeeds.
