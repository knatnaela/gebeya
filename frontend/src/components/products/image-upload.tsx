'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Upload, X, Image as ImageIcon } from 'lucide-react';
import { toast } from 'sonner';
import Image from 'next/image';

interface ImageUploadProps {
  value?: string;
  onChange: (url: string) => void;
  folder?: string;
}

export function ImageUpload({ value, onChange, folder = 'gebeya/products' }: ImageUploadProps) {
  const [uploading, setUploading] = useState(false);
  const [preview, setPreview] = useState<string | null>(value || null);

  const handleFileSelect = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('image/')) {
      toast.error('Please select an image file');
      return;
    }

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      toast.error('Image size must be less than 5MB');
      return;
    }

    setUploading(true);

    try {
      // Create preview
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreview(reader.result as string);
      };
      reader.readAsDataURL(file);

      // For now, we'll use the data URL or upload to Cloudinary
      // In production, this would upload to Cloudinary via backend
      toast.info('Image upload - Direct Cloudinary integration coming soon');
      
      // Temporary: Use the preview URL or allow manual URL entry
      // In production, upload to backend which handles Cloudinary
    } catch (error) {
      toast.error('Failed to upload image');
      console.error(error);
    } finally {
      setUploading(false);
    }
  };

  const handleRemove = () => {
    setPreview(null);
    onChange('');
  };

  const handleUrlChange = (url: string) => {
    onChange(url);
    if (url) {
      setPreview(url);
    }
  };

  return (
    <div className="space-y-4">
      {preview ? (
        <div className="relative">
          <div className="relative w-48 h-48 border rounded-lg overflow-hidden">
            <Image
              src={preview}
              alt="Product preview"
              fill
              className="object-cover"
            />
          </div>
          <Button
            type="button"
            variant="destructive"
            size="sm"
            onClick={handleRemove}
            className="mt-2"
          >
            <X className="mr-2 h-4 w-4" />
            Remove Image
          </Button>
        </div>
      ) : (
        <div className="border-2 border-dashed rounded-lg p-8 text-center">
          <ImageIcon className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
          <Label htmlFor="image-upload" className="cursor-pointer">
            <Button type="button" variant="outline" disabled={uploading} asChild>
              <span>
                <Upload className="mr-2 h-4 w-4" />
                {uploading ? 'Uploading...' : 'Upload Image'}
              </span>
            </Button>
          </Label>
          <Input
            id="image-upload"
            type="file"
            accept="image/*"
            onChange={handleFileSelect}
            className="hidden"
            disabled={uploading}
          />
          <p className="text-xs text-muted-foreground mt-2">
            Or enter image URL below
          </p>
        </div>
      )}

      <div className="space-y-2">
        <Label htmlFor="imageUrl">Image URL</Label>
        <Input
          id="imageUrl"
          placeholder="https://..."
          value={value || ''}
          onChange={(e) => handleUrlChange(e.target.value)}
        />
        <p className="text-xs text-muted-foreground">
          Enter a direct image URL or upload an image above
        </p>
      </div>
    </div>
  );
}

