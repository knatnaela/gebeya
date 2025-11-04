/**
 * Currency formatting utility for Ethiopian Birr
 */

export const formatCurrency = (amount: number | string | null | undefined): string => {
  if (amount === null || amount === undefined || amount === '') {
    return 'ETB 0.00';
  }
  const numAmount = typeof amount === 'string' ? parseFloat(amount) : amount;
  if (isNaN(numAmount)) {
    return 'ETB 0.00';
  }
  return `ETB ${numAmount.toFixed(2)}`;
};

export const formatCurrencyCompact = (amount: number | string | null | undefined): string => {
  if (amount === null || amount === undefined || amount === '') {
    return 'ETB 0';
  }
  const numAmount = typeof amount === 'string' ? parseFloat(amount) : amount;
  if (isNaN(numAmount)) {
    return 'ETB 0';
  }
  // If it's a whole number, don't show decimals
  if (numAmount % 1 === 0) {
    return `ETB ${numAmount.toFixed(0)}`;
  }
  return `ETB ${numAmount.toFixed(2)}`;
};

/**
 * Smart currency formatter that uses compact notation for large values
 * - Values >= 1000: Shows as "ETB 1.5k", "ETB 2.3k", etc.
 * - Values < 1000: Shows full amount with decimals
 */
export const formatCurrencySmart = (amount: number | string | null | undefined): string => {
  if (amount === null || amount === undefined || amount === '') {
    return 'ETB 0.00';
  }
  const numAmount = typeof amount === 'string' ? parseFloat(amount) : amount;
  if (isNaN(numAmount)) {
    return 'ETB 0.00';
  }
  
  // Use compact format for values >= 1000
  if (Math.abs(numAmount) >= 1000) {
    return `ETB ${(numAmount / 1000).toFixed(1)}k`;
  }
  
  // For smaller values, show with decimals
  return `ETB ${numAmount.toFixed(2)}`;
};

