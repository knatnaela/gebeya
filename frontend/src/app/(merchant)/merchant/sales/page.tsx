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
import { ShoppingCart, Plus, Receipt, Search, Download, ExternalLink } from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ExportButton } from '@/components/sales/export-button';
import { toast } from 'sonner';
import { format } from 'date-fns';
import { formatCurrency, formatCurrencySmart } from '@/lib/currency';
import { SubscriptionErrorMessage } from '@/components/subscription/subscription-error-message';

export default function SalesPage() {
  const router = useRouter();
  const [isReceiptDialogOpen, setIsReceiptDialogOpen] = useState(false);
  const [selectedSale, setSelectedSale] = useState<any>(null);
  const [search, setSearch] = useState('');
  const queryClient = useQueryClient();

  const { data: salesData, isLoading, error } = useQuery({
    queryKey: ['sales', search],
    queryFn: async () => {
      const params = search ? { search } : {};
      const res = await apiClient.get('/sales', { params });
      // Backend returns { success: true, data: [...sales array], pagination: {...} }
      return {
        sales: Array.isArray(res.data.data) ? res.data.data : [],
        pagination: res.data.pagination || { page: 1, limit: 20, total: 0, totalPages: 0 },
      };
    },
    retry: false, // Don't retry on subscription expired errors
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Sales</h1>
          <p className="text-muted-foreground">Record and view sales transactions</p>
        </div>
        <div className="flex gap-2">
          {salesData?.sales && salesData.sales.length > 0 && (
            <ExportButton
              data={salesData.sales}
              filename="sales"
              type="sales"
            />
          )}
          <Link href="/merchant/sales/new">
            <Button>
            <Plus className="mr-2 h-4 w-4" />
            New Sale
          </Button>
          </Link>
        </div>
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Sales History</CardTitle>
              <CardDescription>All recorded sales transactions</CardDescription>
            </div>
            <div className="flex items-center gap-2">
              <div className="relative">
                <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="Search sales..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="pl-8 w-64"
                />
              </div>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="text-center py-8">Loading sales...</div>
          ) : error ? (
            <SubscriptionErrorMessage error={error} title="Cannot Load Sales" />
          ) : salesData?.sales && salesData.sales.length > 0 ? (
            <div className="space-y-2">
              <p className="text-sm text-muted-foreground mb-2">
                💡 Click on any row to view detailed sale information
              </p>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Sale Date</TableHead>
                  <TableHead>Items</TableHead>
                  <TableHead>Customer</TableHead>
                  <TableHead>Revenue</TableHead>
                  <TableHead>Net Income</TableHead>
                  <TableHead>Profit Margin</TableHead>
                  <TableHead>User</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {salesData.sales.map((sale: any) => {
                  // Check if any items have price overrides (discount or over-price)
                  const hasDiscounts = sale.sale_items?.some((item: any) => {
                    const defaultPrice = Number(item.defaultPrice || item.products?.price || 0);
                    const soldPrice = Number(item.unitPrice);
                    return soldPrice < defaultPrice;
                  }) || false;
                  const hasOverPrice = sale.sale_items?.some((item: any) => {
                    const defaultPrice = Number(item.defaultPrice || item.products?.price || 0);
                    const soldPrice = Number(item.unitPrice);
                    return soldPrice > defaultPrice;
                  }) || false;

                  return (
                    <TableRow 
                      key={sale.id}
                      className="cursor-pointer hover:bg-muted/50"
                      onClick={() => router.push(`/merchant/sales/${sale.id}`)}
                    >
                    <TableCell>
                      <div>{format(new Date(sale.saleDate || sale.createdAt), 'MMM d, yyyy')}</div>
                      <div className="text-xs text-muted-foreground">
                        {format(new Date(sale.createdAt), 'HH:mm')}
                      </div>
                    </TableCell>
                    <TableCell>
                        <div className="flex items-center gap-2">
                          <span>{sale.sale_items?.length || 0} item(s)</span>
                          {hasDiscounts && (
                            <Badge variant="outline" className="border-orange-300 text-orange-700 bg-orange-50">
                              Discount
                            </Badge>
                          )}
                          {hasOverPrice && (
                            <Badge variant="outline" className="border-green-300 text-green-700 bg-green-50">
                              Over Price
                            </Badge>
                          )}
                        </div>
                      <div className="text-xs text-muted-foreground mt-1">
                        {sale.sale_items?.slice(0, 2).map((item: any) => item.products?.name || 'Unknown').join(', ')}
                        {(sale.sale_items?.length || 0) > 2 && '...'}
                      </div>
                    </TableCell>
                    <TableCell>
                      {sale.customerName ? (
                        <div>
                          <div className="font-medium">{sale.customerName}</div>
                          {sale.customerPhone && (
                            <div className="text-xs text-muted-foreground">{sale.customerPhone}</div>
                          )}
                        </div>
                      ) : (
                        <span className="text-muted-foreground text-sm">-</span>
                      )}
                    </TableCell>
                    <TableCell className="font-medium">
                        {formatCurrencySmart(sale.totalAmount)}
                      </TableCell>
                      <TableCell className="font-medium text-green-600">
                        {formatCurrencySmart(sale.netIncome || 0)}
                      </TableCell>
                      <TableCell className="font-medium text-blue-600">
                        {Number(sale.profitMargin || 0).toFixed(2)}%
                    </TableCell>
                    <TableCell>
                      {sale.users?.firstName || ''} {sale.users?.lastName || ''}
                    </TableCell>
                      <TableCell className="text-right" onClick={(e) => e.stopPropagation()}>
                        <div className="flex justify-end gap-2">
                          <Link href={`/merchant/sales/${sale.id}`}>
                            <Button variant="ghost" size="sm" title="View Details">
                              <ExternalLink className="h-4 w-4" />
                            </Button>
                          </Link>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => {
                          setSelectedSale(sale);
                          setIsReceiptDialogOpen(true);
                        }}
                            title="View Receipt"
                      >
                        <Receipt className="h-4 w-4" />
                      </Button>
                        </div>
                    </TableCell>
                  </TableRow>
                  );
                })}
              </TableBody>
            </Table>
            </div>
          ) : (
            <div className="text-center py-8">
              <ShoppingCart className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No sales recorded yet</p>
              <Link href="/merchant/sales/new">
                <Button className="mt-4">
                <Plus className="mr-2 h-4 w-4" />
                Record Your First Sale
              </Button>
              </Link>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Receipt Dialog */}
      <Dialog open={isReceiptDialogOpen} onOpenChange={setIsReceiptDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Receipt</DialogTitle>
            <DialogDescription>Sale #{selectedSale?.id.slice(-8)}</DialogDescription>
          </DialogHeader>
          {selectedSale && (
            <div className="space-y-4">
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Sale Date:</span>
                  <span>{format(new Date(selectedSale.saleDate || selectedSale.createdAt), 'MMM d, yyyy')}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Recorded:</span>
                  <span>{format(new Date(selectedSale.createdAt), 'MMM d, yyyy HH:mm')}</span>
                </div>
                {selectedSale.customerName && (
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Customer:</span>
                    <span className="font-medium">{selectedSale.customerName}</span>
                  </div>
                )}
                {selectedSale.customerPhone && (
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Phone:</span>
                    <span>{selectedSale.customerPhone}</span>
                  </div>
                )}
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Sold by:</span>
                  <span>
                    {selectedSale.users?.firstName || ''} {selectedSale.users?.lastName || ''}
                  </span>
                </div>
              </div>

              <div className="border-t pt-4">
              {selectedSale.sale_items?.map((item: any, index: number) => {
                const costPrice = Number(item.products?.costPrice || 0);
                const soldPrice = Number(item.unitPrice);
                const defaultPrice = Number(item.defaultPrice || item.products?.price || soldPrice);
                const itemProfit = (soldPrice - costPrice) * item.quantity;
                const itemProfitMargin = soldPrice > 0 ? ((soldPrice - costPrice) / soldPrice) * 100 : 0;
                const isDiscount = soldPrice < defaultPrice;
                const isOverPrice = soldPrice > defaultPrice;
                const priceDiff = Math.abs(soldPrice - defaultPrice);
                const priceDiffPercent = defaultPrice > 0 ? ((priceDiff / defaultPrice) * 100) : 0;
                
                return (
                  <div key={index} className="border-b pb-2 mb-2 last:border-0 last:mb-0">
                    <div className="flex justify-between items-start">
                      <div className="flex-1">
                      <div className="font-medium">{item.products?.name || 'Unknown Product'}</div>
                        <div className="flex items-center gap-2 mt-1">
                          {isDiscount && (
                            <Badge variant="outline" className="border-orange-300 text-orange-700 bg-orange-50 text-xs">
                              Discount: -{formatCurrency(priceDiff)} ({priceDiffPercent.toFixed(1)}%)
                            </Badge>
                          )}
                          {isOverPrice && (
                            <Badge variant="outline" className="border-green-300 text-green-700 bg-green-50 text-xs">
                              Over Price: +{formatCurrency(priceDiff)} ({priceDiffPercent.toFixed(1)}%)
                            </Badge>
                          )}
                        </div>
                      </div>
                      <div className="font-medium">{formatCurrency(item.totalPrice)}</div>
                    </div>
                    <div className="text-xs text-muted-foreground space-y-1 mt-1">
                      <div className="flex justify-between">
                        <span>Qty: {item.quantity}</span>
                        <div className="flex gap-2">
                          {defaultPrice !== soldPrice && (
                            <span className="line-through text-muted-foreground">
                              {formatCurrency(defaultPrice)}
                            </span>
                          )}
                          <span>Sold: {formatCurrency(soldPrice)}</span>
                        </div>
                      </div>
                      <div className="flex justify-between">
                        <span>Cost: {formatCurrency(costPrice)}</span>
                        <span className={itemProfit >= 0 ? 'text-green-600' : 'text-red-600'}>
                          Profit: {formatCurrency(itemProfit)} ({itemProfitMargin.toFixed(1)}%)
                        </span>
                      </div>
                    </div>
                  </div>
                );
              })}
              </div>

              <div className="border-t pt-4 space-y-2">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Revenue:</span>
                  <span className="font-medium">{formatCurrencySmart(selectedSale.totalAmount)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Cost of Goods:</span>
                  <span className="font-medium">{formatCurrencySmart(selectedSale.costOfGoodsSold || 0)}</span>
                </div>
                <div className="flex justify-between text-lg font-bold border-t pt-2">
                  <span>Net Income:</span>
                  <span className="text-green-600">{formatCurrencySmart(selectedSale.netIncome || 0)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Profit Margin:</span>
                  <span className="font-medium text-blue-600">{Number(selectedSale.profitMargin || 0).toFixed(2)}%</span>
                </div>
              </div>

              {selectedSale.notes && (
                <div className="pt-4 border-t">
                  <div className="text-sm">
                    <span className="text-muted-foreground">Notes: </span>
                    {selectedSale.notes}
                  </div>
                </div>
              )}

              <div className="flex justify-end gap-2 pt-4">
                <Button onClick={() => setIsReceiptDialogOpen(false)}>Close</Button>
                <Button variant="outline" onClick={() => window.print()}>
                  Print
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}

