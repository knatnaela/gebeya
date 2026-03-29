/**
 * Copy merchant structured phone onto MERCHANT_ADMIN users when users.phone is null.
 * Run: npx ts-node scripts/backfill-user-phones-from-merchants.ts
 */
import { PrismaClient, UserRole } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const admins = await prisma.users.findMany({
    where: {
      role: UserRole.MERCHANT_ADMIN,
      merchantId: { not: null },
      phone: null,
    },
    select: { id: true, merchantId: true },
  });

  let updated = 0;
  for (const u of admins) {
    if (!u.merchantId) continue;
    const m = await prisma.merchants.findUnique({
      where: { id: u.merchantId },
      select: {
        phone: true,
        phoneCountryIso: true,
        phoneDialCode: true,
        phoneNationalNumber: true,
      },
    });
    if (!m?.phone) continue;

    await prisma.users.update({
      where: { id: u.id },
      data: {
        phoneCountryIso: m.phoneCountryIso,
        phoneDialCode: m.phoneDialCode,
        phoneNationalNumber: m.phoneNationalNumber,
        phone: m.phone,
        updatedAt: new Date(),
      },
    });
    updated += 1;
  }

  console.log(`Updated ${updated} user(s).`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
