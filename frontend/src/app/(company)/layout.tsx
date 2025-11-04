import { MainLayout } from '@/components/layout/main-layout';
import { ProtectedRoute } from '@/components/auth/protected-route';

export default function CompanyLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ProtectedRoute allowedRoles={['PLATFORM_OWNER']}>
      <MainLayout>{children}</MainLayout>
    </ProtectedRoute>
  );
}

