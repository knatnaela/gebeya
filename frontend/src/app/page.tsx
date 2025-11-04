'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/auth-context';

export default function Home() {
  const router = useRouter();
  const { isAuthenticated, user, loading } = useAuth();

  useEffect(() => {
    if (!loading) {
      if (isAuthenticated) {
        // Redirect to appropriate dashboard
        if (user?.role === 'PLATFORM_OWNER') {
          router.push('/company');
        } else {
          router.push('/merchant');
        }
      } else {
        router.push('/login');
      }
    }
  }, [isAuthenticated, user, loading, router]);

  return null;
}
