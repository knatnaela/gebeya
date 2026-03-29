/**
 * Set sales.locationId to merchant default location where still null (e.g. pre-FIFO sales).
 * Run: npx ts-node scripts/backfill-sales-location-default.ts
 */
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const missing = await prisma.sales.findMany({
    where: { locationId: null },
    select: { id: true, merchantId: true },
  });

  for (const row of missing) {
    const loc = await prisma.locations.findFirst({
      where: { merchantId: row.merchantId, isDefault: true, isActive: true },
    });
    if (!loc) continue;
    await prisma.sales.update({
      where: { id: row.id },
      data: { locationId: loc.id },
    });
  }

  console.log(`Updated ${missing.length} sales with default location where applicable.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
