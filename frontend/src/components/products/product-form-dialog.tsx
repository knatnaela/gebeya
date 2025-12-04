'use client';

import { useEffect } from 'react';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Checkbox as UICheckbox } from '@/components/ui/checkbox';
import { toast } from 'sonner';
import { useForm, Controller } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';

export const productSchema = z.object({
  name: z.string().min(1, 'Product name is required'),
  brand: z.string().optional(),
  size: z.string().optional(),
  price: z.number().positive('Selling price must be positive'),
  costPrice: z.number().positive('Cost price must be positive'),
  sku: z.string().optional(),
  barcode: z.string().optional(),
  description: z.string().optional(),
  lowStockThreshold: z.number().int().min(0).optional(),
  imageUrl: z.string().url().optional().or(z.literal('')),
  isActive: z.boolean().optional(),
});

export type ProductFormData = z.infer<typeof productSchema>;

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
  const {
    register,
    handleSubmit,
    reset,
    control,
    formState: { errors },
  } = useForm<ProductFormData>({
    resolver: zodResolver(productSchema),
    defaultValues: {
      name: '',
      brand: '',
      size: '',
      price: 0,
      costPrice: 0,
      sku: '',
      barcode: '',
      description: '',
      lowStockThreshold: 5,
      imageUrl: '',
      isActive: true,
      ...initialValues,
    },
  });

  useEffect(() => {
    if (open) {
      reset({
        name: '',
        brand: '',
        size: '',
        price: 0,
        costPrice: 0,
        sku: '',
        barcode: '',
        description: '',
        lowStockThreshold: 5,
        imageUrl: '',
        isActive: mode === 'edit' ? initialValues?.isActive ?? true : true,
        ...initialValues,
      });
    }
  }, [open, initialValues, mode, reset]);

  const handleClose = () => {
    onOpenChange(false);
  };

  const internalSubmit = (data: ProductFormData) => {
    onSubmit(data);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{mode === 'edit' ? 'Edit Product' : 'Add New Product'}</DialogTitle>
          <DialogDescription>
            {mode === 'edit'
              ? 'Update product information'
              : 'Fill in the details to add a new product to your inventory'}
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit(internalSubmit)} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="name">Product Name *</Label>
              <Input id="name" {...register('name')} />
              {errors.name && (
                <p className="text-sm text-destructive">{errors.name.message}</p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="brand">Brand</Label>
              <Input id="brand" {...register('brand')} />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="size">Size</Label>
              <Input id="size" placeholder="e.g., 50ml" {...register('size')} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="price">Selling Price *</Label>
              <Input
                id="price"
                type="number"
                step="0.01"
                {...register('price', { valueAsNumber: true })}
              />
              {errors.price && (
                <p className="text-sm text-destructive">{errors.price.message}</p>
              )}
            </div>
            <div className="space-y-2">
              <Label htmlFor="costPrice">Cost Price (Bought Price) *</Label>
              <Input
                id="costPrice"
                type="number"
                step="0.01"
                {...register('costPrice', { valueAsNumber: true })}
              />
              {errors.costPrice && (
                <p className="text-sm text-destructive">{errors.costPrice.message}</p>
              )}
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="sku">SKU</Label>
              <Input id="sku" {...register('sku')} />
            </div>
            <div className="space-y-2">
              <Label htmlFor="barcode">Barcode</Label>
              <Input id="barcode" {...register('barcode')} />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="description">Description</Label>
            <Input id="description" {...register('description')} />
          </div>

          <div className="space-y-2">
            <Label htmlFor="lowStockThreshold">Low Stock Threshold</Label>
            <Input
              id="lowStockThreshold"
              type="number"
              {...register('lowStockThreshold', { valueAsNumber: true })}
              placeholder="Default: 5"
            />
            <p className="text-xs text-muted-foreground">
              Stock is managed separately. Add stock using the Stock Management page.
            </p>
          </div>

          {mode === 'edit' && (
            <div className="flex items-center space-x-2">
              <Controller
                name="isActive"
                control={control}
                render={({ field }) => (
                  <UICheckbox
                    id="isActive"
                    checked={field.value ?? true}
                    onCheckedChange={field.onChange}
                  />
                )}
              />
              <Label htmlFor="isActive" className="cursor-pointer">
                Product is active
              </Label>
            </div>
          )}

          <div className="space-y-2">
            <Label>Product Image</Label>
            <div className="border rounded-lg p-4">
              <input
                type="file"
                accept="image/*"
                onChange={(e) => {
                  const file = e.target.files?.[0];
                  if (file) {
                    const reader = new FileReader();
                    reader.onload = () => {
                      // In production, this would upload to Cloudinary via backend
                      toast.info('Image upload feature - Use URL for now');
                    };
                    reader.readAsDataURL(file);
                  }
                }}
                className="w-full"
              />
              <Input
                id="imageUrl"
                placeholder="https://..."
                {...register('imageUrl')}
                className="mt-2"
              />
              <p className="text-xs text-muted-foreground mt-2">
                Upload image or enter direct URL (Cloudinary upload via backend coming soon)
              </p>
            </div>
          </div>

          <div className="flex justify-end gap-2 pt-4">
            <Button
              type="button"
              variant="outline"
              onClick={handleClose}
              disabled={isSubmitting}
            >
              Cancel
            </Button>
            <Button type="submit" disabled={isSubmitting}>
              {mode === 'edit' ? 'Update' : 'Create'} Product
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}


