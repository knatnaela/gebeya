import 'dart:async';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/auth/merchant_currency_provider.dart';
import '../../../core/ui/widgets/app_card.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/ui/widgets/app_empty_view.dart';
import '../../../core/ui/widgets/app_error_view.dart';
import '../../../core/ui/widgets/app_loading_skeleton.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../models/product.dart';
import '../../../models/product_measure_unit.dart';
import '../products_controller.dart';
import '../products_state.dart';
import 'product_create_edit_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  static const routeLocation = '/app/products';

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => _onSearchChanged(_searchController.text));
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final currentState = ref.read(productsControllerProvider);
      final newSearch = value.isEmpty ? null : value;
      // Only update if search actually changed
      if (currentState.search != newSearch) {
        ref.read(productsControllerProvider.notifier).setFilters(search: newSearch);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsControllerProvider);
    final isMultiSelect = state.selectedIds.isNotEmpty;

    return AppScaffold(
      title: 'Products',
      actions: [
        if (isMultiSelect) ...[
          IconButton(
            onPressed: () => ref.read(productsControllerProvider.notifier).clearSelection(),
            icon: const Icon(Icons.close),
            tooltip: 'Cancel selection',
          ),
        ] else ...[
          IconButton(
            onPressed: () => _openFilterSheet(context),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
        ],
      ],
      floatingActionButton: isMultiSelect
          ? null
          : FloatingActionButton(
              heroTag: 'fab_products',
              onPressed: () => context.push(ProductCreateEditScreen.routeLocation),
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          if (isMultiSelect) _BulkActionsBar(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: _searchController,
              label: 'Search products',
              hintText: 'Search by name, brand, SKU, barcode...',
              onFieldSubmitted: (_) => _onSearchChanged(_searchController.text),
            ),
          ),
          Expanded(
            child: state.isLoading && state.products.isEmpty
                ? const AppLoadingSkeletonList(rows: 10)
                : (state.errorMessage != null && state.products.isEmpty)
                    ? AppErrorView(
                        title: 'Couldn\'t load products',
                        message: state.errorMessage,
                        onRetry: () => ref.read(productsControllerProvider.notifier).refresh(),
                      )
                    : state.products.isEmpty
                        ? AppEmptyView(
                            title: 'No products found',
                            message: 'Add your first product to get started.',
                            ctaLabel: 'Add Product',
                            onCtaPressed: () => context.push(ProductCreateEditScreen.routeLocation),
                          )
                        : _ProductsList(),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final state = ref.watch(productsControllerProvider);
    final brands = <String>{};
    final sizes = <String>{};
    for (final p in state.products) {
      if (p.brand != null && p.brand!.isNotEmpty) brands.add(p.brand!);
      if (p.size != null && p.size!.isNotEmpty) sizes.add(p.size!);
    }
    final brandList = brands.toList()..sort();
    final sizeList = sizes.toList()..sort();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _ProductsFilterSheet(
            currentState: state,
            brands: brandList,
            sizes: sizeList,
            onApply: (filters) {
              Navigator.of(ctx).pop();
              ref.read(productsControllerProvider.notifier).setFilters(
                    search: filters.search,
                    brandFilter: filters.brandFilter,
                    sizeFilter: filters.sizeFilter,
                    minPrice: filters.minPrice,
                    maxPrice: filters.maxPrice,
                    stockFilter: filters.stockFilter,
                    isActiveFilter: filters.isActiveFilter,
                  );
            },
          ),
        ),
      ),
    );
  }
}

class _BulkActionsBar extends ConsumerWidget {
  const _BulkActionsBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsControllerProvider);
    final count = state.selectedIds.length;

    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(
                '$count selected',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _confirmBulkDeactivate(context, ref),
                icon: const Icon(Icons.block, size: 18),
                label: const Text('Deactivate'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _exportCsv(context, ref),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export CSV'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmBulkDeactivate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate products?'),
        content: const Text('Selected products will be deactivated. You can reactivate them later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(productsControllerProvider.notifier).bulkDeactivate();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Products deactivated')),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final state = ref.read(productsControllerProvider);
    if (state.selectedIds.isEmpty) return;

    final selectedProducts = state.products
        .where((p) => state.selectedIds.contains(p.id))
        .toList();

    if (selectedProducts.isEmpty) return;

    // Generate CSV
    final csvData = <List<dynamic>>[
      [
        'Name',
        'Brand',
        'Size',
        'Measure unit',
        'Price',
        'Cost Price',
        'SKU',
        'Barcode',
        'Stock',
        'Low Stock Threshold',
        'Status',
        'Description',
      ],
    ];

    for (final product in selectedProducts) {
      final stock = state.stockMap[product.id] ?? 0;
      csvData.add([
        product.name,
        product.brand ?? '',
        product.size ?? '',
        product.measureUnit.name,
        product.price.toStringAsFixed(2),
        product.costPrice.toStringAsFixed(2),
        product.sku ?? '',
        product.barcode ?? '',
        stock.toString(),
        product.lowStockThreshold.toString(),
        product.isActive ? 'Active' : 'Inactive',
        product.description ?? '',
      ]);
    }

    final csvString = const ListToCsvConverter().convert(csvData);
    final timestamp = DateTime.now().toIso8601String().split('T')[0];

    // Share CSV
    try {
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(csvString.codeUnits),
            name: 'products_export_$timestamp.csv',
            mimeType: 'text/csv',
          ),
        ],
        text: 'Products export',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Products exported successfully')),
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

class _ProductsList extends ConsumerWidget {
  const _ProductsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsControllerProvider);
    final controller = ref.read(productsControllerProvider.notifier);
    final currencyCode = ref.watch(merchantCurrencyProvider);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent * 0.8) {
            controller.loadMore();
          }
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.products.length +
            ((state.pagination?.page ?? 0) < (state.pagination?.totalPages ?? 0) ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= state.products.length) {
            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
          }
          final product = state.products[index];
          final stock = state.stockMap[product.id] ?? 0;
          final isSelected = state.selectedIds.contains(product.id);

          return _ProductListItem(
            product: product,
            stock: stock,
            isSelected: isSelected,
            currencyCode: currencyCode,
              onTap: () {
              if (state.selectedIds.isNotEmpty) {
                controller.toggleSelection(product.id);
              } else {
                context.push('${ProductCreateEditScreen.routeLocation}?id=${Uri.encodeComponent(product.id)}');
              }
            },
            onLongPress: () => controller.toggleSelection(product.id),
          );
        },
      ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  const _ProductListItem({
    required this.product,
    required this.stock,
    required this.isSelected,
    required this.currencyCode,
    required this.onTap,
    required this.onLongPress,
  });

  final Product product;
  final num stock;
  final bool isSelected;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stockStatus = _getStockStatus(stock, product.lowStockThreshold);
    final sizeLabel = formatProductSizeLabel(product.size, product.measureUnit);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.check_circle, color: scheme.primary),
              ),
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: scheme.surfaceContainerHighest,
                    child: Icon(Icons.image, color: scheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.brand != null || sizeLabel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (product.brand != null && product.brand!.trim().isNotEmpty)
                          product.brand!.trim(),
                        if (sizeLabel.isNotEmpty) sizeLabel,
                      ].join(' • '),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        AppFormatters.currency(product.price, currencyCode),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 8),
                      _StockBadge(status: stockStatus, stock: stock),
                      const SizedBox(width: 8),
                      _ActiveBadge(isActive: product.isActive),
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

  String _getStockStatus(num stock, int threshold) {
    if (stock <= 0) return 'outOfStock';
    if (stock <= threshold) return 'lowStock';
    return 'inStock';
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.status, required this.stock});

  final String status;
  final num stock;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color color;
    String label;

    switch (status) {
      case 'outOfStock':
        color = scheme.error;
        label = 'Out of stock';
        break;
      case 'lowStock':
        color = Colors.orange;
        label = 'Low stock';
        break;
      default:
        color = Colors.green;
        label = 'In stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label ($stock)',
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.1)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive
              ? Colors.green.withValues(alpha: 0.3)
              : scheme.outline,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          color: isActive ? Colors.green : scheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProductsFilterSheet extends StatefulWidget {
  const _ProductsFilterSheet({
    required this.currentState,
    required this.brands,
    required this.sizes,
    required this.onApply,
  });

  final ProductsState currentState;
  final List<String> brands;
  final List<String> sizes;
  final void Function(_FilterState) onApply;

  @override
  State<_ProductsFilterSheet> createState() => _ProductsFilterSheetState();
}

class _ProductsFilterSheetState extends State<_ProductsFilterSheet> {
  late String? _search;
  late String? _brandFilter;
  late String? _sizeFilter;
  late num? _minPrice;
  late num? _maxPrice;
  late String? _stockFilter;
  late bool? _isActiveFilter;

  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search = widget.currentState.search;
    _brandFilter = widget.currentState.brandFilter;
    _sizeFilter = widget.currentState.sizeFilter;
    _minPrice = widget.currentState.minPrice;
    _maxPrice = widget.currentState.maxPrice;
    _stockFilter = widget.currentState.stockFilter;
    _isActiveFilter = widget.currentState.isActiveFilter;
    _minPriceController.text = _minPrice?.toString() ?? '';
    _maxPriceController.text = _maxPrice?.toString() ?? '';
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filter products', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FilterSection(
                    title: 'Stock status',
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _stockFilter == null,
                        onTap: () => setState(() => _stockFilter = null),
                      ),
                      _FilterChip(
                        label: 'In stock',
                        selected: _stockFilter == 'inStock',
                        onTap: () => setState(() => _stockFilter = 'inStock'),
                      ),
                      _FilterChip(
                        label: 'Low stock',
                        selected: _stockFilter == 'lowStock',
                        onTap: () => setState(() => _stockFilter = 'lowStock'),
                      ),
                      _FilterChip(
                        label: 'Out of stock',
                        selected: _stockFilter == 'outOfStock',
                        onTap: () => setState(() => _stockFilter = 'outOfStock'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FilterSection(
                    title: 'Status',
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _isActiveFilter == null,
                        onTap: () => setState(() => _isActiveFilter = null),
                      ),
                      _FilterChip(
                        label: 'Active',
                        selected: _isActiveFilter == true,
                        onTap: () => setState(() => _isActiveFilter = true),
                      ),
                      _FilterChip(
                        label: 'Inactive',
                        selected: _isActiveFilter == false,
                        onTap: () => setState(() => _isActiveFilter = false),
                      ),
                    ],
                  ),
                  if (widget.brands.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _FilterSection(
                      title: 'Brand',
                      children: [
                        DropdownButtonFormField<String>(
                          value: _brandFilter,
                          decoration: const InputDecoration(labelText: 'Brand'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All brands')),
                            ...widget.brands.map((b) => DropdownMenuItem(value: b, child: Text(b))),
                          ],
                          onChanged: (v) => setState(() => _brandFilter = v),
                        ),
                      ],
                    ),
                  ],
                  if (widget.sizes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _FilterSection(
                      title: 'Size',
                      children: [
                        DropdownButtonFormField<String>(
                          value: _sizeFilter,
                          decoration: const InputDecoration(labelText: 'Size'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All sizes')),
                            ...widget.sizes.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                          ],
                          onChanged: (v) => setState(() => _sizeFilter = v),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  _FilterSection(
                    title: 'Price range',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _minPriceController,
                              decoration: const InputDecoration(labelText: 'Min price'),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                _minPrice = v.isEmpty ? null : num.tryParse(v);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _maxPriceController,
                              decoration: const InputDecoration(labelText: 'Max price'),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                _maxPrice = v.isEmpty ? null : num.tryParse(v);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _search = null;
                      _brandFilter = null;
                      _sizeFilter = null;
                      _minPrice = null;
                      _maxPrice = null;
                      _stockFilter = null;
                      _isActiveFilter = null;
                      _minPriceController.clear();
                      _maxPriceController.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Apply filters',
                  onPressed: () {
                    widget.onApply(_FilterState(
                      search: _search,
                      brandFilter: _brandFilter,
                      sizeFilter: _sizeFilter,
                      minPrice: _minPrice,
                      maxPrice: _maxPrice,
                      stockFilter: _stockFilter,
                      isActiveFilter: _isActiveFilter,
                    ));
                  },
                ),
              ),
            ],
          ),
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
        const SizedBox(height: 8),
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
          color: selected ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? scheme.onPrimary : scheme.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _FilterState {
  const _FilterState({
    this.search,
    this.brandFilter,
    this.sizeFilter,
    this.minPrice,
    this.maxPrice,
    this.stockFilter,
    this.isActiveFilter,
  });

  final String? search;
  final String? brandFilter;
  final String? sizeFilter;
  final num? minPrice;
  final num? maxPrice;
  final String? stockFilter;
  final bool? isActiveFilter;
}
