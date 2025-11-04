'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Skeleton } from '@/components/ui/skeleton';
import { Settings, Database } from 'lucide-react';
import { toast } from 'sonner';
import { usePermissions } from '@/contexts/permissions-context';
import { useState } from 'react';

export default function FeaturesPage() {
  const queryClient = useQueryClient();
  const { canAccess } = usePermissions();
  const [roleType, setRoleType] = useState<'PLATFORM_OWNER' | 'MERCHANT'>('PLATFORM_OWNER');
  const [categoryFilter, setCategoryFilter] = useState<string>('all');

  const { data: features, isLoading } = useQuery({
    queryKey: ['features', roleType, categoryFilter],
    queryFn: async () => {
      const params: any = { type: roleType };
      if (categoryFilter !== 'all') {
        params.category = categoryFilter;
      }
      const res = await apiClient.get('/features', { params });
      return res.data.data || [];
    },
  });

  const seedMutation = useMutation({
    mutationFn: async () => {
      const res = await apiClient.post('/features/seed');
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['features'] });
      toast.success('Features seeded successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to seed features');
    },
  });

  // Get unique categories
  const categories = features
    ? Array.from(new Set(features.map((f: any) => f.category))).sort()
    : [];

  if (!canAccess('features.view')) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Features</h1>
          <p className="text-muted-foreground">You do not have permission to view this page</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">System Features</h1>
          <p className="text-muted-foreground">Manage system features and permissions</p>
        </div>
        <div className="flex items-center gap-2">
          <Select value={roleType} onValueChange={(value: any) => setRoleType(value)}>
            <SelectTrigger className="w-[200px]">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="PLATFORM_OWNER">Platform Owner Features</SelectItem>
              <SelectItem value="MERCHANT">Merchant Features</SelectItem>
            </SelectContent>
          </Select>
          <Select value={categoryFilter} onValueChange={setCategoryFilter}>
            <SelectTrigger className="w-[180px]">
              <SelectValue placeholder="Filter by category" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Categories</SelectItem>
              {categories.map((category) => (
                <SelectItem key={String(category)} value={String(category)}>
                  {String(category)}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          {canAccess('features.create') && (
            <Button
              onClick={() => seedMutation.mutate()}
              disabled={seedMutation.isPending}
              variant="outline"
            >
              <Database className="h-4 w-4 mr-2" />
              {seedMutation.isPending ? 'Seeding...' : 'Seed Features'}
            </Button>
          )}
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>{roleType === 'PLATFORM_OWNER' ? 'Platform Owner' : 'Merchant'} Features</CardTitle>
          <CardDescription>All available system features</CardDescription>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <Skeleton key={i} className="h-16 w-full" />
              ))}
            </div>
          ) : features && features.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Feature Name</TableHead>
                  <TableHead>Slug</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Level</TableHead>
                  <TableHead>Default Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {features.map((feature: any) => (
                  <TableRow key={feature.id}>
                    <TableCell>
                      <div>
                        <div className="font-medium">{feature.name}</div>
                        {feature.description && (
                          <div className="text-sm text-muted-foreground">{feature.description}</div>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <code className="text-xs bg-muted px-2 py-1 rounded">{feature.slug}</code>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">{feature.category}</Badge>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">{feature.type}</Badge>
                    </TableCell>
                    <TableCell>
                      {feature.isPageLevel ? (
                        <Badge>Page-Level</Badge>
                      ) : (
                        <Badge variant="secondary">Action-Level</Badge>
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="flex flex-wrap gap-1">
                        {feature.defaultActions && Array.isArray(feature.defaultActions) && feature.defaultActions.length > 0 ? (
                          feature.defaultActions.map((action: string) => (
                            <Badge key={action} variant="outline" className="text-xs">
                              {action}
                            </Badge>
                          ))
                        ) : (
                          <span className="text-muted-foreground text-sm">N/A</span>
                        )}
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <div className="text-center py-12">
              <Settings className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No features found</p>
              {canAccess('features.create') && (
                <Button
                  onClick={() => seedMutation.mutate()}
                  disabled={seedMutation.isPending}
                  className="mt-4"
                  variant="outline"
                >
                  <Database className="h-4 w-4 mr-2" />
                  Seed Features
                </Button>
              )}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

