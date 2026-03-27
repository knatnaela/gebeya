'use client';

import { useAuth } from '@/contexts/auth-context';

/**
 * ISO 4217 for the signed-in merchant (`user.merchants.currency` from `/auth/me`).
 */
export function useMerchantCurrency(): string {
  const { user } = useAuth();
  const c = user?.merchants?.currency;
  if (typeof c === 'string' && c.trim().length > 0) {
    return c.trim().toUpperCase();
  }
  return 'ETB';
}
