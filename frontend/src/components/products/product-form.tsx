'use client';

import { useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Checkbox as UICheckbox } from '@/components/ui/checkbox';
import { toast } from 'sonner';
import { useForm, Controller } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';

export const PRODUCT_MEASURE_UNITS = [
  'PCS',
  'ML',
  'L',
  'G',
  'KG',
  'IN',
  'CM',
  'MM',
  'M',
  'FT',
  'YD',
  'OZ',
  'LB',
  'GAL',
  'FL_OZ',
] as const;
export type ProductMeasureUnit = (typeof PRODUCT_MEASURE_UNITS)[number];

/** Short suffix for size labels (e.g. "100 ml") — shared with product table display */
export const PRODUCT_MEASURE_UNIT_SHORT_LABELS: Record<ProductMeasureUnit, string> = {
  PCS: 'pcs',
  ML: 'ml',
  L: 'L',
  G: 'g',
  KG: 'kg',
  IN: 'in',
  CM: 'cm',
  MM: 'mm',
  M: 'm',
  FT: 'ft',
  YD: 'yd',
  OZ: 'oz',
  LB: 'lb',
  GAL: 'gal',
  FL_OZ: 'fl oz',
};

const PRODUCT_MEASURE_UNIT_FORM_LABELS: Record<ProductMeasureUnit, string> = {
  PCS: 'Pieces (pcs)',
  ML: 'Milliliters (ml)',
  L: 'Liters (L)',
  G: 'Grams (g)',
  KG: 'Kilograms (kg)',
  IN: 'Inches (in)',
  CM: 'Centimeters (cm)',
  MM: 'Millimeters (mm)',
  M: 'Meters (m)',
  FT: 'Feet (ft)',
  YD: 'Yards (yd)',
  OZ: 'Ounces (oz)',
  LB: 'Pounds (lb)',
  GAL: 'Gallons (gal)',
  FL_OZ: 'Fluid ounces (fl oz)',
};

export const productSchema = z.object({
  name: z.string().min(1, 'Product name is required'),
  brand: z.string().optional(),
  size: z.string().optional(),
  measureUnit: z.enum(PRODUCT_MEASURE_UNITS),
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

export function apiProductToFormValues(product: any): Partial<ProductFormData> {
  return {
    name: product.name,
    brand: product.brand || '',
    size: product.size || '',
    measureUnit: product.measureUnit || 'ML',
    price: Number(product.price),
    costPrice: Number(product.costPrice || 0),
    sku: product.sku || '',
    barcode: product.barcode || '',
    description: product.description || '',
    lowStockThreshold: product.lowStockThreshold,
    imageUrl: product.imageUrl || '',
    isActive: product.isActive ?? true,
  };
}

function buildDefaultValues(
  mode: 'create' | 'edit',
  initialValues?: Partial<ProductFormData>
): ProductFormData {
  return {
    name: '',
    brand: '',
    size: '',
    measureUnit: 'ML',
    price: 0,
    costPrice: 0,
    sku: '',
    barcode: '',
    description: '',
    lowStockThreshold: 5,
    imageUrl: '',
    isActive: mode === 'edit' ? initialValues?.isActive ?? true : true,
    ...initialValues,
  } as ProductFormData;
}

export type ProductFormProps = {
  mode: 'create' | 'edit';
  initialValues?: Partial<ProductFormData>;
  isSubmitting?: boolean;
  onSubmit: (data: ProductFormData) => void;
  onCancel?: () => void;
  /** Hide bottom Cancel / Submit row (use external buttons with form id) */
  hideFooterActions?: boolean;
  formId?: string;
  className?: string;
  /**
   * When used inside a dialog: pass `open` so the form resets when the dialog opens.
   * Omit on full pages (always sync from initialValues).
   */
  dialogOpen?: boolean;
};

export function ProductForm({
  mode,
  initialValues,
  isSubmitting,
  onSubmit,
  onCancel,
  hideFooterActions = false,
  formId = 'product-form',
  className,
  dialogOpen,
}: ProductFormProps) {
  const {
    register,
    handleSubmit,
    reset,
    control,
    formState: { errors },
  } = useForm<ProductFormData>({
    resolver: zodResolver(productSchema),
    defaultValues: buildDefaultValues(mode, initialValues),
  });

  useEffect(() => {
    if (dialogOpen === false) return;
    reset(buildDefaultValues(mode, initialValues));
  }, [dialogOpen, initialValues, mode, reset]);

  return (
    <form
      id={formId}
      onSubmit={handleSubmit(onSubmit)}
      className={className}
    >
      <div className="space-y-4">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
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

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div className="space-y-2">
            <Label htmlFor="size">Size</Label>
            <Input id="size" placeholder="e.g. 100 (shown with unit)" {...register('size')} />
          </div>
          <div className="space-y-2">
            <Label htmlFor="measureUnit">Measure unit (for size label) *</Label>
            <Controller
              name="measureUnit"
              control={control}
              render={({ field }) => (
                <Select value={field.value} onValueChange={field.onChange}>
                  <SelectTrigger id="measureUnit">
                    <SelectValue placeholder="Select unit" />
                  </SelectTrigger>
                  <SelectContent className="max-h-[min(24rem,70vh)]">
                    {PRODUCT_MEASURE_UNITS.map((u) => (
                      <SelectItem key={u} value={u}>
                        {PRODUCT_MEASURE_UNIT_FORM_LABELS[u]}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              )}
            />
            <p className="text-xs text-muted-foreground">Stock is still counted in bottles/units.</p>
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

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
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

        {!hideFooterActions && (
          <div className="flex justify-end gap-2 pt-4">
            <Button
              type="button"
              variant="outline"
              onClick={onCancel}
              disabled={isSubmitting}
            >
              Cancel
            </Button>
            <Button type="submit" disabled={isSubmitting}>
              {mode === 'edit' ? 'Update' : 'Create'} Product
            </Button>
          </div>
        )}
      </div>
    </form>
  );
}
