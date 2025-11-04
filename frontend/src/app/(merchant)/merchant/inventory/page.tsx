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
import { Package, TrendingUp, TrendingDown, RefreshCw, AlertTriangle, Download } from 'lucide-react';
import { ExportButton } from '@/components/sales/export-button';
import { formatCurrency, formatCurrencySmart } from '@/lib/currency';
import { toast } from 'sonner';
import { format } from 'date-fns';
import Link from 'next/link';
import { SubscriptionErrorMessage } from '@/components/subscription/subscription-error-message';

export default function InventoryPage() {
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [selectedProduct, setSelectedProduct] = useState<any>(null);
  const [adjustmentType, setAdjustmentType] = useState('ADJUSTMENT');
  const [quantity, setQuantity] = useState('');
  const [reason, setReason] = useState('');
  const queryClient = useQueryClient();

  const { data: summary, isLoading: summaryLoading, error: summaryError } = useQuery({
    queryKey: ['inventory-summary'],
    queryFn: async () => {
      const res = await apiClient.get('/inventory/summary');
      return res.data.data;
    },
    retry: false, // Don't retry on subscription expired errors
  });

  const { data: transactions, isLoading: transactionsLoading, error: transactionsError } = useQuery({
    queryKey: ['inventory-transactions'],
    queryFn: async () => {
      const res = await apiClient.get('/inventory/transactions', {
        params: { limit: 50 },
      });
      return {
        transactions: res.data.data || [],
        pagination: res.data.pagination || { page: 1, limit: 50, total: 0, totalPages: 0 },
      };
    },
    retry: false, // Don't retry on subscription expired errors
  });

  const { data: products } = useQuery({
    queryKey: ['products'],
    queryFn: async () => {
      const res = await apiClient.get('/products');
      return res.data.data || [];
    },
  });

  const { data: locations } = useQuery({
    queryKey: ['locations'],
    queryFn: async () => {
      const res = await apiClient.get('/locations');
      return res.data.data || [];
    },
  });

  const defaultLocation = locations?.find((loc: any) => loc.isDefault);
  const [selectedLocationId, setSelectedLocationId] = useState<string>('');

  const adjustMutation = useMutation({
    mutationFn: async (data: {
      productId: string;
      locationId?: string;
      type: string;
      quantity: number;
      reason?: string;
    }) => {
      const res = await apiClient.post('/inventory/transactions', data);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['inventory-transactions'] });
      queryClient.invalidateQueries({ queryKey: ['inventory-summary'] });
      queryClient.invalidateQueries({ queryKey: ['products'] });
      toast.success('Stock adjusted successfully');
      setIsDialogOpen(false);
      setQuantity('');
      setReason('');
      setSelectedProduct(null);
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to adjust stock');
    },
  });

  const handleAdjustStock = () => {
    if (!selectedProduct || !quantity) {
      toast.error('Please select a product and enter quantity');
      return;
    }

    const qty = parseInt(quantity);
    if (isNaN(qty) || qty === 0) {
      toast.error('Please enter a valid quantity');
      return;
    }

    const locationId = selectedLocationId || defaultLocation?.id;
    adjustMutation.mutate({
      productId: selectedProduct,
      locationId: locationId || undefined,
      type: adjustmentType,
      quantity: adjustmentType === 'RESTOCK' ? qty : -qty,
      reason: reason || undefined,
    });
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Inventory Management</h1>
          <p className="text-muted-foreground">Track and adjust stock levels</p>
        </div>
        <div className="flex gap-2">
          {transactions?.transactions && transactions.transactions.length > 0 && (
            <ExportButton
              data={transactions.transactions}
              filename="inventory-history"
              type="inventory"
            />
          )}
          <Link href="/merchant/inventory/stock">
            <Button variant="outline">
              <Package className="mr-2 h-4 w-4" />
              Manage Stock
            </Button>
          </Link>
          <Button onClick={() => setIsDialogOpen(true)}>
            <RefreshCw className="mr-2 h-4 w-4" />
            Adjust Stock
          </Button>
        </div>
      </div>

      {summaryLoading ? (
        <div>Loading...</div>
      ) : summaryError ? (
        <SubscriptionErrorMessage error={summaryError} title="Cannot Load Inventory Summary" />
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Products</CardTitle>
              <Package className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{summary?.totalProducts || 0}</div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Stock Value</CardTitle>
              <TrendingUp className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {formatCurrencySmart(summary?.totalStockValue || 0)}
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Low Stock Alerts</CardTitle>
              <AlertTriangle className="h-4 w-4 text-orange-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-orange-600">
                {summary?.lowStockCount || 0}
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Out of Stock</CardTitle>
              <TrendingDown className="h-4 w-4 text-destructive" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-destructive">
                {summary?.outOfStockCount || 0}
              </div>
            </CardContent>
          </Card>
        </div>
      )}


      <Card>
        <CardHeader>
          <CardTitle>Stock Adjustment History</CardTitle>
          <CardDescription>Recent inventory transactions</CardDescription>
        </CardHeader>
        <CardContent>
          {transactionsLoading ? (
            <div>Loading transactions...</div>
          ) : transactionsError ? (
            <SubscriptionErrorMessage error={transactionsError} title="Cannot Load Transactions" />
          ) : transactions?.transactions && transactions.transactions.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Date</TableHead>
                  <TableHead>Product</TableHead>
                  <TableHead>Location</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Quantity</TableHead>
                  <TableHead>Reason</TableHead>
                  <TableHead>User</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {transactions.transactions.map((tx: any) => (
                  <TableRow key={tx.id}>
                    <TableCell>{format(new Date(tx.createdAt), 'MMM d, yyyy HH:mm')}</TableCell>
                    <TableCell className="font-medium">{tx.products?.name || 'Unknown Product'}</TableCell>
                    <TableCell>
                      {tx.locations?.name || <span className="text-muted-foreground">-</span>}
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">{tx.type}</Badge>
                    </TableCell>
                    <TableCell>
                      <span className={tx.quantity > 0 ? 'text-green-600' : 'text-red-600'}>
                        {tx.quantity > 0 ? '+' : ''}
                        {tx.quantity}
                      </span>
                    </TableCell>
                    <TableCell className="text-sm text-muted-foreground">
                      {tx.reason || '-'}
                    </TableCell>
                    <TableCell>
                      {tx.users?.firstName || ''} {tx.users?.lastName || ''}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <div className="text-center py-8 text-muted-foreground">
              No inventory transactions yet
            </div>
          )}
        </CardContent>
      </Card>

      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Adjust Stock</DialogTitle>
            <DialogDescription>Add or remove stock from a product</DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>Product</Label>
              <Select value={selectedProduct} onValueChange={setSelectedProduct}>
                <SelectTrigger>
                  <SelectValue placeholder="Select a product" />
                </SelectTrigger>
                <SelectContent>
                  {products?.map((product: any) => (
                    <SelectItem key={product.id} value={product.id}>
                      {product.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label>Location</Label>
              <Select
                value={selectedLocationId || defaultLocation?.id || ''}
                onValueChange={setSelectedLocationId}
              >
                <SelectTrigger>
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

            <div className="space-y-2">
              <Label>Type</Label>
              <Select value={adjustmentType} onValueChange={setAdjustmentType}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="RESTOCK">Restock (Add)</SelectItem>
                  <SelectItem value="ADJUSTMENT">Adjustment (Remove)</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label>Quantity</Label>
              <Input
                type="number"
                placeholder="Enter quantity"
                value={quantity}
                onChange={(e) => setQuantity(e.target.value)}
              />
            </div>

            <div className="space-y-2">
              <Label>Reason (Optional)</Label>
              <Input
                placeholder="e.g., Damaged items, Inventory correction"
                value={reason}
                onChange={(e) => setReason(e.target.value)}
              />
            </div>

            <div className="flex justify-end gap-2 pt-4">
              <Button variant="outline" onClick={() => setIsDialogOpen(false)}>
                Cancel
              </Button>
              <Button onClick={handleAdjustStock} disabled={adjustMutation.isPending}>
                {adjustMutation.isPending ? 'Adjusting...' : 'Adjust Stock'}
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

