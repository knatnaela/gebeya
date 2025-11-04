import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { notificationService } from '../services/notification.service';
import { prisma } from '../lib/db';
import { format, subDays, startOfDay, endOfDay } from 'date-fns';

export class NotificationController {
  /**
   * Manually trigger daily sales summary for current merchant
   */
  async triggerDailySummary(req: AuthRequest, res: Response): Promise<void> {
    try {
      if (!req.user?.merchantId) {
        res.status(400).json({
          success: false,
          error: 'Merchant ID is required',
        });
        return;
      }

      const today = new Date();
      const todayStart = startOfDay(today);
      const todayEnd = endOfDay(today);

      // Get today's sales
      const sales = await prisma.sales.findMany({
        where: {
          merchantId: req.user.merchantId,
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

      const totalSales = sales.length;
      const totalRevenue = sales.reduce((sum, sale) => sum + Number(sale.totalAmount), 0);

      // Get top products
      const productSales: Record<string, { name: string; quantity: number }> = {};
      sales.forEach((sale) => {
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

      // Get merchant admin email
      const user = await prisma.users.findUnique({
        where: { id: req.user.userId },
      });

      if (!user) {
        res.status(404).json({
          success: false,
          error: 'User not found',
        });
        return;
      }

      await notificationService.sendDailySalesSummary({
        email: user.email,
        date: format(today, 'MMMM d, yyyy'),
        totalSales,
        totalRevenue,
        topProducts,
      });

      res.json({
        success: true,
        message: 'Daily sales summary sent successfully',
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        error: error.message || 'Failed to send daily summary',
      });
    }
  }
}

export const notificationController = new NotificationController();

