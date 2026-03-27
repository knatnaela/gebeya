/**
 * Currency formatting: ISO code + space + amount (e.g. `ETB 1,234.56`).
 * Defaults to ETB for backward compatibility.
 * Merchant-scoped UI should pass the code from `useMerchantCurrency()`.
 * Company-wide aggregates mix merchants; those call sites pass `'ETB'` explicitly (or a future platform default).
 */

const DEFAULT_CURRENCY = 'ETB';

function parseAmount(amount: number | string | null | undefined): number | null {
  if (amount === null || amount === undefined || amount === '') return null;
  const n = typeof amount === 'string' ? parseFloat(amount) : amount;
  return Number.isFinite(n) ? n : null;
}

function normalizeCode(currencyCode: string): string {
  return currencyCode.trim().toUpperCase() || DEFAULT_CURRENCY;
}

/** Number only (grouping + decimals), no currency symbol. */
function formatAmountDigits(
  numAmount: number,
  minimumFractionDigits: number,
  maximumFractionDigits: number,
): string {
  return new Intl.NumberFormat('en-US', {
    minimumFractionDigits,
    maximumFractionDigits,
  }).format(numAmount);
}

export const formatCurrency = (
  amount: number | string | null | undefined,
  currencyCode: string = DEFAULT_CURRENCY,
): string => {
  const n = parseAmount(amount);
  const code = normalizeCode(currencyCode);
  const num = n ?? 0;
  return `${code} ${formatAmountDigits(num, 2, 2)}`;
};

export const formatCurrencyCompact = (
  amount: number | string | null | undefined,
  currencyCode: string = DEFAULT_CURRENCY,
): string => {
  const n = parseAmount(amount);
  const code = normalizeCode(currencyCode);
  const num = n ?? 0;
  const whole = num % 1 === 0;
  return `${code} ${formatAmountDigits(
    num,
    whole ? 0 : 2,
    whole ? 0 : 2,
  )}`;
};

/**
 * Compact style for large values (e.g. dashboard cards).
 */
export const formatCurrencySmart = (
  amount: number | string | null | undefined,
  currencyCode: string = DEFAULT_CURRENCY,
): string => {
  const n = parseAmount(amount);
  const code = normalizeCode(currencyCode);
  if (n === null) {
    return `${code} ${formatAmountDigits(0, 2, 2)}`;
  }
  if (Math.abs(n) >= 1000) {
    const compact = new Intl.NumberFormat('en-US', {
      notation: 'compact',
      compactDisplay: 'short',
      maximumFractionDigits: 1,
    }).format(n);
    return `${code} ${compact}`;
  }
  return `${code} ${formatAmountDigits(n, 2, 2)}`;
};
