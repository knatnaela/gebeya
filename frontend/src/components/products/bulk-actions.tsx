'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { Upload, Download, FileSpreadsheet } from 'lucide-react';
import { toast } from 'sonner';

interface BulkActionsProps {
  onBulkDelete?: (ids: string[]) => void;
  onBulkExport?: () => void;
  selectedIds: string[];
}

export function BulkActions({ onBulkDelete, onBulkExport, selectedIds }: BulkActionsProps) {
  const [isImportDialogOpen, setIsImportDialogOpen] = useState(false);
  const [isExporting, setIsExporting] = useState(false);

  const handleBulkDelete = () => {
    if (selectedIds.length === 0) {
      toast.error('Please select products to delete');
      return;
    }
    if (confirm(`Are you sure you want to delete ${selectedIds.length} product(s)?`)) {
      onBulkDelete?.(selectedIds);
    }
  };

  const handleBulkExport = async () => {
    setIsExporting(true);
    try {
      // Create CSV from selected products
      const csvContent = 'data:text/csv;charset=utf-8,';
      // This would need to fetch product data and format as CSV
      toast.success('Export functionality - Coming soon');
      onBulkExport?.();
    } catch (error) {
      toast.error('Failed to export products');
    } finally {
      setIsExporting(false);
    }
  };

  const handleImport = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    if (!file.name.endsWith('.csv')) {
      toast.error('Please upload a CSV file');
      return;
    }

    const reader = new FileReader();
    reader.onload = (e) => {
      const text = e.target?.result as string;
      // Parse CSV and import products
      toast.info('Bulk import - Coming soon');
      setIsImportDialogOpen(false);
    };
    reader.readAsText(file);
  };

  if (selectedIds.length === 0) {
    return (
      <div className="flex gap-2">
        <Button variant="outline" size="sm" onClick={() => setIsImportDialogOpen(true)}>
          <Upload className="mr-2 h-4 w-4" />
          Import CSV
        </Button>
        <Button variant="outline" size="sm" onClick={handleBulkExport} disabled={isExporting}>
          <Download className="mr-2 h-4 w-4" />
          Export CSV
        </Button>
      </div>
    );
  }

  return (
    <div className="flex items-center gap-2">
      <span className="text-sm text-muted-foreground">
        {selectedIds.length} selected
      </span>
      <Button variant="outline" size="sm" onClick={handleBulkDelete}>
        Delete Selected
      </Button>
      <Button variant="outline" size="sm" onClick={handleBulkExport} disabled={isExporting}>
        <Download className="mr-2 h-4 w-4" />
        Export Selected
      </Button>

      <Dialog open={isImportDialogOpen} onOpenChange={setIsImportDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Import Products from CSV</DialogTitle>
            <DialogDescription>
              Upload a CSV file to bulk import products. CSV should include: name, brand, size, price, costPrice, sku, barcode. Note: Stock is managed separately using the Stock Management page.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>CSV File</Label>
              <input
                type="file"
                accept=".csv"
                onChange={handleImport}
                className="w-full p-2 border rounded"
              />
            </div>
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={() => setIsImportDialogOpen(false)}>
                Cancel
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}

