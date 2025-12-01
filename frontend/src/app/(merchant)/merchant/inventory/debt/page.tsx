'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
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
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { AlertCircle, DollarSign, CreditCard, TrendingUp, CheckCircle2 } from 'lucide-react';
import { toast } from 'sonner';
import { format } from 'date-fns';
import { formatCurrencySmart } from '@/lib/currency';
import { useState } from 'react';

export default function DebtDashboardPage() {
  const queryClient = useQueryClient();
  const [selectedItem, setSelectedItem] = useState<any>(null);
  const [isMarkPaidDialogOpen, setIsMarkPaidDialogOpen] = useState(false);
  const [paidAmount, setPaidAmount] = useState('');

  const { data: debtSummary, isLoading } = useQuery({
    queryKey: ['debt-summary'],
    queryFn: async () => {
      const res = await apiClient.get('/inventory/debt-summary');
      return res.data.data;
    },
  });

  const markAsPaidMutation = useMutation({
    mutationFn: async ({ inventoryId, amount }: { inventoryId: string; amount?: number }) => {
      const payload: any = {};
      if (amount !== undefined) payload.paidAmount = amount;
      const res = await apiClient.patch(`/inventory/entries/${inventoryId}/mark-paid`, payload);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['debt-summary'] });
      queryClient.invalidateQueries({ queryKey: ['inventory-entries'] });
      toast.success('Payment recorded successfully');
      setIsMarkPaidDialogOpen(false);
      setSelectedItem(null);
      setPaidAmount('');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to record payment');
    },
  });

  const handleMarkAsPaid = (item: any) => {
    setSelectedItem(item);
    setPaidAmount(item.outstandingAmount.toString());
    setIsMarkPaidDialogOpen(true);
  };

  const handleSubmitPayment = () => {
    if (!selectedItem) return;
    const amount = paidAmount ? parseFloat(paidAmount) : undefined;
    markAsPaidMutation.mutate({ inventoryId: selectedItem.id, amount });
  };

  if (isLoading) {
    return (
      <div className="container mx-auto py-8">
        <div className="text-center py-8 text-muted-foreground">Loading debt summary...</div>
      </div>
    );
  }

  const summary = debtSummary || {
    totalDebt: 0,
    totalCredit: 0,
    totalPartial: 0,
    unpaidCount: 0,
    unpaidItems: [],
    supplierDebts: [],
  };

  return (
    <div className="container mx-auto py-8 space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Debt & Credit Management</h1>
        <p className="text-muted-foreground">Track outstanding payments for inventory purchases</p>
      </div>

      {/* Summary Cards */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card className="border-red-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Debt</CardTitle>
            <AlertCircle className="h-4 w-4 text-red-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">
              {formatCurrencySmart(summary.totalDebt || 0)}
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              {summary.unpaidCount || 0} unpaid {summary.unpaidCount === 1 ? 'item' : 'items'}
            </p>
          </CardContent>
        </Card>

        <Card className="border-orange-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Full Credit</CardTitle>
            <CreditCard className="h-4 w-4 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">
              {formatCurrencySmart(summary.totalCredit || 0)}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Completely unpaid items</p>
          </CardContent>
        </Card>

        <Card className="border-yellow-200">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Partial Payments</CardTitle>
            <TrendingUp className="h-4 w-4 text-yellow-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-yellow-600">
              {formatCurrencySmart(summary.totalPartial || 0)}
            </div>
            <p className="text-xs text-muted-foreground mt-1">Partially paid items</p>
          </CardContent>
        </Card>
      </div>

      {/* Supplier Breakdown */}
      {summary.supplierDebts && summary.supplierDebts.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Debt by Supplier</CardTitle>
            <CardDescription>Outstanding amounts grouped by supplier</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {summary.supplierDebts.map((supplier: any, index: number) => (
                <div key={index} className="flex items-center justify-between p-3 border rounded-lg">
                  <div>
                    <p className="font-medium">{supplier.name}</p>
                    {supplier.contact && (
                      <p className="text-sm text-muted-foreground">{supplier.contact}</p>
                    )}
                    <p className="text-xs text-muted-foreground mt-1">
                      {supplier.items.length} {supplier.items.length === 1 ? 'item' : 'items'}
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-lg font-bold text-red-600">
                      {formatCurrencySmart(supplier.totalDebt)}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Unpaid Items Table */}
      <Card>
        <CardHeader>
          <CardTitle>Unpaid Inventory Items</CardTitle>
          <CardDescription>
            All inventory purchases that haven't been fully paid
          </CardDescription>
        </CardHeader>
        <CardContent>
          {summary.unpaidItems && summary.unpaidItems.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Date</TableHead>
                  <TableHead>Product</TableHead>
                  <TableHead>Supplier</TableHead>
                  <TableHead>Quantity</TableHead>
                  <TableHead>Total Cost</TableHead>
                  <TableHead>Paid</TableHead>
                  <TableHead>Outstanding</TableHead>
                  <TableHead>Due Date</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {summary.unpaidItems.map((item: any) => (
                  <TableRow key={item.id}>
                    <TableCell>
                      {format(new Date(item.receivedDate), 'MMM d, yyyy')}
                    </TableCell>
                    <TableCell className="font-medium">{item.productName}</TableCell>
                    <TableCell>
                      {item.supplierName || (
                        <span className="text-muted-foreground">-</span>
                      )}
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">{item.quantity}</Badge>
                    </TableCell>
                    <TableCell>{formatCurrencySmart(item.totalCost)}</TableCell>
                    <TableCell>{formatCurrencySmart(item.paidAmount)}</TableCell>
                    <TableCell className="font-semibold text-red-600">
                      {formatCurrencySmart(item.outstandingAmount)}
                    </TableCell>
                    <TableCell>
                      {item.paymentDueDate ? (
                        format(new Date(item.paymentDueDate), 'MMM d, yyyy')
                      ) : (
                        <span className="text-muted-foreground">-</span>
                      )}
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant={
                          item.paymentStatus === 'CREDIT'
                            ? 'destructive'
                            : item.paymentStatus === 'PARTIAL'
                            ? 'secondary'
                            : 'default'
                        }
                      >
                        {item.paymentStatus}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleMarkAsPaid(item)}
                      >
                        <CheckCircle2 className="h-4 w-4 mr-1" />
                        Mark Paid
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <div className="text-center py-8 text-muted-foreground">
              <CheckCircle2 className="h-12 w-12 mx-auto mb-4 opacity-50" />
              <p>No outstanding debts</p>
              <p className="text-sm mt-2">All inventory purchases have been paid</p>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Mark as Paid Dialog */}
      <Dialog open={isMarkPaidDialogOpen} onOpenChange={setIsMarkPaidDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Record Payment</DialogTitle>
            <DialogDescription>
              Mark this inventory purchase as paid or record a partial payment
            </DialogDescription>
          </DialogHeader>
          {selectedItem && (
            <div className="space-y-4">
              <div className="p-3 bg-muted rounded-lg">
                <p className="text-sm text-muted-foreground">Product</p>
                <p className="font-medium">{selectedItem.productName}</p>
                <p className="text-sm text-muted-foreground mt-2">Outstanding Amount</p>
                <p className="text-lg font-bold text-red-600">
                  {formatCurrencySmart(selectedItem.outstandingAmount)}
                </p>
              </div>

              <div>
                <Label htmlFor="paid-amount">
                  Paid Amount (leave empty to mark as fully paid)
                </Label>
                <Input
                  id="paid-amount"
                  type="number"
                  step="0.01"
                  value={paidAmount}
                  onChange={(e) => setPaidAmount(e.target.value)}
                  placeholder={selectedItem.outstandingAmount.toString()}
                />
                <p className="text-xs text-muted-foreground mt-1">
                  Enter the amount paid. If left empty, the full outstanding amount will be marked
                  as paid.
                </p>
              </div>

              <div className="flex justify-end gap-2 pt-4">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => {
                    setIsMarkPaidDialogOpen(false);
                    setSelectedItem(null);
                    setPaidAmount('');
                  }}
                  disabled={markAsPaidMutation.isPending}
                >
                  Cancel
                </Button>
                <Button
                  onClick={handleSubmitPayment}
                  disabled={markAsPaidMutation.isPending}
                >
                  {markAsPaidMutation.isPending ? 'Recording...' : 'Record Payment'}
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}

