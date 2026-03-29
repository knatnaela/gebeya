/**
 * Derive default login mode and phone country from locale + platform "phone-first" ISO list.
 */

export type AuthLoginMode = 'email' | 'phone';

function regionFromLocale(locale: string | undefined): string | null {
  if (!locale || typeof locale !== 'string') return null;
  const parts = locale.replace('_', '-').split('-');
  if (parts.length >= 2) {
    return parts[parts.length - 1].toUpperCase();
  }
  return null;
}

export function getDefaultLoginMode(
  phoneFirstCountryIsoCodes: string[],
  localeHint?: string
): AuthLoginMode {
  const region = regionFromLocale(localeHint ?? (typeof navigator !== 'undefined' ? navigator.language : undefined));
  if (!region) return 'email';
  const set = new Set(phoneFirstCountryIsoCodes.map((c) => c.toUpperCase()));
  return set.has(region) ? 'phone' : 'email';
}

/**
 * Prefer locale region if it is in the phone-first list; else first list entry; else undefined.
 */
export function getDefaultPhoneCountryIso(
  phoneFirstCountryIsoCodes: string[],
  localeHint?: string
): string | undefined {
  const region = regionFromLocale(localeHint ?? (typeof navigator !== 'undefined' ? navigator.language : undefined));
  const codes = phoneFirstCountryIsoCodes.map((c) => c.toUpperCase());
  const set = new Set(codes);
  if (region && set.has(region)) return region;
  return codes[0];
}
