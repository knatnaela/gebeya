import express from 'express';
import cors from 'cors';
import { env } from './config/env';
import { errorHandler } from './middleware/error.middleware';
import { initializeSchedulers } from './services/scheduler.service';
import authRoutes from './routes/auth.routes';
import productRoutes from './routes/product.routes';
import inventoryRoutes from './routes/inventory.routes';
import salesRoutes from './routes/sales.routes';
import auditRoutes from './routes/audit.routes';
import merchantRoutes from './routes/merchant.routes';
import subscriptionRoutes from './routes/subscription.routes';
import platformSettingsRoutes from './routes/platformSettings.routes';
import notificationRoutes from './routes/notification.routes';
import roleRoutes from './routes/role.routes';
import featureRoutes from './routes/feature.routes';
import userRoutes from './routes/user.routes';
import locationRoutes from './routes/location.routes';
import expenseRoutes from './routes/expense.routes';

const app = express();

// Middleware
app.use(cors({
  origin: env.FRONTEND_URL,
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Gebeya API is running' });
});

// API routes
app.get('/api', (req, res) => {
  res.json({ message: 'Gebeya API v1' });
});

// Auth routes
app.use('/api/auth', authRoutes);

// Product routes
app.use('/api/products', productRoutes);

// Inventory routes
app.use('/api/inventory', inventoryRoutes);

// Sales routes
app.use('/api/sales', salesRoutes);

// Audit routes
app.use('/api/audit', auditRoutes);

// Merchant routes (Company dashboard - platform owner only)
app.use('/api/merchants', merchantRoutes);

// Subscription routes
app.use('/api/subscriptions', subscriptionRoutes);

// Platform settings routes
app.use('/api/platform-settings', platformSettingsRoutes);

// Notification routes
app.use('/api/notifications', notificationRoutes);

// RBAC routes
app.use('/api/roles', roleRoutes);
app.use('/api/features', featureRoutes);
app.use('/api/users', userRoutes);

// Location routes
app.use('/api/locations', locationRoutes);

// Expense routes
app.use('/api/expenses', expenseRoutes);

// Error handling middleware (must be last)
app.use(errorHandler);

const PORT = env.PORT;

app.listen(PORT, () => {
  console.log(`🚀 Server is running on http://localhost:${PORT}`);
  console.log(`📊 Environment: ${env.NODE_ENV}`);
  
  // Initialize scheduled notification jobs
  if (env.NODE_ENV === 'production' || process.env.ENABLE_SCHEDULERS === 'true') {
    initializeSchedulers();
  }
});

