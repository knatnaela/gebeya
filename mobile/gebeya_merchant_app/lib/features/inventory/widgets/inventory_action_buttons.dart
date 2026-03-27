import 'package:flutter/material.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_icons.dart';

class InventoryActionButtons extends StatelessWidget {
  const InventoryActionButtons({
    super.key,
    required this.onAdjustStock,
    required this.onTransferStock,
    required this.onViewEntries,
  });

  final VoidCallback onAdjustStock;
  final VoidCallback onTransferStock;
  final VoidCallback onViewEntries;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _ActionButton(label: 'Adjust Stock', icon: AppIcons.add, color: AppColors.brandPurple, onTap: onAdjustStock),
          const SizedBox(width: 12),
          _ActionButton(label: 'Transfer', icon: AppIcons.swap, color: AppColors.brandBlue, onTap: onTransferStock),
          const SizedBox(width: 12),
          _ActionButton(label: 'See Entries', icon: AppIcons.inventory, color: Colors.orange, onTap: onViewEntries),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
