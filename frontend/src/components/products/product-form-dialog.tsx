'use client';

import {
  Dialog,
  MerchantDialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { ProductForm, type ProductFormData } from './product-form';

export * from './product-form';

type ProductFormDialogProps = {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  mode: 'create' | 'edit';
  initialValues?: Partial<ProductFormData>;
  isSubmitting?: boolean;
  onSubmit: (data: ProductFormData) => void;
};

export function ProductFormDialog({
  open,
  onOpenChange,
  mode,
  initialValues,
  isSubmitting,
  onSubmit,
}: ProductFormDialogProps) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <MerchantDialogContent className="sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle>{mode === 'edit' ? 'Edit Product' : 'Add New Product'}</DialogTitle>
          <DialogDescription>
            {mode === 'edit'
              ? 'Update product information'
              : 'Fill in the details to add a new product to your inventory'}
          </DialogDescription>
        </DialogHeader>
        <ProductForm
          mode={mode}
          initialValues={initialValues}
          isSubmitting={isSubmitting}
          onSubmit={onSubmit}
          onCancel={() => onOpenChange(false)}
          dialogOpen={open}
        />
      </MerchantDialogContent>
    </Dialog>
  );
}
