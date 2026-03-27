enum PaymentStatus {
  paid,
  credit,
  partial,
}

extension PaymentStatusExtension on PaymentStatus {
  String toBackendString() {
    switch (this) {
      case PaymentStatus.paid:
        return 'PAID';
      case PaymentStatus.credit:
        return 'CREDIT';
      case PaymentStatus.partial:
        return 'PARTIAL';
    }
  }

  static PaymentStatus fromBackendString(String value) {
    switch (value.toUpperCase()) {
      case 'PAID':
        return PaymentStatus.paid;
      case 'CREDIT':
        return PaymentStatus.credit;
      case 'PARTIAL':
        return PaymentStatus.partial;
      default:
        throw FormatException('Unknown payment status: $value');
    }
  }
}
