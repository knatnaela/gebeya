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
import { Receipt, Plus, Search, Edit, Trash2, Calendar } from 'lucide-react';
import Link from 'next/link';
import { toast } from 'sonner';
import { format } from 'date-fns';
import { formatCurrency, formatCurrencySmart } from '@/lib/currency';
import { SubscriptionErrorMessage } from '@/components/subscription/subscription-error-message';
import { DateFilter } from '@/components/filters/date-filter';

const EXPENSE_CATEGORIES = [
  'MARKETING',
  'RENT',
  'FUEL',
  'UTILITIES',
  'SALARIES',
  'MAINTENANCE',
  'SUPPLIES',
  'INSURANCE',
  'TAXES',
  'OTHER',
] as const;

export default function ExpensesPage() {
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState<string>('all');
  const [startDate, setStartDate] = useState<string | undefined>(undefined);
  const [endDate, setEndDate] = useState<string | undefined>(undefined);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [expenseToDelete, setExpenseToDelete] = useState<any>(null);
  const queryClient = useQueryClient();

  const { data: expensesData, isLoading, error } = useQuery({
    queryKey: ['expenses', categoryFilter, startDate, endDate],
    queryFn: async () => {
      const params: any = {};
      if (categoryFilter !== 'all') {
        params.category = categoryFilter;
      }
      if (startDate) {
        params.startDate = startDate;
      }
      if (endDate) {
        params.endDate = endDate;
      }
      const res = await apiClient.get('/expenses', { params });
      return {
        expenses: res.data.data || [],
        pagination: res.data.pagination || { page: 1, limit: 20, total: 0, totalPages: 0 },
      };
    },
    retry: false,
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      await apiClient.delete(`/expenses/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['expenses'] });
      toast.success('Expense deleted successfully');
      setIsDeleteDialogOpen(false);
      setExpenseToDelete(null);
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to delete expense');
    },
  });

  const handleDelete = (expense: any) => {
    setExpenseToDelete(expense);
    setIsDeleteDialogOpen(true);
  };

  const confirmDelete = () => {
    if (expenseToDelete) {
      deleteMutation.mutate(expenseToDelete.id);
    }
  };

  const getCategoryColor = (category: string) => {
    const colors: Record<string, string> = {
      MARKETING: 'bg-purple-100 text-purple-800',
      RENT: 'bg-blue-100 text-blue-800',
      FUEL: 'bg-orange-100 text-orange-800',
      UTILITIES: 'bg-yellow-100 text-yellow-800',
      SALARIES: 'bg-green-100 text-green-800',
      MAINTENANCE: 'bg-red-100 text-red-800',
      SUPPLIES: 'bg-cyan-100 text-cyan-800',
      INSURANCE: 'bg-indigo-100 text-indigo-800',
      TAXES: 'bg-pink-100 text-pink-800',
      OTHER: 'bg-gray-100 text-gray-800',
    };
    return colors[category] || colors.OTHER;
  };

  const totalExpenses = expensesData?.expenses?.reduce(
    (sum: number, exp: any) => sum + Number(exp.amount || 0),
    0
  ) || 0;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Expenses</h1>
          <p className="text-muted-foreground">Track and manage business expenses</p>
        </div>
        <Link href="/merchant/expenses/new">
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            Add Expense
          </Button>
        </Link>
      </div>

      {/* Summary Card */}
      <Card>
        <CardHeader>
          <CardTitle>Total Expenses</CardTitle>
          <CardDescription>All expenses in the selected period</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="text-3xl font-bold text-red-600">
            {formatCurrencySmart(totalExpenses)}
          </div>
        </CardContent>
      </Card>

      {/* Filters */}
      <Card>
        <CardHeader>
          <CardTitle>Filters</CardTitle>
          <CardDescription>Filter expenses by category and date range</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <Label>Category</Label>
              <Select 
                value={categoryFilter} 
                onValueChange={setCategoryFilter}
              >
                <SelectTrigger>
                  <SelectValue placeholder="All Categories" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Categories</SelectItem>
                  {EXPENSE_CATEGORIES.map((cat) => (
                    <SelectItem key={cat} value={cat}>
                      {cat.replace('_', ' ')}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="flex items-end">
              <Button
                variant="outline"
                onClick={() => {
                  setCategoryFilter('all');
                  setStartDate(undefined);
                  setEndDate(undefined);
                }}
              >
                Clear Filters
              </Button>
            </div>
          </div>
          <DateFilter
            onDateChange={(start, end) => {
              setStartDate(start);
              setEndDate(end);
            }}
            defaultPreset="all-time"
            value={{ startDate, endDate }}
          />
        </CardContent>
      </Card>

      {/* Expenses Table */}
      <Card>
        <CardHeader>
          <CardTitle>Expense History</CardTitle>
          <CardDescription>All recorded expenses</CardDescription>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="text-center py-8">Loading expenses...</div>
          ) : error ? (
            <SubscriptionErrorMessage error={error} title="Cannot Load Expenses" />
          ) : expensesData?.expenses && expensesData.expenses.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Date</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>Description</TableHead>
                  <TableHead>Amount</TableHead>
                  <TableHead>Recorded By</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {expensesData.expenses.map((expense: any) => (
                  <TableRow key={expense.id}>
                    <TableCell>
                      {format(new Date(expense.expenseDate || expense.createdAt), 'MMM d, yyyy')}
                    </TableCell>
                    <TableCell>
                      <Badge className={getCategoryColor(expense.category)}>
                        {expense.category.replace('_', ' ')}
                      </Badge>
                    </TableCell>
                    <TableCell className="max-w-md">
                      {expense.description || (
                        <span className="text-muted-foreground text-sm">-</span>
                      )}
                    </TableCell>
                    <TableCell className="font-medium text-red-600">
                      {formatCurrency(Number(expense.amount))}
                    </TableCell>
                    <TableCell>
                      {expense.users?.firstName || ''} {expense.users?.lastName || ''}
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex justify-end gap-2">
                        <Link href={`/merchant/expenses/${expense.id}`}>
                          <Button variant="ghost" size="sm">
                            <Edit className="h-4 w-4" />
                          </Button>
                        </Link>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleDelete(expense)}
                        >
                          <Trash2 className="h-4 w-4 text-destructive" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <div className="text-center py-8">
              <Receipt className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No expenses recorded yet</p>
              <Link href="/merchant/expenses/new">
                <Button className="mt-4">
                  <Plus className="mr-2 h-4 w-4" />
                  Record Your First Expense
                </Button>
              </Link>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Delete Confirmation Dialog */}
      <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete Expense</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete this expense? This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          {expenseToDelete && (
            <div className="py-4">
              <p className="text-sm text-muted-foreground">
                <strong>Category:</strong> {expenseToDelete.category.replace('_', ' ')}
              </p>
              <p className="text-sm text-muted-foreground">
                <strong>Amount:</strong> {formatCurrency(Number(expenseToDelete.amount))}
              </p>
              {expenseToDelete.description && (
                <p className="text-sm text-muted-foreground">
                  <strong>Description:</strong> {expenseToDelete.description}
                </p>
              )}
            </div>
          )}
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setIsDeleteDialogOpen(false)}>
              Cancel
            </Button>
            <Button variant="destructive" onClick={confirmDelete}>
              Delete
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

