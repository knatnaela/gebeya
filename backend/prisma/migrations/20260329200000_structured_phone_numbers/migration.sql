-- AlterTable merchants
ALTER TABLE "merchants" ADD COLUMN "phoneCountryIso" TEXT;
ALTER TABLE "merchants" ADD COLUMN "phoneDialCode" TEXT;
ALTER TABLE "merchants" ADD COLUMN "phoneNationalNumber" TEXT;

-- AlterTable locations
ALTER TABLE "locations" ADD COLUMN "phoneCountryIso" TEXT;
ALTER TABLE "locations" ADD COLUMN "phoneDialCode" TEXT;
ALTER TABLE "locations" ADD COLUMN "phoneNationalNumber" TEXT;

-- AlterTable sales (customer phone structured fields)
ALTER TABLE "sales" ADD COLUMN "customerPhoneCountryIso" TEXT;
ALTER TABLE "sales" ADD COLUMN "customerPhoneDialCode" TEXT;
ALTER TABLE "sales" ADD COLUMN "customerPhoneNationalNumber" TEXT;
