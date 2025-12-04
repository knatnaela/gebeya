# 🚀 Deployment Guide

This guide will help you deploy Gebeya to production using free hosting services.

## Prerequisites

Before deploying, make sure you have:

1. ✅ GitHub account (repository pushed to GitHub)
2. ✅ Neon account (for PostgreSQL database)
3. ✅ Resend account (for email notifications)
4. ✅ Cloudinary account (for image storage)
5. ✅ Render account (for backend)
6. ✅ Vercel account (for frontend)

## Step-by-Step Deployment

### 1. Database Setup (Neon)

1. Go to [neon.tech](https://neon.tech) and create an account
2. Click "Create Project"
3. Choose a name (e.g., `gebeya-db`)
4. Select a region closest to your users
5. Click "Create Project"
6. Copy the **Connection String** (you'll need this for backend)
   - It looks like: `postgresql://user:password@host.neon.tech/dbname?sslmode=require`

### 2. Backend Deployment (Render)

1. Go to [render.com](https://render.com) and sign up/login
2. Click "New +" → "Web Service"
3. Connect your GitHub account and select your repository
4. Configure the service:
   - **Name**: `gebeya-backend`
   - **Region**: Choose closest to your users
   - **Branch**: `main` (or your default branch)
   - **Root Directory**: `backend`
   - **Runtime**: `Node`
   - **Build Command**: `npm install && npm run build && npx prisma generate`
   - **Start Command**: `npm start`
   - **Plan**: `Free`
5. Click "Advanced" and add environment variables:
   ```
   DATABASE_URL=<your-neon-connection-string>
   JWT_SECRET=<generate-with-openssl-rand-base64-32>
   FRONTEND_URL=https://your-app.vercel.app
   NODE_ENV=production
   RESEND_API_KEY=<your-resend-api-key>
   CLOUDINARY_CLOUD_NAME=<your-cloudinary-cloud-name>
   CLOUDINARY_API_KEY=<your-cloudinary-api-key>
   CLOUDINARY_API_SECRET=<your-cloudinary-api-secret>
   ENABLE_SCHEDULERS=true
   ```
   **Note**: `PORT` is automatically set by Render, don't add it manually.
6. Click "Create Web Service"
7. Wait for deployment to complete (takes 5-10 minutes)
8. Copy your backend URL (e.g., `https://gebeya-backend.onrender.com`)

**Run Database Migrations:**
After deployment, you need to run migrations:
1. In Render dashboard, click on your service
2. Go to "Shell" tab
3. Run: `npx prisma migrate deploy`
4. (Optional) Seed database: `npm run prisma:seed`

### 3. Frontend Deployment (Vercel)

1. Go to [vercel.com](https://vercel.com) and sign up/login
2. Click "Add New" → "Project"
3. Import your GitHub repository
4. Configure the project:
   - **Project Name**: `gebeya-frontend` (or any name)
   - **Root Directory**: `frontend`
   - **Framework Preset**: Next.js (auto-detected)
   - **Build Command**: `npm run build` (default)
   - **Output Directory**: `.next` (default)
   - **Install Command**: `npm install` (default)
5. Add environment variables:
   ```
   NEXT_PUBLIC_API_URL=https://gebeya-backend.onrender.com/api
   NEXT_PUBLIC_APP_URL=https://your-app.vercel.app
   ```
   **Note**: Replace `your-app.vercel.app` with your actual Vercel URL after first deployment
6. Click "Deploy"
7. Wait for deployment (takes 2-5 minutes)
8. Copy your frontend URL (e.g., `https://gebeya-frontend.vercel.app`)

### 4. Update Backend CORS

After getting your Vercel frontend URL:
1. Go back to Render dashboard
2. Edit your backend service
3. Update `FRONTEND_URL` environment variable to your Vercel URL
4. Save changes (this will trigger a redeploy)

### 5. Update Frontend API URL (if needed)

If you need to update the API URL:
1. Go to Vercel dashboard
2. Select your project
3. Go to "Settings" → "Environment Variables"
4. Update `NEXT_PUBLIC_API_URL` if needed
5. Redeploy

## Environment Variables Reference

### Backend (Render)

| Variable | Description | Required |
|----------|------------|----------|
| `DATABASE_URL` | Neon PostgreSQL connection string | ✅ Yes |
| `JWT_SECRET` | Secret for JWT tokens (generate: `openssl rand -base64 32`) | ✅ Yes |
| `FRONTEND_URL` | Your Vercel frontend URL | ✅ Yes |
| `NODE_ENV` | Set to `production` | ✅ Yes |
| `RESEND_API_KEY` | Resend API key for emails | ✅ Yes |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name | ✅ Yes |
| `CLOUDINARY_API_KEY` | Cloudinary API key | ✅ Yes |
| `CLOUDINARY_API_SECRET` | Cloudinary API secret | ✅ Yes |
| `ENABLE_SCHEDULERS` | Set to `true` to enable cron jobs | ⚠️ Recommended |
| `PORT` | Automatically set by Render | ❌ No |
| `UPSTASH_REDIS_REST_URL` | Optional Redis URL | ❌ No |
| `UPSTASH_REDIS_REST_TOKEN` | Optional Redis token | ❌ No |

### Frontend (Vercel)

| Variable | Description | Required |
|----------|------------|----------|
| `NEXT_PUBLIC_API_URL` | Your Render backend URL + `/api` | ✅ Yes |
| `NEXT_PUBLIC_APP_URL` | Your Vercel frontend URL | ✅ Yes |

## Post-Deployment Checklist

- [ ] Backend deployed and accessible at `https://your-backend.onrender.com/health`
- [ ] Database migrations run successfully
- [ ] Frontend deployed and accessible
- [ ] Frontend can connect to backend (check browser console)
- [ ] CORS configured correctly
- [ ] Environment variables set correctly
- [ ] Test login functionality
- [ ] Test image upload (Cloudinary)
- [ ] Test email sending (Resend)

## Troubleshooting

### Backend Issues

**Build fails:**
- Check Render logs for errors
- Ensure `package.json` has correct scripts
- Verify Node.js version compatibility

**Database connection fails:**
- Verify `DATABASE_URL` is correct
- Check Neon database is running
- Ensure connection string includes `?sslmode=require`

**CORS errors:**
- Verify `FRONTEND_URL` matches your Vercel URL exactly
- Check backend logs for CORS errors

### Frontend Issues

**API calls fail:**
- Verify `NEXT_PUBLIC_API_URL` is correct (include `/api` at the end)
- Check browser console for errors
- Verify backend is running and accessible

**Build fails:**
- Check Vercel build logs
- Ensure all dependencies are in `package.json`
- Verify Node.js version compatibility

## Free Tier Limits

### Render (Backend)
- ✅ 750 hours/month (enough for continuous operation)
- ⚠️ Spins down after 15 min inactivity (auto-wakes on request)
- ✅ Free forever

### Vercel (Frontend)
- ✅ 100 GB bandwidth/month
- ✅ Unlimited projects
- ✅ Free forever

### Neon (Database)
- ✅ 0.5 GB storage
- ✅ Free forever

## Support

If you encounter issues:
1. Check service logs (Render/Vercel dashboards)
2. Verify all environment variables are set
3. Check database connection
4. Review this guide again

---

**Happy Deploying! 🎉**

