import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../models/location.dart';
import '../../../models/product.dart';
import '../../products/screens/product_picker_screen.dart';
import '../dto/transfer_stock_dto.dart';
import '../inventory_repository.dart';
import '../stock_entries_controller.dart';

class TransferStockScreen extends ConsumerStatefulWidget {
  const TransferStockScreen({super.key});

  static const routeLocation = '/app/inventory/transfer';

  @override
  ConsumerState<TransferStockScreen> createState() => _TransferStockScreenState();
}

class _TransferStockScreenState extends ConsumerState<TransferStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  Product? _selectedProduct;
  Location? _fromLocation;
  Location? _toLocation;

  bool _isLoading = false;
  bool _isCheckingStock = false;
  int? _availableStock;

  // Cache locations to avoid repeated calls
  List<Location> _allLocations = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    try {
      final locs = await ref.read(inventoryRepositoryProvider).fetchLocations();
      if (mounted) setState(() => _allLocations = locs);
    } catch (e) {
      // Handle silently or show toast?
    }
  }

  Future<void> _pickProduct() async {
    final product = await context.push<Product>(ProductPickerScreen.routeLocation);
    if (product != null) {
      setState(() {
        _selectedProduct = product;
        _fromLocation = null;
        _toLocation = null;
        _availableStock = null;
        _quantityController.clear();
      });
    }
  }

  // Reuse a simple location picker dialog or bottom sheet for now since locations are few
  // or build a simple picker widget if list is long. Assuming < 50 locations usually.
  Future<void> _pickLocation(bool isSource) async {
    if (isSource && _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a product first')));
      return;
    }

    // If source is selected, filter destination
    final available = isSource ? _allLocations : _allLocations.where((l) => l.id != _fromLocation?.id).toList();

    if (!mounted) return;

    final selected = await showModalBottomSheet<Location>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: available.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final loc = available[index];
          return ListTile(
            title: Text(loc.name),
            subtitle: loc.isDefault ? const Text('Default', style: TextStyle(color: Colors.blue, fontSize: 12)) : null,
            onTap: () => Navigator.pop(ctx, loc),
          );
        },
      ),
    );

    if (selected != null) {
      setState(() {
        if (isSource) {
          _fromLocation = selected;
          _toLocation = null; // Reset destination if source changes to avoid same-location error
          _availableStock = null;
          _quantityController.clear();
        } else {
          _toLocation = selected;
        }
      });
      if (isSource) _checkStock();
    }
  }

  Future<void> _checkStock() async {
    if (_selectedProduct == null || _fromLocation == null) return;

    setState(() => _isCheckingStock = true);

    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get(
        Endpoints.inventoryStock(_selectedProduct!.id),
        queryParameters: {'locationId': _fromLocation!.id},
      );

      final stock = res.data['data'] as int? ?? 0;
      if (mounted) {
        setState(() {
          _availableStock = stock;
          _isCheckingStock = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingStock = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to check stock: $e')));
      }
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProduct == null || _fromLocation == null || _toLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select all fields')));
      return;
    }

    final quantity = int.parse(_quantityController.text);
    if (_availableStock != null && quantity > _availableStock!) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Insufficient stock. Available: $_availableStock')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dto = TransferStockDto(
        productId: _selectedProduct!.id,
        fromLocationId: _fromLocation!.id,
        toLocationId: _toLocation!.id,
        quantity: quantity,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await ref.read(stockEntriesControllerProvider.notifier).transferStock(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stock transferred successfully')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to transfer stock: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Transfer Stock',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Selector
              _SelectionCard(
                label: 'Product',
                value: _selectedProduct?.name,
                placeholder: 'Select Product',
                icon: AppIcons.products,
                onTap: _pickProduct,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _SelectionCard(
                      label: 'From',
                      value: _fromLocation?.name,
                      placeholder: 'Source',
                      icon: AppIcons.location,
                      onTap: () => _pickLocation(true),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(AppIcons.forward, color: AppColors.lightMutedText),
                  ),
                  Expanded(
                    child: _SelectionCard(
                      label: 'To',
                      value: _toLocation?.name,
                      placeholder: 'Destination',
                      icon: AppIcons.location,
                      onTap: () => _pickLocation(false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              // Stock Checker
              if (_isCheckingStock)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Checking stock...', style: TextStyle(fontSize: 12, color: AppColors.lightMutedText)),
                    ],
                  ),
                )
              else if (_availableStock != null && _fromLocation != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    'Available at source: $_availableStock',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _availableStock! > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Quantity', border: OutlineInputBorder(), hintText: '0'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final qty = int.tryParse(value);
                  if (qty == null || qty <= 0) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              PrimaryButton(label: 'Transfer Stock', isLoading: _isLoading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String? value;
  final String placeholder;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.lightOutline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.lightMutedText),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightMutedText)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasValue ? value! : placeholder,
              style: TextStyle(
                fontSize: 14,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
                color: hasValue ? AppColors.lightText : AppColors.lightMutedText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
