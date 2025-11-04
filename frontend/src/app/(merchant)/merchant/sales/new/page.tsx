'use client';

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';
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
import { ShoppingCart, Plus, Receipt, X, ArrowLeft, Save } from 'lucide-react';
import { toast } from 'sonner';
import { formatCurrency, formatCurrencySmart } from '@/lib/currency';

interface SaleItem {
  productId: string;
  productName: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}

export default function NewSalePage() {
  const router = useRouter();
  const [isReceiptDialogOpen, setIsReceiptDialogOpen] = useState(false);
  const [selectedSale, setSelectedSale] = useState<any>(null);
  const [saleItems, setSaleItems] = useState<SaleItem[]>([]);
  const [selectedProduct, setSelectedProduct] = useState('');
  const [quantity, setQuantity] = useState('1');
  const [notes, setNotes] = useState('');
  const [saleDate, setSaleDate] = useState(new Date().toISOString().split('T')[0]); // Default to today
  const [customerName, setCustomerName] = useState('');
  const [customerPhone, setCustomerPhone] = useState('');
  const [selectedLocationId, setSelectedLocationId] = useState<string>('');
  const queryClient = useQueryClient();

  const { data: products } = useQuery({
    queryKey: ['products'],
    queryFn: async () => {
      const res = await apiClient.get('/products', { params: { isActive: true } });
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

  const createSaleMutation = useMutation({
    mutationFn: async (data: { items: any[]; locationId?: string; notes?: string; saleDate?: string; customerName?: string; customerPhone?: string }) => {
      const res = await apiClient.post('/sales', data);
      return res.data;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['sales'] });
      queryClient.invalidateQueries({ queryKey: ['products'] });
      queryClient.invalidateQueries({ queryKey: ['inventory'] });
      toast.success('Sale recorded successfully!');
      setSaleItems([]);
      setNotes('');
      setCustomerName('');
      setCustomerPhone('');
      setSaleDate(new Date().toISOString().split('T')[0]);
      setSelectedLocationId('');
      setSelectedSale(data.data);
      setIsReceiptDialogOpen(true);
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to record sale');
    },
  });

  const handleAddItem = async () => {
    if (!selectedProduct || !quantity) {
      toast.error('Please select a product and enter quantity');
      return;
    }

    const product = products?.find((p: any) => p.id === selectedProduct);
    if (!product) return;

    const qty = parseInt(quantity);
    if (qty <= 0) {
      toast.error('Quantity must be greater than 0');
      return;
    }

    // Get current stock using computed stock API
    const locationId = selectedLocationId || defaultLocation?.id;
    if (!locationId) {
      toast.error('Please select a location');
      return;
    }

    try {
      const stockRes = await apiClient.get(`/inventory/stock/${selectedProduct}`, {
        params: { locationId },
      });
      const currentStock = stockRes.data.data.stock || 0;

      if (qty > currentStock) {
        toast.error(`Insufficient stock. Available: ${currentStock}`);
        return;
      }
    } catch (error: any) {
      toast.error(error.response?.data?.error || 'Failed to check stock availability');
      return;
    }

    const unitPrice = Number(product.price);
    const totalPrice = unitPrice * qty;

    const existingIndex = saleItems.findIndex((item) => item.productId === selectedProduct);
    if (existingIndex >= 0) {
      const updated = [...saleItems];
      updated[existingIndex].quantity += qty;
      updated[existingIndex].totalPrice = updated[existingIndex].quantity * updated[existingIndex].unitPrice;
      setSaleItems(updated);
    } else {
      setSaleItems([
        ...saleItems,
        {
          productId: selectedProduct,
          productName: product.name,
          quantity: qty,
          unitPrice,
          totalPrice,
        },
      ]);
    }

    setSelectedProduct('');
    setQuantity('1');
  };

  const handleRemoveItem = (index: number) => {
    setSaleItems(saleItems.filter((_, i) => i !== index));
  };

  const handleUpdateItemPrice = (index: number, newPrice: string) => {
    const price = parseFloat(newPrice);
    if (isNaN(price) || price <= 0) {
      toast.error('Price must be a positive number');
      return;
    }
    const updated = [...saleItems];
    updated[index].unitPrice = price;
    updated[index].totalPrice = updated[index].quantity * price;
    setSaleItems(updated);
  };

  const handleCreateSale = () => {
    if (saleItems.length === 0) {
      toast.error('Please add at least one item to the sale');
      return;
    }

    const invalidItems = saleItems.filter(item => !item.unitPrice || item.unitPrice <= 0);
    if (invalidItems.length > 0) {
      toast.error('All items must have a valid sold price');
      return;
    }

    const locationId = selectedLocationId || defaultLocation?.id;
    createSaleMutation.mutate({
      items: saleItems.map((item) => ({
        productId: item.productId,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
      })),
      locationId: locationId || undefined,
      notes: notes || undefined,
      saleDate: saleDate || undefined,
      customerName: customerName || undefined,
      customerPhone: customerPhone || undefined,
    });
  };

  const totalAmount = saleItems.reduce((sum, item) => sum + item.totalPrice, 0);
  const totalCostOfGoods = saleItems.reduce((sum, item) => {
    const product = products?.find((p: any) => p.id === item.productId);
    const costPrice = product ? Number(product.costPrice || 0) : 0;
    return sum + costPrice * item.quantity;
  }, 0);
  const totalNetIncome = totalAmount - totalCostOfGoods;
  const totalProfitMargin = totalAmount > 0 ? (totalNetIncome / totalAmount) * 100 : 0;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button variant="ghost" onClick={() => router.back()}>
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back
          </Button>
          <div>
            <h1 className="text-3xl font-bold">New Sale</h1>
            <p className="text-muted-foreground">Record a new sales transaction</p>
          </div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        {/* Left Column - Product Selection & Items */}
        <div className="lg:col-span-2 space-y-6">
          {/* Add Product Section */}
          <Card>
            <CardHeader>
              <CardTitle>Add Products</CardTitle>
              <CardDescription>Select products to add to the sale</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="flex gap-2">
                <Select value={selectedProduct} onValueChange={setSelectedProduct}>
                  <SelectTrigger className="flex-1">
                    <SelectValue placeholder="Select product" />
                  </SelectTrigger>
                  <SelectContent>
                    {products?.map((product: any) => (
                      <SelectItem key={product.id} value={product.id}>
                        {product.name} - {formatCurrency(product.price)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <Input
                  type="number"
                  placeholder="Qty"
                  value={quantity}
                  onChange={(e) => setQuantity(e.target.value)}
                  className="w-24"
                  min="1"
                />
                <Button onClick={handleAddItem}>
                  <Plus className="mr-2 h-4 w-4" />
                  Add
                </Button>
              </div>
            </CardContent>
          </Card>

          {/* Sale Items Table */}
          {saleItems.length > 0 && (
            <Card>
              <CardHeader>
                <CardTitle>Sale Items</CardTitle>
                <CardDescription>{saleItems.length} item(s) in this sale</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="border rounded-lg overflow-x-auto">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead className="min-w-[200px]">Product</TableHead>
                        <TableHead className="w-[70px] text-center">Qty</TableHead>
                        <TableHead className="w-[120px]">Cost Price</TableHead>
                        <TableHead className="min-w-[200px]">Sold Price</TableHead>
                        <TableHead className="w-[130px]">Revenue</TableHead>
                        <TableHead className="w-[120px]">Profit</TableHead>
                        <TableHead className="w-[60px]"></TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {saleItems.map((item, index) => {
                        const product = products?.find((p: any) => p.id === item.productId);
                        const defaultPrice = product ? Number(product.price) : item.unitPrice;
                        const costPrice = product ? Number(product.costPrice || 0) : 0;
                        const priceDiffers = Math.abs(item.unitPrice - defaultPrice) > 0.01;
                        const itemProfit = (item.unitPrice - costPrice) * item.quantity;
                        const itemProfitMargin = item.unitPrice > 0 ? ((item.unitPrice - costPrice) / item.unitPrice) * 100 : 0;
                        
                        return (
                          <TableRow key={index}>
                            <TableCell className="font-medium">
                              <div className="text-sm">{item.productName}</div>
                              {priceDiffers && (
                                <div className="flex items-center gap-1 mt-1">
                                  {item.unitPrice < defaultPrice && (
                                    <Badge variant="outline" className="border-orange-300 text-orange-700 bg-orange-50 text-xs px-1 py-0">
                                      Discount
                                    </Badge>
                                  )}
                                  {item.unitPrice > defaultPrice && (
                                    <Badge variant="outline" className="border-green-300 text-green-700 bg-green-50 text-xs px-1 py-0">
                                      Over Price
                                    </Badge>
                                  )}
                                </div>
                              )}
                            </TableCell>
                            <TableCell className="text-center">{item.quantity}</TableCell>
                            <TableCell>
                              <span className="text-sm text-muted-foreground">{formatCurrency(costPrice)}</span>
                            </TableCell>
                            <TableCell>
                              <div className="flex items-center gap-2">
                                <Input
                                  type="number"
                                  step="0.01"
                                  value={item.unitPrice}
                                  onChange={(e) => handleUpdateItemPrice(index, e.target.value)}
                                  className={`w-28 h-9 text-sm ${priceDiffers ? (item.unitPrice < defaultPrice ? 'border-orange-300 bg-orange-50' : 'border-green-300 bg-green-50') : ''}`}
                                  required
                                />
                                {priceDiffers && (
                                  <span className="text-xs text-muted-foreground whitespace-nowrap">
                                    (Default: {formatCurrency(defaultPrice)})
                                  </span>
                                )}
                              </div>
                            </TableCell>
                            <TableCell className="font-medium text-sm">
                              {formatCurrency(item.totalPrice)}
                            </TableCell>
                            <TableCell>
                              <div className="text-sm">
                                <div className={`font-medium ${itemProfit >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                                  {formatCurrency(itemProfit)}
                                </div>
                                <div className="text-xs text-muted-foreground">
                                  {itemProfitMargin.toFixed(1)}%
                                </div>
                              </div>
                            </TableCell>
                            <TableCell>
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => handleRemoveItem(index)}
                                className="h-8 w-8 p-0"
                              >
                                <X className="h-4 w-4" />
                              </Button>
                            </TableCell>
                          </TableRow>
                        );
                      })}
                    </TableBody>
                  </Table>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Sale Information Section */}
          <Card>
            <CardHeader>
              <CardTitle>Sale Information</CardTitle>
              <CardDescription>Sale date, location, and customer details</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="location">Location</Label>
                <Select
                  value={selectedLocationId || defaultLocation?.id || ''}
                  onValueChange={setSelectedLocationId}
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
                <Label htmlFor="saleDate">Sale Date *</Label>
                <Input
                  id="saleDate"
                  type="date"
                  value={saleDate}
                  onChange={(e) => setSaleDate(e.target.value)}
                  className="mt-1"
                  required
                />
              </div>
              <div>
                <Label htmlFor="customerName">Customer Name (Optional)</Label>
                <Input
                  id="customerName"
                  type="text"
                  placeholder="Enter customer full name"
                  value={customerName}
                  onChange={(e) => setCustomerName(e.target.value)}
                  className="mt-1"
                />
              </div>
              <div>
                <Label htmlFor="customerPhone">Customer Phone (Optional)</Label>
                <Input
                  id="customerPhone"
                  type="tel"
                  placeholder="Enter customer phone number"
                  value={customerPhone}
                  onChange={(e) => setCustomerPhone(e.target.value)}
                  className="mt-1"
                />
              </div>
            </CardContent>
          </Card>

          {/* Notes Section */}
          <Card>
            <CardHeader>
              <CardTitle>Notes</CardTitle>
              <CardDescription>Optional notes for this sale</CardDescription>
            </CardHeader>
            <CardContent>
              <textarea
                className="w-full min-h-[100px] p-3 border rounded-md resize-none"
                placeholder="Add any notes about this sale..."
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
              />
            </CardContent>
          </Card>
        </div>

        {/* Right Column - Summary */}
        <div className="space-y-6">
          <Card className="sticky top-4">
            <CardHeader>
              <CardTitle>Sale Summary</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-muted-foreground">Total Revenue:</span>
                  <span className="text-lg font-bold">{formatCurrencySmart(totalAmount)}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-muted-foreground">Cost of Goods:</span>
                  <span className="font-medium text-orange-600">{formatCurrencySmart(totalCostOfGoods)}</span>
                </div>
                <div className="flex justify-between items-center pt-2 border-t">
                  <span className="text-sm font-medium">Net Income:</span>
                  <span className="text-xl font-bold text-green-600">{formatCurrencySmart(totalNetIncome)}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-muted-foreground">Profit Margin:</span>
                  <span className="font-medium text-blue-600">{totalProfitMargin.toFixed(2)}%</span>
                </div>
              </div>

              <div className="pt-4 border-t space-y-2">
                <Button
                  onClick={handleCreateSale}
                  disabled={createSaleMutation.isPending || saleItems.length === 0}
                  className="w-full"
                  size="lg"
                >
                  <Save className="mr-2 h-4 w-4" />
                  {createSaleMutation.isPending ? 'Recording...' : 'Record Sale'}
                </Button>
                <Button
                  variant="outline"
                  onClick={() => router.back()}
                  className="w-full"
                >
                  Cancel
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

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
                  <span>{new Date(selectedSale.saleDate || selectedSale.createdAt).toLocaleDateString()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Recorded:</span>
                  <span>{new Date(selectedSale.createdAt).toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Sold by:</span>
                  <span>
                    {selectedSale.users?.firstName || ''} {selectedSale.users?.lastName || ''}
                  </span>
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
                  <span className="font-medium">{formatCurrency(selectedSale.totalAmount)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Cost of Goods:</span>
                  <span className="font-medium">{formatCurrency(selectedSale.costOfGoodsSold || 0)}</span>
                </div>
                <div className="flex justify-between text-lg font-bold border-t pt-2">
                  <span>Net Income:</span>
                  <span className="text-green-600">{formatCurrency(selectedSale.netIncome || 0)}</span>
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
                <Button variant="outline" onClick={() => {
                  setIsReceiptDialogOpen(false);
                  router.push('/merchant/sales');
                }}>
                  View All Sales
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}

