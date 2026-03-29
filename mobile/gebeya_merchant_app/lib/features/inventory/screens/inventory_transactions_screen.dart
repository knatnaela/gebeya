import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/widgets/app_empty_view.dart';
import '../../../core/ui/widgets/app_error_view.dart';
import '../../../core/ui/widgets/app_loading_skeleton.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/utils/date_period_shortcuts.dart';
import '../../../models/inventory_transaction.dart';
import '../inventory_controller.dart';
import '../inventory_state.dart';
import 'adjust_stock_screen.dart';

class InventoryTransactionsScreen extends ConsumerStatefulWidget {
  const InventoryTransactionsScreen({super.key});

  static const routeLocation = '/app/inventory/transactions';

  @override
  ConsumerState<InventoryTransactionsScreen> createState() => _InventoryTransactionsScreenState();
}

class _InventoryTransactionsScreenState extends ConsumerState<InventoryTransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(inventoryControllerProvider.notifier)
          .setFilters(productIdFilter: null, typeFilter: null, startDateFilter: null, endDateFilter: null);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final state = ref.read(inventoryControllerProvider);
    if (state.allTransactions.isEmpty) return;

    final csvData = <List<dynamic>>[
      ['Date', 'Product', 'Location', 'Type', 'Quantity', 'User', 'Reason'],
    ];

    for (final transaction in state.allTransactions) {
      csvData.add([
        transaction.createdAt.toIso8601String(),
        transaction.product?.name ?? '',
        transaction.location?.name ?? '',
        _getTypeLabel(transaction.type),
        transaction.quantity.toString(),
        transaction.user != null ? '${transaction.user!.firstName} ${transaction.user!.lastName ?? ''}'.trim() : '',
        transaction.reason ?? '',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(csvData);
    final timestamp = DateTime.now().toIso8601String().split('T')[0];

    try {
      await Share.shareXFiles([
        XFile.fromData(
          Uint8List.fromList(csvString.codeUnits),
          name: 'inventory_transactions_export_$timestamp.csv',
          mimeType: 'text/csv',
        ),
      ], text: 'Inventory transactions export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: bg,
              scrolledUnderElevation: 0,
              expandedHeight: 120,
              floating: false,
              pinned: true,
              centerTitle: false,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Text(
                  'Transactions',
                  style: GoogleFonts.outfit(color: scheme.onSurface, fontWeight: FontWeight.bold, fontSize: 24),
                ),
                background: Container(color: bg),
              ),
              actions: [
                IconButton(
                  onPressed: () => _exportCsv(context, ref),
                  icon: const Icon(AppIcons.download, color: AppColors.brandPurple),
                  tooltip: 'Export CSV',
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverSearchDelegate(
                child: Container(
                  height: 60,
                  color: bg,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search transactions...',
                            prefixIcon: const Icon(AppIcons.search, size: 20),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            filled: true,
                            fillColor: scheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.brandPurple),
                            ),
                          ),
                          onChanged: (val) {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => _openFilterSheet(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
                          ),
                          child: Icon(AppIcons.filter, size: 20, color: scheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: state.isLoading && state.allTransactions.isEmpty
            ? const Padding(padding: EdgeInsets.all(16), child: AppLoadingSkeletonList(rows: 10))
            : (state.errorMessage != null && state.allTransactions.isEmpty)
            ? AppErrorView(
                title: 'Couldn\'t load transactions',
                message: state.errorMessage,
                onRetry: () => ref.read(inventoryControllerProvider.notifier).refresh(),
              )
            : state.allTransactions.isEmpty
            ? AppEmptyView(
                title: 'No transactions found',
                message: 'Adjust stock to create transactions.',
                ctaLabel: 'Adjust Stock',
                onCtaPressed: () => Navigator.of(context).push(AdjustStockScreen.routeLocation as Route<Object?>),
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    final metrics = notification.metrics;
                    if (metrics.pixels >= metrics.maxScrollExtent * 0.8) {
                      ref.read(inventoryControllerProvider.notifier).loadMoreTransactions();
                    }
                  }
                  return false;
                },
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
                  itemCount:
                      state.allTransactions.length +
                      (state.pagination != null && state.pagination!.page < state.pagination!.totalPages ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
                  itemBuilder: (context, index) {
                    if (index >= state.allTransactions.length) {
                      return const Center(
                        child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                      );
                    }
                    final transaction = state.allTransactions[index];
                    return _TransactionItem(transaction: transaction);
                  },
                ),
              ),
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final state = ref.watch(inventoryControllerProvider);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _TransactionsFilterSheet(
            currentState: state,
            onApply: (filters) {
              Navigator.of(ctx).pop();
              ref
                  .read(inventoryControllerProvider.notifier)
                  .setFilters(
                    productIdFilter: filters.productIdFilter,
                    typeFilter: filters.typeFilter,
                    startDateFilter: filters.startDateFilter,
                    endDateFilter: filters.endDateFilter,
                  );
            },
          ),
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
        return AppColors.brandGreen;
      case InventoryTransactionType.adjustment:
        return AppColors.brandPurple;
      case InventoryTransactionType.restock:
        return Colors.blue;
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
        return AppIcons.sales;
      case InventoryTransactionType.adjustment:
        return AppIcons.settings;
      case InventoryTransactionType.restock:
        return AppIcons.add;
      case InventoryTransactionType.return_:
        return AppIcons.swap;
      case InventoryTransactionType.transferIn:
        return AppIcons.download;
      case InventoryTransactionType.transferOut:
        return AppIcons.logout;
      case InventoryTransactionType.stockIn:
        return AppIcons.inventory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.62);
    final typeColor = _getTypeColor(transaction.type);
    final isPositive = transaction.quantity > 0;

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(_getTypeIcon(transaction.type), color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),

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
                        transaction.product?.name ?? 'Unknown Product',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: scheme.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPositive ? '+${transaction.quantity}' : '${transaction.quantity}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isPositive ? AppColors.brandGreen : AppColors.brandRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _getTypeLabel(transaction.type),
                      style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(color: scheme.outline.withValues(alpha: 0.5), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppFormatters.formatDate(transaction.createdAt),
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
                if (transaction.reason != null && transaction.reason!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.reason!,
                    style: TextStyle(color: muted, fontSize: 12, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverSearchDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverSearchDelegate({required this.child});

  @override
  double get minExtent => 60.0;
  @override
  double get maxExtent => 60.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class _TransactionsFilterSheet extends StatefulWidget {
  const _TransactionsFilterSheet({required this.currentState, required this.onApply});

  final InventoryState currentState;
  final void Function(_FilterState) onApply;

  @override
  State<_TransactionsFilterSheet> createState() => _TransactionsFilterSheetState();
}

class _TransactionsFilterSheetState extends State<_TransactionsFilterSheet> {
  InventoryTransactionType? _typeFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;

  @override
  void initState() {
    super.initState();
    _typeFilter = widget.currentState.typeFilter;
    _startDateFilter = widget.currentState.startDateFilter;
    _endDateFilter = widget.currentState.endDateFilter;
  }

  void _applyThisMonth() {
    final r = thisMonthRangeLocal();
    setState(() {
      _startDateFilter = r.start;
      _endDateFilter = r.end;
    });
  }

  bool _selectionMatchesThisMonth() {
    if (_startDateFilter == null || _endDateFilter == null) return false;
    return matchesThisMonthRange(_startDateFilter!, _endDateFilter!);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDateFilter != null && _endDateFilter != null
          ? DateTimeRange(start: _startDateFilter!, end: _endDateFilter!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDateFilter = picked.start;
        _endDateFilter = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.62);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filter transactions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FilterSection(
                    title: 'Transaction Type',
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _typeFilter == null,
                        onTap: () => setState(() => _typeFilter = null),
                      ),
                      _FilterChip(
                        label: 'Sale',
                        selected: _typeFilter == InventoryTransactionType.sale,
                        onTap: () => setState(() => _typeFilter = InventoryTransactionType.sale),
                      ),
                      _FilterChip(
                        label: 'Adjustment',
                        selected: _typeFilter == InventoryTransactionType.adjustment,
                        onTap: () => setState(() => _typeFilter = InventoryTransactionType.adjustment),
                      ),
                      _FilterChip(
                        label: 'Restock',
                        selected: _typeFilter == InventoryTransactionType.restock,
                        onTap: () => setState(() => _typeFilter = InventoryTransactionType.restock),
                      ),
                      _FilterChip(
                        label: 'Return',
                        selected: _typeFilter == InventoryTransactionType.return_,
                        onTap: () => setState(() => _typeFilter = InventoryTransactionType.return_),
                      ),
                      _FilterChip(
                        label: 'Stock In',
                        selected: _typeFilter == InventoryTransactionType.stockIn,
                        onTap: () => setState(() => _typeFilter = InventoryTransactionType.stockIn),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Date Range', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterChip(
                        label: 'This month',
                        selected: _selectionMatchesThisMonth(),
                        onTap: _applyThisMonth,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDateRange,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(AppIcons.calendar, size: 20, color: muted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _startDateFilter != null && _endDateFilter != null
                                  ? '${AppFormatters.formatDate(_startDateFilter!)} - ${AppFormatters.formatDate(_endDateFilter!)}'
                                  : 'Select date range',
                              style: TextStyle(
                                color: _startDateFilter != null ? scheme.onSurface : muted,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (_startDateFilter != null)
                            InkWell(
                              onTap: () => setState(() {
                                _startDateFilter = null;
                                _endDateFilter = null;
                              }),
                              child: Icon(AppIcons.close, size: 16, color: muted),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _typeFilter = null;
                      _startDateFilter = null;
                      _endDateFilter = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Clear', style: TextStyle(color: scheme.onSurface)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(
                      _FilterState(
                        productIdFilter: null,
                        typeFilter: _typeFilter,
                        startDateFilter: _startDateFilter,
                        endDateFilter: _endDateFilter,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.brandPurple : scheme.outline.withValues(alpha: 0.45)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : scheme.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FilterState {
  const _FilterState({this.productIdFilter, this.typeFilter, this.startDateFilter, this.endDateFilter});

  final String? productIdFilter;
  final InventoryTransactionType? typeFilter;
  final DateTime? startDateFilter;
  final DateTime? endDateFilter;
}
