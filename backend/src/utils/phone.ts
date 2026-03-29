import { parsePhoneNumberFromString, type CountryCode } from 'libphonenumber-js';

export interface NormalizedPhone {
  countryIso: string;
  dialCode: string;
  nationalNumber: string;
  e164: string;
}

/**
 * Build normalized phone from ISO + national digits. Throws if invalid or empty input when phone is required.
 */
export function normalizePhoneFromParts(
  countryIso: string | undefined | null,
  nationalNumber: string | undefined | null
): NormalizedPhone | null {
  const isoRaw = countryIso?.trim();
  const nationalRaw = nationalNumber?.trim();
  if (!isoRaw || !nationalRaw) return null;

  const iso = isoRaw.toUpperCase() as CountryCode;
  const nationalDigits = nationalRaw.replace(/\D/g, '');
  if (!nationalDigits) return null;

  const parsed = parsePhoneNumberFromString(nationalDigits, iso);
  if (!parsed || !parsed.isValid()) {
    throw new Error('Invalid phone number for selected country');
  }

  const country = parsed.country;
  if (!country) {
    throw new Error('Could not resolve country for phone number');
  }

  return {
    countryIso: country,
    dialCode: `+${parsed.countryCallingCode}`,
    nationalNumber: parsed.nationalNumber,
    e164: parsed.format('E.164'),
  };
}

/**
 * Optional phone: returns null if both iso and national are empty; validates when any part is present.
 */
export function normalizeOptionalPhoneFromParts(
  countryIso: string | undefined | null,
  nationalNumber: string | undefined | null
): NormalizedPhone | null {
  const isoRaw = countryIso?.trim();
  const nationalRaw = nationalNumber?.trim();
  if (!isoRaw && !nationalRaw?.replace(/\D/g, '')) return null;
  if (!isoRaw || !nationalRaw) {
    throw new Error('Country and phone number are both required when entering a phone');
  }
  return normalizePhoneFromParts(isoRaw, nationalRaw);
}

/**
 * Parse a legacy free-text phone string into structured fields. Returns null if empty or unparseable.
 */
export function parseLegacyPhoneString(raw: string | null | undefined): NormalizedPhone | null {
  const s = raw?.trim();
  if (!s) return null;
  const parsed = parsePhoneNumberFromString(s);
  if (!parsed || !parsed.isValid()) return null;
  const country = parsed.country;
  if (!country) return null;
  return {
    countryIso: country,
    dialCode: `+${parsed.countryCallingCode}`,
    nationalNumber: parsed.nationalNumber,
    e164: parsed.format('E.164'),
  };
}

export interface DbPhoneFields {
  phoneCountryIso: string | null;
  phoneDialCode: string | null;
  phoneNationalNumber: string | null;
  phone: string | null;
}

const emptyDbPhone: DbPhoneFields = {
  phoneCountryIso: null,
  phoneDialCode: null,
  phoneNationalNumber: null,
  phone: null,
};

function normalizedToDb(n: NormalizedPhone): DbPhoneFields {
  return {
    phoneCountryIso: n.countryIso,
    phoneDialCode: n.dialCode,
    phoneNationalNumber: n.nationalNumber,
    phone: n.e164,
  };
}

/**
 * Convert API input (structured parts and/or legacy string) to DB columns. Throws on invalid partial input.
 */
export function toDbPhoneFieldsOrThrow(input: {
  phoneCountryIso?: string | null;
  phoneNationalNumber?: string | null;
  phoneLegacy?: string | null;
}): DbPhoneFields {
  const iso = input.phoneCountryIso?.trim() ?? '';
  const nat = input.phoneNationalNumber?.trim() ?? '';
  const legacy = input.phoneLegacy?.trim() ?? '';

  if (iso && nat) {
    const n = normalizePhoneFromParts(iso, nat);
    if (!n) throw new Error('Invalid phone number');
    return normalizedToDb(n);
  }

  if (iso || nat) {
    throw new Error('Country and phone number are both required when entering a phone');
  }

  if (legacy) {
    const n = parseLegacyPhoneString(legacy);
    if (!n) throw new Error('Invalid phone number');
    return normalizedToDb(n);
  }

  return emptyDbPhone;
}

/**
 * Like `toDbPhoneFieldsOrThrow` but returns null fields when all inputs are empty (no throw).
 */
export function toOptionalDbPhoneFieldsOrThrow(input: {
  phoneCountryIso?: string | null;
  phoneNationalNumber?: string | null;
  phoneLegacy?: string | null;
}): DbPhoneFields {
  const iso = input.phoneCountryIso?.trim() ?? '';
  const nat = input.phoneNationalNumber?.trim() ?? '';
  const legacy = input.phoneLegacy?.trim() ?? '';
  if (!iso && !nat && !legacy) return emptyDbPhone;
  return toDbPhoneFieldsOrThrow(input);
}

export function toCustomerDbPhoneFieldsOrThrow(input: {
  customerPhoneCountryIso?: string | null;
  customerPhoneNationalNumber?: string | null;
  customerPhoneLegacy?: string | null;
}): {
  customerPhoneCountryIso: string | null;
  customerPhoneDialCode: string | null;
  customerPhoneNationalNumber: string | null;
  customerPhone: string | null;
} {
  const base = toOptionalDbPhoneFieldsOrThrow({
    phoneCountryIso: input.customerPhoneCountryIso,
    phoneNationalNumber: input.customerPhoneNationalNumber,
    phoneLegacy: input.customerPhoneLegacy,
  });
  return {
    customerPhoneCountryIso: base.phoneCountryIso,
    customerPhoneDialCode: base.phoneDialCode,
    customerPhoneNationalNumber: base.phoneNationalNumber,
    customerPhone: base.phone,
  };
}
