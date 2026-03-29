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
import { ArrowLeft, Package, Save, Check, ChevronsUpDown } from 'lucide-react';
import { toast } from 'sonner';

const addStockSchema = z.object({
  productId: z.string().min(1, 'Product is required'),
  locationId: z.string().optional(),
  quantity: z.number().int().positive('Quantity must be positive'),
  batchNumber: z.string().optional(),
  expirationDate: z.string().optional(),
  receivedDate: z.string().optional(),
  notes: z.string().optional(),
  paymentStatus: z.enum(['PAID', 'CREDIT', 'PARTIAL']).optional(),
  supplierName: z.string().optional(),
  supplierContact: z.string().optional(),
  totalCost: z.number().nonnegative().optional(),
  paidAmount: z.number().nonnegative().optional(),
  paymentDueDate: z.string().optional(),
});

type AddStockFormData = z.infer<typeof addStockSchema>;

const PRODUCT_PICKER_PAGE = 30;

function AddStockFormInner() {
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
    queryKey: ['products', 'add-stock-picker', debouncedProductSearch],
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
  } = useForm<AddStockFormData>({
    resolver: zodResolver(addStockSchema),
    defaultValues: {
      productId: prefillProductId || '',
      receivedDate: new Date().toISOString().split('T')[0],
      paymentStatus: 'PAID',
    },
  });

  const productId = watch('productId');
  const paymentStatus = watch('paymentStatus');

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

  const addStockMutation = useMutation({
    mutationFn: async (data: AddStockFormData) => {
      const payload: any = {
        productId: data.productId,
        quantity: data.quantity,
      };
      if (data.locationId) payload.locationId = data.locationId;
      if (data.batchNumber) payload.batchNumber = data.batchNumber;
      if (data.expirationDate) payload.expirationDate = new Date(data.expirationDate).toISOString();
      if (data.receivedDate) payload.receivedDate = new Date(data.receivedDate).toISOString();
      if (data.notes) payload.notes = data.notes;
      if (data.paymentStatus) payload.paymentStatus = data.paymentStatus;
      if (data.supplierName) payload.supplierName = data.supplierName;
      if (data.supplierContact) payload.supplierContact = data.supplierContact;
      if (data.totalCost !== undefined) payload.totalCost = data.totalCost;
      if (data.paidAmount !== undefined) payload.paidAmount = data.paidAmount;
      if (data.paymentDueDate) payload.paymentDueDate = new Date(data.paymentDueDate).toISOString();

      const res = await apiClient.post('/inventory/stock', payload);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['inventory-entries'] });
      queryClient.invalidateQueries({ queryKey: ['inventory-transactions'] });
      queryClient.invalidateQueries({ queryKey: ['inventory-summary'] });
      queryClient.invalidateQueries({ queryKey: ['products'] });
      queryClient.invalidateQueries({ queryKey: ['products-stock'] });
      toast.success('Stock added successfully');
      router.push('/merchant/inventory/stock');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to add stock');
    },
  });

  const defaultLocation = locations?.find((loc: any) => loc.isDefault);
  const locationIdValue = watch('locationId') || defaultLocation?.id || '';

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button variant="ghost" type="button" onClick={() => router.back()}>
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back
          </Button>
          <div>
            <h1 className="text-3xl font-bold">Add Stock</h1>
            <p className="text-muted-foreground">Record a new inventory entry for a product</p>
          </div>
        </div>
      </div>

      <form onSubmit={handleSubmit((data) => addStockMutation.mutate(data))}>
        <div className="grid gap-6 lg:grid-cols-3">
          <div className="space-y-6 lg:col-span-2">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Package className="h-5 w-5" />
                  Product & quantity
                </CardTitle>
                <CardDescription>Choose what you received and how much</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <Label htmlFor="product">Product *</Label>
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
                        id="product"
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

                <div>
                  <Label htmlFor="location">Location</Label>
                  <Select
                    value={locationIdValue}
                    onValueChange={(value) => setValue('locationId', value)}
                  >
                    <SelectTrigger id="location" className="mt-1">
                      <SelectValue placeholder="Select location (defaults to default location)" />
                    </SelectTrigger>
                    <SelectContent>
                      {locations?.map((loc: any) => (
                        <SelectItem key={loc.id} value={loc.id}>
                          {loc.name} {loc.isDefault && '(Default)'}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label htmlFor="quantity">Quantity *</Label>
                  <Input
                    id="quantity"
                    type="number"
                    className="mt-1 max-w-xs"
                    {...register('quantity', { valueAsNumber: true })}
                    placeholder="Enter quantity"
                  />
                  {errors.quantity && (
                    <p className="text-sm text-red-500 mt-1">{errors.quantity.message}</p>
                  )}
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Batch & dates</CardTitle>
                <CardDescription>Optional tracking details</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <Label htmlFor="batch-number">Batch number (optional)</Label>
                  <Input
                    id="batch-number"
                    className="mt-1"
                    {...register('batchNumber')}
                    placeholder="e.g. BATCH-2024-001"
                  />
                </div>
                <div className="grid gap-4 sm:grid-cols-2">
                  <div>
                    <Label htmlFor="expiration-date">Expiration date (optional)</Label>
                    <Input
                      id="expiration-date"
                      type="date"
                      className="mt-1"
                      {...register('expirationDate')}
                    />
                  </div>
                  <div>
                    <Label htmlFor="received-date">Received date *</Label>
                    <Input
                      id="received-date"
                      type="date"
                      className="mt-1"
                      {...register('receivedDate')}
                      required
                    />
                  </div>
                </div>
                <div>
                  <Label htmlFor="notes">Notes (optional)</Label>
                  <Input
                    id="notes"
                    className="mt-1"
                    {...register('notes')}
                    placeholder="Additional notes about this stock entry"
                  />
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Payment information</CardTitle>
                <CardDescription>Track whether this stock was paid for or bought on credit</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <Label htmlFor="payment-status">Payment status</Label>
                  <Select
                    value={paymentStatus || 'PAID'}
                    onValueChange={(value) =>
                      setValue('paymentStatus', value as 'PAID' | 'CREDIT' | 'PARTIAL')
                    }
                  >
                    <SelectTrigger id="payment-status" className="mt-1">
                      <SelectValue placeholder="Select payment status" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="PAID">Paid</SelectItem>
                      <SelectItem value="CREDIT">Credit (unpaid)</SelectItem>
                      <SelectItem value="PARTIAL">Partial payment</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="grid gap-4 sm:grid-cols-2">
                  <div>
                    <Label htmlFor="supplier-name">Supplier name (optional)</Label>
                    <Input
                      id="supplier-name"
                      className="mt-1"
                      {...register('supplierName')}
                      placeholder="Supplier name"
                    />
                  </div>
                  <div>
                    <Label htmlFor="supplier-contact">Supplier contact (optional)</Label>
                    <Input
                      id="supplier-contact"
                      className="mt-1"
                      {...register('supplierContact')}
                      placeholder="Phone or email"
                    />
                  </div>
                </div>

                <div>
                  <Label htmlFor="total-cost">Total cost (optional)</Label>
                  <Input
                    id="total-cost"
                    type="number"
                    step="0.01"
                    className="mt-1 max-w-xs"
                    {...register('totalCost', { valueAsNumber: true })}
                    placeholder="0.00"
                  />
                </div>

                {paymentStatus === 'PARTIAL' && (
                  <div>
                    <Label htmlFor="paid-amount">Paid amount</Label>
                    <Input
                      id="paid-amount"
                      type="number"
                      step="0.01"
                      className="mt-1 max-w-xs"
                      {...register('paidAmount', { valueAsNumber: true })}
                      placeholder="0.00"
                    />
                  </div>
                )}

                {(paymentStatus === 'CREDIT' || paymentStatus === 'PARTIAL') && (
                  <div>
                    <Label htmlFor="payment-due-date">Payment due date (optional)</Label>
                    <Input
                      id="payment-due-date"
                      type="date"
                      className="mt-1 max-w-xs"
                      {...register('paymentDueDate')}
                    />
                  </div>
                )}
              </CardContent>
            </Card>
          </div>

          <div className="space-y-6">
            <Card className="sticky top-4">
              <CardHeader>
                <CardTitle>Submit entry</CardTitle>
                <CardDescription>Stock will appear in your inventory entries</CardDescription>
              </CardHeader>
              <CardContent className="space-y-3">
                <Button
                  type="submit"
                  className="w-full"
                  size="lg"
                  disabled={addStockMutation.isPending}
                >
                  <Save className="mr-2 h-4 w-4" />
                  {addStockMutation.isPending ? 'Adding…' : 'Add stock'}
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  className="w-full"
                  onClick={() => router.push('/merchant/inventory/stock')}
                  disabled={addStockMutation.isPending}
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

export default function AddStockPage() {
  return (
    <Suspense
      fallback={
        <div className="flex min-h-[40vh] items-center justify-center text-muted-foreground">
          Loading…
        </div>
      }
    >
      <AddStockFormInner />
    </Suspense>
  );
}
