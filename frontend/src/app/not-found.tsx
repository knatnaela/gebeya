'use client';

import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { FileQuestion, ArrowLeft } from 'lucide-react';

export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 to-blue-50 p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <div className="flex justify-center mb-4">
            <div className="h-16 w-16 rounded-full bg-purple-100 flex items-center justify-center">
              <FileQuestion className="h-8 w-8 text-purple-600" />
            </div>
          </div>
          <CardTitle className="text-2xl">404 - Page Not Found</CardTitle>
          <CardDescription>
            The page you're looking for doesn't exist
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-center text-muted-foreground">
            The page may have been moved or deleted.
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

