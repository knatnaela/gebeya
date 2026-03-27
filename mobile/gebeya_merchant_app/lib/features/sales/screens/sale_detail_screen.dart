import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/ui/widgets/app_card.dart';
import '../../../core/ui/widgets/app_error_view.dart';
import '../../../core/ui/widgets/app_loading_skeleton.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/auth/merchant_currency_provider.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../models/sale.dart';
import '../sales_repository.dart';

class SaleDetailScreen extends ConsumerStatefulWidget {
  const SaleDetailScreen({super.key, required this.saleId});

  final String saleId;

  static String pathFor(String saleId) => '/app/sales/detail/$saleId';

  @override
  ConsumerState<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends ConsumerState<SaleDetailScreen> {
  Sale? _sale;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sale = await ref.read(salesRepositoryProvider).fetchSaleById(widget.saleId);
      setState(() {
        _sale = sale;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _share(Sale sale, String currencyCode) async {
    final b = StringBuffer()
      ..writeln('Sale ${sale.id}')
      ..writeln(AppFormatters.formatDate(sale.saleDate))
      ..writeln('Total: ${sale.totalAmount.toCurrency(currencyCode)}')
      ..writeln('COGS: ${sale.costOfGoodsSold.toCurrency(currencyCode)}')
      ..writeln('Net: ${sale.netIncome.toCurrency(currencyCode)} (${sale.profitMargin.toStringAsFixed(1)}%)')
      ..writeln()
      ..writeln('Items:');
    for (final item in sale.items) {
      final lineProfit = item.totalPrice - item.quantity * item.costPrice;
      b.writeln(
        '• ${item.productName} x${item.quantity} @ ${item.unitPrice.toCurrency(currencyCode)} → ${item.totalPrice.toCurrency(currencyCode)} (profit ${lineProfit.toCurrency(currencyCode)})',
      );
    }
    await SharePlus.instance.share(
      ShareParams(text: b.toString(), subject: 'Sale ${sale.id}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return AppScaffold(
        title: 'Sale',
        body: const AppLoadingSkeletonList(rows: 8),
      );
    }
    if (_error != null || _sale == null) {
      return AppScaffold(
        title: 'Sale',
        body: AppErrorView(
          title: 'Couldn’t load sale',
          message: _error ?? 'Unknown error',
          onRetry: _load,
        ),
      );
    }

    final sale = _sale!;
    final currencyCode = ref.watch(merchantCurrencyProvider);

    return AppScaffold(
      title: 'Sale',
      actions: [
        IconButton(
          onPressed: () => _share(sale, currencyCode),
          icon: const Icon(Icons.share),
          tooltip: 'Share',
        ),
      ],
      body: ListView(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${AppFormatters.formatDate(sale.saleDate)} · ${sale.id}', style: Theme.of(context).textTheme.titleSmall),
                if ((sale.customerName ?? '').isNotEmpty) Text('Customer: ${sale.customerName}'),
                if ((sale.customerPhone ?? '').isNotEmpty) Text('Phone: ${sale.customerPhone}'),
                if (sale.seller != null)
                  Text(
                    'Sold by: ${sale.seller!.firstName ?? ''} ${sale.seller!.lastName ?? ''} ${sale.seller!.email != null ? '(${sale.seller!.email})' : ''}',
                  ),
                if ((sale.notes ?? '').isNotEmpty) Text('Notes: ${sale.notes}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Totals', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Text('Revenue: ${sale.totalAmount.toCurrency(currencyCode)}'),
                Text('COGS: ${sale.costOfGoodsSold.toCurrency(currencyCode)}'),
                Text('Net income: ${sale.netIncome.toCurrency(currencyCode)}'),
                Text('Margin: ${sale.profitMargin.toStringAsFixed(2)}%'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('Line items', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...sale.items.map(
            (item) {
              final lineProfit = item.totalPrice - item.quantity * item.costPrice;
              final margin = item.totalPrice > 0 ? (lineProfit / item.totalPrice) * 100 : 0.0;
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName, style: Theme.of(context).textTheme.titleSmall),
                    Text('Qty ${item.quantity} · Default ${item.defaultPrice.toCurrency(currencyCode)} · Sold ${item.unitPrice.toCurrency(currencyCode)}'),
                    Text('Revenue: ${item.totalPrice.toCurrency(currencyCode)}'),
                    Text('Cost: ${(item.quantity * item.costPrice).toCurrency(currencyCode)}'),
                    Text('Profit: ${lineProfit.toCurrency(currencyCode)} (${margin.toStringAsFixed(1)}%)'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
