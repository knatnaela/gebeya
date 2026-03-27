import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/merchant_currency_provider.dart';
import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/widgets/app_error_view.dart';
import '../../../core/ui/widgets/app_loading_skeleton.dart';
import '../inventory_controller.dart';
import '../screens/adjust_stock_screen.dart';
import '../screens/transfer_stock_screen.dart';
import '../widgets/inventory_action_buttons.dart';
import '../widgets/inventory_summary_carousel.dart';
import '../widgets/transaction_history_list.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  static const routeLocation = '/app/inventory';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryControllerProvider);
    final currencyCode = ref.watch(merchantCurrencyProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: AppColors.lightBackground,
              scrolledUnderElevation: 0,
              expandedHeight: 120, // Height for large title
              floating: false,
              pinned: true,
              centerTitle: false,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Text(
                  'Inventory',
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        24, // Smaller font size when collapsed is handled by Flutter? No, this is the expanded text size.
                    // Actually FlexibleSpaceBar title scales.
                  ),
                ),
                background: Container(color: AppColors.lightBackground),
              ),
              actions: [
                IconButton(
                  onPressed: () {}, // Search implementation later
                  icon: const Icon(AppIcons.search, color: AppColors.lightText),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ];
        },
        body: state.isLoading && state.summary == null
            ? const Padding(padding: EdgeInsets.all(16.0), child: AppLoadingSkeletonList(rows: 5))
            : (state.errorMessage != null && state.summary == null)
            ? AppErrorView(
                title: 'Couldn\'t load inventory',
                message: state.errorMessage,
                onRetry: () => ref.read(inventoryControllerProvider.notifier).refresh(),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.read(inventoryControllerProvider.notifier).refresh(),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // Quick Actions
                          InventoryActionButtons(
                            onAdjustStock: () => _openAdjustStockSheet(context, ref),
                            onTransferStock: () => _openTransferStockSheet(context, ref),
                            onViewEntries: () => context.push('/app/inventory/entries'),
                          ),

                          const SizedBox(height: 24),

                          // Summary Carousel
                          if (state.summary != null)
                            InventorySummaryCarousel(summary: state.summary!, currencyCode: currencyCode),

                          const SizedBox(height: 32),

                          // Transactions
                          TransactionHistoryList(
                            transactions: state.recentTransactions,
                            onViewAll: () => context.push('/app/inventory/transactions'),
                          ),

                          const SizedBox(height: 32), // Bottom padding
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _openAdjustStockSheet(BuildContext context, WidgetRef ref) {
    context.push(AdjustStockScreen.routeLocation);
  }

  void _openTransferStockSheet(BuildContext context, WidgetRef ref) {
    context.push(TransferStockScreen.routeLocation);
  }
}
