'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
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
import { Plus, Search, Edit, Trash2, Image as ImageIcon, Package, Download, RotateCcw, ChevronLeft, ChevronRight } from 'lucide-react';
import { BulkActions } from '@/components/products/bulk-actions';
import { Checkbox as UICheckbox } from '@/components/ui/checkbox';
import { toast } from 'sonner';
import { formatCurrency } from '@/lib/currency';
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import Image from 'next/image';
import { SubscriptionErrorMessage } from '@/components/subscription/subscription-error-message';

const productSchema = z.object({
  name: z.string().min(1, 'Product name is required'),
  brand: z.string().optional(),
  size: z.string().optional(),
  price: z.number().positive('Selling price must be positive'),
  costPrice: z.number().positive('Cost price must be positive'),
  sku: z.string().optional(),
  barcode: z.string().optional(),
  description: z.string().optional(),
  lowStockThreshold: z.number().int().min(0).optional(),
  imageUrl: z.string().url().optional().or(z.literal('')),
  isActive: z.boolean().optional(),
});

type ProductFormData = z.infer<typeof productSchema>;

export default function ProductsPage() {
  const [search, setSearch] = useState('');
  const [stockFilter, setStockFilter] = useState<string>('all'); // 'all', 'inStock', 'outOfStock', 'lowStock'
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(20);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<any>(null);
  const [selectedProducts, setSelectedProducts] = useState<string[]>([]);
  const queryClient = useQueryClient();

  const { data, isLoading, error } = useQuery({
    queryKey: ['products', search, stockFilter, page, limit],
    queryFn: async () => {
      const params: any = {};
      if (search) {
        params.search = search;
      }
      if (stockFilter === 'inStock') {
        params.inStock = 'true';
      } else if (stockFilter === 'outOfStock') {
        params.outOfStock = 'true';
      } else if (stockFilter === 'lowStock') {
        params.lowStock = 'true';
      }
      params.page = page;
      params.limit = limit;
      
      const res = await apiClient.get('/products', { params });
      return {
        products: res.data.data || [],
        pagination: res.data.pagination || { page: 1, limit: 20, total: 0, totalPages: 0 },
      };
    },
    retry: false, // Don't retry on subscription expired errors
  });

  const { data: lowStockProducts } = useQuery({
    queryKey: ['products', 'low-stock'],
    queryFn: async () => {
      const res = await apiClient.get('/products/low-stock');
      return res.data.data || [];
    },
  });

  // Fetch default location and stock for products
  const { data: defaultLocation } = useQuery({
    queryKey: ['locations', 'default'],
    queryFn: async () => {
      const res = await apiClient.get('/locations/default');
      return res.data.data;
    },
  });

  // Fetch current stock for all products
  const { data: productStock } = useQuery({
    queryKey: ['products-stock', data?.products?.map((p: any) => p.id).join(',')],
    queryFn: async () => {
      if (!data?.products || !defaultLocation) return {};
      const stockMap: Record<string, number> = {};
      await Promise.all(
        data.products.map(async (product: any) => {
          try {
            const res = await apiClient.get(`/inventory/stock/${product.id}`, {
              params: { locationId: defaultLocation.id },
            });
            stockMap[product.id] = res.data.data.stock || 0;
          } catch {
            stockMap[product.id] = 0;
          }
        })
      );
      return stockMap;
    },
    enabled: !!data?.products && !!defaultLocation && data.products.length > 0,
  });

  const createMutation = useMutation({
    mutationFn: async (data: ProductFormData) => {
      const res = await apiClient.post('/products', data);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      queryClient.refetchQueries({ queryKey: ['products'] });
      toast.success('Product created successfully');
      setIsDialogOpen(false);
      reset();
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to create product');
    },
  });

  const updateMutation = useMutation({
    mutationFn: async ({ id, data }: { id: string; data: ProductFormData }) => {
      const res = await apiClient.put(`/products/${id}`, data);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      toast.success('Product updated successfully');
      setIsDialogOpen(false);
      setEditingProduct(null);
      reset();
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to update product');
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const res = await apiClient.delete(`/products/${id}`);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      toast.success('Product deleted successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to delete product');
    },
  });

  const reactivateMutation = useMutation({
    mutationFn: async (id: string) => {
      const res = await apiClient.put(`/products/${id}`, { isActive: true });
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      toast.success('Product reactivated successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to reactivate product');
    },
  });

  const {
    register,
    handleSubmit,
    reset,
    control,
    formState: { errors },
  } = useForm<ProductFormData>({
    resolver: zodResolver(productSchema),
  });

  const onSubmit = (data: ProductFormData) => {
    if (editingProduct) {
      updateMutation.mutate({ id: editingProduct.id, data });
    } else {
      createMutation.mutate(data);
    }
  };

  const handleEdit = (product: any) => {
    setEditingProduct(product);
    reset({
      name: product.name,
      brand: product.brand || '',
      size: product.size || '',
      price: Number(product.price),
      costPrice: Number(product.costPrice || 0),
      sku: product.sku || '',
      barcode: product.barcode || '',
      description: product.description || '',
      lowStockThreshold: product.lowStockThreshold,
      imageUrl: product.imageUrl || '',
      isActive: product.isActive ?? true,
    });
    setIsDialogOpen(true);
  };

  const handleDelete = (id: string) => {
    if (confirm('Are you sure you want to delete this product? It will be marked as inactive.')) {
      deleteMutation.mutate(id);
    }
  };

  const handleReactivate = (id: string) => {
    if (confirm('Are you sure you want to reactivate this product?')) {
      reactivateMutation.mutate(id);
    }
  };

  const handleNewProduct = () => {
    setEditingProduct(null);
    reset({
      name: '',
      brand: '',
      size: '',
      price: 0,
      costPrice: 0,
      sku: '',
      barcode: '',
      description: '',
      lowStockThreshold: 5,
      imageUrl: '',
    });
    setIsDialogOpen(true);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Products</h1>
          <p className="text-muted-foreground">Manage your perfume inventory</p>
        </div>
        <Button onClick={handleNewProduct}>
          <Plus className="mr-2 h-4 w-4" />
          Add Product
        </Button>
      </div>


      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>All Products</CardTitle>
              <CardDescription>Your complete product catalog</CardDescription>
            </div>
            <div className="flex items-center gap-2 flex-wrap">
              <div className="relative">
                <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search products..."
                  value={search}
                  onChange={(e) => {
                    setSearch(e.target.value);
                    setPage(1); // Reset to first page on search
                  }}
                  className="pl-8 w-64"
                />
              </div>
              <Select
                value={stockFilter}
                onValueChange={(value) => {
                  setStockFilter(value);
                  setPage(1); // Reset to first page on filter change
                }}
              >
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Filter by stock" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Products</SelectItem>
                  <SelectItem value="inStock">In Stock</SelectItem>
                  <SelectItem value="outOfStock">Out of Stock</SelectItem>
                  <SelectItem value="lowStock">Low Stock</SelectItem>
                </SelectContent>
              </Select>
              <BulkActions
                selectedIds={selectedProducts}
                onBulkDelete={(ids) => {
                  ids.forEach((id) => deleteMutation.mutate(id));
                  setSelectedProducts([]);
                }}
                onBulkExport={() => {
                  // Export selected products to CSV
                  const selected = data?.products.filter((p: any) => selectedProducts.includes(p.id));
                  if (selected && selected.length > 0) {
                    const csv = [
                      ['Name', 'Brand', 'Size', 'Price', 'SKU', 'Stock'],
                      ...selected.map((p: any) => [
                        p.name,
                        p.brand || '',
                        p.size || '',
                        p.price,
                        p.sku || '',
                        productStock?.[p.id] || 0,
                      ]),
                    ]
                      .map((row) => row.map((cell: any) => `"${cell}"`).join(','))
                      .join('\n');
                    const blob = new Blob([csv], { type: 'text/csv' });
                    const url = window.URL.createObjectURL(blob);
                    const a = document.createElement('a');
                    a.href = url;
                    a.download = `products-export-${Date.now()}.csv`;
                    a.click();
                    toast.success(`Exported ${selected.length} products`);
                  }
                }}
              />
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="text-center py-8">Loading products...</div>
          ) : error ? (
            <SubscriptionErrorMessage error={error} title="Cannot Load Products" />
          ) : data && data.products && data.products.length > 0 ? (
            <>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="w-12">
                      <UICheckbox
                        checked={selectedProducts.length === data.products.length && data.products.length > 0}
                        onCheckedChange={(checked) => {
                          if (checked) {
                            setSelectedProducts(data.products.map((p: any) => p.id));
                          } else {
                            setSelectedProducts([]);
                          }
                        }}
                      />
                    </TableHead>
                    <TableHead>Image</TableHead>
                    <TableHead>Name</TableHead>
                    <TableHead>Brand</TableHead>
                    <TableHead>SKU</TableHead>
                    <TableHead>Price</TableHead>
                    <TableHead>Stock</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {data.products.map((product: any) => (
                    <TableRow key={product.id} className={selectedProducts.includes(product.id) ? 'bg-muted/50' : ''}>
                      <TableCell>
                        <UICheckbox
                          checked={selectedProducts.includes(product.id)}
                          onCheckedChange={(checked) => {
                            if (checked) {
                              setSelectedProducts([...selectedProducts, product.id]);
                            } else {
                              setSelectedProducts(selectedProducts.filter((id) => id !== product.id));
                            }
                          }}
                        />
                      </TableCell>
                      <TableCell>
                        {product.imageUrl ? (
                          <Image
                            src={product.imageUrl}
                            alt={product.name}
                            width={40}
                            height={40}
                            className="rounded"
                          />
                        ) : (
                          <div className="w-10 h-10 bg-muted rounded flex items-center justify-center">
                            <ImageIcon className="h-5 w-5 text-muted-foreground" />
                          </div>
                        )}
                      </TableCell>
                      <TableCell className="font-medium">{product.name}</TableCell>
                      <TableCell>{product.brand || '-'}</TableCell>
                      <TableCell>{product.sku || '-'}</TableCell>
                      <TableCell>{formatCurrency(product.price)}</TableCell>
                      <TableCell>
                        <Badge
                          variant={
                            (productStock?.[product.id] || 0) <= product.lowStockThreshold
                              ? 'destructive'
                              : 'default'
                          }
                        >
                          {productStock?.[product.id] ?? '...'}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Badge variant={product.isActive ? 'default' : 'secondary'}>
                          {product.isActive ? 'Active' : 'Inactive'}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          {product.isActive ? (
                            <>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleEdit(product)}
                          >
                            <Edit className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleDelete(product.id)}
                          >
                            <Trash2 className="h-4 w-4 text-destructive" />
                          </Button>
                            </>
                          ) : (
                            <>
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleReactivate(product.id)}
                                className="text-green-600 hover:text-green-700"
                              >
                                <RotateCcw className="h-4 w-4" />
                              </Button>
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleEdit(product)}
                              >
                                <Edit className="h-4 w-4" />
                              </Button>
                            </>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
              
              {/* Pagination Controls */}
              {data?.pagination && data.pagination.totalPages > 1 && (
                <div className="flex items-center justify-between mt-4 pt-4 border-t">
                  <div className="flex items-center gap-2">
                    <p className="text-sm text-muted-foreground">
                      Showing {((data.pagination.page - 1) * data.pagination.limit) + 1} to{' '}
                      {Math.min(data.pagination.page * data.pagination.limit, data.pagination.total)} of{' '}
                      {data.pagination.total} products
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    <Select
                      value={limit.toString()}
                      onValueChange={(value) => {
                        setLimit(parseInt(value, 10));
                        setPage(1); // Reset to first page when changing limit
                      }}
                    >
                      <SelectTrigger className="w-[100px]">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="10">10</SelectItem>
                        <SelectItem value="20">20</SelectItem>
                        <SelectItem value="50">50</SelectItem>
                        <SelectItem value="100">100</SelectItem>
                      </SelectContent>
                    </Select>
                    <div className="flex items-center gap-1">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setPage((p) => Math.max(1, p - 1))}
                        disabled={data.pagination.page === 1}
                      >
                        <ChevronLeft className="h-4 w-4" />
                      </Button>
                      <div className="flex items-center gap-1 px-2">
                        <span className="text-sm">
                          Page {data.pagination.page} of {data.pagination.totalPages}
                        </span>
                      </div>
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => setPage((p) => Math.min(data.pagination.totalPages, p + 1))}
                        disabled={data.pagination.page === data.pagination.totalPages}
                      >
                        <ChevronRight className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                </div>
              )}
            </>
          ) : (
            <div className="text-center py-8">
              <Package className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No products found</p>
              <Button onClick={handleNewProduct} className="mt-4">
                <Plus className="mr-2 h-4 w-4" />
                Add Your First Product
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editingProduct ? 'Edit Product' : 'Add New Product'}</DialogTitle>
            <DialogDescription>
              {editingProduct
                ? 'Update product information'
                : 'Fill in the details to add a new product to your inventory'}
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="name">Product Name *</Label>
                <Input id="name" {...register('name')} />
                {errors.name && (
                  <p className="text-sm text-destructive">{errors.name.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="brand">Brand</Label>
                <Input id="brand" {...register('brand')} />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="size">Size</Label>
                <Input id="size" placeholder="e.g., 50ml" {...register('size')} />
              </div>
              <div className="space-y-2">
                <Label htmlFor="price">Selling Price *</Label>
                <Input
                  id="price"
                  type="number"
                  step="0.01"
                  {...register('price', { valueAsNumber: true })}
                />
                {errors.price && (
                  <p className="text-sm text-destructive">{errors.price.message}</p>
                )}
              </div>
              <div className="space-y-2">
                <Label htmlFor="costPrice">Cost Price (Bought Price) *</Label>
                <Input
                  id="costPrice"
                  type="number"
                  step="0.01"
                  {...register('costPrice', { valueAsNumber: true })}
                />
                {errors.costPrice && (
                  <p className="text-sm text-destructive">{errors.costPrice.message}</p>
                )}
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="sku">SKU</Label>
                <Input id="sku" {...register('sku')} />
              </div>
              <div className="space-y-2">
                <Label htmlFor="barcode">Barcode</Label>
                <Input id="barcode" {...register('barcode')} />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="description">Description</Label>
              <Input id="description" {...register('description')} />
            </div>

            <div className="space-y-2">
              <Label htmlFor="lowStockThreshold">Low Stock Threshold</Label>
              <Input
                id="lowStockThreshold"
                type="number"
                {...register('lowStockThreshold', { valueAsNumber: true })}
                placeholder="Default: 5"
              />
              <p className="text-xs text-muted-foreground">
                Stock is managed separately. Add stock using the Stock Management page.
              </p>
            </div>

            {editingProduct && (
              <div className="flex items-center space-x-2">
                <Controller
                  name="isActive"
                  control={control}
                  render={({ field }) => (
                    <UICheckbox
                      id="isActive"
                      checked={field.value ?? true}
                      onCheckedChange={field.onChange}
                    />
                  )}
                />
                <Label htmlFor="isActive" className="cursor-pointer">
                  Product is active
                </Label>
              </div>
            )}

            <div className="space-y-2">
              <Label>Product Image</Label>
              <div className="border rounded-lg p-4">
                <input
                  type="file"
                  accept="image/*"
                  onChange={(e) => {
                    const file = e.target.files?.[0];
                    if (file) {
                      // For now, just show a preview
                      const reader = new FileReader();
                      reader.onload = () => {
                        // In production, this would upload to Cloudinary via backend
                        toast.info('Image upload feature - Use URL for now');
                      };
                      reader.readAsDataURL(file);
                    }
                  }}
                  className="w-full"
                />
                <Input
                  id="imageUrl"
                  placeholder="https://..."
                  {...register('imageUrl')}
                  className="mt-2"
                />
                <p className="text-xs text-muted-foreground mt-2">
                  Upload image or enter direct URL (Cloudinary upload via backend coming soon)
                </p>
              </div>
            </div>

            <div className="flex justify-end gap-2 pt-4">
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsDialogOpen(false)}
              >
                Cancel
              </Button>
              <Button type="submit" disabled={createMutation.isPending || updateMutation.isPending}>
                {editingProduct ? 'Update' : 'Create'} Product
              </Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}

