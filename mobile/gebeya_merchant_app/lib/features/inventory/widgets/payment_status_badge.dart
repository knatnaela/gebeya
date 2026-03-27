import 'package:flutter/material.dart';

import '../../../models/payment_status.dart';

class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({
    super.key,
    required this.status,
  });

  final PaymentStatus status;

  String _getLabel() {
    switch (status) {
      case PaymentStatus.paid:
        return 'PAID';
      case PaymentStatus.credit:
        return 'CREDIT';
      case PaymentStatus.partial:
        return 'PARTIAL';
    }
  }

  Color _getColor(BuildContext context) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.partial:
        return Colors.orange;
      case PaymentStatus.credit:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
