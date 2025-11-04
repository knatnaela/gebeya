'use client';

import { useQuery } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from 'recharts';
import { Users, ShoppingCart, TrendingUp, Building2 } from 'lucide-react';
import { formatCurrency, formatCurrencySmart } from '@/lib/currency';

const COLORS = ['#667eea', '#764ba2', '#f093fb', '#4facfe', '#43e97b'];

export default function CompanyAnalyticsPage() {
  const { data: analytics, isLoading } = useQuery({
    queryKey: ['platform-analytics'],
    queryFn: async () => {
      const res = await apiClient.get('/merchants/analytics');
      return res.data.data;
    },
  });

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Platform Analytics</h1>
          <p className="text-muted-foreground">System-wide performance metrics</p>
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

  const topMerchantsData =
    analytics?.topMerchants?.map((item: any) => ({
      name: item.merchant?.name || 'Unknown',
      revenue: Number(item.totalRevenue || 0),
      sales: item.totalSales || 0,
    })) || [];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Platform Analytics</h1>
        <p className="text-muted-foreground">System-wide performance metrics and insights</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-5">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Merchants</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{analytics?.totalMerchants || 0}</div>
            <p className="text-xs text-muted-foreground mt-1">
              {analytics?.activeMerchants || 0} active
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Merchants</CardTitle>
            <Building2 className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{analytics?.activeMerchants || 0}</div>
            <p className="text-xs text-muted-foreground mt-1">Currently active</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Sales</CardTitle>
            <ShoppingCart className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{analytics?.totalSales || 0}</div>
            <p className="text-xs text-muted-foreground mt-1">Across all merchants</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Merchant Revenue</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {formatCurrencySmart(analytics?.totalRevenue || 0)}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Aggregate of all merchant sales</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Platform Revenue</CardTitle>
            <TrendingUp className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">
              {formatCurrencySmart(analytics?.platformRevenue || 0)}
            </div>
            <p className="text-xs text-muted-foreground mt-1">From transaction fees</p>
          </CardContent>
        </Card>
      </div>

      {topMerchantsData.length > 0 && (
        <div className="grid gap-4 md:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle>Top Merchants by Revenue</CardTitle>
              <CardDescription>Best performing merchants</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={topMerchantsData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" angle={-45} textAnchor="end" height={100} />
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
                    formatter={(value: any) => formatCurrency(value)}
                  />
                  <Legend />
                  <Bar dataKey="revenue" fill="#667eea" name="Revenue (ETB)" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Top Merchants by Sales Count</CardTitle>
              <CardDescription>Most active merchants</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={topMerchantsData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" angle={-45} textAnchor="end" height={100} />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="sales" fill="#10b981" name="Sales Count" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </div>
      )}

      {analytics?.topMerchants && analytics.topMerchants.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Top Performing Merchants</CardTitle>
            <CardDescription>Detailed breakdown by revenue</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {analytics.topMerchants.map((item: any, index: number) => (
                <div
                  key={item.merchant?.id}
                  className="flex items-center justify-between p-4 border rounded-lg hover:shadow-sm transition-shadow"
                >
                  <div className="flex items-center gap-4">
                    <div className="h-10 w-10 rounded-full bg-gradient-to-br from-purple-500 to-blue-500 flex items-center justify-center text-white font-bold">
                      #{index + 1}
                    </div>
                    <div>
                      <p className="font-medium">{item.merchant?.name || 'Unknown'}</p>
                      <p className="text-sm text-muted-foreground">
                        {item.totalSales} sales
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-2xl font-bold">
                      {formatCurrencySmart(item.totalRevenue || 0)}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

