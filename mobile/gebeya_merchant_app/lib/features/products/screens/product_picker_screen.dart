import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/merchant_currency_provider.dart';
import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/widgets/app_empty_view.dart';
import '../../../core/ui/widgets/app_error_view.dart';
import '../../../core/ui/widgets/app_loading_skeleton.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../models/product.dart';
import '../dto/product_list_response_dto.dart';
import '../products_repository.dart';

class ProductPickerScreen extends ConsumerStatefulWidget {
  const ProductPickerScreen({super.key});

  static const routeLocation = '/app/products/picker';

  @override
  ConsumerState<ProductPickerScreen> createState() => _ProductPickerScreenState();
}

class _ProductPickerScreenState extends ConsumerState<ProductPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  String _query = '';
  final List<Product> _items = [];
  PaginationDto _pagination = const PaginationDto(page: 1, limit: 20, total: 0, totalPages: 0);
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 280) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    final q = _query;
    setState(() {
      _loading = true;
      _error = null;
      _items.clear();
    });
    try {
      final repo = ref.read(productsRepositoryProvider);
      final result = await repo.fetchProducts(
        page: 1,
        limit: 20,
        search: q.isEmpty ? null : q,
        isActive: true,
      );
      if (!mounted || _query != q) return;
      setState(() {
        _items.addAll(result.products);
        _pagination = result.pagination;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || _query != q) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  bool get _hasMore {
    if (_pagination.totalPages <= 0) return false;
    return _pagination.page < _pagination.totalPages;
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    final q = _query;
    final nextPage = _pagination.page + 1;
    setState(() => _loadingMore = true);
    try {
      final repo = ref.read(productsRepositoryProvider);
      final result = await repo.fetchProducts(
        page: nextPage,
        limit: 20,
        search: q.isEmpty ? null : q,
        isActive: true,
      );
      if (!mounted || _query != q) return;
      setState(() {
        _items.addAll(result.products);
        _pagination = result.pagination;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted || _query != q) return;
      setState(() => _loadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load more: $e')));
    }
  }

  void _onSearchChanged(String raw) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _query = raw.trim());
      _refresh();
    });
  }

  void _onProductSelected(Product product) {
    context.pop(product);
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = ref.watch(merchantCurrencyProvider);

    return AppScaffold(
      title: 'Select product',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name, SKU, or brand',
                prefixIcon: const Icon(AppIcons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                          _refresh();
                        },
                      )
                    : null,
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
          Expanded(
            child: _buildBody(currencyCode),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String currencyCode) {
    if (_loading && _items.isEmpty) {
      return const Padding(padding: EdgeInsets.all(16), child: AppLoadingSkeletonList(rows: 8));
    }
    if (_error != null && _items.isEmpty) {
      return AppErrorView(
        title: 'Couldn’t load products',
        message: _error!,
        onRetry: _refresh,
      );
    }
    if (_items.isEmpty) {
      return AppEmptyView(
        title: 'No products found',
        message: _query.isEmpty ? 'No active products yet' : 'No matches for "$_query"',
        icon: AppIcons.products,
        ctaLabel: null,
        onCtaPressed: null,
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _items.length + (_hasMore || _loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: _loadingMore
                    ? const CircularProgressIndicator()
                    : _hasMore
                        ? TextButton.icon(
                            onPressed: _loadMore,
                            icon: const Icon(Icons.expand_more),
                            label: const Text('Load more'),
                          )
                        : const SizedBox.shrink(),
              ),
            );
          }
          final product = _items[index];
          return _ProductPickerItem(
            product: product,
            currencyCode: currencyCode,
            onTap: () => _onProductSelected(product),
          );
        },
      ),
    );
  }
}

class _ProductPickerItem extends StatelessWidget {
  const _ProductPickerItem({
    required this.product,
    required this.currencyCode,
    required this.onTap,
  });

  final Product product;
  final String currencyCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.brandPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(AppIcons.products, color: AppColors.brandPurple, size: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.lightText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.price.toCurrency(currencyCode),
                    style: const TextStyle(fontSize: 14, color: AppColors.brandPurple, fontWeight: FontWeight.w500),
                  ),
                  if (product.brand != null || product.sku != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (product.brand != null) product.brand,
                        if (product.sku != null) 'SKU: ${product.sku}',
                      ].join(' • '),
                      style: const TextStyle(fontSize: 13, color: AppColors.lightMutedText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(AppIcons.forward, size: 16, color: AppColors.lightMutedText),
          ],
        ),
      ),
    );
  }
}
