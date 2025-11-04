import cron from 'node-cron';
import { prisma } from '../lib/db';
import { notificationService } from './notification.service';
import { salesService } from './sales.service';
import { format, subDays, startOfDay, endOfDay } from 'date-fns';

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
        // Get today's sales for this merchant
        const sales = await prisma.sales.findMany({
          where: {
            merchantId: merchant.id,
            createdAt: {
              gte: todayStart,
              lte: todayEnd,
            },
          },
          include: {
            sale_items: {
              include: {
                products: {
                  select: {
                    name: true,
                  },
                },
              },
            },
          },
        });

        if (sales.length === 0) {
          continue; // Skip if no sales today
        }

        // Calculate totals
        const totalSales = sales.length;
        const totalRevenue = sales.reduce(
          (sum: number, sale: any) => sum + Number(sale.totalAmount),
          0
        );

        // Get top products
        const productSales: Record<string, { name: string; quantity: number }> = {};
        sales.forEach((sale: any) => {
          sale.sale_items.forEach((item: any) => {
            const productName = item.products.name;
            if (!productSales[productName]) {
              productSales[productName] = { name: productName, quantity: 0 };
            }
            productSales[productName].quantity += item.quantity;
          });
        });

        const topProducts = Object.values(productSales)
          .sort((a, b) => b.quantity - a.quantity)
          .slice(0, 5);

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
        // Get week's sales
        const sales = await prisma.sales.findMany({
          where: {
            merchantId: merchant.id,
            createdAt: {
              gte: weekStart,
              lte: weekEnd,
            },
          },
          include: {
            sale_items: {
              include: {
                products: {
                  select: {
                    name: true,
                  },
                },
              },
            },
          },
        });

        if (sales.length === 0) {
          continue; // Skip if no sales this week
        }

        // Calculate totals
        const totalSales = sales.length;
        const totalRevenue = sales.reduce(
          (sum: number, sale: any) => sum + Number(sale.totalAmount),
          0
        );

        // Get top products
        const productSales: Record<string, { name: string; quantity: number }> = {};
        sales.forEach((sale: any) => {
          sale.sale_items.forEach((item: any) => {
            const productName = item.products.name;
            if (!productSales[productName]) {
              productSales[productName] = { name: productName, quantity: 0 };
            }
            productSales[productName].quantity += item.quantity;
          });
        });

        const topProducts = Object.values(productSales)
          .sort((a, b) => b.quantity - a.quantity)
          .slice(0, 10);

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

