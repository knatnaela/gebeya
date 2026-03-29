import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/phone/phone_api_payload.dart';
import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/widgets/app_card.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/auth/merchant_currency_provider.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../models/location.dart';
import '../../../models/product.dart';
import '../../../models/sale.dart';
import '../../locations/locations_repository.dart';
import '../../products/products_repository.dart';
import '../../subscription/subscription_controller.dart';
import '../../products/screens/product_create_edit_screen.dart';
import '../../products/screens/product_picker_screen.dart';
import '../dto/create_sale_dto.dart';
import '../sales_controller.dart';
import '../sales_repository.dart';

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key});

  static const routeLocation = '/app/sales/new';

  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _CartLine {
  _CartLine({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.defaultPrice,
    required this.costPrice,
  });

  final String productId;
  final String productName;
  int quantity;
  num unitPrice;
  final num defaultPrice;
  final num costPrice;

  num get lineTotal => quantity * unitPrice;
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen> {
  List<Location> _locations = [];
  Location? _selectedLocation;
  Product? _selectedProduct;
  final _qtyController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final _customerNameController = TextEditingController();
  final List<_CartLine> _lines = [];
  String? _customerPhoneE164;
  final Map<String, TextEditingController> _unitPriceControllers = {};
  DateTime _saleDate = DateTime.now();
  bool _loading = true;
  bool _submitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _unitPriceControllers.values) {
      c.dispose();
    }
    _unitPriceControllers.clear();
    _qtyController.dispose();
    _notesController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final locations = await ref.read(locationsRepositoryProvider).fetchLocations();
      Location? def;
      for (final l in locations) {
        if (l.isDefault) {
          def = l;
          break;
        }
      }
      setState(() {
        _locations = locations;
        _selectedLocation = def ?? (locations.isNotEmpty ? locations.first : null);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = _dioErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _selectLocation() async {
    if (_locations.isEmpty) return;
    final selected = await showDialog<Location>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Select location', style: Theme.of(context).textTheme.titleMedium),
            ),
            const Divider(height: 1),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.45),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _locations.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final location = _locations[index];
                  return ListTile(
                    title: Text(location.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: location.isDefault
                        ? const Text('Default', style: TextStyle(color: AppColors.brandPurple))
                        : null,
                    trailing: location.isDefault ? const Icon(AppIcons.check, color: AppColors.brandPurple) : null,
                    onTap: () => Navigator.of(context).pop(location),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null && mounted) setState(() => _selectedLocation = selected);
  }

  Future<void> _selectProduct() async {
    final picked = await context.push<Product>(ProductPickerScreen.routeLocation);
    if (picked != null && mounted) setState(() => _selectedProduct = picked);
  }

  Future<void> _addLine() async {
    final product = _selectedProduct;
    final locId = _selectedLocation?.id;
    if (product == null || locId == null) {
      _snack('Select a product and location');
      return;
    }
    final productId = product.id;
    final qty = int.tryParse(_qtyController.text.trim());
    if (qty == null || qty <= 0) {
      _snack('Enter a valid quantity');
      return;
    }

    final productsRepo = ref.read(productsRepositoryProvider);
    num currentStock;
    try {
      currentStock = await productsRepo.fetchProductStock(productId, locationId: locId);
    } catch (e) {
      _snack('Stock check failed: ${_dioErrorMessage(e)}');
      return;
    }

    final existingIdx = _lines.indexWhere((l) => l.productId == productId);
    final totalQty = existingIdx >= 0 ? _lines[existingIdx].quantity + qty : qty;

    if (totalQty > currentStock) {
      _snack('Insufficient stock. Available: $currentStock');
      return;
    }

    final unitPrice = product.price;
    setState(() {
      if (existingIdx >= 0) {
        _lines[existingIdx].quantity = totalQty;
        final ctrl = _unitPriceControllers[product.id];
        if (ctrl != null) {
          ctrl.text = _lines[existingIdx].unitPrice.toStringAsFixed(2);
        }
      } else {
        _lines.add(
          _CartLine(
            productId: product.id,
            productName: product.name,
            quantity: qty,
            unitPrice: unitPrice,
            defaultPrice: product.price,
            costPrice: product.costPrice,
          ),
        );
        _unitPriceControllers[product.id] = TextEditingController(text: unitPrice.toStringAsFixed(2));
      }
      _selectedProduct = null;
      _qtyController.text = '1';
    });
  }

  void _removeLine(int index) {
    final line = _lines[index];
    _unitPriceControllers[line.productId]?.dispose();
    _unitPriceControllers.remove(line.productId);
    setState(() => _lines.removeAt(index));
  }

  Future<void> _submit() async {
    if (ref.read(subscriptionControllerProvider).isExpired) {
      _snack('Subscription expired');
      return;
    }
    if (_lines.isEmpty) {
      _snack('Add at least one line item');
      return;
    }
    final locId = _selectedLocation?.id;
    if (locId == null) {
      _snack('Select a location');
      return;
    }

    setState(() => _submitting = true);
    try {
      final customer = PhoneApiPayload.customerSale(_customerPhoneE164);
      final payload = CreateSaleDto(
        items: _lines
            .map((l) => CreateSaleItemDto(productId: l.productId, quantity: l.quantity, unitPrice: l.unitPrice))
            .toList(),
        locationId: locId,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        saleDate: _saleDate.toIso8601String().split('T')[0],
        customerName: _customerNameController.text.trim().isEmpty ? null : _customerNameController.text.trim(),
        customerPhoneCountryIso: customer?['customerPhoneCountryIso'],
        customerPhoneNationalNumber: customer?['customerPhoneNationalNumber'],
        customerPhone: customer?['customerPhone'],
      );

      final sale = await ref.read(salesRepositoryProvider).createSale(payload);
      if (!mounted) return;
      ref.read(salesControllerProvider.notifier).refresh();
      await _showReceipt(context, sale, ref.read(merchantCurrencyProvider));
      if (!mounted) return;
      context.pop();
    } catch (e) {
      _snack(_dioErrorMessage(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showReceipt(BuildContext context, Sale sale, String currencyCode) async {
    final buffer = StringBuffer()
      ..writeln('Sale ${sale.id}')
      ..writeln(AppFormatters.formatDate(sale.saleDate))
      ..writeln('Total: ${sale.totalAmount.toCurrency(currencyCode)}')
      ..writeln('Net: ${sale.netIncome.toCurrency(currencyCode)} (${sale.profitMargin.toStringAsFixed(1)}% margin)');
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
                Text('Sale recorded', style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 12),
                SelectableText(buffer.toString()),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Share',
                  onPressed: () async {
                    await SharePlus.instance.share(
                      ShareParams(text: buffer.toString(), subject: 'Sale ${sale.id}'),
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = ref.watch(merchantCurrencyProvider);
    final theme = Theme.of(context);
    // M3 merges OutlinedButton defaults with theme; min width can stay ∞ and break Rows.
    // Force a finite minimum so sibling buttons in a Row lay out.
    final rowOutlineStyle = theme.outlinedButtonTheme.style?.copyWith(
          minimumSize: const WidgetStatePropertyAll(Size(64, 52)),
        ) ??
        OutlinedButton.styleFrom(minimumSize: const Size(64, 52));
    final expired = ref.watch(subscriptionControllerProvider).isExpired;
    final totalRev = _lines.fold<num>(0, (s, l) => s + l.lineTotal);
    final totalCogs = _lines.fold<num>(0, (s, l) => s + l.quantity * l.costPrice);
    final net = totalRev - totalCogs;
    final margin = totalRev > 0 ? (net / totalRev) * 100 : 0.0;

    if (_loading) {
      return const AppScaffold(
        title: 'New sale',
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return AppScaffold(
        title: 'New sale',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!),
              const SizedBox(height: 12),
              TextButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      title: 'New sale',
      body: ListView(
        children: [
          if (expired)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Trial expired — recording sales may be blocked.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          _SaleSelectionCard(
            icon: AppIcons.products,
            title: 'Product',
            value: _selectedProduct?.name,
            placeholder: 'Select Product',
            onTap: _selectProduct,
          ),
          const SizedBox(height: 12),
          _SaleSelectionCard(
            icon: AppIcons.location,
            title: 'Location',
            value: _selectedLocation == null
                ? null
                : '${_selectedLocation!.name}${_selectedLocation!.isDefault ? ' (default)' : ''}',
            placeholder: 'Select Location',
            onTap: _selectLocation,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: rowOutlineStyle,
                  onPressed: _addLine,
                  icon: const Icon(Icons.add),
                  label: const Text('Add to sale'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: rowOutlineStyle,
                onPressed: () async {
                  await context.push(ProductCreateEditScreen.routeLocation);
                  await _loadData();
                },
                child: const Text('New product'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_lines.isNotEmpty) ...[
            Text('Line items', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...List.generate(_lines.length, (i) {
              final line = _lines[i];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(line.productName, style: Theme.of(context).textTheme.titleSmall)),
                        IconButton(onPressed: () => _removeLine(i), icon: const Icon(Icons.delete_outline)),
                      ],
                    ),
                    Text('Qty: ${line.quantity}'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _unitPriceControllers[line.productId],
                      decoration: const InputDecoration(labelText: 'Sold price (unit)', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) {
                        final p = num.tryParse(v);
                        if (p != null && p > 0) {
                          setState(() => line.unitPrice = p);
                        }
                      },
                    ),
                    Text('Line total: ${line.lineTotal.toCurrency(currencyCode)}'),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Sale date'),
            subtitle: Text(_saleDate.toIso8601String().split('T')[0]),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _saleDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (d != null) setState(() => _saleDate = d);
            },
          ),
          TextFormField(
            controller: _customerNameController,
            decoration: const InputDecoration(labelText: 'Customer name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          IntlPhoneField(
            decoration: const InputDecoration(
              labelText: 'Customer phone',
              border: OutlineInputBorder(),
            ),
            initialCountryCode: 'ET',
            disableLengthCheck: true,
            onChanged: (phone) {
              final c = phone.completeNumber.trim();
              setState(() {
                _customerPhoneE164 = c.isEmpty ? null : (c.startsWith('+') ? c : '+$c');
              });
            },
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Summary', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Text('Revenue: ${totalRev.toCurrency(currencyCode)}'),
                Text('COGS: ${totalCogs.toCurrency(currencyCode)}'),
                Text('Net: ${net.toCurrency(currencyCode)} (${margin.toStringAsFixed(1)}% margin)'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Record sale', isLoading: _submitting, onPressed: expired ? null : _submit),
        ],
      ),
    );
  }
}

/// Mirrors [AddStockScreen]’s `_SelectionCard` (product / location rows).
class _SaleSelectionCard extends StatelessWidget {
  const _SaleSelectionCard({
    required this.icon,
    required this.title,
    this.value,
    this.placeholder,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.62);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.brandPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.brandPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, color: muted)),
                  const SizedBox(height: 4),
                  Text(
                    value ?? placeholder ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
                      color: value != null ? scheme.onSurface : muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(AppIcons.forward, size: 16, color: muted),
          ],
        ),
      ),
    );
  }
}

String _dioErrorMessage(Object e) {
  if (e is DioException) {
    final d = e.response?.data;
    if (d is Map && d['error'] != null) return d['error'].toString();
  }
  return e.toString();
}
