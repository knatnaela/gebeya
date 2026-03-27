-- Merchant-level display currency (ISO 4217). Existing rows default to ETB.
ALTER TABLE "merchants" ADD COLUMN "currency" TEXT NOT NULL DEFAULT 'ETB';
