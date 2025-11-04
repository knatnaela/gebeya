'use client';

import { useQuery } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { TrendingUp, Package, DollarSign } from 'lucide-react';
import { formatCurrency, formatCurrencySmart } from '@/lib/currency';

export default function AnalyticsPage() {
  const { data: salesAnalytics, isLoading } = useQuery({
    queryKey: ['sales-analytics'],
    queryFn: async () => {
      const res = await apiClient.get('/sales/analytics');
      return res.data.data;
    },
  });

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Analytics</h1>
          <p className="text-muted-foreground">Performance insights and trends</p>
        </div>
        <div className="grid gap-4 md:grid-cols-3">
          {[...Array(3)].map((_, i) => (
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

  const dailySalesData = salesAnalytics?.dailySales || [];
  const topProducts = salesAnalytics?.topProducts || [];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Analytics</h1>
        <p className="text-muted-foreground">Performance insights and trends</p>
      </div>

      <div className="grid gap-4 md:grid-cols-3 lg:grid-cols-5">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Sales</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{salesAnalytics?.totalSales || 0}</div>
            <p className="text-xs text-muted-foreground">All time sales count</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {formatCurrencySmart(salesAnalytics?.totalRevenue || 0)}
            </div>
            <p className="text-xs text-muted-foreground">All time revenue</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Net Income</CardTitle>
            <TrendingUp className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">
              {formatCurrencySmart(salesAnalytics?.totalNetIncome || 0)}
            </div>
            <p className="text-xs text-muted-foreground">Revenue - COGS</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Profit Margin</CardTitle>
            <TrendingUp className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">
              {Number(salesAnalytics?.totalProfitMargin || 0).toFixed(2)}%
            </div>
            <p className="text-xs text-muted-foreground">Profit / Revenue</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Average Sale</CardTitle>
            <Package className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {formatCurrency(salesAnalytics?.averageSaleAmount || 0)}
            </div>
            <p className="text-xs text-muted-foreground">Per transaction</p>
          </CardContent>
        </Card>
      </div>

      {dailySalesData.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Sales Trends</CardTitle>
            <CardDescription>Daily sales over the last 30 days</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={dailySalesData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis 
                  width={80}
                  tickFormatter={(value) => {
                    if (value >= 1000) {
                      return `ETB ${(value / 1000).toFixed(1)}k`;
                    }
                    return `ETB ${value}`;
                  }}
                />
                <Tooltip 
                  formatter={(value: any, name: string) => {
                    if (name === 'Revenue (ETB)') {
                      return formatCurrency(value);
                    }
                    return value;
                  }}
                />
                <Legend />
                <Line
                  type="monotone"
                  dataKey="count"
                  stroke="#667eea"
                  name="Sales Count"
                  strokeWidth={2}
                />
                <Line
                  type="monotone"
                  dataKey="revenue"
                  stroke="#10b981"
                  name="Revenue (ETB)"
                  strokeWidth={2}
                />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      )}

      {topProducts.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Top Selling Products</CardTitle>
            <CardDescription>Best performing products by quantity sold</CardDescription>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={topProducts.slice(0, 10)}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" angle={-45} textAnchor="end" height={100} />
                <YAxis 
                  width={80}
                  tickFormatter={(value) => {
                    // Format for revenue (large values)
                    if (value >= 1000) {
                      return `ETB ${(value / 1000).toFixed(1)}k`;
                    }
                    // For quantity (smaller values), show as-is
                    return value.toString();
                  }}
                />
                <Tooltip 
                  formatter={(value: any, name: string) => {
                    if (name === 'Revenue (ETB)') {
                      return formatCurrency(value);
                    }
                    return value;
                  }}
                />
                <Legend />
                <Bar dataKey="quantity" fill="#667eea" name="Quantity Sold" />
                <Bar dataKey="revenue" fill="#10b981" name="Revenue (ETB)" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      )}

      {topProducts.length === 0 && dailySalesData.length === 0 && (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-muted-foreground">No analytics data available yet</p>
            <p className="text-sm text-muted-foreground mt-2">
              Start recording sales to see analytics
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

