'use client';

import { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import apiClient from '@/lib/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import { ArrowLeft, Save } from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';

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

export default function NewExpensePage() {
  const router = useRouter();
  const queryClient = useQueryClient();
  const [category, setCategory] = useState<string>('');
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');
  const [expenseDate, setExpenseDate] = useState(
    new Date().toISOString().split('T')[0]
  );

  const createMutation = useMutation({
    mutationFn: async (data: {
      category: string;
      amount: number;
      description?: string;
      expenseDate?: string;
    }) => {
      const res = await apiClient.post('/expenses', data);
      return res.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['expenses'] });
      toast.success('Expense created successfully');
      router.push('/merchant/expenses');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || 'Failed to create expense');
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!category) {
      toast.error('Please select a category');
      return;
    }

    const amountNum = parseFloat(amount);
    if (isNaN(amountNum) || amountNum <= 0) {
      toast.error('Please enter a valid amount greater than 0');
      return;
    }

    createMutation.mutate({
      category: category as any,
      amount: amountNum,
      description: description || undefined,
      expenseDate: expenseDate || undefined,
    });
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link href="/merchant/expenses">
          <Button variant="ghost" size="sm">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back
          </Button>
        </Link>
        <div>
          <h1 className="text-3xl font-bold">New Expense</h1>
          <p className="text-muted-foreground">Record a new business expense</p>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Expense Details</CardTitle>
          <CardDescription>Enter the details of the expense</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="category">Category *</Label>
              <Select value={category} onValueChange={setCategory} required>
                <SelectTrigger id="category">
                  <SelectValue placeholder="Select a category" />
                </SelectTrigger>
                <SelectContent>
                  {EXPENSE_CATEGORIES.map((cat) => (
                    <SelectItem key={cat} value={cat}>
                      {cat.replace('_', ' ')}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="amount">Amount *</Label>
              <Input
                id="amount"
                type="number"
                step="0.01"
                min="0.01"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                placeholder="0.00"
                required
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="expenseDate">Expense Date *</Label>
              <Input
                id="expenseDate"
                type="date"
                value={expenseDate}
                onChange={(e) => setExpenseDate(e.target.value)}
                required
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="description">Description</Label>
              <Textarea
                id="description"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Optional description or notes about this expense"
                rows={4}
              />
            </div>

            <div className="flex justify-end gap-2 pt-4">
              <Link href="/merchant/expenses">
                <Button type="button" variant="outline">
                  Cancel
                </Button>
              </Link>
              <Button type="submit" disabled={createMutation.isPending}>
                <Save className="mr-2 h-4 w-4" />
                {createMutation.isPending ? 'Creating...' : 'Create Expense'}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}

