import 'package:flutter/material.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_icons.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../models/inventory_summary.dart';

class InventorySummaryCarousel extends StatelessWidget {
  const InventorySummaryCarousel({super.key, required this.summary, required this.currencyCode});

  final InventorySummary summary;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _SummaryCard(
            title: 'Stock Value',
            value: AppFormatters.currency(summary.totalStockValue, currencyCode),
            icon: AppIcons.money,
            color: AppColors.brandBlue,
            isPrimary: true,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            title: 'Low Stock',
            value: summary.lowStockCount.toString(),
            icon: AppIcons.warning,
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            title: 'Out of Stock',
            value: summary.outOfStockCount.toString(),
            icon: AppIcons.inventory,
            color: AppColors.brandPurple,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            title: 'Products',
            value: summary.totalProducts.toString(),
            icon: AppIcons.products,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isPrimary = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.65);
    return Container(
      width: isPrimary ? 160 : 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary ? color : scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isPrimary ? null : Border.all(color: scheme.outline.withValues(alpha: 0.55)),
        boxShadow: isPrimary
            ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: isPrimary ? Colors.white : color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isPrimary ? Colors.white.withValues(alpha: 0.9) : muted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isPrimary ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.white : scheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
