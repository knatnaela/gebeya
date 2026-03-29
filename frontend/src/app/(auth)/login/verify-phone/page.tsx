'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/auth-context';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { toast } from 'sonner';
import { Loader2 } from 'lucide-react';

import { GATEWAY_LOGIN_REQUEST_STORAGE_KEY } from '@/lib/gateway-login-phone';

export default function VerifyPhoneLoginPage() {
  const router = useRouter();
  const { gatewayLoginVerify } = useAuth();
  const [ready, setReady] = useState(false);
  const [requestId, setRequestId] = useState<string | null>(null);
  const [otpCode, setOtpCode] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    const params = new URLSearchParams(window.location.search);
    const fromUrl = params.get('rid')?.trim();
    const fromStorage = sessionStorage.getItem(GATEWAY_LOGIN_REQUEST_STORAGE_KEY)?.trim();
    const id = fromUrl || fromStorage || null;
    if (fromUrl) {
      sessionStorage.setItem(GATEWAY_LOGIN_REQUEST_STORAGE_KEY, fromUrl);
    }
    setRequestId(id);
    setReady(true);
  }, []);

  const goBackToLogin = () => {
    sessionStorage.removeItem(GATEWAY_LOGIN_REQUEST_STORAGE_KEY);
    router.push('/login');
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const id = requestId;
    if (!id) {
      toast.error('Your sign-in session expired. Start again from sign in.');
      return;
    }
    const code = otpCode.trim();
    if (code.length < 4) {
      toast.error('Enter the code from Telegram');
      return;
    }
    setLoading(true);
    try {
      await gatewayLoginVerify(id, code);
      sessionStorage.removeItem(GATEWAY_LOGIN_REQUEST_STORAGE_KEY);
      toast.success('Logged in successfully!');
    } catch (error: any) {
      toast.error(error.message || 'Verification failed');
    } finally {
      setLoading(false);
    }
  };

  if (!ready) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 via-blue-50 to-indigo-50 p-4">
        <Loader2 className="h-8 w-8 animate-spin text-purple-600" />
      </div>
    );
  }

  if (!requestId) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 via-blue-50 to-indigo-50 p-4">
        <Card className="w-full max-w-md shadow-xl border-0">
          <CardHeader>
            <CardTitle className="text-2xl font-bold text-center">Verification</CardTitle>
            <CardDescription className="text-center">
              No active phone sign-in session. Send a code from the sign-in page first.
            </CardDescription>
          </CardHeader>
          <CardContent className="text-center">
            <Button asChild className="w-full">
              <Link href="/login">Back to sign in</Link>
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 via-blue-50 to-indigo-50 p-4">
      <Card className="w-full max-w-md shadow-xl border-0">
        <CardHeader className="space-y-1 pb-6">
          <div className="flex justify-center mb-4">
            <div className="h-16 w-16 rounded-full bg-gradient-to-br from-purple-600 to-blue-600 flex items-center justify-center">
              <span className="text-2xl font-bold text-white">G</span>
            </div>
          </div>
          <CardTitle className="text-2xl font-bold text-center bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
            Enter verification code
          </CardTitle>
          <CardDescription className="text-center text-base">
            Open Telegram and enter the code we sent for this number.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="otp">Code from Telegram</Label>
              <Input
                id="otp"
                inputMode="numeric"
                autoComplete="one-time-code"
                placeholder="Enter the code"
                value={otpCode}
                onChange={(e) => setOtpCode(e.target.value)}
                disabled={loading}
                autoFocus
              />
            </div>
            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Verifying…
                </>
              ) : (
                'Continue'
              )}
            </Button>
          </form>
          <div className="mt-6 flex flex-col gap-2 text-center text-sm">
            <button
              type="button"
              className="text-purple-600 hover:text-purple-700 font-medium"
              onClick={goBackToLogin}
            >
              Use a different number
            </button>
            <Link href="/login" className="text-muted-foreground hover:text-foreground">
              Back to sign in
            </Link>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
