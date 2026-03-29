import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/auth/merchant_currency_provider.dart';
import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/widgets/app_empty_view.dart';
import '../../../core/ui/widgets/app_error_view.dart';
import '../../../core/ui/widgets/app_loading_skeleton.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/utils/date_period_shortcuts.dart';
import '../../../models/sale.dart';
import '../sales_controller.dart';
import 'new_sale_screen.dart';
import 'sale_detail_screen.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  static const routeLocation = '/app/sales';

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesControllerProvider);
    final filtered = ref.read(salesControllerProvider.notifier).filteredSales(state.sales);

    return AppScaffold(
      title: 'Sales',
      actions: [
        IconButton(
          onPressed: () => _openDateFilterSheet(context, ref),
          icon: const Icon(AppIcons.calendar),
          tooltip: 'Filter by date',
        ),
        if (state.sales.isNotEmpty)
          IconButton(
            onPressed: () => _exportCsv(context, filtered),
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
          ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_sales',
        onPressed: () => context.push(NewSaleScreen.routeLocation),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('New sale'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _searchController,
            label: 'Search',
            hintText: 'Search by id, customer, seller…',
            prefixIcon: const Icon(Icons.search),
            outlined: true,
            onChanged: (v) => ref.read(salesControllerProvider.notifier).setSearch(v),
          ),
          const SizedBox(height: 8),
          Text(
            _periodLabel(state.startDate, state.endDate),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: state.isLoading && state.sales.isEmpty
                ? const AppLoadingSkeletonList(rows: 8)
                : (state.errorMessage != null && state.sales.isEmpty)
                    ? AppErrorView(
                        title: 'Couldn’t load sales',
                        message: state.errorMessage,
                        onRetry: () => ref.read(salesControllerProvider.notifier).refresh(),
                      )
                    : filtered.isEmpty
                        ? AppEmptyView(
                            title: state.searchQuery.isNotEmpty ? 'No matching sales' : 'No sales yet',
                            message: state.searchQuery.isNotEmpty
                                ? 'Try a different search or clear filters.'
                                : 'Record your first sale to see it here.',
                            ctaLabel: 'New sale',
                            onCtaPressed: () => context.push(NewSaleScreen.routeLocation),
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(salesControllerProvider.notifier).refresh(),
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (n) {
                                if (n.metrics.pixels < n.metrics.maxScrollExtent - 120) {
                                  return false;
                                }
                                final p = state.pagination;
                                if (p == null || p.page >= p.totalPages) return false;
                                if (state.isLoadingMore || state.isLoading) return false;
                                ref.read(salesControllerProvider.notifier).loadMore();
                                return false;
                              },
                              child: ListView.builder(
                                itemCount:
                                    filtered.length + (state.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= filtered.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  final sale = filtered[index];
                                  return _SaleTile(
                                    sale: sale,
                                    onTap: () =>
                                        context.push(SaleDetailScreen.pathFor(sale.id)),
                                  );
                                },
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, List<Sale> sales) async {
    if (sales.isEmpty) return;

    final csvData = <List<dynamic>>[
      [
        'Sale ID',
        'Sale date',
        'Created',
        'Customer',
        'Phone',
        'Total',
        'Net income',
        'Margin %',
        'Items',
      ],
    ];

    for (final s in sales) {
      csvData.add([
        s.id,
        s.saleDate.toIso8601String(),
        s.createdAt.toIso8601String(),
        s.customerName ?? '',
        s.customerPhone ?? '',
        s.totalAmount.toStringAsFixed(2),
        s.netIncome.toStringAsFixed(2),
        s.profitMargin.toStringAsFixed(2),
        s.items.length.toString(),
      ]);
    }

    final csvString = const ListToCsvConverter().convert(csvData);
    final timestamp = DateTime.now().toIso8601String().split('T')[0];

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              Uint8List.fromList(csvString.codeUnits),
              name: 'sales_export_$timestamp.csv',
              mimeType: 'text/csv',
            ),
          ],
          text: 'Sales export',
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export ready to share')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}

class _SaleTile extends ConsumerWidget {
  const _SaleTile({required this.sale, required this.onTap});

  final Sale sale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyCode = ref.watch(merchantCurrencyProvider);
    final seller = sale.seller;
    final sellerLabel = seller == null
        ? ''
        : '${seller.firstName ?? ''} ${seller.lastName ?? ''}'.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(
          AppFormatters.formatDate(sale.saleDate),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          [
            if (sale.status == 'VOIDED') 'Voided',
            if ((sale.locationName ?? '').isNotEmpty) sale.locationName!,
            if ((sale.customerName ?? '').isNotEmpty) sale.customerName!,
            if (sellerLabel.isNotEmpty) sellerLabel,
            '${sale.items.length} item(s)',
          ].where((e) => e.isNotEmpty).join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(sale.totalAmount.toCurrency(currencyCode), style: Theme.of(context).textTheme.titleSmall),
            Text(
              '${sale.profitMargin.toStringAsFixed(1)}% margin',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openDateFilterSheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Filter by date', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.all_inclusive),
                title: const Text('All time'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await ref.read(salesControllerProvider.notifier).clearDateRange();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_week),
                title: const Text('Last 7 days'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await ref.read(salesControllerProvider.notifier).setLastDays(7);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_month),
                title: const Text('Last 30 days'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await ref.read(salesControllerProvider.notifier).setLastDays(30);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_note),
                title: const Text('This month'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await ref.read(salesControllerProvider.notifier).setThisMonth();
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Custom range'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked == null) return;
                  await ref
                      .read(salesControllerProvider.notifier)
                      .setDateRange(startDate: picked.start, endDate: picked.end);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _periodLabel(DateTime? start, DateTime? end) {
  if (start == null || end == null) return 'All time';
  if (matchesThisMonthRange(start, end)) return 'This month';
  final s = start.toIso8601String().split('T')[0];
  final e = end.toIso8601String().split('T')[0];
  return 'Period: $s → $e';
}
