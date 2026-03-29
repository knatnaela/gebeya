'use client';

import { useMemo, useState } from 'react';
import Link from 'next/link';
import { useQuery, useInfiniteQuery } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Button } from '@/components/ui/button';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
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
import { Plus, Package, ArrowRightLeft, Check, ChevronsUpDown } from 'lucide-react';
import { format } from 'date-fns';

const PRODUCT_FILTER_PAGE = 30;

export default function StockManagementPage() {
  const currency = useMerchantCurrency();
  const [productFilter, setProductFilter] = useState('');
  const [locationFilter, setLocationFilter] = useState('');
  const [productFilterPopoverOpen, setProductFilterPopoverOpen] = useState(false);
  const [productFilterSearch, setProductFilterSearch] = useState('');
  const debouncedProductFilterSearch = useDebounce(productFilterSearch, 400);
  const [selectedFilterProductRow, setSelectedFilterProductRow] = useState<any | null>(null);

  const { data: locations } = useQuery({
    queryKey: ['locations'],
    queryFn: async () => {
      const res = await apiClient.get('/locations');
      return res.data.data || [];
    },
  });

  const { data: filterProductDetail } = useQuery({
    queryKey: ['product', productFilter],
    queryFn: async () => {
      const res = await apiClient.get(`/products/${productFilter}`);
      return res.data.data;
    },
    enabled: Boolean(productFilter),
  });

  const {
    data: filterProductsPages,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading: isLoadingFilterProducts,
  } = useInfiniteQuery({
    queryKey: ['products', 'stock-entries-filter', debouncedProductFilterSearch],
    queryFn: async ({ pageParam }) => {
      const res = await apiClient.get('/products', {
        params: {
          isActive: true,
          ...(debouncedProductFilterSearch.trim()
            ? { search: debouncedProductFilterSearch.trim() }
            : {}),
          page: pageParam,
          limit: PRODUCT_FILTER_PAGE,
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
    enabled: productFilterPopoverOpen,
  });

  const filterPickerProducts = useMemo(
    () => filterProductsPages?.pages.flatMap((p) => p.products) ?? [],
    [filterProductsPages]
  );

  const productFilterTriggerLabel = useMemo(() => {
    if (!productFilter) return 'All products';
    if (selectedFilterProductRow?.id === productFilter) {
      const p = selectedFilterProductRow;
      return `${p.name}${p.size ? ` (${p.size})` : ''}`;
    }
    const p = filterPickerProducts.find((x: any) => x.id === productFilter);
    if (p) return `${p.name}${p.size ? ` (${p.size})` : ''}`;
    if (filterProductDetail?.id === productFilter) {
      return `${filterProductDetail.name}${filterProductDetail.size ? ` (${filterProductDetail.size})` : ''}`;
    }
    return 'Loading…';
  }, [
    productFilter,
    selectedFilterProductRow,
    filterPickerProducts,
    filterProductDetail,
  ]);

  const { data: inventoryEntries, isLoading } = useQuery({
    queryKey: ['inventory-entries', productFilter, locationFilter],
    queryFn: async () => {
      const params: any = {};
      if (productFilter) params.productId = productFilter;
      if (locationFilter) params.locationId = locationFilter;
      const res = await apiClient.get('/inventory/entries', { params });
      return {
        entries: res.data.data || [],
        pagination: res.data.pagination || { page: 1, limit: 20, total: 0, totalPages: 0 },
      };
    },
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Stock Management</h1>
          <p className="text-muted-foreground">Add stock, view entries, and transfer between locations</p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" asChild>
            <Link href="/merchant/inventory/stock/transfer">
              <ArrowRightLeft className="h-4 w-4 mr-2" />
              Transfer Stock
            </Link>
          </Button>
          <Button asChild>
            <Link href="/merchant/inventory/stock/add">
              <Plus className="h-4 w-4 mr-2" />
              Add Stock
            </Link>
          </Button>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Inventory Entries</CardTitle>
          <CardDescription>All stock entries (immutable records)</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex gap-4 mb-4">
            <div className="flex-1 min-w-0">
              <Label>Filter by Product</Label>
              <Popover
                open={productFilterPopoverOpen}
                onOpenChange={(open) => {
                  setProductFilterPopoverOpen(open);
                  if (!open) setProductFilterSearch('');
                }}
              >
                <PopoverTrigger asChild>
                  <Button
                    type="button"
                    variant="outline"
                    role="combobox"
                    aria-expanded={productFilterPopoverOpen}
                    className="mt-1 w-full justify-between font-normal"
                  >
                    <span className="truncate text-left">{productFilterTriggerLabel}</span>
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
                      value={productFilterSearch}
                      onValueChange={setProductFilterSearch}
                    />
                    <CommandList>
                      {isLoadingFilterProducts ? (
                        <div className="py-6 text-center text-sm text-muted-foreground">
                          Loading products…
                        </div>
                      ) : (
                        <>
                          <CommandGroup heading="Filter">
                            <CommandItem
                              value="__all_products__"
                              onSelect={() => {
                                setProductFilter('');
                                setSelectedFilterProductRow(null);
                                setProductFilterPopoverOpen(false);
                                setProductFilterSearch('');
                              }}
                            >
                              <Check
                                className={cn(
                                  'mr-2 h-4 w-4 shrink-0',
                                  !productFilter ? 'opacity-100' : 'opacity-0'
                                )}
                              />
                              All products
                            </CommandItem>
                          </CommandGroup>
                          <CommandEmpty>
                            {debouncedProductFilterSearch.trim()
                              ? 'No products match your search.'
                              : 'No active products yet.'}
                          </CommandEmpty>
                          <CommandGroup>
                            {filterPickerProducts.map((product: any) => (
                              <CommandItem
                                key={product.id}
                                value={product.id}
                                onSelect={() => {
                                  setProductFilter(product.id);
                                  setSelectedFilterProductRow(product);
                                  setProductFilterPopoverOpen(false);
                                  setProductFilterSearch('');
                                }}
                              >
                                <Check
                                  className={cn(
                                    'mr-2 h-4 w-4 shrink-0',
                                    productFilter === product.id ? 'opacity-100' : 'opacity-0'
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
            </div>
            <div className="flex-1">
              <Label>Filter by Location</Label>
              <Select
                value={locationFilter || 'all'}
                onValueChange={(value) => setLocationFilter(value === 'all' ? '' : value)}
              >
                <SelectTrigger>
                  <SelectValue placeholder="All locations" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All locations</SelectItem>
                  {locations?.map((loc: any) => (
                    <SelectItem key={loc.id} value={loc.id}>
                      {loc.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          {isLoading ? (
            <div className="text-center py-8 text-muted-foreground">Loading entries...</div>
          ) : !inventoryEntries?.entries || inventoryEntries.entries.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              <Package className="h-12 w-12 mx-auto mb-4 opacity-50" />
              <p>No inventory entries found</p>
              <p className="text-sm mt-2">
                <Link href="/merchant/inventory/stock/add" className="text-primary underline underline-offset-4">
                  Add stock
                </Link>{' '}
                to create inventory entries
              </p>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Date</TableHead>
                  <TableHead>Product</TableHead>
                  <TableHead>Location</TableHead>
                  <TableHead>Quantity</TableHead>
                  <TableHead>Payment Status</TableHead>
                  <TableHead>Supplier</TableHead>
                  <TableHead>Cost</TableHead>
                  <TableHead>Batch</TableHead>
                  <TableHead>Expiration</TableHead>
                  <TableHead>Added By</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {inventoryEntries.entries.map((entry: any) => (
                  <TableRow key={entry.id}>
                    <TableCell>{format(new Date(entry.receivedDate), 'MMM d, yyyy')}</TableCell>
                    <TableCell className="font-medium">{entry.products?.name || 'Unknown Product'}</TableCell>
                    <TableCell>{entry.locations?.name || 'Unknown Location'}</TableCell>
                    <TableCell>
                      <Badge variant="default">{entry.quantity}</Badge>
                    </TableCell>
                    <TableCell>
                      {entry.paymentStatus && (
                        <Badge
                          variant={
                            entry.paymentStatus === 'CREDIT'
                              ? 'destructive'
                              : entry.paymentStatus === 'PARTIAL'
                                ? 'secondary'
                                : 'default'
                          }
                        >
                          {entry.paymentStatus}
                        </Badge>
                      )}
                      {!entry.paymentStatus && <span className="text-muted-foreground">-</span>}
                    </TableCell>
                    <TableCell>
                      {entry.supplierName ? (
                        <div>
                          <div className="font-medium">{entry.supplierName}</div>
                          {entry.supplierContact && (
                            <div className="text-xs text-muted-foreground">{entry.supplierContact}</div>
                          )}
                        </div>
                      ) : (
                        <span className="text-muted-foreground">-</span>
                      )}
                    </TableCell>
                    <TableCell>
                      {entry.totalCost ? (
                        <div>
                          <div className="font-medium">
                            {new Intl.NumberFormat('en-US', {
                              style: 'currency',
                              currency: 'USD',
                            }).format(Number(entry.totalCost))}
                          </div>
                          {entry.paymentStatus === 'PARTIAL' && entry.paidAmount && (
                            <div className="text-xs text-muted-foreground">
                              Paid: {new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: 'USD',
                              }).format(Number(entry.paidAmount))}
                            </div>
                          )}
                        </div>
                      ) : (
                        <span className="text-muted-foreground">-</span>
                      )}
                    </TableCell>
                    <TableCell>
                      {entry.batchNumber || <span className="text-muted-foreground">-</span>}
                    </TableCell>
                    <TableCell>
                      {entry.expirationDate ? (
                        format(new Date(entry.expirationDate), 'MMM d, yyyy')
                      ) : (
                        <span className="text-muted-foreground">-</span>
                      )}
                    </TableCell>
                    <TableCell>
                      {entry.users?.firstName || ''} {entry.users?.lastName || ''}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

