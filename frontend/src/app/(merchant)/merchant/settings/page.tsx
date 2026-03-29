'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { useAuth } from '@/contexts/auth-context';
import { Settings, KeyRound } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';
import apiClient from '@/lib/api';
import { Loader2 } from 'lucide-react';

export default function MerchantSettingsPage() {
  const { user, refreshUser } = useAuth();
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (user) {
      setFirstName(user.firstName ?? '');
      setLastName(user.lastName ?? '');
    }
  }, [user]);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!firstName.trim()) {
      toast.error('First name is required');
      return;
    }
    setSaving(true);
    try {
      await apiClient.patch('/users/me', {
        firstName: firstName.trim(),
        lastName: lastName.trim() || undefined,
      });
      toast.success('Profile updated');
      await refreshUser();
    } catch (error: any) {
      toast.error(error.response?.data?.error || 'Failed to update profile');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold sm:text-3xl">Settings</h1>
        <p className="text-muted-foreground">Merchant account and preferences</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Settings className="h-5 w-5" />
            Account
          </CardTitle>
          <CardDescription>Signed-in user for this merchant workspace</CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <form onSubmit={handleSave} className="space-y-4 max-w-md">
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input id="email" type="email" value={user?.email ?? ''} disabled readOnly />
              <p className="text-xs text-muted-foreground">Email cannot be changed here.</p>
            </div>
            <div className="space-y-2">
              <Label htmlFor="firstName">First name</Label>
              <Input
                id="firstName"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
                required
                disabled={saving}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="lastName">Last name</Label>
              <Input
                id="lastName"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
                disabled={saving}
              />
            </div>
            <Button type="submit" disabled={saving}>
              {saving ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Saving…
                </>
              ) : (
                'Save name'
              )}
            </Button>
          </form>

          <div className="border-t pt-6">
            <p className="text-sm font-medium mb-2">Password</p>
            <p className="text-sm text-muted-foreground mb-3">
              Change your password while staying signed in on other devices until you sign out.
            </p>
            <Button variant="outline" asChild>
              <Link href="/change-password" className="inline-flex items-center gap-2">
                <KeyRound className="h-4 w-4" />
                Change password
              </Link>
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
