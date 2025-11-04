'use client';

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { XCircle, AlertTriangle } from 'lucide-react';
import { format } from 'date-fns';

interface SubscriptionErrorMessageProps {
  error: any;
  title?: string;
}

export function SubscriptionErrorMessage({ error, title = 'Access Restricted' }: SubscriptionErrorMessageProps) {
  // Check if this is a subscription expired error
  const isSubscriptionExpired =
    error?.response?.status === 403 &&
    error?.response?.data?.error === 'Trial subscription has expired';

  if (!isSubscriptionExpired) {
    return null;
  }

  const details = error?.response?.data?.details;

  return (
    <Card className="border-red-200 bg-red-50">
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-red-800">
          <XCircle className="h-5 w-5" />
          {title}
        </CardTitle>
        <CardDescription className="text-red-700">
          {error?.response?.data?.error || 'Your trial subscription has expired.'}
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="space-y-2">
          <p className="text-sm text-red-700">
            {details?.message || 'Please contact the platform owner to extend your trial or activate your subscription.'}
          </p>
          {details?.trialEndDate && (
            <div className="flex items-center gap-2 text-sm text-red-700">
              <AlertTriangle className="h-4 w-4" />
              <span>
                Trial ended on:{' '}
                {format(new Date(details.trialEndDate), 'MMM d, yyyy')}
              </span>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}

