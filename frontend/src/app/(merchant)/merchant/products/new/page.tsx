'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { ProductForm, type ProductFormData } from '@/components/products/product-form';
import { ArrowLeft, Package, Save } from 'lucide-react';
import { toast } from 'sonner';

export default function NewProductPage() {
  const router = useRouter();
  const queryClient = useQueryClient();

  const mutation = useMutation({
    mutationFn: async (data: ProductFormData) => {
      const res = await apiClient.post('/products', data);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      toast.success('Product created successfully');
      router.push('/merchant/products');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to create product');
    },
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Button variant="ghost" asChild>
          <Link href="/merchant/products">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back
          </Link>
        </Button>
        <div>
          <h1 className="text-3xl font-bold">Add Product</h1>
          <p className="text-muted-foreground">Create a new product in your catalog</p>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <div className="space-y-6 lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Package className="h-5 w-5" />
                Product details
              </CardTitle>
              <CardDescription>Prices, SKU, and optional image URL</CardDescription>
            </CardHeader>
            <CardContent>
              <ProductForm
                mode="create"
                formId="product-form"
                hideFooterActions
                isSubmitting={mutation.isPending}
                onSubmit={(data) => mutation.mutate(data)}
              />
            </CardContent>
          </Card>
        </div>
        <div className="space-y-6">
          <Card className="sticky top-4">
            <CardHeader>
              <CardTitle>Save</CardTitle>
              <CardDescription>Your product will appear in the catalog</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              <Button
                type="submit"
                form="product-form"
                className="w-full"
                size="lg"
                disabled={mutation.isPending}
              >
                <Save className="mr-2 h-4 w-4" />
                {mutation.isPending ? 'Creating…' : 'Create product'}
              </Button>
              <Button variant="outline" className="w-full" asChild disabled={mutation.isPending}>
                <Link href="/merchant/products">Cancel</Link>
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
