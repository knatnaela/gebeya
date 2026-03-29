'use client';

import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import {
  ProductForm,
  type ProductFormData,
  apiProductToFormValues,
} from '@/components/products/product-form';
import { ArrowLeft, Package, Save } from 'lucide-react';
import { toast } from 'sonner';

export default function EditProductPage() {
  const params = useParams();
  const id = params.id as string;
  const router = useRouter();
  const queryClient = useQueryClient();

  const { data: product, isLoading, error } = useQuery({
    queryKey: ['product', id],
    queryFn: async () => {
      const res = await apiClient.get(`/products/${id}`);
      return res.data.data;
    },
  });

  const mutation = useMutation({
    mutationFn: async (data: ProductFormData) => {
      const res = await apiClient.put(`/products/${id}`, data);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      queryClient.invalidateQueries({ queryKey: ['product', id] });
      toast.success('Product updated successfully');
      router.push('/merchant/products');
    },
    onError: (err: any) => {
      toast.error(err.response?.data?.error || 'Failed to update product');
    },
  });

  if (isLoading) {
    return (
      <div className="space-y-6" role="status" aria-live="polite" aria-busy="true">
        <span className="sr-only">Loading product</span>
        <div className="flex items-center gap-4">
          <Skeleton className="h-10 w-24" />
          <div className="space-y-2">
            <Skeleton className="h-9 w-48" />
            <Skeleton className="h-4 w-72" />
          </div>
        </div>
        <Skeleton className="h-[28rem] w-full max-w-4xl rounded-lg" />
      </div>
    );
  }

  if (error || !product) {
    return (
      <div className="space-y-4">
        <p className="text-destructive">Product not found or could not be loaded.</p>
        <Button asChild variant="outline">
          <Link href="/merchant/products">Back to products</Link>
        </Button>
      </div>
    );
  }

  const initialValues = apiProductToFormValues(product);

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
          <h1 className="text-3xl font-bold">Edit Product</h1>
          <p className="text-muted-foreground">Update {product.name}</p>
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
              <CardDescription>Changes apply to your catalog and new sales</CardDescription>
            </CardHeader>
            <CardContent>
              <ProductForm
                key={product.id}
                mode="edit"
                formId="product-form"
                hideFooterActions
                initialValues={initialValues}
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
              <CardDescription>Updates are saved to your catalog</CardDescription>
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
                {mutation.isPending ? 'Saving…' : 'Save changes'}
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
