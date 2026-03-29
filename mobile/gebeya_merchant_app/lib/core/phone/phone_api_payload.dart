import 'package:phone_numbers_parser/phone_numbers_parser.dart';

/// Maps an E.164-style string from [IntlPhoneField] to backend structured fields.
class PhoneApiPayload {
  PhoneApiPayload._();

  static Map<String, String>? merchantOrLocation(String? e164) {
    if (e164 == null || e164.trim().isEmpty) return null;
    final normalized = e164.trim().startsWith('+') ? e164.trim() : '+${e164.trim()}';
    final p = PhoneNumber.parse(normalized);
    if (!p.isValid()) return null;
    return {
      'phoneCountryIso': p.isoCode.name,
      'phoneNationalNumber': p.nsn,
      'phone': '+${p.countryCode}${p.nsn}',
    };
  }

  static Map<String, String>? customerSale(String? e164) {
    final m = merchantOrLocation(e164);
    if (m == null) return null;
    return {
      'customerPhoneCountryIso': m['phoneCountryIso']!,
      'customerPhoneNationalNumber': m['phoneNationalNumber']!,
      'customerPhone': m['phone']!,
    };
  }
}
