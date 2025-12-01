'use client';

import { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useSearchParams, useRouter } from 'next/navigation';
import apiClient from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Badge } from '@/components/ui/badge';
import { Package, ShoppingCart, TrendingUp, TrendingDown, AlertTriangle, Clock, XCircle, Calendar } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { formatCurrency, formatCurrencySmart } from '@/lib/currency';
import { format } from 'date-fns';
import { SubscriptionErrorMessage } from '@/components/subscription/subscription-error-message';
import { DateFilter } from '@/components/filters/date-filter';

export default function MerchantDashboard() {
  const searchParams = useSearchParams();
  const router = useRouter();
  
  // Initialize from URL query params
  const [startDate, setStartDate] = useState<string | undefined>(
    searchParams.get('startDate') || undefined
  );
  const [endDate, setEndDate] = useState<string | undefined>(
    searchParams.get('endDate') || undefined
  );
  
  // Sync state when URL params change (e.g., browser back/forward)
  useEffect(() => {
    const urlStartDate = searchParams.get('startDate') || undefined;
    const urlEndDate = searchParams.get('endDate') || undefined;
    
    if (urlStartDate !== startDate || urlEndDate !== endDate) {
      setStartDate(urlStartDate);
      setEndDate(urlEndDate);
    }
  }, [searchParams]); // Only depend on searchParams to avoid loops
  
  // Update URL when dates change
  useEffect(() => {
    const params = new URLSearchParams(searchParams.toString());
    
    if (startDate) {
      params.set('startDate', startDate);
    } else {
      params.delete('startDate');
    }
    
    if (endDate) {
      params.set('endDate', endDate);
    } else {
      params.delete('endDate');
    }
    
    // Only update URL if params actually changed
    const newParamsString = params.toString();
    const currentParamsString = searchParams.toString();
    
    if (newParamsString !== currentParamsString) {
      router.replace(`/merchant?${newParamsString}`, { scroll: false });
    }
  }, [startDate, endDate, router, searchParams]);

  const { data: inventorySummary, isLoading: inventoryLoading, error: inventoryError } = useQuery({
    queryKey: ['inventory-summary'],
    queryFn: async () => {
      const res = await apiClient.get('/inventory/summary');
      return res.data.data;
    },
    retry: false, // Don't retry on subscription expired errors
  });

  const { data: salesAnalytics, isLoading: salesLoading, error: salesError } = useQuery({
    queryKey: ['sales-analytics', startDate, endDate],
    queryFn: async () => {
      const params: any = {};
      if (startDate) {
        params.startDate = startDate;
      }
      if (endDate) {
        params.endDate = endDate;
      }
      const res = await apiClient.get('/sales/analytics', { params });
      return res.data.data;
    },
    retry: false, // Don't retry on subscription expired errors
  });

  const { data: subscriptionStatus, isLoading: subscriptionLoading } = useQuery({
    queryKey: ['subscription-status'],
    queryFn: async () => {
      const res = await apiClient.get('/subscriptions/status');
      return res.data.data;
    },
  });

  if (inventoryLoading || salesLoading || subscriptionLoading) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Merchant Dashboard</h1>
          <p className="text-muted-foreground">Overview of your business performance</p>
        </div>
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {[...Array(4)].map((_, i) => (
            <Card key={i}>
              <CardHeader>
                <Skeleton className="h-4 w-24" />
                <Skeleton className="h-8 w-32 mt-2" />
              </CardHeader>
            </Card>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold">Merchant Dashboard</h1>
          <p className="text-muted-foreground">Overview of your business performance</p>
        </div>
        <div className="flex gap-2">
          <Link href="/merchant/sales">
            <Button>
              <ShoppingCart className="mr-2 h-4 w-4" />
              New Sale
            </Button>
          </Link>
          <Link href="/merchant/products">
            <Button variant="outline">
              <Package className="mr-2 h-4 w-4" />
              Add Product
            </Button>
          </Link>
        </div>
      </div>

      {/* Trial Status Banner */}
      {subscriptionStatus && (
        <>
          {!subscriptionStatus.isActive && (
            <Card className="border-red-200 bg-red-50">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-red-800">
                  <XCircle className="h-5 w-5" />
                  Trial Subscription Expired
                </CardTitle>
                <CardDescription className="text-red-700">
                  Your trial subscription has expired. Please contact the platform owner to extend your trial or activate your subscription.
                </CardDescription>
              </CardHeader>
              {subscriptionStatus.trialEndDate && (
                <CardContent>
                  <p className="text-sm text-red-700">
                    Trial ended on: {format(new Date(subscriptionStatus.trialEndDate), 'MMM d, yyyy')}
                  </p>
                </CardContent>
              )}
            </Card>
          )}

          {subscriptionStatus.isActive && subscriptionStatus.status === 'ACTIVE_TRIAL' && (
            <>
              {subscriptionStatus.daysRemaining !== undefined && subscriptionStatus.daysRemaining <= 7 && (
                <Card className={`border-orange-200 ${subscriptionStatus.daysRemaining <= 3 ? 'bg-red-50' : 'bg-orange-50'}`}>
                  <CardHeader>
                    <CardTitle className={`flex items-center gap-2 ${subscriptionStatus.daysRemaining <= 3 ? 'text-red-800' : 'text-orange-800'}`}>
                      <AlertTriangle className="h-5 w-5" />
                      Trial Expiring Soon
                    </CardTitle>
                    <CardDescription className={subscriptionStatus.daysRemaining <= 3 ? 'text-red-700' : 'text-orange-700'}>
                      Your trial subscription expires in {subscriptionStatus.daysRemaining} day{subscriptionStatus.daysRemaining !== 1 ? 's' : ''}. 
                      Please contact the platform owner to extend your trial.
                    </CardDescription>
                  </CardHeader>
                  {subscriptionStatus.trialEndDate && (
                    <CardContent>
                      <p className={`text-sm ${subscriptionStatus.daysRemaining <= 3 ? 'text-red-700' : 'text-orange-700'}`}>
                        Trial ends on: {format(new Date(subscriptionStatus.trialEndDate), 'MMM d, yyyy')}
                      </p>
                    </CardContent>
                  )}
                </Card>
              )}

              <Card className="border-blue-200 bg-blue-50">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-blue-800">
                    <Clock className="h-5 w-5" />
                    Trial Subscription Active
                  </CardTitle>
                  <CardDescription className="text-blue-700">
                    You are currently on a trial subscription
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    {subscriptionStatus.daysRemaining !== undefined && (
                      <div className="flex items-center justify-between">
                        <span className="text-sm text-blue-700">Days Remaining:</span>
                        <span className="text-lg font-bold text-blue-800">{subscriptionStatus.daysRemaining} days</span>
                      </div>
                    )}
                    {subscriptionStatus.trialEndDate && (
                      <div className="flex items-center justify-between">
                        <span className="text-sm text-blue-700">Trial End Date:</span>
                        <span className="text-sm font-medium text-blue-800">
                          {format(new Date(subscriptionStatus.trialEndDate), 'MMM d, yyyy')}
                        </span>
                      </div>
                    )}
                  </div>
                </CardContent>
              </Card>
            </>
          )}
        </>
      )}

      {(inventoryError || salesError) ? (
        <SubscriptionErrorMessage 
          error={inventoryError || salesError} 
          title="Cannot Load Dashboard Data" 
        />
      ) : (
        <>
          {/* Date Filter */}
          <Card>
            <CardHeader>
              <CardTitle>Date Range</CardTitle>
              <CardDescription>Filter analytics by date range</CardDescription>
            </CardHeader>
            <CardContent>
              <DateFilter
                onDateChange={(start, end) => {
                  setStartDate(start);
                  setEndDate(end);
                }}
                defaultPreset="all-time"
                value={{ startDate, endDate }}
              />
            </CardContent>
          </Card>

          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <Card className="hover:shadow-md transition-shadow border-purple-100">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
                <div className="p-2 rounded-full bg-purple-100">
                  <TrendingUp className="h-4 w-4 text-purple-600" />
                </div>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {formatCurrencySmart(salesAnalytics?.totalRevenue || 0)}
                </div>
                <p className="text-xs text-muted-foreground mt-1">
                  {startDate && endDate ? 'Selected period' : 'All time'} revenue
                </p>
              </CardContent>
            </Card>

        <Card className="hover:shadow-md transition-shadow border-emerald-100">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Gross Profit</CardTitle>
            <div className="p-2 rounded-full bg-emerald-100">
              <TrendingUp className="h-4 w-4 text-emerald-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-emerald-600">
              {formatCurrencySmart(salesAnalytics?.grossProfit || 0)}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Revenue - COGS</p>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow border-red-100">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Expenses</CardTitle>
            <div className="p-2 rounded-full bg-red-100">
              <TrendingDown className="h-4 w-4 text-red-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">
              {formatCurrencySmart(salesAnalytics?.totalExpenses || 0)}
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              {startDate && endDate ? 'Selected period' : 'All'} expenses
            </p>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow border-blue-100">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Net Profit</CardTitle>
            <div className="p-2 rounded-full bg-blue-100">
              <TrendingUp className="h-4 w-4 text-blue-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className={`text-2xl font-bold ${(salesAnalytics?.netProfit || 0) >= 0 ? 'text-blue-600' : 'text-red-600'}`}>
              {formatCurrencySmart(salesAnalytics?.netProfit || 0)}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Gross Profit - Expenses</p>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow border-cyan-100">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Profit Margin</CardTitle>
            <div className="p-2 rounded-full bg-cyan-100">
              <TrendingUp className="h-4 w-4 text-cyan-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className={`text-2xl font-bold ${Number(salesAnalytics?.profitMargin || 0) >= 0 ? 'text-cyan-600' : 'text-red-600'}`}>
              {Number(salesAnalytics?.profitMargin || 0).toFixed(2)}%
            </div>
            <p className="text-xs text-muted-foreground mt-1">Net Profit / Revenue</p>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow border-green-100">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Sales</CardTitle>
            <div className="p-2 rounded-full bg-green-100">
              <ShoppingCart className="h-4 w-4 text-green-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{salesAnalytics?.totalSales || 0}</div>
            <p className="text-xs text-muted-foreground mt-1">
              {startDate && endDate ? 'Selected period' : 'All time'} sales
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-2">
        <Card className="hover:shadow-md transition-shadow border-blue-100">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Products</CardTitle>
            <div className="p-2 rounded-full bg-blue-100">
              <Package className="h-4 w-4 text-blue-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{inventorySummary?.totalProducts || 0}</div>
            <p className="text-xs text-muted-foreground mt-1">Active products</p>
          </CardContent>
        </Card>

        <Card className="hover:shadow-md transition-shadow border-orange-100">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Low Stock Alerts</CardTitle>
            <div className="p-2 rounded-full bg-orange-100">
              <AlertTriangle className="h-4 w-4 text-orange-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">
              {inventorySummary?.lowStockCount || 0}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Need restocking</p>
          </CardContent>
        </Card>
      </div>


      {/* Quick Actions */}
      <div className="grid gap-4 md:grid-cols-3">
        <Link href="/merchant/sales">
          <Card className="hover:shadow-md transition-shadow cursor-pointer border-green-100 hover:border-green-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <ShoppingCart className="h-5 w-5 text-green-600" />
                Record Sale
              </CardTitle>
              <CardDescription>Quick sale recording</CardDescription>
            </CardHeader>
          </Card>
        </Link>
        <Link href="/merchant/inventory">
          <Card className="hover:shadow-md transition-shadow cursor-pointer border-blue-100 hover:border-blue-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="h-5 w-5 text-blue-600" />
                Adjust Stock
              </CardTitle>
              <CardDescription>Update inventory levels</CardDescription>
            </CardHeader>
          </Card>
        </Link>
        <Link href="/merchant/analytics">
          <Card className="hover:shadow-md transition-shadow cursor-pointer border-purple-100 hover:border-purple-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="h-5 w-5 text-purple-600" />
                View Analytics
              </CardTitle>
              <CardDescription>Performance insights</CardDescription>
            </CardHeader>
          </Card>
        </Link>
      </div>
        </>
      )}
    </div>
  );
}
