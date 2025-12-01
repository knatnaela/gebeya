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
import { Plus, Package, ArrowRightLeft, Search, Filter } from 'lucide-react';
import { toast } from 'sonner';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { format } from 'date-fns';

const addStockSchema = z.object({
  productId: z.string().min(1, 'Product is required'),
  locationId: z.string().optional(),
  quantity: z.number().int().positive('Quantity must be positive'),
  batchNumber: z.string().optional(),
  expirationDate: z.string().optional(),
  receivedDate: z.string().optional(),
  notes: z.string().optional(),
  // Payment tracking fields
  paymentStatus: z.enum(['PAID', 'CREDIT', 'PARTIAL']).optional(),
  supplierName: z.string().optional(),
  supplierContact: z.string().optional(),
  totalCost: z.number().nonnegative().optional(),
  paidAmount: z.number().nonnegative().optional(),
  paymentDueDate: z.string().optional(),
});

const transferStockSchema = z.object({
  productId: z.string().min(1, 'Product is required'),
  fromLocationId: z.string().min(1, 'Source location is required'),
  toLocationId: z.string().min(1, 'Destination location is required'),
  quantity: z.number().int().positive('Quantity must be positive'),
  notes: z.string().optional(),
});

type AddStockFormData = z.infer<typeof addStockSchema>;
type TransferStockFormData = z.infer<typeof transferStockSchema>;

export default function StockManagementPage() {
  const [isAddStockDialogOpen, setIsAddStockDialogOpen] = useState(false);
  const [isTransferDialogOpen, setIsTransferDialogOpen] = useState(false);
  const [productFilter, setProductFilter] = useState('');
  const [locationFilter, setLocationFilter] = useState('');
  const queryClient = useQueryClient();

  const { data: locations } = useQuery({
    queryKey: ['locations'],
    queryFn: async () => {
      const res = await apiClient.get('/locations');
      return res.data.data || [];
    },
  });

  const { data: products } = useQuery({
    queryKey: ['products'],
    queryFn: async () => {
      const res = await apiClient.get('/products', { params: { isActive: true } });
      return res.data.data || [];
    },
  });

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
      // Payment tracking fields
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
      setIsAddStockDialogOpen(false);
      resetAddStock();
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to add stock');
    },
  });

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
      setIsTransferDialogOpen(false);
      resetTransfer();
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to transfer stock');
    },
  });

  const {
    register: registerAddStock,
    handleSubmit: handleSubmitAddStock,
    reset: resetAddStock,
    formState: { errors: errorsAddStock },
    watch: watchAddStock,
    setValue: setValueAddStock,
  } = useForm<AddStockFormData>({
    resolver: zodResolver(addStockSchema),
    defaultValues: {
      receivedDate: new Date().toISOString().split('T')[0],
    },
  });

  const {
    register: registerTransfer,
    handleSubmit: handleSubmitTransfer,
    reset: resetTransfer,
    formState: { errors: errorsTransfer },
    watch: watchTransfer,
    setValue: setValueTransfer,
  } = useForm<TransferStockFormData>({
    resolver: zodResolver(transferStockSchema),
  });

  const defaultLocation = locations?.find((loc: any) => loc.isDefault);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Stock Management</h1>
          <p className="text-muted-foreground">Add stock, view entries, and transfer between locations</p>
        </div>
        <div className="flex gap-2">
          <Dialog open={isTransferDialogOpen} onOpenChange={setIsTransferDialogOpen}>
            <DialogTrigger asChild>
              <Button variant="outline" onClick={() => resetTransfer()}>
                <ArrowRightLeft className="h-4 w-4 mr-2" />
                Transfer Stock
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-md">
              <DialogHeader>
                <DialogTitle>Transfer Stock</DialogTitle>
                <DialogDescription>Move stock between locations</DialogDescription>
              </DialogHeader>
              <form onSubmit={handleSubmitTransfer((data) => transferStockMutation.mutate(data))} className="space-y-4">
                <div>
                  <Label htmlFor="transfer-product">Product *</Label>
                  <Select
                    value={watchTransfer('productId')}
                    onValueChange={(value) => setValueTransfer('productId', value)}
                  >
                    <SelectTrigger id="transfer-product">
                      <SelectValue placeholder="Select product" />
                    </SelectTrigger>
                    <SelectContent>
                      {products?.map((product: any) => (
                        <SelectItem key={product.id} value={product.id}>
                          {product.name}{product.size ? ` (${product.size})` : ''}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  {errorsTransfer.productId && (
                    <p className="text-sm text-red-500 mt-1">{errorsTransfer.productId.message}</p>
                  )}
                </div>
                <div>
                  <Label htmlFor="from-location">From Location *</Label>
                  <Select
                    value={watchTransfer('fromLocationId')}
                    onValueChange={(value) => setValueTransfer('fromLocationId', value)}
                  >
                    <SelectTrigger id="from-location">
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
                  {errorsTransfer.fromLocationId && (
                    <p className="text-sm text-red-500 mt-1">{errorsTransfer.fromLocationId.message}</p>
                  )}
                </div>
                <div>
                  <Label htmlFor="to-location">To Location *</Label>
                  <Select
                    value={watchTransfer('toLocationId')}
                    onValueChange={(value) => setValueTransfer('toLocationId', value)}
                  >
                    <SelectTrigger id="to-location">
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
                  {errorsTransfer.toLocationId && (
                    <p className="text-sm text-red-500 mt-1">{errorsTransfer.toLocationId.message}</p>
                  )}
                </div>
                <div>
                  <Label htmlFor="transfer-quantity">Quantity *</Label>
                  <Input
                    id="transfer-quantity"
                    type="number"
                    {...registerTransfer('quantity', { valueAsNumber: true })}
                    placeholder="Enter quantity"
                  />
                  {errorsTransfer.quantity && (
                    <p className="text-sm text-red-500 mt-1">{errorsTransfer.quantity.message}</p>
                  )}
                </div>
                <div>
                  <Label htmlFor="transfer-notes">Notes (Optional)</Label>
                  <Input
                    id="transfer-notes"
                    {...registerTransfer('notes')}
                    placeholder="Transfer notes"
                  />
                </div>
                <div className="flex justify-end gap-2 pt-4">
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => setIsTransferDialogOpen(false)}
                    disabled={transferStockMutation.isPending}
                  >
                    Cancel
                  </Button>
                  <Button type="submit" disabled={transferStockMutation.isPending}>
                    {transferStockMutation.isPending ? 'Transferring...' : 'Transfer'}
                  </Button>
                </div>
              </form>
            </DialogContent>
          </Dialog>
          <Dialog open={isAddStockDialogOpen} onOpenChange={setIsAddStockDialogOpen}>
            <DialogTrigger asChild>
              <Button onClick={() => resetAddStock()}>
                <Plus className="h-4 w-4 mr-2" />
                Add Stock
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-md max-h-[90vh] overflow-y-auto">
              <DialogHeader>
                <DialogTitle>Add Stock</DialogTitle>
                <DialogDescription>Create a new inventory entry</DialogDescription>
              </DialogHeader>
              <form onSubmit={handleSubmitAddStock((data) => addStockMutation.mutate(data))} className="space-y-4">
                <div>
                  <Label htmlFor="product">Product *</Label>
                  <Select
                    value={watchAddStock('productId')}
                    onValueChange={(value) => setValueAddStock('productId', value)}
                  >
                    <SelectTrigger id="product">
                      <SelectValue placeholder="Select product" />
                    </SelectTrigger>
                    <SelectContent>
                      {products?.map((product: any) => (
                        <SelectItem key={product.id} value={product.id}>
                          {product.name}{product.size ? ` (${product.size})` : ''}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  {errorsAddStock.productId && (
                    <p className="text-sm text-red-500 mt-1">{errorsAddStock.productId.message}</p>
                  )}
                </div>
                <div>
                  <Label htmlFor="location">Location</Label>
                  <Select
                    value={watchAddStock('locationId') || defaultLocation?.id || undefined}
                    onValueChange={(value) => setValueAddStock('locationId', value)}
                  >
                    <SelectTrigger id="location">
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
                    {...registerAddStock('quantity', { valueAsNumber: true })}
                    placeholder="Enter quantity"
                  />
                  {errorsAddStock.quantity && (
                    <p className="text-sm text-red-500 mt-1">{errorsAddStock.quantity.message}</p>
                  )}
                </div>
                <div>
                  <Label htmlFor="batch-number">Batch Number (Optional)</Label>
                  <Input
                    id="batch-number"
                    {...registerAddStock('batchNumber')}
                    placeholder="e.g., BATCH-2024-001"
                  />
                </div>
                <div>
                  <Label htmlFor="expiration-date">Expiration Date (Optional)</Label>
                  <Input
                    id="expiration-date"
                    type="date"
                    {...registerAddStock('expirationDate')}
                  />
                </div>
                <div>
                  <Label htmlFor="received-date">Received Date *</Label>
                  <Input
                    id="received-date"
                    type="date"
                    {...registerAddStock('receivedDate')}
                    required
                  />
                </div>
                <div>
                  <Label htmlFor="notes">Notes (Optional)</Label>
                  <Input
                    id="notes"
                    {...registerAddStock('notes')}
                    placeholder="Additional notes about this stock entry"
                  />
                </div>
                
                {/* Payment Tracking Section */}
                <div className="border-t pt-4 space-y-4">
                  <div>
                    <Label className="text-base font-semibold">Payment Information</Label>
                    <p className="text-sm text-muted-foreground">Track whether this stock was paid for or bought on credit</p>
                  </div>
                  
                  <div>
                    <Label htmlFor="payment-status">Payment Status</Label>
                    <Select
                      value={watchAddStock('paymentStatus') || 'PAID'}
                      onValueChange={(value) => setValueAddStock('paymentStatus', value as 'PAID' | 'CREDIT' | 'PARTIAL')}
                    >
                      <SelectTrigger id="payment-status">
                        <SelectValue placeholder="Select payment status" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="PAID">Paid</SelectItem>
                        <SelectItem value="CREDIT">Credit (Unpaid)</SelectItem>
                        <SelectItem value="PARTIAL">Partial Payment</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label htmlFor="supplier-name">Supplier Name (Optional)</Label>
                    <Input
                      id="supplier-name"
                      {...registerAddStock('supplierName')}
                      placeholder="Enter supplier name"
                    />
                  </div>

                  <div>
                    <Label htmlFor="supplier-contact">Supplier Contact (Optional)</Label>
                    <Input
                      id="supplier-contact"
                      {...registerAddStock('supplierContact')}
                      placeholder="Phone or email"
                    />
                  </div>

                  <div>
                    <Label htmlFor="total-cost">Total Cost (Optional)</Label>
                    <Input
                      id="total-cost"
                      type="number"
                      step="0.01"
                      {...registerAddStock('totalCost', { valueAsNumber: true })}
                      placeholder="0.00"
                    />
                  </div>

                  {watchAddStock('paymentStatus') === 'PARTIAL' && (
                    <div>
                      <Label htmlFor="paid-amount">Paid Amount</Label>
                      <Input
                        id="paid-amount"
                        type="number"
                        step="0.01"
                        {...registerAddStock('paidAmount', { valueAsNumber: true })}
                        placeholder="0.00"
                      />
                    </div>
                  )}

                  {(watchAddStock('paymentStatus') === 'CREDIT' || watchAddStock('paymentStatus') === 'PARTIAL') && (
                    <div>
                      <Label htmlFor="payment-due-date">Payment Due Date (Optional)</Label>
                      <Input
                        id="payment-due-date"
                        type="date"
                        {...registerAddStock('paymentDueDate')}
                      />
                    </div>
                  )}
                </div>

                <div className="flex justify-end gap-2 pt-4">
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => setIsAddStockDialogOpen(false)}
                    disabled={addStockMutation.isPending}
                  >
                    Cancel
                  </Button>
                  <Button type="submit" disabled={addStockMutation.isPending}>
                    {addStockMutation.isPending ? 'Adding...' : 'Add Stock'}
                  </Button>
                </div>
              </form>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Inventory Entries</CardTitle>
          <CardDescription>All stock entries (immutable records)</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex gap-4 mb-4">
            <div className="flex-1">
              <Label>Filter by Product</Label>
              <Select 
                value={productFilter || 'all'} 
                onValueChange={(value) => setProductFilter(value === 'all' ? '' : value)}
              >
                <SelectTrigger>
                  <SelectValue placeholder="All products" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All products</SelectItem>
                  {products?.map((product: any) => (
                    <SelectItem key={product.id} value={product.id}>
                      {product.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
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
              <p className="text-sm mt-2">Add stock to create inventory entries</p>
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

