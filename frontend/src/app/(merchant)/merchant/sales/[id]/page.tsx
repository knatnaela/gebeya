'use client';

import { useQuery } from '@tanstack/react-query';
import { useParams, useRouter } from 'next/navigation';
import apiClient from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { ArrowLeft, Receipt, Download, TrendingUp, DollarSign, Package, User } from 'lucide-react';
import { format } from 'date-fns';
import { toast } from 'sonner';
import { formatCurrency, formatCurrencySmart } from '@/lib/currency';

export default function SaleDetailPage() {
  const params = useParams();
  const router = useRouter();
  const saleId = params.id as string;

  const { data: sale, isLoading, error } = useQuery({
    queryKey: ['sale', saleId],
    queryFn: async () => {
      const res = await apiClient.get(`/sales/${saleId}`);
      return res.data.data;
    },
  });

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-4">
          <Skeleton className="h-10 w-10" />
          <Skeleton className="h-8 w-64" />
        </div>
        <div className="grid gap-4 md:grid-cols-2">
          {[...Array(4)].map((_, i) => (
            <Card key={i}>
              <CardHeader>
                <Skeleton className="h-4 w-24" />
                <Skeleton className="h-8 w-32 mt-2" />
              </CardHeader>
            </Card>
          ))}
        </div>
      </div>
    );
  }

  if (error || !sale) {
    return (
      <div className="space-y-6">
        <Button variant="ghost" onClick={() => router.back()}>
          <ArrowLeft className="mr-2 h-4 w-4" />
          Back
        </Button>
        <Card>
          <CardContent className="pt-6">
            <p className="text-center text-muted-foreground">
              Sale not found or error loading sale details.
            </p>
          </CardContent>
        </Card>
      </div>
    );
  }

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
            <h1 className="text-3xl font-bold">Sale Details</h1>
            <p className="text-muted-foreground">
              Sale Date: {format(new Date(sale.saleDate || sale.createdAt), 'MMMM d, yyyy')}
              {' • '}
              Recorded: {format(new Date(sale.createdAt), 'h:mm a')}
            </p>
            {sale.customerName && (
              <p className="text-muted-foreground">
                Customer: {sale.customerName} {sale.customerPhone && `• ${sale.customerPhone}`}
              </p>
            )}
          </div>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => window.print()}>
            <Download className="mr-2 h-4 w-4" />
            Print
          </Button>
        </div>
      </div>

      {/* Key Metrics */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card className="border-purple-100">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
            <div className="p-2 rounded-full bg-purple-100">
              <DollarSign className="h-4 w-4 text-purple-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {formatCurrencySmart(sale.totalAmount)}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Total sale amount</p>
          </CardContent>
        </Card>

        <Card className="border-orange-100">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Cost of Goods</CardTitle>
            <div className="p-2 rounded-full bg-orange-100">
              <Package className="h-4 w-4 text-orange-600" />
            </div>
          </CardHeader>
          <CardContent>
              <div className="text-2xl font-bold text-orange-600">
                {formatCurrencySmart(sale.costOfGoodsSold || 0)}
              </div>
            <p className="text-xs text-muted-foreground mt-1">Total cost</p>
          </CardContent>
        </Card>

        <Card className="border-emerald-100">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Net Income</CardTitle>
            <div className="p-2 rounded-full bg-emerald-100">
              <TrendingUp className="h-4 w-4 text-emerald-600" />
            </div>
          </CardHeader>
          <CardContent>
              <div className="text-2xl font-bold text-emerald-600">
                {formatCurrencySmart(sale.netIncome || 0)}
              </div>
            <p className="text-xs text-muted-foreground mt-1">Revenue - COGS</p>
          </CardContent>
        </Card>

        <Card className="border-cyan-100">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Profit Margin</CardTitle>
            <div className="p-2 rounded-full bg-cyan-100">
              <TrendingUp className="h-4 w-4 text-cyan-600" />
            </div>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-cyan-600">
              {Number(sale.profitMargin || 0).toFixed(2)}%
            </div>
            <p className="text-xs text-muted-foreground mt-1">Profit / Revenue</p>
          </CardContent>
        </Card>
      </div>

      {/* Sale Items */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Receipt className="h-5 w-5" />
            Sale Items
          </CardTitle>
          <CardDescription>
            {sale.sale_items?.length || 0} item(s) in this sale
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {sale.sale_items?.map((item: any, index: number) => {
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
                <div
                  key={index}
                  className="border rounded-lg p-4 hover:shadow-md transition-shadow"
                >
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex-1">
                      <h3 className="font-semibold text-lg">{item.products?.name || 'Unknown Product'}</h3>
                      {item.products?.brand && (
                        <p className="text-sm text-muted-foreground">{item.products.brand}</p>
                      )}
                      <div className="flex items-center gap-2 mt-2">
                        {item.products?.sku && (
                          <Badge variant="outline" className="text-xs">
                            SKU: {item.products.sku}
                          </Badge>
                        )}
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
                    <div className="text-right">
                      <div className="text-lg font-bold">
                        {formatCurrency(item.totalPrice)}
                      </div>
                      <div className="text-sm text-muted-foreground">
                        {item.quantity} × 
                        {defaultPrice !== soldPrice ? (
                          <>
                            <span className="line-through mx-1">{formatCurrency(defaultPrice)}</span>
                            <span className="text-green-600 font-medium">{formatCurrency(soldPrice)}</span>
                          </>
                        ) : (
                          ` ${formatCurrency(soldPrice)}`
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4 pt-3 border-t">
                    <div>
                      <p className="text-xs text-muted-foreground mb-1">Cost Price</p>
                      <p className="font-medium">{formatCurrency(costPrice)}</p>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground mb-1">
                        {defaultPrice !== soldPrice ? 'Default Price' : 'Sold Price'}
                      </p>
                      <div>
                        {defaultPrice !== soldPrice ? (
                          <>
                            <p className="font-medium line-through text-muted-foreground">{formatCurrency(defaultPrice)}</p>
                            <p className="font-medium text-green-600">{formatCurrency(soldPrice)}</p>
                          </>
                        ) : (
                          <p className="font-medium">{formatCurrency(soldPrice)}</p>
                        )}
                      </div>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground mb-1">Item Profit</p>
                      <p className={`font-medium ${itemProfit >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                        {formatCurrency(itemProfit)}
                      </p>
                    </div>
                    <div>
                      <p className="text-xs text-muted-foreground mb-1">Profit Margin</p>
                      <p className={`font-medium ${itemProfitMargin >= 0 ? 'text-blue-600' : 'text-red-600'}`}>
                        {itemProfitMargin.toFixed(2)}%
                      </p>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Sale Summary */}
      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Sale Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex justify-between">
              <span className="text-muted-foreground">Sale ID:</span>
              <span className="font-mono text-sm">{sale.id}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Sale Date:</span>
              <span>{format(new Date(sale.saleDate || sale.createdAt), 'MMM d, yyyy')}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Recorded:</span>
              <span>{format(new Date(sale.createdAt), 'MMM d, yyyy h:mm a')}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Sold By:</span>
              <div className="flex items-center gap-2">
                <User className="h-4 w-4 text-muted-foreground" />
                <span>
                  {sale.users?.firstName || ''} {sale.users?.lastName || ''}
                </span>
              </div>
            </div>
            {sale.customerName && (
              <div className="flex justify-between pt-2 border-t">
                <span className="text-muted-foreground">Customer:</span>
                <span className="font-medium">{sale.customerName}</span>
              </div>
            )}
            {sale.customerPhone && (
              <div className="flex justify-between">
                <span className="text-muted-foreground">Phone:</span>
                <span>{sale.customerPhone}</span>
              </div>
            )}
            {sale.notes && (
              <div className="pt-3 border-t">
                <p className="text-sm text-muted-foreground mb-1">Notes:</p>
                <p className="text-sm">{sale.notes}</p>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Financial Summary</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex justify-between">
              <span className="text-muted-foreground">Total Revenue:</span>
              <span className="font-medium">{formatCurrencySmart(sale.totalAmount)}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Cost of Goods Sold:</span>
              <span className="font-medium text-orange-600">
                {formatCurrencySmart(sale.costOfGoodsSold || 0)}
              </span>
            </div>
            <div className="flex justify-between pt-2 border-t text-lg font-bold">
              <span>Net Income:</span>
              <span className="text-emerald-600">
                {formatCurrencySmart(sale.netIncome || 0)}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Profit Margin:</span>
              <span className="font-medium text-cyan-600">
                {Number(sale.profitMargin || 0).toFixed(2)}%
              </span>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

