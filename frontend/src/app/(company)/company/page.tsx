'use client';

import { useQuery } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Badge } from '@/components/ui/badge';
import { Users, ShoppingCart, TrendingUp, Building2 } from 'lucide-react';
import { formatCurrency, formatCurrencySmart } from '@/lib/currency';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default function CompanyDashboard() {
  const { data: merchantsData, isLoading: merchantsLoading } = useQuery({
    queryKey: ['merchants'],
    queryFn: async () => {
      const res = await apiClient.get('/merchants');
      return res.data.data;
    },
  });

  const { data: pendingMerchants } = useQuery({
    queryKey: ['pending-merchants'],
    queryFn: async () => {
      const res = await apiClient.get('/merchants/pending');
      return res.data.data || [];
    },
  });

  const { data: platformAnalytics, isLoading: analyticsLoading } = useQuery({
    queryKey: ['platform-analytics'],
    queryFn: async () => {
      const res = await apiClient.get('/merchants/analytics');
      return res.data.data;
    },
  });

  const merchants = merchantsData || [];

  if (merchantsLoading || analyticsLoading) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Company Dashboard</h1>
          <p className="text-muted-foreground">Overview of all merchants and platform performance</p>
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
      <div>
        <h1 className="text-3xl font-bold">Company Dashboard</h1>
        <p className="text-muted-foreground">Overview of all merchants and platform performance</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-5">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Merchants</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {platformAnalytics?.totalMerchants || merchants.length || 0}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Merchants</CardTitle>
            <Building2 className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {platformAnalytics?.activeMerchants || merchants.filter((m: any) => m.isActive).length || 0}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Sales</CardTitle>
            <ShoppingCart className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{platformAnalytics?.totalSales || 0}</div>
            <p className="text-xs text-muted-foreground">Aggregate across all merchants</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Merchant Revenue</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {formatCurrencySmart(platformAnalytics?.totalRevenue || 0)}
            </div>
            <p className="text-xs text-muted-foreground">Aggregate of all merchant sales</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Platform Revenue</CardTitle>
            <TrendingUp className="h-4 w-4 text-green-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">
              {formatCurrencySmart(platformAnalytics?.platformRevenue || 0)}
            </div>
            <p className="text-xs text-muted-foreground">From transaction fees</p>
          </CardContent>
        </Card>
      </div>

      {pendingMerchants && pendingMerchants.length > 0 && (
        <Card className="border-orange-200 bg-orange-50">
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="flex items-center gap-2">
                  Pending Merchant Approvals
                </CardTitle>
                <CardDescription>
                  {pendingMerchants.length} merchant registration(s) awaiting approval
                </CardDescription>
              </div>
              <Link href="/company/merchants?status=pending">
                <Button variant="outline" size="sm">
                  View All
                </Button>
              </Link>
            </div>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {pendingMerchants.slice(0, 3).map((merchant: any) => (
                <div
                  key={merchant.id}
                  className="flex items-center justify-between p-3 border border-orange-200 rounded-lg bg-white"
                >
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <span className="font-medium">{merchant.name}</span>
                      <Badge variant="outline" className="border-orange-300 text-orange-700 bg-orange-50">
                        Pending
                      </Badge>
                    </div>
                    <p className="text-sm text-muted-foreground mt-1">{merchant.email}</p>
                  </div>
                </div>
              ))}
              {pendingMerchants.length > 3 && (
                <Link href="/company/merchants?status=pending">
                  <Button variant="link" className="w-full mt-2">
                    View all {pendingMerchants.length} pending merchants
                  </Button>
                </Link>
              )}
            </div>
          </CardContent>
        </Card>
      )}

      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Recent Merchants</CardTitle>
            <CardDescription>Latest registered merchants</CardDescription>
          </CardHeader>
          <CardContent>
            {merchants && merchants.length > 0 ? (
              <div className="space-y-2">
                {merchants.slice(0, 5).map((merchant: any) => (
                  <div
                    key={merchant.id}
                    className="flex items-center justify-between p-2 border rounded"
                  >
                    <div>
                      <span className="font-medium">{merchant.name}</span>
                      <p className="text-xs text-muted-foreground">{merchant.email}</p>
                    </div>
                    <Badge variant={merchant.isActive ? 'default' : 'secondary'}>
                      {merchant.isActive ? 'Active' : 'Inactive'}
                    </Badge>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-muted-foreground">No merchants yet</p>
            )}
          </CardContent>
        </Card>

        {platformAnalytics?.topMerchants && platformAnalytics.topMerchants.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle>Top Performing Merchants</CardTitle>
              <CardDescription>By total revenue</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                {platformAnalytics.topMerchants.map((item: any, index: number) => (
                  <div
                    key={item.merchant?.id}
                    className="flex items-center justify-between p-2 border rounded"
                  >
                    <div>
                      <span className="font-medium">
                        #{index + 1} {item.merchant?.name}
                      </span>
                      <p className="text-xs text-muted-foreground">
                        {item.totalSales} sales
                      </p>
                    </div>
                    <div className="text-right">
                      <div className="font-medium">
                        {formatCurrencySmart(item.totalRevenue)}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
}

