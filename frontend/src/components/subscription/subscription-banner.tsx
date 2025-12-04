'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { XCircle, AlertTriangle, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { format } from 'date-fns';
import { useQuery } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { useAuth } from '@/contexts/auth-context';

export function SubscriptionBanner() {
  const { isPlatformOwner } = useAuth();
  const [subscriptionExpired, setSubscriptionExpired] = useState(false);
  const [expiredDetails, setExpiredDetails] = useState<any>(null);
  const [dismissed, setDismissed] = useState(false);

  // Fetch subscription status
  const { data: subscriptionStatus, error: subscriptionError } = useQuery({
    queryKey: ['subscription-status'],
    queryFn: async () => {
      try {
        const res = await apiClient.get('/subscriptions/status');
        return res.data.data;
      } catch (error: any) {
        // Check if it's a subscription expired error
        if (
          error.response?.status === 403 &&
          error.response?.data?.error === 'Trial subscription has expired'
        ) {
          setSubscriptionExpired(true);
          setExpiredDetails(error.response.data.details);
        }
        throw error; // Re-throw to let React Query handle it
      }
    },
    enabled: !isPlatformOwner, // Only fetch for merchants
    retry: false, // Don't retry on subscription expired errors
  });

  // Handle subscription errors
  useEffect(() => {
    if (subscriptionError) {
      const error = subscriptionError as any;
      if (
        error.response?.status === 403 &&
        error.response?.data?.error === 'Trial subscription has expired'
      ) {
        setSubscriptionExpired(true);
        setExpiredDetails(error.response.data.details);
      }
    }
  }, [subscriptionError]);

  // Listen for subscription expired events from API interceptor
  useEffect(() => {
    const handleSubscriptionExpired = (event: any) => {
      setSubscriptionExpired(true);
      setExpiredDetails(event.detail);
    };

    window.addEventListener('subscription-expired', handleSubscriptionExpired);

    // Check localStorage
    const isExpired = localStorage.getItem('subscription_expired') === 'true';
    if (isExpired) {
      setSubscriptionExpired(true);
    }

    return () => {
      window.removeEventListener('subscription-expired', handleSubscriptionExpired);
    };
  }, []);

  // Update state based on subscription status
  useEffect(() => {
    if (subscriptionStatus && !subscriptionStatus.isActive) {
      setSubscriptionExpired(true);
      setExpiredDetails({
        status: subscriptionStatus.status,
        trialEndDate: subscriptionStatus.trialEndDate,
      });
    } else if (subscriptionStatus?.isActive) {
      setSubscriptionExpired(false);
      setDismissed(false);
      localStorage.removeItem('subscription_expired');
    }
  }, [subscriptionStatus]);

  // Don't show for platform owners or if dismissed
  if (isPlatformOwner || dismissed || !subscriptionExpired) {
    return null;
  }

  return (
    <Card className="border-red-200 bg-red-50 mb-4 sticky top-0 z-10 shadow-lg">
      <CardHeader className="pb-3">
        <div className="flex items-start justify-between">
          <div className="flex items-start gap-3 flex-1">
            <XCircle className="h-5 w-5 text-red-600 mt-0.5 flex-shrink-0" />
            <div className="flex-1">
              <CardTitle className="text-red-800 mb-1">
                Trial Subscription Expired
              </CardTitle>
              <CardDescription className="text-red-700">
                Your trial subscription has expired. Please contact the platform owner to extend your trial or activate your subscription.
              </CardDescription>
            </div>
          </div>
          <Button
            variant="ghost"
            size="icon"
            className="h-6 w-6 text-red-600 hover:text-red-800 hover:bg-red-100"
            onClick={() => setDismissed(true)}
          >
            <X className="h-4 w-4" />
          </Button>
        </div>
      </CardHeader>
      {expiredDetails?.trialEndDate && (
        <CardContent className="pt-0">
          <div className="flex items-center gap-2 text-sm text-red-700">
            <AlertTriangle className="h-4 w-4" />
            <span>
              Trial ended on:{' '}
              {format(new Date(expiredDetails.trialEndDate), 'MMM d, yyyy')}
            </span>
          </div>
        </CardContent>
      )}
    </Card>
  );
}

