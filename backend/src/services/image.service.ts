import { v2 as cloudinary } from 'cloudinary';
import { env } from '../config/env';
import { Readable } from 'stream';

// Configure Cloudinary
cloudinary.config({
  cloud_name: env.CLOUDINARY_CLOUD_NAME,
  api_key: env.CLOUDINARY_API_KEY,
  api_secret: env.CLOUDINARY_API_SECRET,
});

export interface ImageUploadResult {
  url: string;
  publicId: string;
  width: number;
  height: number;
}

/**
 * Image service abstraction layer
 * This allows easy swapping of image providers (Cloudinary, S3, etc.)
 */
export class ImageService {
  /**
   * Upload image to Cloudinary
   * @param file - File buffer or stream
   * @param folder - Optional folder path in Cloudinary
   * @returns Upload result with URL and metadata
   */
  async uploadImage(
    file: Buffer | Readable,
    folder: string = 'gebeya/products'
  ): Promise<ImageUploadResult> {
    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder,
          resource_type: 'image',
          transformation: [
            { width: 800, height: 800, crop: 'limit' },
            { quality: 'auto' },
          ],
        },
        (error, result) => {
          if (error) {
            reject(new Error(`Image upload failed: ${error.message}`));
            return;
          }

          if (!result) {
            reject(new Error('Image upload failed: No result returned'));
            return;
          }

          resolve({
            url: result.secure_url,
            publicId: result.public_id,
            width: result.width || 0,
            height: result.height || 0,
          });
        }
      );

      if (Buffer.isBuffer(file)) {
        // Convert buffer to stream
        const readable = new Readable();
        readable.push(file);
        readable.push(null);
        readable.pipe(uploadStream);
      } else {
        file.pipe(uploadStream);
      }
    });
  }

  /**
   * Delete image from Cloudinary
   * @param publicId - Cloudinary public ID
   */
  async deleteImage(publicId: string): Promise<void> {
    return new Promise((resolve, reject) => {
      cloudinary.uploader.destroy(publicId, (error, result) => {
        if (error) {
          reject(new Error(`Image deletion failed: ${error.message}`));
          return;
        }
        resolve();
      });
    });
  }

  /**
   * Get optimized image URL
   * @param publicId - Cloudinary public ID
   * @param options - Transformation options
   */
  getOptimizedUrl(
    publicId: string,
    options: {
      width?: number;
      height?: number;
      quality?: string | number;
      format?: string;
    } = {}
  ): string {
    const { width, height, quality = 'auto', format } = options;
    return cloudinary.url(publicId, {
      width,
      height,
      quality,
      format,
      secure: true,
    });
  }
}

export const imageService = new ImageService();

