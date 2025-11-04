import { MainLayout } from '@/components/layout/main-layout';
import { ProtectedRoute } from '@/components/auth/protected-route';

export default function MerchantLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ProtectedRoute allowedRoles={['MERCHANT_ADMIN', 'MERCHANT_STAFF', 'PLATFORM_OWNER']}>
      <MainLayout>{children}</MainLayout>
    </ProtectedRoute>
  );
}

