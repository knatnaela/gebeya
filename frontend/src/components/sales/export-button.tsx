'use client';

import { Button } from '@/components/ui/button';
import { Download } from 'lucide-react';
import { toast } from 'sonner';

interface ExportButtonProps {
  data: any[];
  filename: string;
  type?: 'sales' | 'products' | 'inventory';
}

export function ExportButton({ data, filename, type = 'sales' }: ExportButtonProps) {
  const handleExport = () => {
    if (!data || data.length === 0) {
      toast.error('No data to export');
      return;
    }

    let csv: string;
    let headers: string[];

    if (type === 'sales') {
      headers = ['Date', 'Total Amount', 'Items Count', 'User'];
      csv = [
        headers,
        ...data.map((sale: any) => [
          new Date(sale.createdAt).toLocaleDateString(),
          sale.totalAmount,
          sale.items?.length || 0,
          `${sale.user?.firstName || ''} ${sale.user?.lastName || ''}`.trim(),
        ]),
      ]
        .map((row) => row.map((cell) => `"${cell}"`).join(','))
        .join('\n');
    } else if (type === 'products') {
      headers = ['Name', 'Brand', 'Size', 'Price', 'SKU'];
      csv = [
        headers,
        ...data.map((product: any) => [
          product.name,
          product.brand || '',
          product.size || '',
          product.price,
          product.sku || '',
        ]),
      ]
        .map((row) => row.map((cell) => `"${cell}"`).join(','))
        .join('\n');
    } else {
      headers = ['Date', 'Product', 'Location', 'Type', 'Quantity', 'Reason', 'User'];
      csv = [
        headers,
        ...data.map((tx: any) => [
          new Date(tx.createdAt).toLocaleDateString(),
          tx.product?.name || '',
          tx.location?.name || '',
          tx.type,
          tx.quantity,
          tx.reason || '',
          `${tx.user?.firstName || ''} ${tx.user?.lastName || ''}`.trim(),
        ]),
      ]
        .map((row) => row.map((cell) => `"${cell}"`).join(','))
        .join('\n');
    }

    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `${filename}-${Date.now()}.csv`;
    link.click();
    window.URL.revokeObjectURL(url);

    toast.success(`Exported ${data.length} records`);
  };

  return (
    <Button variant="outline" size="sm" onClick={handleExport}>
      <Download className="mr-2 h-4 w-4" />
      Export CSV
    </Button>
  );
}

