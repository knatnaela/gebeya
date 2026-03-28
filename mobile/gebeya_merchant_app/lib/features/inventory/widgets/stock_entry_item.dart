import 'package:flutter/material.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_icons.dart';
import '../../../../models/inventory_entry.dart';
import 'payment_status_badge.dart';

class StockEntryItem extends StatelessWidget {
  const StockEntryItem({super.key, required this.entry, this.onTap});

  final InventoryEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.62);
    final product = entry.product;
    final location = entry.location;

    final productName = product?.name ?? 'Unknown Product';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.brandPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(AppIcons.products, color: AppColors.brandPurple, size: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: scheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${entry.quantity}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (entry.supplierName != null) ...[
                        Icon(AppIcons.business, size: 12, color: muted),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            entry.supplierName!,
                            style: TextStyle(fontSize: 12, color: muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (location != null) ...[
                        Icon(AppIcons.location, size: 12, color: muted),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location.name,
                            style: TextStyle(fontSize: 12, color: muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      PaymentStatusBadge(status: entry.paymentStatus),
                      const Spacer(),
                      Text(
                        _formatDate(entry.receivedDate),
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
