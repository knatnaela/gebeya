-- AlterEnum: extend ProductMeasureUnit for length + US/imperial units
ALTER TYPE "ProductMeasureUnit" ADD VALUE 'IN';
ALTER TYPE "ProductMeasureUnit" ADD VALUE 'CM';
ALTER TYPE "ProductMeasureUnit" ADD VALUE 'MM';
ALTER TYPE "ProductMeasureUnit" ADD VALUE 'M';
ALTER TYPE "ProductMeasureUnit" ADD VALUE 'FT';
ALTER TYPE "ProductMeasureUnit" ADD VALUE 'YD';
ALTER TYPE "ProductMeasureUnit" ADD VALUE 'OZ';
ALTER TYPE "ProductMeasureUnit" ADD VALUE 'LB';
ALTER TYPE "ProductMeasureUnit" ADD VALUE 'GAL';
ALTER TYPE "ProductMeasureUnit" ADD VALUE 'FL_OZ';
