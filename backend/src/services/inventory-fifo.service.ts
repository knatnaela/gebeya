import { Prisma } from '@prisma/client';
import { AppError } from '../middleware/error.middleware';

export interface FifoAllocation {
  inventoryId: string;
  quantity: number;
  unitCost: number;
  totalCost: number;
}

/**
 * FIFO allocation of physical stock from inventory batches (remainingQuantity).
 * Uses row locks (FOR UPDATE) for concurrent sale safety.
 */
export const inventoryFifoService = {
  async allocateFifo(
    tx: Prisma.TransactionClient,
    params: {
      productId: string;
      locationId: string;
      quantity: number;
      fallbackUnitCost: number;
    }
  ): Promise<FifoAllocation[]> {
    const { productId, locationId, quantity: needQty, fallbackUnitCost } = params;
    if (needQty <= 0) {
      return [];
    }

    const rows = await tx.$queryRaw<
      Array<{ id: string; remainingQuantity: number; unitCost: Prisma.Decimal | null }>
    >`
      SELECT id, "remainingQuantity", "unitCost"
      FROM inventory
      WHERE "productId" = ${productId}
        AND "locationId" = ${locationId}
        AND "remainingQuantity" > 0
      ORDER BY "receivedDate" ASC, id ASC
      FOR UPDATE
    `;

    const allocations: FifoAllocation[] = [];
    let remaining = needQty;

    for (const row of rows) {
      if (remaining <= 0) break;
      const take = Math.min(row.remainingQuantity, remaining);
      const uc =
        row.unitCost != null ? Number(row.unitCost) : fallbackUnitCost;
      const tc = Math.round(take * uc * 100) / 100;

      await tx.inventory.update({
        where: { id: row.id },
        data: { remainingQuantity: { decrement: take } },
      });

      allocations.push({
        inventoryId: row.id,
        quantity: take,
        unitCost: uc,
        totalCost: tc,
      });
      remaining -= take;
    }

    if (remaining > 0) {
      throw new AppError('Insufficient stock for this operation', 400);
    }

    return allocations;
  },

  weightedAverageUnitCost(allocations: FifoAllocation[]): number {
    const totalQty = allocations.reduce((s, a) => s + a.quantity, 0);
    if (totalQty === 0) return 0;
    const sumCost = allocations.reduce((s, a) => s + a.totalCost, 0);
    return Math.round((sumCost / totalQty) * 100) / 100;
  },
};
