import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/widgets/app_card.dart';
import '../../../core/ui/widgets/app_error_view.dart';
import '../../../core/ui/widgets/app_loading_skeleton.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/auth/merchant_currency_provider.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/utils/app_formatters.dart';
import '../../inventory/screens/inventory_screen.dart';
import '../../products/screens/products_screen.dart';
import '../../sales/screens/new_sale_screen.dart';
import '../dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const routeLocation = '/app/dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);
    final currencyCode = ref.watch(merchantCurrencyProvider);

    return AppScaffold(
      title: 'Dashboard',
      actions: [
        IconButton(
          onPressed: () => _openDateFilterSheet(context, ref),
          icon: const Icon(AppIcons.calendar),
          tooltip: 'Filter by date',
        ),
      ],
      body: state.isLoading
          ? const AppLoadingSkeletonList(rows: 10)
          : (state.errorMessage != null)
          ? AppErrorView(
              title: 'Couldn’t load dashboard',
              message: state.errorMessage,
              onRetry: () => ref.read(dashboardControllerProvider.notifier).refresh(),
            )
          : _DashboardContent(
              currencyCode: currencyCode,
              startDate: state.startDate,
              endDate: state.endDate,
              totalRevenue: state.salesAnalytics?.totalRevenue ?? 0,
              grossProfit: state.salesAnalytics?.grossProfit ?? 0,
              totalExpenses: state.salesAnalytics?.totalExpenses ?? 0,
              netProfit: state.salesAnalytics?.netProfit ?? 0,
              profitMargin: state.salesAnalytics?.profitMargin ?? 0,
              totalSales: state.salesAnalytics?.totalSales ?? 0,
              totalProducts: state.inventorySummary?.totalProducts ?? 0,
              lowStockCount: state.inventorySummary?.lowStockCount ?? 0,
            ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.currencyCode,
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.grossProfit,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.totalSales,
    required this.totalProducts,
    required this.lowStockCount,
  });

  final String currencyCode;
  final DateTime? startDate;
  final DateTime? endDate;

  final num totalRevenue;
  final num grossProfit;
  final num totalExpenses;
  final num netProfit;
  final num profitMargin;
  final int totalSales;

  final int totalProducts;
  final int lowStockCount;

  @override
  Widget build(BuildContext context) {
    final periodLabel = _periodLabel(startDate, endDate);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Row(
              children: [
                const Icon(AppIcons.calendar),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date range', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(periodLabel, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _KpiGrid(
            items: [
              _Kpi(
                title: 'Total Revenue',
                value: AppFormatters.dashboardAmount(totalRevenue, currencyCode),
                subtitle: '$periodLabel revenue',
                icon: AppIcons.trendingUp,
                backgroundColor: AppColors.cardTintPurple,
              ),
              _Kpi(
                title: 'Gross Profit',
                value: AppFormatters.dashboardAmount(grossProfit, currencyCode),
                subtitle: 'Revenue - COGS',
                icon: AppIcons.chart,
                backgroundColor: AppColors.cardTintBlue,
              ),
              _Kpi(
                title: 'Total Expenses',
                value: AppFormatters.dashboardAmount(totalExpenses, currencyCode),
                subtitle: '$periodLabel expenses',
                icon: AppIcons.trendingDown,
                backgroundColor: AppColors.cardTintRed,
              ),
              _Kpi(
                title: 'Net Profit',
                value: AppFormatters.dashboardAmount(netProfit, currencyCode),
                subtitle: 'Gross Profit - Expenses',
                icon: AppIcons.analytics,
                backgroundColor: AppColors.cardTintGreen,
              ),
              _Kpi(
                title: 'Profit Margin',
                value: '${profitMargin.toStringAsFixed(2)}%',
                subtitle: 'Net Profit / Revenue',
                icon: AppIcons.percent,
                backgroundColor: AppColors.cardTintBlue,
              ),
              _Kpi(
                title: 'Total Sales',
                value: totalSales.toString(),
                subtitle: '$periodLabel sales',
                icon: AppIcons.receipt,
                backgroundColor: AppColors.cardTintNeutral,
              ),
              _Kpi(
                title: 'Total Products',
                value: totalProducts.toString(),
                subtitle: 'Active products',
                icon: AppIcons.products,
                backgroundColor: AppColors.cardTintNeutral,
              ),
              _Kpi(
                title: 'Low Stock Alerts',
                value: lowStockCount.toString(),
                subtitle: 'Need restocking',
                icon: Icons.warning_amber_rounded,
                backgroundColor: AppColors.cardTintOrange,
              ),
            ],
          ),

          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'New Sale',
                  onPressed: () => context.push(NewSaleScreen.routeLocation),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.go(ProductsScreen.routeLocation),
                  child: const Text('Add Product'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.go(InventoryScreen.routeLocation),
                  child: const Text('Adjust Stock'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.items});
  final List<_Kpi> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => AppCard(backgroundColor: items[i].backgroundColor, child: items[i]),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
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
                  await ref.read(dashboardControllerProvider.notifier).clearDateRange();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_week),
                title: const Text('Last 7 days'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await ref.read(dashboardControllerProvider.notifier).setLastDays(7);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_month),
                title: const Text('Last 30 days'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await ref.read(dashboardControllerProvider.notifier).setLastDays(30);
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
                      .read(dashboardControllerProvider.notifier)
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
  final s = start.toIso8601String().split('T')[0];
  final e = end.toIso8601String().split('T')[0];
  return '$s → $e';
}

