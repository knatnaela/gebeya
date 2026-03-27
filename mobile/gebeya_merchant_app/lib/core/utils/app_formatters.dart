import 'package:intl/intl.dart';

/// Centralized formatting utilities for the app.
class AppFormatters {
  AppFormatters._();

  static final Map<String, NumberFormat> _decimalByFractionDigits = {};
  static NumberFormat? _compactPlain;

  static final _numberFormatter = NumberFormat.decimalPattern();
  static final _compactNumberFormatter = NumberFormat.compact();
  static final _dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  /// Formats a date as dd/MM/yyyy HH:mm.
  static String formatDate(DateTime date) => _dateFormatter.format(date);

  static NumberFormat _decimalsFormat(int fractionDigits) {
    final key = 'en_US_$fractionDigits';
    return _decimalByFractionDigits.putIfAbsent(
      key,
      () => NumberFormat.decimalPatternDigits(locale: 'en_US', decimalDigits: fractionDigits),
    );
  }

  /// ISO code + space + amount (e.g. `ETB 1,234.56`).
  static String currency(num value, String currencyCode) {
    final code = currencyCode.toUpperCase();
    return '$code ${_decimalsFormat(2).format(value)}';
  }

  /// Compact currency (e.g. `ETB 1.2M`).
  static String compactCurrency(num value, String currencyCode) {
    final code = currencyCode.toUpperCase();
    _compactPlain ??= NumberFormat.compact(locale: 'en_US');
    return '$code ${_compactPlain!.format(value)}';
  }

  /// Dashboard KPI style: fewer fraction digits when |value| ≥ 1000.
  static String dashboardAmount(num value, String currencyCode) {
    final abs = value.abs();
    final decimals = abs >= 1000 ? 0 : 2;
    final code = currencyCode.toUpperCase();
    return '$code ${_decimalsFormat(decimals).format(value)}';
  }

  /// Formats a number with standard decimal pattern (e.g., 1,234).
  static String formatNumber(num value) => _numberFormatter.format(value);

  /// Formats a number in compact form (e.g., 1.2K).
  static String compactNumber(num value) => _compactNumberFormatter.format(value);
}

/// Extensions for formatting with an explicit ISO 4217 code (e.g. from [merchantCurrencyProvider]).
extension NumFormattingX on num {
  String toCurrency(String currencyCode) => AppFormatters.currency(this, currencyCode);

  String toCompactCurrency(String currencyCode) => AppFormatters.compactCurrency(this, currencyCode);

  String toFormattedInt() => AppFormatters.formatNumber(this);

  String toCompact() => AppFormatters.compactNumber(this);
}
