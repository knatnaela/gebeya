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
    final product = entry.product;
    final location = entry.location;

    // Get product initials or fallback icon
    final productName = product?.name ?? 'Unknown Product';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Icon/Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.brandPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(AppIcons.products, color: AppColors.brandPurple, size: 24)),
            ),
            const SizedBox(width: 16),

            // Content
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
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.lightText),
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
                        const Icon(AppIcons.business, size: 12, color: AppColors.lightMutedText),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            entry.supplierName!,
                            style: const TextStyle(fontSize: 12, color: AppColors.lightMutedText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (location != null) ...[
                        const Icon(AppIcons.location, size: 12, color: AppColors.lightMutedText),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location.name,
                            style: const TextStyle(fontSize: 12, color: AppColors.lightMutedText),
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
                        style: const TextStyle(fontSize: 12, color: AppColors.lightMutedText),
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
