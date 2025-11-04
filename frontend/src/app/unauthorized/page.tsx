'use client';

import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { ShieldAlert, ArrowLeft } from 'lucide-react';

export default function UnauthorizedPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 to-blue-50 p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <div className="flex justify-center mb-4">
            <div className="h-16 w-16 rounded-full bg-orange-100 flex items-center justify-center">
              <ShieldAlert className="h-8 w-8 text-orange-600" />
            </div>
          </div>
          <CardTitle className="text-2xl">Access Denied</CardTitle>
          <CardDescription>
            You don't have permission to access this page
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-center text-muted-foreground">
            Please contact your administrator if you believe this is an error.
          </p>
          <Link href="/">
            <Button className="w-full">
              <ArrowLeft className="mr-2 h-4 w-4" />
              Go Back Home
            </Button>
          </Link>
        </CardContent>
      </Card>
    </div>
  );
}

