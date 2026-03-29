import { parsePhoneNumber } from 'libphonenumber-js';

/** Build API payload fields from an E.164 value produced by the phone input. */
export function splitE164ForApi(e164: string | undefined): {
  phoneCountryIso: string;
  phoneNationalNumber: string;
  phone: string;
} | null {
  if (!e164?.trim()) return null;
  const p = parsePhoneNumber(e164);
  if (!p?.isValid()) return null;
  const country = p.country;
  if (!country) return null;
  return {
    phoneCountryIso: country,
    phoneNationalNumber: p.nationalNumber,
    phone: p.format('E.164'),
  };
}

export function splitCustomerE164ForApi(e164: string | undefined): {
  customerPhoneCountryIso: string;
  customerPhoneNationalNumber: string;
  customerPhone: string;
} | null {
  const s = splitE164ForApi(e164);
  if (!s) return null;
  return {
    customerPhoneCountryIso: s.phoneCountryIso,
    customerPhoneNationalNumber: s.phoneNationalNumber,
    customerPhone: s.phone,
  };
}
