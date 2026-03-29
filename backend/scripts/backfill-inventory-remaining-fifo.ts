/**
 * One-time backfill after FIFO migration:
 * 1) Set unitCost and remainingQuantity on each inventory row
 * 2) Shrink remainingQuantity FIFO per (productId, locationId) to match legacy on-hand stock
 *
 * Run: npx ts-node scripts/backfill-inventory-remaining-fifo.ts
 * (from backend/, with DATABASE_URL set)
 */
import { PrismaClient, InventoryTransactionType } from '@prisma/client';

const prisma = new PrismaClient();

async function legacyOnHand(productId: string, locationId: string): Promise<number> {
  const inv = await prisma.inventory.aggregate({
    where: { productId, locationId },
    _sum: { quantity: true },
  });
  const txn = await prisma.inventory_transactions.aggregate({
    where: {
      productId,
      locationId,
      type: {
        notIn: [InventoryTransactionType.STOCK_IN, InventoryTransactionType.TRANSFER_IN],
      },
    },
    _sum: { quantity: true },
  });
  return (inv._sum.quantity ?? 0) + (txn._sum.quantity ?? 0);
}

async function main() {
  console.log('Backfill: setting unitCost and remainingQuantity = quantity...');

  const rows = await prisma.inventory.findMany({
    include: {
      products: { select: { costPrice: true } },
    },
  });

  for (const row of rows) {
    const unitCost =
      row.totalCost != null && row.quantity > 0
        ? Number(row.totalCost) / row.quantity
        : Number(row.products.costPrice);

    await prisma.inventory.update({
      where: { id: row.id },
      data: {
        unitCost,
        remainingQuantity: row.quantity,
      },
    });
  }

  const pairs = await prisma.inventory.findMany({
    distinct: ['productId', 'locationId'],
    select: { productId: true, locationId: true },
  });

  console.log(`Backfill: FIFO shrink for ${pairs.length} product/location pairs...`);

  for (const { productId, locationId } of pairs) {
    const batches = await prisma.inventory.findMany({
      where: { productId, locationId },
      orderBy: [{ receivedDate: 'asc' }, { id: 'asc' }],
    });

    const r = batches.reduce((s, b) => s + b.remainingQuantity, 0);
    const s = await legacyOnHand(productId, locationId);
    let excess = r - s;

    if (excess < 0) {
      console.warn(
        `[backfill] Inconsistent stock productId=${productId} locationId=${locationId}: remaining sum ${r} < legacy ${s}. Clamping remaining to 0.`
      );
      for (const b of batches) {
        await prisma.inventory.update({
          where: { id: b.id },
          data: { remainingQuantity: 0 },
        });
      }
      continue;
    }

    if (excess === 0) continue;

    for (const b of batches) {
      if (excess <= 0) break;
      const current = await prisma.inventory.findUnique({
        where: { id: b.id },
        select: { remainingQuantity: true },
      });
      if (!current) continue;
      const take = Math.min(current.remainingQuantity, excess);
      await prisma.inventory.update({
        where: { id: b.id },
        data: { remainingQuantity: current.remainingQuantity - take },
      });
      excess -= take;
    }

    if (excess > 0) {
      console.warn(
        `[backfill] Could not remove full excess for productId=${productId} locationId=${locationId}, left ${excess}`
      );
    }
  }

  console.log('Backfill complete.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
