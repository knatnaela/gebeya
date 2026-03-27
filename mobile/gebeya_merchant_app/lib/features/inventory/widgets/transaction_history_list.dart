import 'package:flutter/material.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_icons.dart';
import '../../../../models/inventory_transaction.dart';

class TransactionHistoryList extends StatelessWidget {
  const TransactionHistoryList({super.key, required this.transactions, required this.onViewAll});

  final List<InventoryTransaction> transactions;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText),
              ),
              TextButton(onPressed: onViewAll, child: const Text('View All')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (transactions.isEmpty)
          _EmptyState()
        else
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length > 5 ? 5 : transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _TransactionItem(transaction: transactions[index]);
            },
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(AppIcons.time, size: 48, color: AppColors.lightMutedText.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No recent activity', style: TextStyle(color: AppColors.lightMutedText, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction});

  final InventoryTransaction transaction;

  String _getTypeLabel(InventoryTransactionType type) {
    switch (type) {
      case InventoryTransactionType.sale:
        return 'Sale';
      case InventoryTransactionType.adjustment:
        return 'Adjustment';
      case InventoryTransactionType.restock:
        return 'Restock';
      case InventoryTransactionType.return_:
        return 'Return';
      case InventoryTransactionType.transferIn:
        return 'Transfer In';
      case InventoryTransactionType.transferOut:
        return 'Transfer Out';
      case InventoryTransactionType.stockIn:
        return 'Stock In';
    }
  }

  Color _getTypeColor(InventoryTransactionType type) {
    switch (type) {
      case InventoryTransactionType.sale:
        return Colors.green;
      case InventoryTransactionType.adjustment:
        return AppColors.brandPurple;
      case InventoryTransactionType.restock:
        return AppColors.brandBlue;
      case InventoryTransactionType.return_:
        return Colors.orange;
      case InventoryTransactionType.transferIn:
        return Colors.cyan;
      case InventoryTransactionType.transferOut:
        return Colors.purple;
      case InventoryTransactionType.stockIn:
        return Colors.teal;
    }
  }

  IconData _getTypeIcon(InventoryTransactionType type) {
    switch (type) {
      case InventoryTransactionType.sale:
        return AppIcons.money;
      case InventoryTransactionType.adjustment:
        return AppIcons.edit;
      case InventoryTransactionType.restock:
        return AppIcons.download;
      case InventoryTransactionType.return_:
        return AppIcons.back;
      case InventoryTransactionType.transferIn:
        return AppIcons.forward; // Assuming arrow right implies "in" contextually or just movement
      case InventoryTransactionType.transferOut:
        return AppIcons.back; // Or chevron left
      case InventoryTransactionType.stockIn:
        return AppIcons.check;
    }
  }

  String _formatDate(DateTime date) {
    // Simple formatter, can be replaced with intl later if needed relative time
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(transaction.type);
    final isPositive = transaction.quantity > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightOutline.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(_getTypeIcon(transaction.type), size: 20, color: typeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.product?.name ?? 'Unknown Product',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.lightText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_getTypeLabel(transaction.type)} • ${_formatDate(transaction.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.lightMutedText),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isPositive ? '+${transaction.quantity}' : '${transaction.quantity}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
              if (transaction.location != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    transaction.location!.name,
                    style: const TextStyle(fontSize: 10, color: AppColors.lightMutedText),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
