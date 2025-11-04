'use client';

import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/auth-context';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Building2, Mail, Users, TrendingUp, Settings, Save } from 'lucide-react';
import { toast } from 'sonner';

export default function SettingsPage() {
  const { user } = useAuth();
  const queryClient = useQueryClient();

  const { data: platformSettings, isLoading: settingsLoading } = useQuery({
    queryKey: ['platform-settings'],
    queryFn: async () => {
      const res = await apiClient.get('/platform-settings');
      return res.data.data;
    },
  });

  const [defaultTrialPeriodDays, setDefaultTrialPeriodDays] = useState('');
  const [defaultTransactionFeeRate, setDefaultTransactionFeeRate] = useState('');

  // Initialize form when settings load
  useEffect(() => {
    if (platformSettings) {
      setDefaultTrialPeriodDays(platformSettings.defaultTrialPeriodDays?.toString());
      setDefaultTransactionFeeRate(Number(platformSettings.defaultTransactionFeeRate).toFixed(2));
    }
  }, [platformSettings]);

  const updateSettingsMutation = useMutation({
    mutationFn: async (data: {
      defaultTrialPeriodDays?: number;
      defaultTransactionFeeRate?: number;
    }) => {
      const res = await apiClient.patch('/platform-settings', data);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['platform-settings'] });
      toast.success('Platform settings updated successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to update settings');
    },
  });

  const handleSaveDefaults = () => {
    const trialDays = parseInt(defaultTrialPeriodDays, 10);
    const feeRate = parseFloat(defaultTransactionFeeRate);

    if (isNaN(trialDays) || trialDays <= 0) {
      toast.error('Please enter a valid trial period (must be greater than 0)');
      return;
    }

    if (isNaN(feeRate) || feeRate < 0 || feeRate > 100) {
      toast.error('Please enter a valid fee rate (0-100)');
      return;
    }

    updateSettingsMutation.mutate({
      defaultTrialPeriodDays: trialDays,
      defaultTransactionFeeRate: feeRate,
    });
  };

  if (settingsLoading) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Settings</h1>
          <p className="text-muted-foreground">Platform configuration and preferences</p>
        </div>
        <Card>
          <CardContent className="pt-6">
            <div className="space-y-4">
              <div className="h-4 bg-muted animate-pulse rounded w-1/4"></div>
              <div className="h-10 bg-muted animate-pulse rounded"></div>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Settings</h1>
        <p className="text-muted-foreground">Platform configuration and preferences</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Company Information</CardTitle>
          <CardDescription>Your company profile and details</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex items-start gap-3">
              <Building2 className="h-5 w-5 text-muted-foreground mt-0.5" />
              <div className="flex-1">
                <p className="text-sm font-medium">Company Name</p>
                <p className="text-sm text-muted-foreground">Gebeya Platform</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <Mail className="h-5 w-5 text-muted-foreground mt-0.5" />
              <div className="flex-1">
                <p className="text-sm font-medium">Email</p>
                <p className="text-sm text-muted-foreground">{user?.email}</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <Users className="h-5 w-5 text-muted-foreground mt-0.5" />
              <div className="flex-1">
                <p className="text-sm font-medium">Role</p>
                <Badge className="mt-1">Platform Owner</Badge>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Notification Settings</CardTitle>
          <CardDescription>Configure email notification preferences</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex items-center justify-between p-4 border rounded-lg">
              <div>
                <p className="font-medium">Daily Sales Summaries</p>
                <p className="text-sm text-muted-foreground">
                  Receive daily email summaries of sales activity
                </p>
              </div>
              <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                Enabled
              </Badge>
            </div>
            <div className="flex items-center justify-between p-4 border rounded-lg">
              <div>
                <p className="font-medium">Weekly Reports</p>
                <p className="text-sm text-muted-foreground">
                  Receive comprehensive weekly performance reports
                </p>
              </div>
              <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                Enabled
              </Badge>
            </div>
            <div className="flex items-center justify-between p-4 border rounded-lg">
              <div>
                <p className="font-medium">Low Stock Alerts</p>
                <p className="text-sm text-muted-foreground">
                  Get notified when products are running low
                </p>
              </div>
              <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
                Enabled
              </Badge>
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Settings className="h-5 w-5" />
            Platform Settings
          </CardTitle>
          <CardDescription>Configure default trial period and transaction fee rate for new merchants</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            <div className="space-y-2">
              <Label htmlFor="defaultTrialPeriodDays">Default Trial Period (Days)</Label>
              <Input
                id="defaultTrialPeriodDays"
                type="number"
                min="1"
                value={defaultTrialPeriodDays || platformSettings?.defaultTrialPeriodDays || '30'}
                onChange={(e) => setDefaultTrialPeriodDays(e.target.value)}
                placeholder="30"
              />
              <p className="text-xs text-muted-foreground">
                New merchants will receive this many days of trial when approved
              </p>
            </div>

            <div className="space-y-2">
              <Label htmlFor="defaultTransactionFeeRate">Default Transaction Fee Rate (%)</Label>
              <Input
                id="defaultTransactionFeeRate"
                type="number"
                min="0"
                max="100"
                step="0.01"
                value={defaultTransactionFeeRate || Number(platformSettings?.defaultTransactionFeeRate || 5.0).toFixed(2)}
                onChange={(e) => setDefaultTransactionFeeRate(e.target.value)}
                placeholder="5.00"
              />
              <p className="text-xs text-muted-foreground">
                Default percentage fee charged on each sale (0-100)
              </p>
            </div>

            <Button
              onClick={handleSaveDefaults}
              disabled={updateSettingsMutation.isPending}
              className="w-full sm:w-auto"
            >
              <Save className="h-4 w-4 mr-2" />
              {updateSettingsMutation.isPending ? 'Saving...' : 'Save Defaults'}
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>System Information</CardTitle>
          <CardDescription>Platform version and status</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-muted-foreground">Platform Version:</span>
              <span className="font-medium">1.0.0</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Database:</span>
              <span className="font-medium">PostgreSQL (Neon)</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Status:</span>
              <Badge variant="default" className="bg-green-500">Operational</Badge>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

