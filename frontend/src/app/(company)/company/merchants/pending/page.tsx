'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { CheckCircle, XCircle, Clock, Building2, Mail, Phone, MapPin, User } from 'lucide-react';
import { toast } from 'sonner';
import { format } from 'date-fns';

export default function PendingMerchantsPage() {
  const queryClient = useQueryClient();

  const { data: pendingMerchants, isLoading } = useQuery({
    queryKey: ['pending-merchants'],
    queryFn: async () => {
      const res = await apiClient.get('/merchants/pending');
      return res.data.data || [];
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
      queryClient.invalidateQueries({ queryKey: ['pending-merchants'] });
      queryClient.invalidateQueries({ queryKey: ['merchants'] });
      queryClient.invalidateQueries({ queryKey: ['platform-analytics'] });
      queryClient.invalidateQueries({ queryKey: ['subscriptions'] });
      toast.success('Merchant approved successfully');
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
      queryClient.invalidateQueries({ queryKey: ['pending-merchants'] });
      queryClient.invalidateQueries({ queryKey: ['merchants'] });
      toast.success('Merchant rejected');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to reject merchant');
    },
  });

  const handleApprove = (merchantId: string) => {
    if (confirm('Are you sure you want to approve this merchant? A trial subscription will be created automatically.')) {
      approveMutation.mutate(merchantId);
    }
  };

  const handleReject = (merchantId: string) => {
    if (confirm('Are you sure you want to reject this merchant registration?')) {
      rejectMutation.mutate(merchantId);
    }
  };

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Pending Merchant Approvals</h1>
          <p className="text-muted-foreground">Review and approve merchant registrations</p>
        </div>
        <Card>
          <CardContent className="pt-6">
            <div className="space-y-4">
              {[...Array(3)].map((_, i) => (
                <Skeleton key={i} className="h-32 w-full" />
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Pending Merchant Approvals</h1>
        <p className="text-muted-foreground">Review and approve merchant registrations</p>
      </div>

      {pendingMerchants && pendingMerchants.length > 0 ? (
        <div className="grid gap-4">
          {pendingMerchants.map((merchant: any) => (
            <Card key={merchant.id} className="border-orange-200 bg-orange-50">
              <CardHeader>
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <CardTitle className="flex items-center gap-2 mb-2">
                      <Building2 className="h-5 w-5 text-orange-600" />
                      {merchant.name}
                    </CardTitle>
                    <CardDescription>Registration submitted on {format(new Date(merchant.createdAt), 'MMM d, yyyy')}</CardDescription>
                  </div>
                  <Badge variant="outline" className="border-orange-300 text-orange-700 bg-orange-50">
                    Pending Approval
                  </Badge>
                </div>
              </CardHeader>
              <CardContent>
                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-3">
                    <div className="flex items-start gap-3">
                      <Mail className="h-4 w-4 text-muted-foreground mt-0.5" />
                      <div>
                        <p className="text-sm font-medium">Email</p>
                        <p className="text-sm text-muted-foreground">{merchant.email}</p>
                      </div>
                    </div>
                    {merchant.phone && (
                      <div className="flex items-start gap-3">
                        <Phone className="h-4 w-4 text-muted-foreground mt-0.5" />
                        <div>
                          <p className="text-sm font-medium">Phone</p>
                          <p className="text-sm text-muted-foreground">{merchant.phone}</p>
                        </div>
                      </div>
                    )}
                    {merchant.address && (
                      <div className="flex items-start gap-3">
                        <MapPin className="h-4 w-4 text-muted-foreground mt-0.5" />
                        <div>
                          <p className="text-sm font-medium">Address</p>
                          <p className="text-sm text-muted-foreground">{merchant.address}</p>
                        </div>
                      </div>
                    )}
                  </div>
                  <div className="space-y-3">
                    {merchant.users && merchant.users.length > 0 && (
                      <div className="flex items-start gap-3">
                        <User className="h-4 w-4 text-muted-foreground mt-0.5" />
                        <div>
                          <p className="text-sm font-medium">Admin User</p>
                          <p className="text-sm text-muted-foreground">
                            {merchant.users[0].firstName} {merchant.users[0].lastName}
                          </p>
                          <p className="text-xs text-muted-foreground">{merchant.users[0].email}</p>
                        </div>
                      </div>
                    )}
                    <div className="flex items-start gap-3">
                      <Clock className="h-4 w-4 text-muted-foreground mt-0.5" />
                      <div>
                        <p className="text-sm font-medium">Registered</p>
                        <p className="text-sm text-muted-foreground">
                          {format(new Date(merchant.createdAt), 'MMM d, yyyy h:mm a')}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
                <div className="flex justify-end gap-2 mt-6 pt-4 border-t">
                  <Button
                    variant="destructive"
                    onClick={() => handleReject(merchant.id)}
                    disabled={rejectMutation.isPending}
                  >
                    <XCircle className="h-4 w-4 mr-2" />
                    Reject
                  </Button>
                  <Button
                    variant="default"
                    onClick={() => handleApprove(merchant.id)}
                    disabled={approveMutation.isPending}
                    className="bg-green-600 hover:bg-green-700"
                  >
                    <CheckCircle className="h-4 w-4 mr-2" />
                    Approve Merchant
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      ) : (
        <Card>
          <CardContent className="pt-6">
            <div className="text-center py-12">
              <CheckCircle className="mx-auto h-12 w-12 text-green-500 mb-4" />
              <p className="text-lg font-medium mb-2">No pending approvals</p>
              <p className="text-muted-foreground">All merchant registrations have been processed</p>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

