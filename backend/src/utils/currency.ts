/**
 * Validates ISO 4217-style currency codes for merchant settings.
 * Allows common codes; extend the set as needed.
 */
const ALLOWED_CURRENCIES = new Set([
  'ETB',
  'USD',
  'EUR',
  'GBP',
  'KES',
  'UGX',
  'TZS',
  'SOS',
  'ZAR',
  'NGN',
  'EGP',
  'SAR',
  'AED',
  'JPY',
  'CNY',
  'INR',
  'AUD',
  'CAD',
  'CHF',
  'SEK',
  'NOK',
  'DKK',
  'TRY',
  'BRL',
  'MXN',
  'PLN',
  'CZK',
  'HUF',
  'RON',
  'RUB',
  'HKD',
  'SGD',
  'NZD',
  'KRW',
  'THB',
  'VND',
  'IDR',
  'PHP',
  'MYR',
  'PKR',
  'BDT',
  'LKR',
  'XOF',
  'XAF',
]);

export function isValidMerchantCurrency(code: string | undefined | null): boolean {
  if (!code || typeof code !== 'string') return false;
  const upper = code.trim().toUpperCase();
  if (!/^[A-Z]{3}$/.test(upper)) return false;
  if (upper === 'XXX') return false;
  return ALLOWED_CURRENCIES.has(upper);
}

export function normalizeMerchantCurrency(code: string): string {
  return code.trim().toUpperCase();
}
