'use client';

import { Suspense, useEffect, useMemo, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { useQuery, useMutation, useQueryClient, useInfiniteQuery } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import apiClient from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from '@/components/ui/command';
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover';
import { cn } from '@/lib/utils';
import { useDebounce } from '@/hooks/use-debounce';
import { formatCurrency } from '@/lib/currency';
import { useMerchantCurrency } from '@/hooks/use-merchant-currency';
import { ArrowLeft, ArrowRightLeft, Check, ChevronsUpDown } from 'lucide-react';
import { toast } from 'sonner';

const transferStockSchema = z
  .object({
    productId: z.string().min(1, 'Product is required'),
    fromLocationId: z.string().min(1, 'Source location is required'),
    toLocationId: z.string().min(1, 'Destination location is required'),
    quantity: z.number().int().positive('Quantity must be positive'),
    notes: z.string().optional(),
  })
  .refine((data) => data.fromLocationId !== data.toLocationId, {
    message: 'Choose a different destination than the source',
    path: ['toLocationId'],
  });

type TransferStockFormData = z.infer<typeof transferStockSchema>;

const PRODUCT_PICKER_PAGE = 30;

function TransferStockFormInner() {
  const currency = useMerchantCurrency();
  const router = useRouter();
  const searchParams = useSearchParams();
  const prefillProductId = searchParams.get('productId')?.trim() || '';

  const [productComboboxOpen, setProductComboboxOpen] = useState(false);
  const [productSearch, setProductSearch] = useState('');
  const debouncedProductSearch = useDebounce(productSearch, 400);
  const [selectedProductRow, setSelectedProductRow] = useState<any | null>(null);

  const queryClient = useQueryClient();

  const { data: locations } = useQuery({
    queryKey: ['locations'],
    queryFn: async () => {
      const res = await apiClient.get('/locations');
      return res.data.data || [];
    },
  });

  const { data: prefillProduct } = useQuery({
    queryKey: ['product', prefillProductId],
    queryFn: async () => {
      const res = await apiClient.get(`/products/${prefillProductId}`);
      return res.data.data;
    },
    enabled: Boolean(prefillProductId),
  });

  const {
    data: productsPages,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading: isLoadingProducts,
  } = useInfiniteQuery({
    queryKey: ['products', 'transfer-stock-picker', debouncedProductSearch],
    queryFn: async ({ pageParam }) => {
      const res = await apiClient.get('/products', {
        params: {
          isActive: true,
          ...(debouncedProductSearch.trim() ? { search: debouncedProductSearch.trim() } : {}),
          page: pageParam,
          limit: PRODUCT_PICKER_PAGE,
        },
      });
      return {
        products: res.data.data || [],
        pagination: res.data.pagination,
      };
    },
    initialPageParam: 1,
    getNextPageParam: (lastPage) => {
      const p = lastPage.pagination;
      if (!p || p.page >= p.totalPages) return undefined;
      return p.page + 1;
    },
  });

  const products = useMemo(
    () => productsPages?.pages.flatMap((p) => p.products) ?? [],
    [productsPages]
  );

  const {
    register,
    handleSubmit,
    watch,
    setValue,
    formState: { errors },
  } = useForm<TransferStockFormData>({
    resolver: zodResolver(transferStockSchema),
    defaultValues: {
      productId: prefillProductId || '',
    },
  });

  const productId = watch('productId');

  useEffect(() => {
    if (prefillProductId) {
      setValue('productId', prefillProductId);
    }
  }, [prefillProductId, setValue]);

  useEffect(() => {
    if (prefillProduct?.id && prefillProduct.id === prefillProductId) {
      setSelectedProductRow(prefillProduct);
    }
  }, [prefillProduct, prefillProductId]);

  const selectedProductDisplay = useMemo(() => {
    if (!productId) return null;
    if (selectedProductRow?.id === productId) {
      const p = selectedProductRow;
      return `${p.name}${p.size ? ` (${p.size})` : ''} — ${formatCurrency(p.price, currency)}`;
    }
    const p = products.find((x: any) => x.id === productId);
    return p
      ? `${p.name}${p.size ? ` (${p.size})` : ''} — ${formatCurrency(p.price, currency)}`
      : prefillProduct?.id === productId
        ? `${prefillProduct.name}${prefillProduct.size ? ` (${prefillProduct.size})` : ''} — ${formatCurrency(prefillProduct.price, currency)}`
        : null;
  }, [productId, selectedProductRow, products, prefillProduct, currency]);

  const transferStockMutation = useMutation({
    mutationFn: async (data: TransferStockFormData) => {
      const payload: any = {
        productId: data.productId,
        fromLocationId: data.fromLocationId,
        toLocationId: data.toLocationId,
        quantity: data.quantity,
      };
      if (data.notes) payload.notes = data.notes;

      const res = await apiClient.post('/inventory/transfer', payload);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['inventory-entries'] });
      queryClient.invalidateQueries({ queryKey: ['inventory-summary'] });
      queryClient.invalidateQueries({ queryKey: ['inventory-transactions'] });
      queryClient.invalidateQueries({ queryKey: ['products'] });
      queryClient.invalidateQueries({ queryKey: ['products-stock'] });
      toast.success('Stock transferred successfully');
      router.push('/merchant/inventory/stock');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to transfer stock');
    },
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button variant="ghost" type="button" onClick={() => router.back()}>
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back
          </Button>
          <div>
            <h1 className="text-3xl font-bold">Transfer Stock</h1>
            <p className="text-muted-foreground">Move quantity from one location to another</p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit((data) => transferStockMutation.mutate(data))}>
        <div className="grid gap-6 lg:grid-cols-3">
          <div className="space-y-6 lg:col-span-2">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <ArrowRightLeft className="h-5 w-5" />
                  Product & locations
                </CardTitle>
                <CardDescription>What to move, from where, and to where</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <Label htmlFor="transfer-product">Product *</Label>
                  <Popover
                    open={productComboboxOpen}
                    onOpenChange={(open) => {
                      setProductComboboxOpen(open);
                      if (!open) setProductSearch('');
                    }}
                  >
                    <PopoverTrigger asChild>
                      <Button
                        type="button"
                        variant="outline"
                        role="combobox"
                        aria-expanded={productComboboxOpen}
                        className="mt-1 w-full justify-between font-normal"
                        id="transfer-product"
                      >
                        <span className="truncate text-left">
                          {selectedProductDisplay ?? 'Search or select product…'}
                        </span>
                        <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent
                      className="w-[min(420px,calc(100vw-2rem))] max-w-[calc(100vw-2rem)] p-0"
                      align="start"
                    >
                      <Command shouldFilter={false}>
                        <CommandInput
                          placeholder="Search by name, SKU, or barcode…"
                          value={productSearch}
                          onValueChange={setProductSearch}
                        />
                        <CommandList>
                          {isLoadingProducts ? (
                            <div className="py-6 text-center text-sm text-muted-foreground">
                              Loading products…
                            </div>
                          ) : (
                            <>
                              <CommandEmpty>
                                {debouncedProductSearch.trim()
                                  ? 'No products match your search.'
                                  : 'No active products yet.'}
                              </CommandEmpty>
                              <CommandGroup>
                                {products.map((product: any) => (
                                  <CommandItem
                                    key={product.id}
                                    value={product.id}
                                    onSelect={() => {
                                      setValue('productId', product.id);
                                      setSelectedProductRow(product);
                                      setProductComboboxOpen(false);
                                      setProductSearch('');
                                    }}
                                  >
                                    <Check
                                      className={cn(
                                        'mr-2 h-4 w-4 shrink-0',
                                        productId === product.id ? 'opacity-100' : 'opacity-0'
                                      )}
                                    />
                                    <span className="min-w-0 flex-1 truncate">
                                      {product.name}
                                      {product.size ? ` (${product.size})` : ''}
                                      {product.sku ? (
                                        <span className="text-muted-foreground"> · {product.sku}</span>
                                      ) : null}
                                    </span>
                                    <span className="ml-2 shrink-0 text-muted-foreground tabular-nums">
                                      {formatCurrency(product.price, currency)}
                                    </span>
                                  </CommandItem>
                                ))}
                              </CommandGroup>
                              {hasNextPage ? (
                                <div className="border-t p-2">
                                  <Button
                                    type="button"
                                    variant="ghost"
                                    size="sm"
                                    className="w-full"
                                    disabled={isFetchingNextPage}
                                    onClick={() => fetchNextPage()}
                                  >
                                    {isFetchingNextPage ? 'Loading…' : 'Load more'}
                                  </Button>
                                </div>
                              ) : null}
                            </>
                          )}
                        </CommandList>
                      </Command>
                    </PopoverContent>
                  </Popover>
                  {errors.productId && (
                    <p className="text-sm text-red-500 mt-1">{errors.productId.message}</p>
                  )}
                </div>

                <div className="grid gap-4 sm:grid-cols-2">
                  <div>
                    <Label htmlFor="from-location">From location *</Label>
                    <Select
                      value={watch('fromLocationId')}
                      onValueChange={(value) => setValue('fromLocationId', value)}
                    >
                      <SelectTrigger id="from-location" className="mt-1">
                        <SelectValue placeholder="Select source location" />
                      </SelectTrigger>
                      <SelectContent>
                        {locations?.map((loc: any) => (
                          <SelectItem key={loc.id} value={loc.id}>
                            {loc.name} {loc.isDefault && '(Default)'}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    {errors.fromLocationId && (
                      <p className="text-sm text-red-500 mt-1">{errors.fromLocationId.message}</p>
                    )}
                  </div>
                  <div>
                    <Label htmlFor="to-location">To location *</Label>
                    <Select
                      value={watch('toLocationId')}
                      onValueChange={(value) => setValue('toLocationId', value)}
                    >
                      <SelectTrigger id="to-location" className="mt-1">
                        <SelectValue placeholder="Select destination location" />
                      </SelectTrigger>
                      <SelectContent>
                        {locations?.map((loc: any) => (
                          <SelectItem key={loc.id} value={loc.id}>
                            {loc.name} {loc.isDefault && '(Default)'}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    {errors.toLocationId && (
                      <p className="text-sm text-red-500 mt-1">{errors.toLocationId.message}</p>
                    )}
                  </div>
                </div>

                <div>
                  <Label htmlFor="transfer-quantity">Quantity *</Label>
                  <Input
                    id="transfer-quantity"
                    type="number"
                    className="mt-1 max-w-xs"
                    {...register('quantity', { valueAsNumber: true })}
                    placeholder="Enter quantity"
                  />
                  {errors.quantity && (
                    <p className="text-sm text-red-500 mt-1">{errors.quantity.message}</p>
                  )}
                </div>

                <div>
                  <Label htmlFor="transfer-notes">Notes (optional)</Label>
                  <Input
                    id="transfer-notes"
                    className="mt-1"
                    {...register('notes')}
                    placeholder="e.g. shelf move, branch request"
                  />
                </div>
              </CardContent>
            </Card>
          </div>

          <div className="space-y-6">
            <Card className="sticky top-4">
              <CardHeader>
                <CardTitle>Complete transfer</CardTitle>
                <CardDescription>Inventory will update at both locations</CardDescription>
              </CardHeader>
              <CardContent className="space-y-3">
                <Button
                  type="submit"
                  className="w-full"
                  size="lg"
                  disabled={transferStockMutation.isPending}
                >
                  <ArrowRightLeft className="mr-2 h-4 w-4" />
                  {transferStockMutation.isPending ? 'Transferring…' : 'Transfer stock'}
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  className="w-full"
                  onClick={() => router.push('/merchant/inventory/stock')}
                  disabled={transferStockMutation.isPending}
                >
                  Cancel
                </Button>
              </CardContent>
            </Card>
          </div>
        </div>
      </form>
    </div>
  );
}

export default function TransferStockPage() {
  return (
    <Suspense
      fallback={
        <div className="flex min-h-[40vh] items-center justify-center text-muted-foreground">
          Loading…
        </div>
      }
    >
      <TransferStockFormInner />
    </Suspense>
  );
}
