'use client';

import { useState, Suspense } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSearchParams } from 'next/navigation';
import apiClient from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Skeleton } from '@/components/ui/skeleton';
import { Calendar, Clock, DollarSign, RefreshCw, Plus, Edit, RotateCcw, Search, Filter } from 'lucide-react';
import { formatCurrency } from '@/lib/currency';
import { toast } from 'sonner';
import { format } from 'date-fns';

export default function SubscriptionsPage() {
  const queryClient = useQueryClient();
  const searchParams = useSearchParams();
  const merchantIdFilter = searchParams.get('merchantId');
  
  const [selectedSubscription, setSelectedSubscription] = useState<any>(null);
  const [isExtendDialogOpen, setIsExtendDialogOpen] = useState(false);
  const [isResetDialogOpen, setIsResetDialogOpen] = useState(false);
  const [isUpdatePeriodDialogOpen, setIsUpdatePeriodDialogOpen] = useState(false);
  const [isUpdateFeeDialogOpen, setIsUpdateFeeDialogOpen] = useState(false);
  const [isReactivateDialogOpen, setIsReactivateDialogOpen] = useState(false);
  const [extendDays, setExtendDays] = useState('');
  const [resetDays, setResetDays] = useState('');
  const [updatePeriodDays, setUpdatePeriodDays] = useState('');
  const [feeRate, setFeeRate] = useState('');
  const [reactivateDays, setReactivateDays] = useState('');
  const [reactivateFeeRate, setReactivateFeeRate] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('all');

  const { data: subscriptionsData, isLoading } = useQuery({
    queryKey: ['subscriptions', merchantIdFilter, statusFilter, searchQuery],
    queryFn: async () => {
      const params: any = {};
      if (merchantIdFilter) {
        params.merchantId = merchantIdFilter;
      }
      if (statusFilter !== 'all') {
        params.status = statusFilter;
      }
      if (searchQuery.trim()) {
        params.search = searchQuery.trim();
      }
      const res = await apiClient.get('/subscriptions', { params });
      return res.data.data || []; // This is already the subscriptions array
    },
  });

  const subscriptions = subscriptionsData || [];

  const extendMutation = useMutation({
    mutationFn: async ({ subscriptionId, additionalDays }: { subscriptionId: string; additionalDays: number }) => {
      const res = await apiClient.patch(`/subscriptions/${subscriptionId}/extend`, {
        additionalDays,
      });
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['subscriptions'] });
      setIsExtendDialogOpen(false);
      setExtendDays('');
      toast.success('Trial extended successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to extend trial');
    },
  });

  const resetMutation = useMutation({
    mutationFn: async ({ subscriptionId, newTrialPeriodDays }: { subscriptionId: string; newTrialPeriodDays: number }) => {
      const res = await apiClient.patch(`/subscriptions/${subscriptionId}/reset`, {
        newTrialPeriodDays,
      });
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['subscriptions'] });
      setIsResetDialogOpen(false);
      setResetDays('');
      toast.success('Trial reset successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to reset trial');
    },
  });

  const updatePeriodMutation = useMutation({
    mutationFn: async ({ subscriptionId, newTrialPeriodDays }: { subscriptionId: string; newTrialPeriodDays: number }) => {
      const res = await apiClient.patch(`/subscriptions/${subscriptionId}/trial-period`, {
        newTrialPeriodDays,
      });
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['subscriptions'] });
      setIsUpdatePeriodDialogOpen(false);
      setUpdatePeriodDays('');
      toast.success('Trial period updated successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to update trial period');
    },
  });

  const updateFeeMutation = useMutation({
    mutationFn: async ({ subscriptionId, feeRate }: { subscriptionId: string; feeRate: number }) => {
      const res = await apiClient.patch(`/subscriptions/${subscriptionId}/fee-rate`, {
        feeRate,
      });
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['subscriptions'] });
      setIsUpdateFeeDialogOpen(false);
      setFeeRate('');
      toast.success('Transaction fee rate updated successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to update fee rate');
    },
  });

  const reactivateMutation = useMutation({
    mutationFn: async ({ subscriptionId, trialPeriodDays, transactionFeeRate }: { subscriptionId: string; trialPeriodDays?: number; transactionFeeRate?: number }) => {
      const body: any = {};
      if (trialPeriodDays) body.trialPeriodDays = trialPeriodDays;
      if (transactionFeeRate !== undefined) body.transactionFeeRate = transactionFeeRate;
      
      const res = await apiClient.patch(`/subscriptions/${subscriptionId}/reactivate`, body);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['subscriptions'] });
      setIsReactivateDialogOpen(false);
      setReactivateDays('');
      setReactivateFeeRate('');
      toast.success('Subscription reactivated successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to reactivate subscription');
    },
  });

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'ACTIVE_TRIAL':
        return <Badge className="bg-blue-100 text-blue-800 border-blue-200">Active Trial</Badge>;
      case 'ACTIVE_PAID':
        return <Badge className="bg-green-100 text-green-800 border-green-200">Active Paid</Badge>;
      case 'EXPIRED':
        return <Badge variant="destructive">Expired</Badge>;
      case 'CANCELLED':
        return <Badge variant="secondary">Cancelled</Badge>;
      default:
        return <Badge variant="outline">{status}</Badge>;
    }
  };

  const getDaysRemaining = (trialEndDate: string) => {
    const endDate = new Date(trialEndDate);
    const now = new Date();
    const diff = Math.ceil((endDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
    return diff;
  };

  const handleExtend = () => {
    if (!selectedSubscription || !extendDays) return;
    const days = parseInt(extendDays, 10);
    if (isNaN(days) || days <= 0) {
      toast.error('Please enter a valid number of days');
      return;
    }
    extendMutation.mutate({ subscriptionId: selectedSubscription.id, additionalDays: days });
  };

  const handleReset = () => {
    if (!selectedSubscription || !resetDays) return;
    const days = parseInt(resetDays, 10);
    if (isNaN(days) || days <= 0) {
      toast.error('Please enter a valid number of days');
      return;
    }
    resetMutation.mutate({ subscriptionId: selectedSubscription.id, newTrialPeriodDays: days });
  };

  const handleUpdatePeriod = () => {
    if (!selectedSubscription || !updatePeriodDays) return;
    const days = parseInt(updatePeriodDays, 10);
    if (isNaN(days) || days <= 0) {
      toast.error('Please enter a valid number of days');
      return;
    }
    updatePeriodMutation.mutate({ subscriptionId: selectedSubscription.id, newTrialPeriodDays: days });
  };

  const handleUpdateFee = () => {
    if (!selectedSubscription || !feeRate) return;
    const rate = parseFloat(feeRate);
    if (isNaN(rate) || rate < 0 || rate > 100) {
      toast.error('Please enter a valid fee rate between 0 and 100');
      return;
    }
    updateFeeMutation.mutate({ subscriptionId: selectedSubscription.id, feeRate: rate });
  };

  const handleReactivate = () => {
    if (!selectedSubscription) return;
    
    const trialPeriodDays = reactivateDays ? parseInt(reactivateDays, 10) : undefined;
    const transactionFeeRate = reactivateFeeRate ? parseFloat(reactivateFeeRate) : undefined;

    if (trialPeriodDays !== undefined && (isNaN(trialPeriodDays) || trialPeriodDays <= 0)) {
      toast.error('Please enter a valid number of days');
      return;
    }

    if (transactionFeeRate !== undefined && (isNaN(transactionFeeRate) || transactionFeeRate < 0 || transactionFeeRate > 100)) {
      toast.error('Please enter a valid fee rate between 0 and 100');
      return;
    }

    reactivateMutation.mutate({
      subscriptionId: selectedSubscription.id,
      trialPeriodDays,
      transactionFeeRate,
    });
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Subscriptions & Trials</h1>
          <p className="text-muted-foreground">Manage merchant subscriptions and trials</p>
        </div>
        <Card>
          <CardContent className="pt-6">
            <Skeleton className="h-64 w-full" />
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Subscriptions & Trials</h1>
        <p className="text-muted-foreground">Manage merchant subscriptions and trials</p>
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>All Subscriptions</CardTitle>
              <CardDescription>View and manage all merchant subscriptions and trials</CardDescription>
            </div>
            <div className="flex items-center gap-2">
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Filter by status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Status</SelectItem>
                  <SelectItem value="ACTIVE_TRIAL">Active Trial</SelectItem>
                  <SelectItem value="ACTIVE_PAID">Active Paid</SelectItem>
                  <SelectItem value="EXPIRED">Expired</SelectItem>
                  <SelectItem value="CANCELLED">Cancelled</SelectItem>
                </SelectContent>
              </Select>
              <div className="relative">
                <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search by merchant email or name..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-8 w-64"
                />
              </div>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {subscriptions.length === 0 ? (
            <p className="text-muted-foreground text-center py-8">
              {searchQuery || statusFilter !== 'all' 
                ? 'No subscriptions found matching your filters' 
                : 'No subscriptions found'}
            </p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Merchant</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Plan Type</TableHead>
                  <TableHead>Trial End Date</TableHead>
                  <TableHead>Days Remaining</TableHead>
                  <TableHead>Fee Rate</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {subscriptions.map((subscription: any) => {
                  // Safety check: ensure subscription has required fields
                  if (!subscription || !subscription.id) {
                    return null;
                  }
                  
                  const daysRemaining = subscription.status === 'ACTIVE_TRIAL' && subscription.trialEndDate
                    ? getDaysRemaining(subscription.trialEndDate)
                    : null;

                  return (
                    <TableRow key={subscription.id}>
                      <TableCell>
                        <div>
                          <div className="font-medium">{subscription.merchant?.name || 'N/A'}</div>
                          <div className="text-sm text-muted-foreground">{subscription.merchant?.email || ''}</div>
                        </div>
                      </TableCell>
                      <TableCell>{getStatusBadge(subscription.status)}</TableCell>
                      <TableCell>
                        <Badge variant="outline">{subscription.planType}</Badge>
                      </TableCell>
                      <TableCell>
                        {subscription.trialEndDate
                          ? format(new Date(subscription.trialEndDate), 'MMM d, yyyy')
                          : 'N/A'}
                      </TableCell>
                      <TableCell>
                        {daysRemaining !== null ? (
                          <span className={daysRemaining <= 7 ? 'text-orange-600 font-medium' : ''}>
                            {daysRemaining} days
                          </span>
                        ) : (
                          'N/A'
                        )}
                      </TableCell>
                      <TableCell>{subscription.transactionFeeRate ? Number(subscription.transactionFeeRate).toFixed(2) : '0.00'}%</TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          {subscription.status === 'ACTIVE_TRIAL' && (
                            <>
                              <Dialog
                                open={isExtendDialogOpen && selectedSubscription?.id === subscription.id}
                                onOpenChange={(open) => {
                                  setIsExtendDialogOpen(open);
                                  if (open) {
                                    setSelectedSubscription(subscription);
                                    setExtendDays('');
                                  }
                                }}
                              >
                                <DialogTrigger asChild>
                                  <Button size="sm" variant="outline">
                                    <Plus className="h-4 w-4 mr-1" />
                                    Extend
                                  </Button>
                                </DialogTrigger>
                                <DialogContent>
                                  <DialogHeader>
                                    <DialogTitle>Extend Trial</DialogTitle>
                                    <DialogDescription>
                                      Add additional days to the current trial period for {subscription.merchant?.name}
                                    </DialogDescription>
                                  </DialogHeader>
                                  <div className="space-y-4">
                                    <div className="space-y-2">
                                      <Label htmlFor="extendDays">Additional Days</Label>
                                      <Input
                                        id="extendDays"
                                        type="number"
                                        min="1"
                                        value={extendDays}
                                        onChange={(e) => setExtendDays(e.target.value)}
                                        placeholder="Enter number of days"
                                      />
                                    </div>
                                    <Button
                                      onClick={handleExtend}
                                      disabled={extendMutation.isPending}
                                      className="w-full"
                                    >
                                      {extendMutation.isPending ? 'Extending...' : 'Extend Trial'}
                                    </Button>
                                  </div>
                                </DialogContent>
                              </Dialog>

                              <Dialog
                                open={isResetDialogOpen && selectedSubscription?.id === subscription.id}
                                onOpenChange={(open) => {
                                  setIsResetDialogOpen(open);
                                  if (open && subscription?.trialPeriodDays != null) {
                                    setSelectedSubscription(subscription);
                                    setResetDays(subscription.trialPeriodDays.toString());
                                  }
                                }}
                              >
                                <DialogTrigger asChild>
                                  <Button size="sm" variant="outline">
                                    <RefreshCw className="h-4 w-4 mr-1" />
                                    Reset
                                  </Button>
                                </DialogTrigger>
                                <DialogContent>
                                  <DialogHeader>
                                    <DialogTitle>Reset Trial</DialogTitle>
                                    <DialogDescription>
                                      Reset the trial period starting from today for {subscription.merchant?.name}
                                    </DialogDescription>
                                  </DialogHeader>
                                  <div className="space-y-4">
                                    <div className="space-y-2">
                                      <Label htmlFor="resetDays">New Trial Period (Days)</Label>
                                      <Input
                                        id="resetDays"
                                        type="number"
                                        min="1"
                                        value={resetDays}
                                        onChange={(e) => setResetDays(e.target.value)}
                                        placeholder="Enter number of days"
                                      />
                                    </div>
                                    <Button
                                      onClick={handleReset}
                                      disabled={resetMutation.isPending}
                                      className="w-full"
                                    >
                                      {resetMutation.isPending ? 'Resetting...' : 'Reset Trial'}
                                    </Button>
                                  </div>
                                </DialogContent>
                              </Dialog>

                              <Dialog
                                open={isUpdatePeriodDialogOpen && selectedSubscription?.id === subscription.id}
                                onOpenChange={(open) => {
                                  setIsUpdatePeriodDialogOpen(open);
                                  if (open && subscription?.trialPeriodDays != null) {
                                    setSelectedSubscription(subscription);
                                    setUpdatePeriodDays(subscription.trialPeriodDays.toString());
                                  }
                                }}
                              >
                                <DialogTrigger asChild>
                                  <Button size="sm" variant="outline">
                                    <Edit className="h-4 w-4 mr-1" />
                                    Update Period
                                  </Button>
                                </DialogTrigger>
                                <DialogContent>
                                  <DialogHeader>
                                    <DialogTitle>Update Trial Period</DialogTitle>
                                    <DialogDescription>
                                      Update the trial period duration for {subscription.merchant?.name}
                                    </DialogDescription>
                                  </DialogHeader>
                                  <div className="space-y-4">
                                    <div className="space-y-2">
                                      <Label htmlFor="updatePeriodDays">New Trial Period (Days)</Label>
                                      <Input
                                        id="updatePeriodDays"
                                        type="number"
                                        min="1"
                                        value={updatePeriodDays}
                                        onChange={(e) => setUpdatePeriodDays(e.target.value)}
                                        placeholder="Enter number of days"
                                      />
                                    </div>
                                    <Button
                                      onClick={handleUpdatePeriod}
                                      disabled={updatePeriodMutation.isPending}
                                      className="w-full"
                                    >
                                      {updatePeriodMutation.isPending ? 'Updating...' : 'Update Period'}
                                    </Button>
                                  </div>
                                </DialogContent>
                              </Dialog>
                            </>
                          )}

                          {(subscription.status === 'EXPIRED' || subscription.status === 'CANCELLED') && (
                            <Dialog
                              open={isReactivateDialogOpen && selectedSubscription?.id === subscription.id}
                              onOpenChange={(open) => {
                                setIsReactivateDialogOpen(open);
                                if (open) {
                                  setSelectedSubscription(subscription);
                                  setReactivateDays('');
                                  setReactivateFeeRate('');
                                }
                              }}
                            >
                              <DialogTrigger asChild>
                                <Button size="sm" variant="default" className="bg-green-600 hover:bg-green-700">
                                  <RotateCcw className="h-4 w-4 mr-1" />
                                  Reactivate
                                </Button>
                              </DialogTrigger>
                              <DialogContent>
                                <DialogHeader>
                                  <DialogTitle>Reactivate Subscription</DialogTitle>
                                  <DialogDescription>
                                    Reactivate the expired subscription for {subscription.merchant?.name}. Leave fields blank to use platform defaults.
                                  </DialogDescription>
                                </DialogHeader>
                                <div className="space-y-4">
                                  <div className="space-y-2">
                                    <Label htmlFor="reactivateDays">Trial Period (Days) - Optional</Label>
                                    <Input
                                      id="reactivateDays"
                                      type="number"
                                      min="1"
                                      value={reactivateDays}
                                      onChange={(e) => setReactivateDays(e.target.value)}
                                      placeholder="Leave blank for default"
                                    />
                                    <p className="text-xs text-muted-foreground">Uses platform default if not specified</p>
                                  </div>
                                  <div className="space-y-2">
                                    <Label htmlFor="reactivateFeeRate">Transaction Fee Rate (%) - Optional</Label>
                                    <Input
                                      id="reactivateFeeRate"
                                      type="number"
                                      min="0"
                                      max="100"
                                      step="0.01"
                                      value={reactivateFeeRate}
                                      onChange={(e) => setReactivateFeeRate(e.target.value)}
                                      placeholder="Leave blank for default"
                                    />
                                    <p className="text-xs text-muted-foreground">Uses platform default if not specified</p>
                                  </div>
                                  <Button
                                    onClick={handleReactivate}
                                    disabled={reactivateMutation.isPending}
                                    className="w-full bg-green-600 hover:bg-green-700"
                                  >
                                    {reactivateMutation.isPending ? 'Reactivating...' : 'Reactivate Subscription'}
                                  </Button>
                                </div>
                              </DialogContent>
                            </Dialog>
                          )}

                          <Dialog
                            open={isUpdateFeeDialogOpen && selectedSubscription?.id === subscription.id}
                            onOpenChange={(open) => {
                              setIsUpdateFeeDialogOpen(open);
                              if (open) {
                                setSelectedSubscription(subscription);
                                setFeeRate(Number(subscription.transactionFeeRate || 0).toString());
                              }
                            }}
                          >
                            <DialogTrigger asChild>
                              <Button size="sm" variant="outline">
                                <DollarSign className="h-4 w-4 mr-1" />
                                Fee Rate
                              </Button>
                            </DialogTrigger>
                            <DialogContent>
                              <DialogHeader>
                                <DialogTitle>Update Transaction Fee Rate</DialogTitle>
                                <DialogDescription>
                                  Update the transaction fee rate for {subscription.merchant?.name}
                                </DialogDescription>
                              </DialogHeader>
                              <div className="space-y-4">
                                <div className="space-y-2">
                                  <Label htmlFor="feeRate">Fee Rate (%)</Label>
                                  <Input
                                    id="feeRate"
                                    type="number"
                                    min="0"
                                    max="100"
                                    step="0.01"
                                    value={feeRate}
                                    onChange={(e) => setFeeRate(e.target.value)}
                                    placeholder="Enter fee rate (e.g., 5.00)"
                                  />
                                </div>
                                <Button
                                  onClick={handleUpdateFee}
                                  disabled={updateFeeMutation.isPending}
                                  className="w-full"
                                >
                                  {updateFeeMutation.isPending ? 'Updating...' : 'Update Fee Rate'}
                                </Button>
                              </div>
                            </DialogContent>
                          </Dialog>
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

