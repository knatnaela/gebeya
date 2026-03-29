'use client';

import { useState, useMemo, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import { useAuth } from '@/contexts/auth-context';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { toast } from 'sonner';
import { Loader2 } from 'lucide-react';
import Link from 'next/link';
import apiClient from '@/lib/api';
import { MerchantPhoneInput } from '@/components/merchant-phone-input';
import { splitE164ForApi } from '@/lib/phone';
import { getDefaultLoginMode, getDefaultPhoneCountryIso } from '@/lib/auth-region';
import {
  GATEWAY_LOGIN_REQUEST_STORAGE_KEY,
  parseGatewayStartRequestId,
} from '@/lib/gateway-login-phone';
import type { Country } from 'react-phone-number-input';

type MainTab = 'email' | 'phone';

export default function LoginPage() {
  const router = useRouter();
  const [mainTab, setMainTab] = useState<MainTab>('email');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [phoneE164, setPhoneE164] = useState<string | undefined>(undefined);
  const [loading, setLoading] = useState(false);
  const [sendingCode, setSendingCode] = useState(false);
  const [tabInitialized, setTabInitialized] = useState(false);
  const { login } = useAuth();

  const { data: publicConfig } = useQuery({
    queryKey: ['auth-public-config'],
    queryFn: async () => {
      const res = await apiClient.get('/auth/public-config');
      return res.data.data as { phoneFirstCountryIsoCodes: string[] };
    },
    staleTime: 5 * 60 * 1000,
  });

  const phoneFirstList = publicConfig?.phoneFirstCountryIsoCodes ?? [];

  const defaultCountry = useMemo(() => {
    const iso = getDefaultPhoneCountryIso(phoneFirstList);
    return (iso ?? 'ET') as Country;
  }, [phoneFirstList]);

  useEffect(() => {
    if (tabInitialized || !publicConfig) return;
    setMainTab(getDefaultLoginMode(phoneFirstList));
    setTabInitialized(true);
  }, [publicConfig, phoneFirstList, tabInitialized]);

  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await login({ email: email.trim(), password });
      toast.success('Logged in successfully!');
    } catch (error: any) {
      toast.error(error.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  const handleSendTelegramCode = async () => {
    const parts = splitE164ForApi(phoneE164);
    if (!parts) {
      toast.error('Enter a valid phone number');
      return;
    }
    setSendingCode(true);
    try {
      const res = await apiClient.post('/auth/login/gateway/start', {
        phoneCountryIso: parts.phoneCountryIso,
        phoneNationalNumber: parts.phoneNationalNumber,
      });
      const requestId = parseGatewayStartRequestId(res.data.data);
      if (requestId) {
        sessionStorage.setItem(GATEWAY_LOGIN_REQUEST_STORAGE_KEY, requestId);
        toast.success('Check Telegram for your verification code.');
        router.push(`/login/verify-phone?rid=${encodeURIComponent(requestId)}`);
      } else {
        toast.message('If an account exists for this number, a verification code was sent.');
      }
    } catch (error: any) {
      toast.error(error.response?.data?.error || 'Could not send code');
    } finally {
      setSendingCode(false);
    }
  };

  const switchTab = (tab: MainTab) => {
    setMainTab(tab);
    if (tab === 'email') {
      sessionStorage.removeItem(GATEWAY_LOGIN_REQUEST_STORAGE_KEY);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 via-blue-50 to-indigo-50 p-4">
      <Card className="w-full max-w-md shadow-xl border-0">
        <CardHeader className="space-y-1 pb-6">
          <div className="flex justify-center mb-4">
            <div className="h-16 w-16 rounded-full bg-gradient-to-br from-purple-600 to-blue-600 flex items-center justify-center">
              <span className="text-2xl font-bold text-white">G</span>
            </div>
          </div>
          <CardTitle className="text-3xl font-bold text-center bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
            Welcome to Gebeya
          </CardTitle>
          <CardDescription className="text-center text-base">
            {mainTab === 'email'
              ? 'Sign in with your email and password.'
              : 'We’ll send a sign-in code to Telegram for this number.'}
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex rounded-lg border p-1 bg-muted/40">
            <button
              type="button"
              className={`flex-1 rounded-md py-2 text-sm font-medium transition-colors ${
                mainTab === 'email' ? 'bg-background shadow text-foreground' : 'text-muted-foreground'
              }`}
              onClick={() => switchTab('email')}
            >
              Email
            </button>
            <button
              type="button"
              className={`flex-1 rounded-md py-2 text-sm font-medium transition-colors ${
                mainTab === 'phone' ? 'bg-background shadow text-foreground' : 'text-muted-foreground'
              }`}
              onClick={() => switchTab('phone')}
            >
              Phone
            </button>
          </div>

          {mainTab === 'email' ? (
            <form onSubmit={handleEmailSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input
                  id="email"
                  type="email"
                  placeholder="name@example.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  disabled={loading}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="password">Password</Label>
                <Input
                  id="password"
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  disabled={loading}
                />
              </div>
              <Button type="submit" className="w-full" disabled={loading}>
                {loading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Signing in...
                  </>
                ) : (
                  'Sign In'
                )}
              </Button>
            </form>
          ) : (
            <div className="space-y-4">
              <p className="text-sm text-muted-foreground">
                Use the same number as on your merchant account. We’ll send a code to Telegram — no password needed. You’ll
                enter the code on the next screen.
              </p>
              <div className="space-y-2">
                <Label htmlFor="phone">Phone number</Label>
                <MerchantPhoneInput
                  id="phone"
                  value={phoneE164}
                  onChange={setPhoneE164}
                  disabled={sendingCode}
                  defaultCountry={defaultCountry}
                />
              </div>
              <Button
                type="button"
                variant="secondary"
                className="w-full"
                disabled={sendingCode}
                onClick={handleSendTelegramCode}
              >
                {sendingCode ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Sending...
                  </>
                ) : (
                  'Send code'
                )}
              </Button>
            </div>
          )}

          {mainTab === 'email' && (
            <div className="text-center">
              <Link
                href="/forgot-password"
                className="text-sm text-purple-600 hover:text-purple-700 font-medium"
              >
                Forgot password?
              </Link>
            </div>
          )}

          <div className="mt-6">
            <div className="text-center">
              <p className="text-sm text-muted-foreground">
                Don&apos;t have an account?{' '}
                <Link href="/register" className="text-purple-600 hover:text-purple-700 font-medium">
                  Register as Merchant
                </Link>
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
