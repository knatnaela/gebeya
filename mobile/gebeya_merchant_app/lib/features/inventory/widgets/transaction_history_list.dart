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
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: scheme.onSurface),
              ),
              TextButton(onPressed: onViewAll, child: const Text('View All')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (transactions.isEmpty)
          const _EmptyState()
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.62);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(AppIcons.time, size: 48, color: muted.withValues(alpha: 0.45)),
            const SizedBox(height: 16),
            Text('No recent activity', style: TextStyle(color: muted, fontSize: 14)),
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
        return AppIcons.forward;
      case InventoryTransactionType.transferOut:
        return AppIcons.back;
      case InventoryTransactionType.stockIn:
        return AppIcons.check;
    }
  }

  String _formatDate(DateTime date) {
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
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.62);
    final typeColor = _getTypeColor(transaction.type);
    final isPositive = transaction.quantity > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(_getTypeIcon(transaction.type), size: 20, color: typeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.product?.name ?? 'Unknown Product',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: scheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_getTypeLabel(transaction.type)} • ${_formatDate(transaction.createdAt)}',
                  style: TextStyle(fontSize: 12, color: muted),
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
                    style: TextStyle(fontSize: 10, color: muted),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
