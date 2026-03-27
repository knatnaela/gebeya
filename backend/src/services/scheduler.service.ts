import cron from 'node-cron';
import { prisma } from '../lib/db';
import { notificationService } from './notification.service';
import { format, subDays, startOfDay, endOfDay } from 'date-fns';

/** Today's sales stats + top products without loading every sale row. */
async function getMerchantSalesSummaryForCreatedRange(
  merchantId: string,
  rangeStart: Date,
  rangeEnd: Date,
  topLimit: number
) {
  const agg = await prisma.sales.aggregate({
    where: {
      merchantId,
      createdAt: { gte: rangeStart, lte: rangeEnd },
    },
    _count: true,
    _sum: { totalAmount: true },
  });

  if (agg._count === 0) {
    return null;
  }

  const topRows = await prisma.$queryRaw<Array<{ name: string; quantity: bigint }>>`
    SELECT p.name, SUM(si.quantity)::bigint AS quantity
    FROM sale_items si
    INNER JOIN sales s ON s.id = si."saleId"
    INNER JOIN products p ON p.id = si."productId"
    WHERE s."merchantId" = ${merchantId}
      AND s."createdAt" >= ${rangeStart}
      AND s."createdAt" <= ${rangeEnd}
    GROUP BY p.name
    ORDER BY SUM(si.quantity) DESC
    LIMIT ${topLimit}
  `;

  return {
    totalSales: agg._count,
    totalRevenue: Number(agg._sum.totalAmount ?? 0),
    topProducts: topRows.map((r) => ({
      name: r.name,
      quantity: Number(r.quantity),
    })),
  };
}

/**
 * Schedule daily sales summary emails
 * Runs at 9 PM every day
 */
export function scheduleDailySalesSummaries() {
  cron.schedule('0 21 * * *', async () => {
    console.log('📧 Running daily sales summary job...');

    try {
      // Get all active merchants
      const merchants = await prisma.merchants.findMany({
        where: { isActive: true },
        include: {
          users: {
            where: {
              role: 'MERCHANT_ADMIN',
              isActive: true,
            },
          },
        },
      });

      const today = new Date();
      const todayStart = startOfDay(today);
      const todayEnd = endOfDay(today);

      for (const merchant of merchants) {
        const summary = await getMerchantSalesSummaryForCreatedRange(
          merchant.id,
          todayStart,
          todayEnd,
          5
        );

        if (!summary) {
          continue;
        }

        const { totalSales, totalRevenue, topProducts } = summary;

        // Send email to each admin
        for (const admin of merchant.users) {
          try {
            await notificationService.sendDailySalesSummary({
              email: admin.email,
              date: format(today, 'MMMM d, yyyy'),
              totalSales,
              totalRevenue,
              topProducts,
            });

            console.log(`✅ Daily summary sent to ${admin.email}`);
          } catch (error) {
            console.error(`❌ Failed to send daily summary to ${admin.email}:`, error);
          }
        }
      }

      console.log('✅ Daily sales summary job completed');
    } catch (error) {
      console.error('❌ Daily sales summary job failed:', error);
    }
  });

  console.log('📅 Daily sales summary scheduler initialized (runs at 9 PM daily)');
}

/**
 * Schedule weekly reports
 * Runs every Monday at 9 AM
 */
export function scheduleWeeklyReports() {
  cron.schedule('0 9 * * 1', async () => {
    console.log('📧 Running weekly report job...');

    try {
      // Get all active merchants
      const merchants = await prisma.merchants.findMany({
        where: { isActive: true },
        include: {
          users: {
            where: {
              role: 'MERCHANT_ADMIN',
              isActive: true,
            },
          },
        },
      });

      const weekStart = startOfDay(subDays(new Date(), 7));
      const weekEnd = endOfDay(new Date());

      for (const merchant of merchants) {
        const weekSummary = await getMerchantSalesSummaryForCreatedRange(
          merchant.id,
          weekStart,
          weekEnd,
          10
        );

        if (!weekSummary) {
          continue;
        }

        const { totalSales, totalRevenue, topProducts } = weekSummary;

        // Get inventory status using computed stock
        const products = await prisma.products.findMany({
          where: {
            merchantId: merchant.id,
            isActive: true,
          },
          select: {
            id: true,
            name: true,
            lowStockThreshold: true,
          },
        });

        // Get default location for stock calculation
        const defaultLocation = await prisma.locations.findFirst({
          where: { merchantId: merchant.id, isDefault: true, isActive: true },
        });

        let lowStockProducts: any[] = [];
        if (defaultLocation && products.length > 0) {
          const { inventoryStockService } = await import('./inventory-stock.service');
          const productIds = products.map((p: any) => p.id);
          const stockMap = await inventoryStockService.getCurrentStockForProducts(
            productIds,
            defaultLocation.id
          );

          lowStockProducts = products
            .map((p: any) => ({
              ...p,
              stockQuantity: stockMap[p.id] || 0,
            }))
            .filter((p: any) => p.stockQuantity <= p.lowStockThreshold);
        }

        // Send weekly report to each admin
        for (const admin of merchant.users) {
          try {
            // For weekly reports, we can use a similar template but with weekly data
            await notificationService.sendDailySalesSummary({
              email: admin.email,
              date: `${format(weekStart, 'MMM d')} - ${format(weekEnd, 'MMM d, yyyy')}`,
              totalSales,
              totalRevenue,
              topProducts: topProducts.map((p) => ({
                name: p.name,
                quantity: p.quantity,
              })),
            });

            console.log(`✅ Weekly report sent to ${admin.email}`);
          } catch (error) {
            console.error(`❌ Failed to send weekly report to ${admin.email}:`, error);
          }
        }
      }

      console.log('✅ Weekly report job completed');
    } catch (error) {
      console.error('❌ Weekly report job failed:', error);
    }
  });

  console.log('📅 Weekly report scheduler initialized (runs every Monday at 9 AM)');
}

/**
 * Initialize all scheduled jobs
 */
export function initializeSchedulers() {
  scheduleDailySalesSummaries();
  scheduleWeeklyReports();
  console.log('✅ All notification schedulers initialized');
}

