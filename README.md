# Gebeya - Multi-Tenant Perfume Sales & Inventory Management System

A comprehensive multi-tenant platform for managing perfume sales and inventory with modern UI/UX and scalable architecture.

## 🚀 Features

- **Multi-Tenant Architecture**: Complete data isolation per merchant
- **Role-Based Access Control**: Platform Owner, Merchant Admin, and Merchant Staff roles
- **Product Management**: Full CRUD with image upload, search, filtering, and bulk operations
- **Inventory Tracking**: Real-time stock management with low stock alerts
- **Sales Management**: Manual sales recording with receipts and transaction history
- **Analytics Dashboards**: Company-wide and merchant-specific analytics with charts
- **Email Notifications**: Automated low stock alerts, daily summaries, and weekly reports via Resend
- **Audit Logging**: Complete audit trail for all sales and inventory changes
- **Data Export**: CSV export for products, sales, and inventory
- **Responsive Design**: Modern UI built with shadcn/ui, fully mobile-responsive

## 📋 Prerequisites

- Node.js 18+ and npm/yarn
- PostgreSQL database (Neon recommended)
- Resend API key (for email notifications)
- Cloudinary account (for image storage)

## 🛠️ Setup Instructions

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd gebeya
```

### 2. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Edit .env and fill in your configuration:
# - DATABASE_URL (Neon PostgreSQL)
# - JWT_SECRET (generate with: openssl rand -base64 32)
# - RESEND_API_KEY
# - CLOUDINARY credentials
# - FRONTEND_URL

# Generate Prisma client
npx prisma generate

# Run database migrations
npx prisma migrate dev

# Seed the database (optional - creates sample data)
npm run seed

# Start development server
npm run dev
```

Backend will run on `http://localhost:5000`

### 3. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Copy environment variables
cp .env.local.example .env.local

# Edit .env.local and set:
# - NEXT_PUBLIC_API_URL (backend URL)
# - NEXT_PUBLIC_APP_URL (frontend URL)

# Start development server
npm run dev
```

Frontend will run on `http://localhost:3000`

## 🔐 Default Login Credentials

After seeding the database, you can login with:

**Platform Owner:**
- Email: `admin@gebeya.com`
- Password: `admin123` (check seed output or welcome email)

**Merchant Admin:**
- Email: `merchant@example.com`
- Password: `merchant123` (check seed output or welcome email)

⚠️ **Important**: Change these passwords immediately after first login!

## 📁 Project Structure

```
gebeya/
├── backend/              # Express.js API server
│   ├── src/
│   │   ├── controllers/ # Request handlers
│   │   ├── services/     # Business logic
│   │   ├── middleware/   # Auth, validation, error handling
│   │   ├── routes/       # API routes
│   │   └── app.ts        # Express app setup
│   └── prisma/           # Database schema & migrations
│
├── frontend/             # Next.js frontend
│   ├── src/
│   │   ├── app/          # Next.js pages (App Router)
│   │   ├── components/   # React components
│   │   └── lib/          # Utilities (API client, auth)
│   └── public/           # Static assets
│
└── README.md             # This file
```

## 🔧 Environment Variables

See `.env.example` files for detailed configuration:

- **Backend**: `backend/.env.example`
- **Frontend**: `frontend/.env.local.example`

### Required Backend Variables

- `DATABASE_URL` - Neon PostgreSQL connection string
- `JWT_SECRET` - Secret key for JWT tokens
- `FRONTEND_URL` - Frontend URL for CORS
- `RESEND_API_KEY` - Resend API key for emails
- `CLOUDINARY_*` - Cloudinary credentials for image uploads

### Required Frontend Variables

- `NEXT_PUBLIC_API_URL` - Backend API URL
- `NEXT_PUBLIC_APP_URL` - Frontend application URL

## 🚢 Deployment

### Backend (Railway)

1. Create a Railway account and project
2. Connect your GitHub repository
3. Add environment variables in Railway dashboard
4. Deploy - Railway will auto-detect Node.js

### Frontend (Vercel)

1. Create a Vercel account
2. Import your GitHub repository
3. Set environment variables in Vercel dashboard
4. Deploy - Vercel will auto-detect Next.js

### Database (Neon)

1. Create a Neon account and project
2. Get your connection string
3. Add to backend `.env` as `DATABASE_URL`
4. Run migrations: `npx prisma migrate deploy`

## 📚 API Documentation

### Authentication

- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `GET /api/auth/me` - Get current user

### Products

- `GET /api/products` - List products (with search/filter)
- `POST /api/products` - Create product
- `GET /api/products/:id` - Get product details
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product
- `GET /api/products/low-stock` - Get low stock products

### Inventory

- `GET /api/inventory/summary` - Get inventory summary
- `GET /api/inventory/transactions` - Get stock transaction history
- `POST /api/inventory/transactions` - Create stock adjustment

### Sales

- `GET /api/sales` - List sales (with search)
- `POST /api/sales` - Create sale
- `GET /api/sales/:id` - Get sale details
- `GET /api/sales/analytics` - Get sales analytics

### Merchants (Platform Owner only)

- `GET /api/merchants` - List all merchants
- `GET /api/merchants/:id` - Get merchant details
- `GET /api/merchants/analytics` - Platform-wide analytics

## 🧪 Testing

```bash
# Backend tests (if configured)
cd backend
npm test

# Frontend tests (if configured)
cd frontend
npm test
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

This project is private and proprietary.

## 🆘 Support

For issues and questions, please contact the development team.

## 🎯 Roadmap

- [ ] Advanced filtering and search
- [ ] PDF report generation
- [ ] Mobile app (React Native)
- [ ] Real-time notifications (WebSocket)
- [ ] Multi-language support
- [ ] Advanced analytics with ML insights

---

Built with ❤️ using Next.js, Express.js, PostgreSQL, and modern web technologies.
