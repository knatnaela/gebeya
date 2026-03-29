-- AlterTable platform_settings
ALTER TABLE "platform_settings" ADD COLUMN "phoneFirstCountryIsoCodes" TEXT[] DEFAULT ARRAY[]::TEXT[];

-- AlterTable users
ALTER TABLE "users" ADD COLUMN "phoneCountryIso" TEXT;
ALTER TABLE "users" ADD COLUMN "phoneDialCode" TEXT;
ALTER TABLE "users" ADD COLUMN "phoneNationalNumber" TEXT;
ALTER TABLE "users" ADD COLUMN "phone" TEXT;

CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateTable telegram_gateway_verification_sessions
CREATE TABLE "telegram_gateway_verification_sessions" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "requestId" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "consumedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "telegram_gateway_verification_sessions_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "telegram_gateway_verification_sessions_requestId_key" ON "telegram_gateway_verification_sessions"("requestId");

CREATE INDEX "telegram_gateway_verification_sessions_userId_idx" ON "telegram_gateway_verification_sessions"("userId");

CREATE INDEX "telegram_gateway_verification_sessions_expiresAt_idx" ON "telegram_gateway_verification_sessions"("expiresAt");

ALTER TABLE "telegram_gateway_verification_sessions" ADD CONSTRAINT "telegram_gateway_verification_sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
