'use client';

import { useState, useEffect, Suspense } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useSearchParams } from 'next/navigation';
import apiClient from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Search, Building2, Eye, Clock, AlertCircle, CheckCircle2, XCircle } from 'lucide-react';
import Link from 'next/link';
import { Skeleton } from '@/components/ui/skeleton';

function MerchantsPageContent() {
  const searchParams = useSearchParams();
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>(searchParams.get('status') || 'all');

  // Update filter when URL param changes
  useEffect(() => {
    const status = searchParams.get('status');
    if (status) {
      setStatusFilter(status);
    } else {
      setStatusFilter('all');
    }
  }, [searchParams]);

  const { data, isLoading } = useQuery({
    queryKey: ['merchants', search, statusFilter],
    queryFn: async () => {
      const params: any = {};
      if (search) params.search = search;
      if (statusFilter !== 'all') {
        // Map filter to API parameter
        if (statusFilter === 'pending') {
          // For pending, we'll need to fetch separately or filter
        } else {
          params.isActive = statusFilter === 'active';
        }
      }
      const res = await apiClient.get('/merchants', { params });
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

  const { data: allSubscriptions } = useQuery({
    queryKey: ['subscriptions'],
    queryFn: async () => {
      const res = await apiClient.get('/subscriptions');
      return res.data.data || [];
    },
  });


  // Combine merchants and filter by status
  let merchants = data || [];
  if (statusFilter === 'pending') {
    merchants = pendingMerchants || [];
  } else if (statusFilter === 'active') {
    merchants = merchants.filter((m: any) => m.isActive && m.status === 'ACTIVE');
  } else if (statusFilter === 'inactive') {
    merchants = merchants.filter((m: any) => !m.isActive || m.status === 'INACTIVE');
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Merchants</h1>
          <p className="text-muted-foreground">Manage and view all registered merchants</p>
        </div>
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>
                {statusFilter === 'pending' 
                  ? 'Pending Approvals' 
                  : statusFilter === 'active'
                  ? 'Active Merchants'
                  : statusFilter === 'inactive'
                  ? 'Inactive Merchants'
                  : 'All Merchants'}
              </CardTitle>
              <CardDescription>
                {statusFilter === 'pending'
                  ? 'Merchants awaiting approval'
                  : 'Complete list of merchants on the platform'}
              </CardDescription>
            </div>
            <div className="flex items-center gap-2">
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Filter by status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Merchants</SelectItem>
                  <SelectItem value="pending">Pending Approval</SelectItem>
                  <SelectItem value="active">Active</SelectItem>
                  <SelectItem value="inactive">Inactive</SelectItem>
                </SelectContent>
              </Select>
              <div className="relative">
                <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search merchants..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="pl-8 w-64"
                />
              </div>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <Skeleton key={i} className="h-16 w-full" />
              ))}
            </div>
          ) : merchants.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Merchant</TableHead>
                  <TableHead>Email</TableHead>
                  <TableHead>Phone</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Subscription</TableHead>
                  <TableHead>Stats</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {merchants.map((merchant: any) => {
                  // Find subscription for this merchant
                  const subscription = allSubscriptions?.find((sub: any) => sub.merchantId === merchant.id);
                  
                  const getSubscriptionBadge = () => {
                    if (!subscription) {
                      return <Badge variant="outline" className="border-gray-300 text-gray-600">No Subscription</Badge>;
                    }
                    
                    switch (subscription.status) {
                      case 'ACTIVE_TRIAL':
                        return (
                          <Badge className="bg-blue-100 text-blue-800 border-blue-200 flex items-center gap-1">
                            <Clock className="h-3 w-3" />
                            Active Trial
                          </Badge>
                        );
                      case 'ACTIVE_PAID':
                        return (
                          <Badge className="bg-green-100 text-green-800 border-green-200 flex items-center gap-1">
                            <CheckCircle2 className="h-3 w-3" />
                            Active Paid
                          </Badge>
                        );
                      case 'EXPIRED':
                        return (
                          <Badge variant="destructive" className="flex items-center gap-1">
                            <AlertCircle className="h-3 w-3" />
                            Expired
                          </Badge>
                        );
                      case 'CANCELLED':
                        return (
                          <Badge variant="secondary" className="flex items-center gap-1">
                            <XCircle className="h-3 w-3" />
                            Cancelled
                          </Badge>
                        );
                      default:
                        return <Badge variant="outline">{subscription.status}</Badge>;
                    }
                  };

                  return (
                    <TableRow key={merchant.id}>
                      <TableCell className="font-medium">
                        <div className="flex items-center gap-2">
                          <Building2 className="h-4 w-4 text-muted-foreground" />
                          {merchant.name}
                        </div>
                      </TableCell>
                      <TableCell>{merchant.email}</TableCell>
                      <TableCell>{merchant.phone || '-'}</TableCell>
                      <TableCell>
                        {merchant.status === 'PENDING_APPROVAL' ? (
                          <Badge variant="outline" className="border-orange-300 text-orange-700 bg-orange-50">
                            Pending Approval
                          </Badge>
                        ) : merchant.status === 'ACTIVE' ? (
                          <Badge variant="default" className="bg-green-600">
                            Active
                          </Badge>
                        ) : (
                          <Badge variant="secondary">Inactive</Badge>
                        )}
                      </TableCell>
                      <TableCell>
                        {getSubscriptionBadge()}
                      </TableCell>
                      <TableCell>
                        <div className="text-sm text-muted-foreground">
                          {merchant._count?.products || 0} products, {merchant._count?.sales || 0}{' '}
                          sales
                        </div>
                      </TableCell>
                      <TableCell className="text-right">
                        <Link href={`/company/merchants/${merchant.id}`}>
                          <Button variant="ghost" size="sm">
                            <Eye className="h-4 w-4 mr-1" />
                            View
                          </Button>
                        </Link>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          ) : (
            <div className="text-center py-12">
              <Building2 className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No merchants found</p>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

export default function MerchantsPage() {
  return (
    <Suspense fallback={
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Merchants</h1>
          <p className="text-muted-foreground">Manage and view all registered merchants</p>
        </div>
        <Card>
          <CardContent className="pt-6">
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <Skeleton key={i} className="h-16 w-full" />
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    }>
      <MerchantsPageContent />
    </Suspense>
  );
}

