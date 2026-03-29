'use client';

import { useState, useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useMutation, useQuery } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { getDefaultPhoneCountryIso } from '@/lib/auth-region';
import type { Country } from 'react-phone-number-input';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { toast } from 'sonner';
import Link from 'next/link';
import { MerchantPhoneInput } from '@/components/merchant-phone-input';
import { splitE164ForApi } from '@/lib/phone';

export default function RegisterPage() {
  const router = useRouter();
  const [phoneE164, setPhoneE164] = useState<string | undefined>(undefined);

  const { data: publicConfig } = useQuery({
    queryKey: ['auth-public-config'],
    queryFn: async () => {
      const res = await apiClient.get('/auth/public-config');
      return res.data.data as { phoneFirstCountryIsoCodes: string[] };
    },
    staleTime: 5 * 60 * 1000,
  });

  const defaultCountry = useMemo(() => {
    const iso = getDefaultPhoneCountryIso(publicConfig?.phoneFirstCountryIsoCodes ?? []);
    return (iso ?? 'ET') as Country;
  }, [publicConfig?.phoneFirstCountryIsoCodes]);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    address: '',
    firstName: '',
    lastName: '',
    password: '',
    confirmPassword: '',
  });

  const registerMutation = useMutation({
    mutationFn: async (vars: {
      name: string;
      email: string;
      address?: string;
      firstName: string;
      lastName?: string;
      password: string;
      phoneCountryIso?: string;
      phoneNationalNumber?: string;
      phone?: string;
    }) => {
      const res = await apiClient.post('/merchants/register', vars);
      return res.data;
    },
    onSuccess: () => {
      toast.success('Registration submitted successfully! Awaiting platform owner approval.');
      router.push('/login');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to register merchant');
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    // Validation
    if (!formData.name || !formData.email || !formData.firstName || !formData.password) {
      toast.error('Please fill in all required fields');
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      toast.error('Passwords do not match');
      return;
    }

    if (formData.password.length < 6) {
      toast.error('Password must be at least 6 characters');
      return;
    }

    const phoneParts = splitE164ForApi(phoneE164);
    registerMutation.mutate({
      name: formData.name,
      email: formData.email,
      address: formData.address || undefined,
      firstName: formData.firstName,
      lastName: formData.lastName || undefined,
      password: formData.password,
      ...(phoneParts
        ? {
            phoneCountryIso: phoneParts.phoneCountryIso,
            phoneNationalNumber: phoneParts.phoneNationalNumber,
            phone: phoneParts.phone,
          }
        : {}),
    });
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 to-blue-50 p-4">
      <Card className="w-full max-w-2xl">
        <CardHeader className="space-y-1">
          <CardTitle className="text-2xl font-bold text-center">Merchant Registration</CardTitle>
          <CardDescription className="text-center">
            Register your business to start using the platform. Your registration will be reviewed by the platform owner.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid gap-4 md:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="name">
                  Business Name <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="name"
                  name="name"
                  type="text"
                  placeholder="Your business name"
                  value={formData.name}
                  onChange={handleChange}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="email">
                  Email <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="email"
                  name="email"
                  type="email"
                  placeholder="business@example.com"
                  value={formData.email}
                  onChange={handleChange}
                  required
                />
              </div>

              <div className="space-y-2 md:col-span-2">
                <Label htmlFor="phone">Phone</Label>
                <MerchantPhoneInput
                  id="phone"
                  value={phoneE164}
                  onChange={setPhoneE164}
                  defaultCountry={defaultCountry}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="address">Address</Label>
                <Input
                  id="address"
                  name="address"
                  type="text"
                  placeholder="Business address"
                  value={formData.address}
                  onChange={handleChange}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="firstName">
                  First Name <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="firstName"
                  name="firstName"
                  type="text"
                  placeholder="Your first name"
                  value={formData.firstName}
                  onChange={handleChange}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="lastName">Last Name</Label>
                <Input
                  id="lastName"
                  name="lastName"
                  type="text"
                  placeholder="Your last name"
                  value={formData.lastName}
                  onChange={handleChange}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="password">
                  Password <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="password"
                  name="password"
                  type="password"
                  placeholder="At least 6 characters"
                  value={formData.password}
                  onChange={handleChange}
                  required
                  minLength={6}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="confirmPassword">
                  Confirm Password <span className="text-red-500">*</span>
                </Label>
                <Input
                  id="confirmPassword"
                  name="confirmPassword"
                  type="password"
                  placeholder="Confirm your password"
                  value={formData.confirmPassword}
                  onChange={handleChange}
                  required
                  minLength={6}
                />
              </div>
            </div>

            <div className="flex items-center justify-between pt-4">
              <Link href="/login" className="text-sm text-muted-foreground hover:text-primary">
                Already have an account? Sign in
              </Link>
              <Button type="submit" disabled={registerMutation.isPending}>
                {registerMutation.isPending ? 'Submitting...' : 'Register'}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}

