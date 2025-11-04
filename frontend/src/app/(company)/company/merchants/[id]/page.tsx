'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useParams, useRouter } from 'next/navigation';
import apiClient from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Button } from '@/components/ui/button';
import {
  Building2,
  Mail,
  Phone,
  MapPin,
  Package,
  ShoppingCart,
  TrendingUp,
  Users,
  CheckCircle,
  XCircle,
  Clock,
  AlertCircle,
  CheckCircle2,
  CreditCard,
  RotateCcw,
  ExternalLink,
} from 'lucide-react';
import { formatCurrency, formatCurrencySmart } from '@/lib/currency';
import { toast } from 'sonner';
import Link from 'next/link';
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
import { format, subDays } from 'date-fns';

export default function MerchantDetailPage() {
  const params = useParams();
  const router = useRouter();
  const queryClient = useQueryClient();
  const merchantId = params.id as string;

  const { data: merchant, isLoading: merchantLoading } = useQuery({
    queryKey: ['merchant', merchantId],
    queryFn: async () => {
      const res = await apiClient.get(`/merchants/${merchantId}`);
      return res.data.data;
    },
  });

  const { data: analytics, isLoading: analyticsLoading } = useQuery({
    queryKey: ['merchant-analytics', merchantId],
    queryFn: async () => {
      const res = await apiClient.get(`/merchants/${merchantId}/analytics`);
      return res.data.data;
    },
  });

  const { data: subscription, isLoading: subscriptionLoading } = useQuery({
    queryKey: ['merchant-subscription', merchantId],
    queryFn: async () => {
      try {
        const res = await apiClient.get(`/subscriptions/merchant/${merchantId}`);
        return res.data.data;
      } catch (error: any) {
        // If subscription doesn't exist, return null
        if (error.response?.status === 404) {
          return null;
        }
        throw error;
      }
    },
  });

  const approveMutation = useMutation({
    mutationFn: async (merchantId: string) => {
      try {
        const res = await apiClient.post(`/merchants/${merchantId}/approve`);
        return res.data;
      } catch (error: any) {
        const errorMessage = error.response?.data?.error || error.message || 'Failed to approve merchant';
        throw new Error(errorMessage);
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['merchant', merchantId] });
      queryClient.invalidateQueries({ queryKey: ['pending-merchants'] });
      queryClient.invalidateQueries({ queryKey: ['merchants'] });
      queryClient.invalidateQueries({ queryKey: ['platform-analytics'] });
      queryClient.invalidateQueries({ queryKey: ['subscriptions'] });
      toast.success('Merchant approved successfully');
      router.refresh();
    },
    onError: (error: any) => {
      toast.error(error.message || error.response?.data?.error || 'Failed to approve merchant');
    },
  });

  const rejectMutation = useMutation({
    mutationFn: async (merchantId: string) => {
      const res = await apiClient.post(`/merchants/${merchantId}/reject`);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['merchant', merchantId] });
      queryClient.invalidateQueries({ queryKey: ['pending-merchants'] });
      queryClient.invalidateQueries({ queryKey: ['merchants'] });
      toast.success('Merchant rejected');
      router.refresh();
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to reject merchant');
    },
  });

  const handleApprove = () => {
    if (confirm('Are you sure you want to approve this merchant? A trial subscription will be created automatically.')) {
      approveMutation.mutate(merchantId);
    }
  };

  const handleReject = () => {
    if (confirm('Are you sure you want to reject this merchant registration?')) {
      rejectMutation.mutate(merchantId);
    }
  };

  if (merchantLoading || analyticsLoading || subscriptionLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
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
      <div className="flex items-center justify-between">
      <div>
        <h1 className="text-3xl font-bold">{merchant?.name || 'Merchant Details'}</h1>
        <p className="text-muted-foreground">Detailed merchant information and analytics</p>
        </div>
        {merchant?.status === 'PENDING_APPROVAL' && (
          <div className="flex gap-2">
            <Button
              variant="default"
              onClick={handleApprove}
              disabled={approveMutation.isPending}
              className="bg-green-600 hover:bg-green-700"
            >
              <CheckCircle className="h-4 w-4 mr-2" />
              Approve Merchant
            </Button>
            <Button
              variant="destructive"
              onClick={handleReject}
              disabled={rejectMutation.isPending}
            >
              <XCircle className="h-4 w-4 mr-2" />
              Reject Merchant
            </Button>
          </div>
        )}
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Merchant Information</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-2">
            <div className="flex items-start gap-3">
              <Building2 className="h-5 w-5 text-muted-foreground mt-0.5" />
              <div>
                <p className="text-sm font-medium">Name</p>
                <p className="text-sm text-muted-foreground">{merchant?.name}</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <Mail className="h-5 w-5 text-muted-foreground mt-0.5" />
              <div>
                <p className="text-sm font-medium">Email</p>
                <p className="text-sm text-muted-foreground">{merchant?.email}</p>
              </div>
            </div>
            {merchant?.phone && (
              <div className="flex items-start gap-3">
                <Phone className="h-5 w-5 text-muted-foreground mt-0.5" />
                <div>
                  <p className="text-sm font-medium">Phone</p>
                  <p className="text-sm text-muted-foreground">{merchant.phone}</p>
                </div>
              </div>
            )}
            {merchant?.address && (
              <div className="flex items-start gap-3">
                <MapPin className="h-5 w-5 text-muted-foreground mt-0.5" />
                <div>
                  <p className="text-sm font-medium">Address</p>
                  <p className="text-sm text-muted-foreground">{merchant.address}</p>
                </div>
              </div>
            )}
            <div>
              <p className="text-sm font-medium">Status</p>
              <div className="mt-1">
                {merchant?.status === 'PENDING_APPROVAL' ? (
                  <Badge variant="outline" className="border-orange-300 text-orange-700 bg-orange-50">
                    Pending Approval
                  </Badge>
                ) : merchant?.status === 'ACTIVE' ? (
                  <Badge variant="default" className="bg-green-600">
                    Active
              </Badge>
                ) : (
                  <Badge variant="secondary">Inactive</Badge>
                )}
              </div>
            </div>
            <div>
              <p className="text-sm font-medium">Subscription</p>
              <div className="mt-1 flex items-center gap-2">
                {!subscription ? (
                  <Badge variant="outline" className="border-gray-300 text-gray-600">
                    No Subscription
                  </Badge>
                ) : subscription.status === 'ACTIVE_TRIAL' ? (
                  <Badge className="bg-blue-100 text-blue-800 border-blue-200 flex items-center gap-1">
                    <Clock className="h-3 w-3" />
                    Active Trial
                  </Badge>
                ) : subscription.status === 'ACTIVE_PAID' ? (
                  <Badge className="bg-green-100 text-green-800 border-green-200 flex items-center gap-1">
                    <CheckCircle2 className="h-3 w-3" />
                    Active Paid
                  </Badge>
                ) : subscription.status === 'EXPIRED' ? (
                  <>
                    <Badge variant="destructive" className="flex items-center gap-1">
                      <AlertCircle className="h-3 w-3" />
                      Expired
                    </Badge>
                    <Link href={`/company/subscriptions?merchantId=${merchantId}`}>
                      <Button size="sm" variant="default" className="bg-green-600 hover:bg-green-700">
                        <RotateCcw className="h-3 w-3 mr-1" />
                        Reactivate
                      </Button>
                    </Link>
                  </>
                ) : subscription.status === 'CANCELLED' ? (
                  <>
                    <Badge variant="secondary" className="flex items-center gap-1">
                      <XCircle className="h-3 w-3" />
                      Cancelled
                    </Badge>
                    <Link href={`/company/subscriptions?merchantId=${merchantId}`}>
                      <Button size="sm" variant="default" className="bg-green-600 hover:bg-green-700">
                        <RotateCcw className="h-3 w-3 mr-1" />
                        Reactivate
                      </Button>
                    </Link>
                  </>
                ) : (
                  <Badge variant="outline">{subscription.status}</Badge>
                )}
                {(subscription?.status === 'ACTIVE_TRIAL' || subscription?.status === 'ACTIVE_PAID') && (
                  <Link href={`/company/subscriptions?merchantId=${merchantId}`}>
                    <Button size="sm" variant="outline">
                      <ExternalLink className="h-3 w-3 mr-1" />
                      Manage
                    </Button>
                  </Link>
                )}
              </div>
              {subscription && (
                <div className="mt-2 text-xs text-muted-foreground">
                  {subscription.status === 'ACTIVE_TRIAL' && subscription.trialEndDate && (
                    <span>
                      Trial ends: {format(new Date(subscription.trialEndDate), 'MMM d, yyyy')}
                    </span>
                  )}
                  {subscription.transactionFeeRate && (
                    <span className="ml-2">
                      Fee Rate: {Number(subscription.transactionFeeRate).toFixed(2)}%
                    </span>
                  )}
                </div>
              )}
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Products</CardTitle>
            <Package className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{analytics?.totalProducts || 0}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Sales</CardTitle>
            <ShoppingCart className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{analytics?.totalSales || 0}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {formatCurrencySmart(analytics?.totalRevenue || 0)}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Low Stock</CardTitle>
            <Package className="h-4 w-4 text-orange-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">
              {analytics?.lowStockProducts || 0}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

