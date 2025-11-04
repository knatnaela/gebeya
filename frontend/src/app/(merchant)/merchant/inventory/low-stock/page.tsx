'use client';

import { useQuery } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { AlertTriangle, Package, ArrowRight } from 'lucide-react';
import Link from 'next/link';
import { formatCurrency } from '@/lib/currency';

export default function LowStockPage() {
  const { data: lowStockProducts, isLoading } = useQuery({
    queryKey: ['products', 'low-stock'],
    queryFn: async () => {
      const res = await apiClient.get('/products/low-stock');
      return res.data.data || [];
    },
  });

  const { data: defaultLocation } = useQuery({
    queryKey: ['locations', 'default'],
    queryFn: async () => {
      const res = await apiClient.get('/locations/default');
      return res.data.data;
    },
  });

  // Fetch current stock for low stock products
  const { data: productStock } = useQuery({
    queryKey: ['products-stock', lowStockProducts?.map((p: any) => p.id).join(',')],
    queryFn: async () => {
      if (!lowStockProducts || !defaultLocation) return {};
      const stockMap: Record<string, number> = {};
      await Promise.all(
        lowStockProducts.map(async (product: any) => {
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
    enabled: !!lowStockProducts && !!defaultLocation && (lowStockProducts?.length || 0) > 0,
  });

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-muted-foreground">Loading low stock products...</div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Low Stock Products</h1>
          <p className="text-muted-foreground">Products that need restocking</p>
        </div>
      </div>

      {!lowStockProducts || lowStockProducts.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <Package className="h-12 w-12 text-muted-foreground mb-4" />
            <p className="text-lg font-medium text-muted-foreground">No low stock products</p>
            <p className="text-sm text-muted-foreground mt-2">
              All products are above their low stock threshold
            </p>
          </CardContent>
        </Card>
      ) : (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <AlertTriangle className="h-5 w-5 text-orange-600" />
              {lowStockProducts.length} Product{lowStockProducts.length !== 1 ? 's' : ''} Need Attention
            </CardTitle>
            <CardDescription>
              These products are at or below their low stock threshold
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Product Name</TableHead>
                  <TableHead>Brand</TableHead>
                  <TableHead>SKU</TableHead>
                  <TableHead>Current Stock</TableHead>
                  <TableHead>Threshold</TableHead>
                  <TableHead>Price</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {lowStockProducts.map((product: any) => {
                  const currentStock = productStock?.[product.id] || 0;
                  const isOutOfStock = currentStock === 0;
                  const isLowStock = currentStock > 0 && currentStock <= product.lowStockThreshold;

                  return (
                    <TableRow key={product.id}>
                      <TableCell className="font-medium">{product.name}</TableCell>
                      <TableCell>{product.brand || '-'}</TableCell>
                      <TableCell>{product.sku || '-'}</TableCell>
                      <TableCell>
                        <Badge
                          variant={isOutOfStock ? 'destructive' : 'outline'}
                          className={
                            isOutOfStock
                              ? ''
                              : 'border-orange-300 text-orange-700 bg-orange-50'
                          }
                        >
                          {currentStock}
                        </Badge>
                      </TableCell>
                      <TableCell>{product.lowStockThreshold}</TableCell>
                      <TableCell>{formatCurrency(product.price)}</TableCell>
                      <TableCell>
                        {isOutOfStock ? (
                          <Badge variant="destructive">Out of Stock</Badge>
                        ) : (
                          <Badge variant="outline" className="border-orange-300 text-orange-700 bg-orange-50">
                            Low Stock
                          </Badge>
                        )}
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Link href={`/merchant/inventory/stock?productId=${product.id}`}>
                            <Button variant="outline" size="sm">
                              Add Stock
                            </Button>
                          </Link>
                          <Link href={`/merchant/products?highlight=${product.id}`}>
                            <Button variant="ghost" size="sm">
                              View Product
                              <ArrowRight className="ml-2 h-4 w-4" />
                            </Button>
                          </Link>
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

