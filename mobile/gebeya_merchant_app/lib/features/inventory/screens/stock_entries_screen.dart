import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/widgets/app_empty_view.dart';
import '../../../core/ui/widgets/app_error_view.dart';
import '../../../core/ui/widgets/app_loading_skeleton.dart';
import '../../../models/location.dart';
import '../../../models/product.dart';
import '../inventory_repository.dart';
import '../stock_entries_controller.dart';
import '../widgets/stock_entry_item.dart';

class StockEntriesScreen extends ConsumerStatefulWidget {
  const StockEntriesScreen({super.key});

  static const routeLocation = '/app/inventory/entries';

  @override
  ConsumerState<StockEntriesScreen> createState() => _StockEntriesScreenState();
}

class _StockEntriesScreenState extends ConsumerState<StockEntriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial load is handled by controller
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockEntriesControllerProvider);

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
                  'Stock Entries',
                  style: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold, fontSize: 24),
                ),
                background: Container(color: AppColors.lightBackground),
              ),
              actions: [
                IconButton(
                  onPressed: () => _openAddStockScreen(context),
                  icon: const Icon(AppIcons.add, color: AppColors.brandPurple),
                  tooltip: 'Add Stock',
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverSearchDelegate(
                child: Container(
                  height: 60,
                  color: AppColors.lightBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search product...',
                            prefixIcon: const Icon(AppIcons.search, size: 20),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.lightOutline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.lightOutline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.brandPurple),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => _openFilterSheet(context, ref),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.lightOutline),
                          ),
                          child: const Icon(AppIcons.filter, size: 20, color: AppColors.lightText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: state.isLoading && state.entries.isEmpty
            ? const Padding(padding: EdgeInsets.all(16.0), child: AppLoadingSkeletonList(rows: 10))
            : (state.errorMessage != null && state.entries.isEmpty)
            ? AppErrorView(
                title: 'Couldn\'t load stock entries',
                message: state.errorMessage,
                onRetry: () => ref.read(stockEntriesControllerProvider.notifier).refresh(),
              )
            : state.entries.isEmpty
            ? AppEmptyView(
                title: 'No stock entries found',
                message: 'Add stock to create entries.',
                ctaLabel: 'Add Stock',
                onCtaPressed: () => _openAddStockScreen(context),
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    final metrics = notification.metrics;
                    if (metrics.pixels >= metrics.maxScrollExtent * 0.8) {
                      ref.read(stockEntriesControllerProvider.notifier).loadMore();
                    }
                  }
                  return false;
                },
                child: RefreshIndicator(
                  onRefresh: () => ref.read(stockEntriesControllerProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 32),
                    itemCount:
                        state.entries.length +
                        (state.pagination != null && state.pagination!.page < state.pagination!.totalPages ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
                    itemBuilder: (context, index) {
                      if (index >= state.entries.length) {
                        return const Center(
                          child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                        );
                      }
                      final entry = state.entries[index];
                      return StockEntryItem(entry: entry);
                    },
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context, WidgetRef ref) async {
    final currentState = ref.read(stockEntriesControllerProvider);
    String? selectedProductId = currentState.productIdFilter;
    String? selectedLocationId = currentState.locationIdFilter;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return _FilterSheet(
              selectedProductId: selectedProductId,
              selectedLocationId: selectedLocationId,
              onProductChanged: (id) {
                setModalState(() {
                  selectedProductId = id;
                });
              },
              onLocationChanged: (id) {
                setModalState(() {
                  selectedLocationId = id;
                });
              },
              onApply: () {
                ref
                    .read(stockEntriesControllerProvider.notifier)
                    .setFilters(productIdFilter: selectedProductId, locationIdFilter: selectedLocationId);
                Navigator.of(ctx).pop();
              },
              onClear: () {
                setModalState(() {
                  selectedProductId = null;
                  selectedLocationId = null;
                });
                ref
                    .read(stockEntriesControllerProvider.notifier)
                    .setFilters(productIdFilter: null, locationIdFilter: null);
                Navigator.of(ctx).pop();
              },
            );
          },
        ),
      ),
    );
  }

  void _openAddStockScreen(BuildContext context) {
    context.push('/app/inventory/entries/add');
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

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet({
    required this.selectedProductId,
    required this.selectedLocationId,
    required this.onProductChanged,
    required this.onLocationChanged,
    required this.onApply,
    required this.onClear,
  });

  final String? selectedProductId;
  final String? selectedLocationId;
  final ValueChanged<String?> onProductChanged;
  final ValueChanged<String?> onLocationChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(_productsProvider);
    final locationsAsync = ref.watch(_locationsProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter Entries', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Product',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lightMutedText),
          ),
          const SizedBox(height: 12),
          productsAsync.when(
            data: (products) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceChip(
                  label: 'All Products',
                  selected: selectedProductId == null,
                  onSelected: (_) => onProductChanged(null),
                ),
                ...products.map(
                  (p) => _ChoiceChip(
                    label: p.name,
                    selected: selectedProductId == p.id,
                    onSelected: (_) => onProductChanged(p.id),
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error loading products'),
          ),

          const SizedBox(height: 24),

          Text(
            'Location',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lightMutedText),
          ),
          const SizedBox(height: 12),
          locationsAsync.when(
            data: (locations) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceChip(
                  label: 'All Locations',
                  selected: selectedLocationId == null,
                  onSelected: (_) => onLocationChanged(null),
                ),
                ...locations.map(
                  (l) => _ChoiceChip(
                    label: l.name,
                    selected: selectedLocationId == l.id,
                    onSelected: (_) => onLocationChanged(l.id),
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error loading locations'),
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onClear,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.lightOutline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: onApply,
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
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: Colors.white,
        selectedColor: AppColors.brandPurple,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.lightText,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? Colors.transparent : AppColors.lightOutline),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
    );
  }
}

final _productsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.read(inventoryRepositoryProvider).fetchProducts(isActive: true);
});

final _locationsProvider = FutureProvider<List<Location>>((ref) async {
  return ref.read(inventoryRepositoryProvider).fetchLocations();
});
