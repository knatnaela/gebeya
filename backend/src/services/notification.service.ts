import { Resend } from 'resend';
import { env } from '../config/env';
import { prisma } from '../lib/db';

// Enum types - will be available after prisma generate
type NotificationType = 'LOW_STOCK' | 'SALE_SUMMARY' | 'WEEKLY_REPORT' | 'WELCOME' | 'ROLE_ASSIGNED' | 'PASSWORD_RESET';
type NotificationStatus = 'PENDING' | 'SENT' | 'FAILED';

const resend = new Resend(env.RESEND_API_KEY || '');

export interface EmailData {
    to: string;
    subject: string;
    html: string;
    from?: string;
}

export interface WelcomeEmailData {
    email: string;
    firstName: string;
    password?: string;
    role: string;
}

export interface LowStockEmailData {
    email: string;
    productName: string;
    currentStock: number;
    threshold: number;
}

export interface SalesSummaryData {
    email: string;
    date: string;
    totalSales: number;
    totalRevenue: number;
    topProducts: Array<{ name: string; quantity: number }>;
}

export class NotificationService {
    private defaultFrom = 'Gebeya <noreply@gebeya.com>';

    /**
     * Send email using Resend
     */
    async sendEmail(data: EmailData): Promise<void> {
        if (!env.RESEND_API_KEY) {
            console.warn('Resend API key not configured. Email not sent:', data.to);
            return;
        }

        try {
            await resend.emails.send({
                from: data.from || this.defaultFrom,
                to: data.to,
                subject: data.subject,
                html: data.html,
            });
        } catch (error) {
            console.error('Failed to send email:', error);
            throw error;
        }
    }

    /**
     * Send welcome email with password (for new users)
     */
    async sendWelcomeEmail(data: WelcomeEmailData): Promise<void> {
        const passwordSection = data.password
            ? `
        <div style="background-color: #f3f4f6; padding: 16px; border-radius: 8px; margin: 20px 0;">
          <p style="margin: 0 0 8px 0; font-weight: 600; color: #111827;">Your Temporary Password:</p>
          <p style="margin: 0; font-size: 18px; font-family: monospace; color: #059669; font-weight: bold;">${data.password}</p>
          <p style="margin: 8px 0 0 0; font-size: 12px; color: #6b7280;">Please change this password after your first login for security.</p>
        </div>
      `
            : '';

        const html = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px 10px 0 0; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 28px;">Welcome to Gebeya!</h1>
          </div>
          
          <div style="background: white; padding: 30px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 10px 10px;">
            <p>Hello ${data.firstName},</p>
            
            <p>Welcome to Gebeya - your perfume sales and inventory management platform!</p>
            
            ${passwordSection}
            
            <div style="margin: 30px 0;">
              <p><strong>Your Account Details:</strong></p>
              <ul style="margin: 10px 0; padding-left: 20px;">
                <li><strong>Email:</strong> ${data.email}</li>
                <li><strong>Role:</strong> ${data.role}</li>
              </ul>
            </div>
            
            <div style="text-align: center; margin: 30px 0;">
              <a href="${env.FRONTEND_URL}/login" 
                 style="display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; font-weight: 600;">
                Get Started
              </a>
            </div>
            
            <p style="margin-top: 30px; color: #6b7280; font-size: 14px;">
              If you have any questions, please don't hesitate to contact our support team.
            </p>
            
            <p style="margin-top: 20px; color: #6b7280; font-size: 14px;">
              Best regards,<br>
              The Gebeya Team
            </p>
          </div>
        </body>
      </html>
    `;

        await this.sendEmail({
            to: data.email,
            subject: 'Welcome to Gebeya - Your Account is Ready!',
            html,
        });

        // Store notification in database
        await this.createNotification({
            userId: undefined, // Will be set after user creation
            emailTo: data.email,
            type: 'WELCOME' as NotificationType,
            subject: 'Welcome to Gebeya - Your Account is Ready!',
            content: html,
        });
    }

    /**
     * Send low stock alert email
     */
    async sendLowStockAlert(data: LowStockEmailData): Promise<void> {
        const html = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
        </head>
        <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="background: #fef3c7; border-left: 4px solid #f59e0b; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
            <h2 style="margin: 0 0 10px 0; color: #92400e;">⚠️ Low Stock Alert</h2>
            <p style="margin: 0; color: #78350f;">One of your products is running low on stock.</p>
          </div>
          
          <div style="background: white; padding: 30px; border: 1px solid #e5e7eb; border-radius: 10px;">
            <p><strong>Product:</strong> ${data.productName}</p>
            <p><strong>Current Stock:</strong> ${data.currentStock} units</p>
            <p><strong>Threshold:</strong> ${data.threshold} units</p>
            
            <div style="margin-top: 20px; padding: 15px; background: #fef2f2; border-radius: 6px;">
              <p style="margin: 0; color: #991b1b;">
                <strong>Action Required:</strong> Please restock this product to avoid running out of inventory.
              </p>
            </div>
          </div>
        </body>
      </html>
    `;

        await this.sendEmail({
            to: data.email,
            subject: `Low Stock Alert: ${data.productName}`,
            html,
        });
    }

    /**
     * Send daily sales summary email
     */
    async sendDailySalesSummary(data: SalesSummaryData): Promise<void> {
        const topProductsList = data.topProducts
            .map((p, i) => `${i + 1}. ${p.name} - ${p.quantity} sold`)
            .join('<br>');

        const html = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
        </head>
        <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); padding: 30px; border-radius: 10px 10px 0 0; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 28px;">Daily Sales Summary</h1>
            <p style="color: white; margin: 10px 0 0 0; opacity: 0.9;">${data.date}</p>
          </div>
          
          <div style="background: white; padding: 30px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 10px 10px;">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 30px;">
              <div style="background: #f0fdf4; padding: 20px; border-radius: 8px;">
                <p style="margin: 0 0 5px 0; color: #6b7280; font-size: 14px;">Total Sales</p>
                <p style="margin: 0; font-size: 32px; font-weight: bold; color: #059669;">${data.totalSales}</p>
              </div>
              <div style="background: #f0fdf4; padding: 20px; border-radius: 8px;">
                <p style="margin: 0 0 5px 0; color: #6b7280; font-size: 14px;">Total Revenue</p>
                <p style="margin: 0; font-size: 32px; font-weight: bold; color: #059669;">$${data.totalRevenue.toFixed(2)}</p>
              </div>
            </div>
            
            <div>
              <h3 style="margin: 0 0 15px 0;">Top Selling Products</h3>
              <div style="background: #f9fafb; padding: 20px; border-radius: 8px;">
                ${topProductsList || '<p>No products sold today.</p>'}
              </div>
            </div>
          </div>
        </body>
      </html>
    `;

        await this.sendEmail({
            to: data.email,
            subject: `Daily Sales Summary - ${data.date}`,
            html,
        });
    }

    /**
     * Create notification record in database
     */
    async createNotification(data: {
        userId?: string;
        merchantId?: string;
        emailTo: string;
        type: NotificationType;
        subject: string;
        content: string;
    }): Promise<void> {
        // Generate ID (Prisma requires explicit ID for notifications model)
        // Using a simple cuid-like generator
        const generateId = () => {
            const timestamp = Date.now().toString(36);
            const random = Math.random().toString(36).substring(2, 15);
            return `cl${timestamp}${random}`;
        };
        
        await prisma.notifications.create({
            data: {
                id: generateId(),
                userId: data.userId || undefined,
                merchantId: data.merchantId || undefined,
                emailTo: data.emailTo,
                type: data.type,
                subject: data.subject || undefined,
                content: data.content,
                status: 'PENDING' as NotificationStatus,
                updatedAt: new Date(),
            },
        });
    }

    /**
     * Mark notification as sent
     */
    async markNotificationSent(notificationId: string): Promise<void> {
        await prisma.notifications.update({
            where: { id: notificationId },
            data: {
                status: 'SENT' as NotificationStatus,
                sentAt: new Date(),
            },
        });
    }

    /**
     * Mark notification as failed
     */
    async markNotificationFailed(notificationId: string, error: string): Promise<void> {
        await prisma.notifications.update({
            where: { id: notificationId },
            data: {
                status: 'FAILED' as NotificationStatus,
                error,
            },
        });
    }
}

export const notificationService = new NotificationService();

