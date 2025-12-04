# 🚀 Deployment Checklist - Gebeya

## Your Deployment Details

- **GitHub Repo**: https://github.com/knatnaela/gebeya
- **Database**: Neon (already configured)
- **Backend**: Render
- **Frontend**: Vercel

## Environment Variables

### Backend (Render) - Copy these exactly:

```
DATABASE_URL=postgresql://neondb_owner:npg_39cEasLCAebV@ep-spring-rain-a433tb8n-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
JWT_SECRET=p4kmYwetlARWc8kzEf/DpkgP7l0+SzoUDUcOesy67xw=
FRONTEND_URL=https://your-app.vercel.app
NODE_ENV=production
RESEND_API_KEY=re_Hq9iypJV_7DPtPQtfsanaXsF3bT3WWPNT
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
ENABLE_SCHEDULERS=true
```

**Note**: Replace `https://your-app.vercel.app` with your actual Vercel URL after frontend deployment.

### Frontend (Vercel) - Copy these exactly:

```
NEXT_PUBLIC_API_URL=https://your-backend.onrender.com/api
NEXT_PUBLIC_APP_URL=https://your-app.vercel.app
```

**Note**: Replace URLs with actual URLs after deployment.

## Step-by-Step Deployment

### Step 1: Deploy Backend to Render

1. Go to [render.com](https://render.com) and login
2. Click **"New +"** → **"Web Service"**
3. Click **"Connect account"** if not connected, then select your GitHub account
4. Find and select repository: **knatnaela/gebeya**
5. Configure service:
   - **Name**: `gebeya-backend`
   - **Region**: Choose closest to you (default is fine)
   - **Branch**: `main`
   - **Root Directory**: `backend`
   - **Runtime**: `Node`
   - **Build Command**: `npm install && npm run build && npx prisma generate`
   - **Start Command**: `npm start`
   - **Plan**: `Free`
6. Click **"Advanced"** → Scroll to **"Environment Variables"**
7. Add each variable one by one (copy from above):
   - Click **"Add Environment Variable"**
   - Add all variables listed above
   - **Important**: Leave `FRONTEND_URL` as `https://your-app.vercel.app` for now, we'll update it later
8. Click **"Create Web Service"**
9. Wait for deployment (5-10 minutes)
10. Copy your backend URL (e.g., `https://gebeya-backend.onrender.com`)

**After Backend Deploys:**
1. Click on your service → **"Shell"** tab
2. Run: `npx prisma migrate deploy`
3. (Optional) Run: `npm run prisma:seed` to seed sample data

### Step 2: Deploy Frontend to Vercel

1. Go to [vercel.com](https://vercel.com) and login
2. Click **"Add New"** → **"Project"**
3. Import repository: **knatnaela/gebeya**
4. Configure project:
   - **Project Name**: `gebeya-frontend` (or any name)
   - **Root Directory**: `frontend` (click "Edit" and change from root to `frontend`)
   - **Framework Preset**: Next.js (auto-detected)
   - **Build Command**: `npm run build` (default)
   - **Output Directory**: `.next` (default)
   - **Install Command**: `npm install` (default)
5. Click **"Environment Variables"**
6. Add variables:
   - `NEXT_PUBLIC_API_URL` = `https://your-backend.onrender.com/api` (replace with your actual Render URL)
   - `NEXT_PUBLIC_APP_URL` = Leave blank for now (will auto-fill after deployment)
7. Click **"Deploy"**
8. Wait for deployment (2-5 minutes)
9. Copy your frontend URL (e.g., `https://gebeya-frontend.vercel.app`)

### Step 3: Update Environment Variables

**Update Backend (Render):**
1. Go to Render dashboard → Your backend service
2. Click **"Environment"** tab
3. Edit `FRONTEND_URL` → Change to your actual Vercel URL
4. Save (this will trigger a redeploy)

**Update Frontend (Vercel):**
1. Go to Vercel dashboard → Your project
2. Go to **"Settings"** → **"Environment Variables"**
3. Edit `NEXT_PUBLIC_APP_URL` → Change to your actual Vercel URL
4. Go to **"Deployments"** → Click **"..."** on latest deployment → **"Redeploy"**

## Post-Deployment Testing

1. ✅ Visit your frontend URL
2. ✅ Check backend health: `https://your-backend.onrender.com/health`
3. ✅ Try logging in (if you seeded the database)
4. ✅ Test API connection (check browser console for errors)

## Important Notes

⚠️ **Cloudinary**: Image uploads won't work until you configure Cloudinary. You can add it later by:
1. Sign up at [cloudinary.com](https://cloudinary.com)
2. Get your credentials
3. Add them to Render environment variables

⚠️ **Render Free Tier**: Backend spins down after 15 min inactivity but wakes up automatically on request (30-60 sec delay).

## Troubleshooting

**Backend not starting:**
- Check Render logs
- Verify all environment variables are set
- Check database connection string

**Frontend can't connect to backend:**
- Verify `NEXT_PUBLIC_API_URL` includes `/api` at the end
- Check CORS settings (FRONTEND_URL in backend)
- Check browser console for errors

**Database connection fails:**
- Verify DATABASE_URL is correct
- Check Neon dashboard to ensure database is running

---

**Ready to deploy? Follow the steps above! 🚀**

