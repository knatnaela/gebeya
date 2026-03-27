import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../models/inventory_transaction.dart';
import '../../../models/location.dart';
import '../../../models/product.dart';
import '../../products/screens/product_picker_screen.dart';
import '../dto/create_transaction_dto.dart';
import '../inventory_controller.dart';
import '../inventory_repository.dart';

class AdjustStockScreen extends ConsumerStatefulWidget {
  const AdjustStockScreen({super.key});

  static const routeLocation = '/app/inventory/adjust';

  @override
  ConsumerState<AdjustStockScreen> createState() => _AdjustStockScreenState();
}

class _AdjustStockScreenState extends ConsumerState<AdjustStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  Product? _selectedProduct;
  Location? _selectedLocation;
  InventoryTransactionType _selectedType = InventoryTransactionType.adjustment;
  bool _isLoading = false;
  List<Location> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await ref.read(inventoryRepositoryProvider).fetchLocations();
      final defaultLocation = locations.where((l) => l.isDefault).firstOrNull;

      if (mounted) {
        setState(() {
          _locations = locations;
          _selectedLocation = defaultLocation ?? (locations.isNotEmpty ? locations.first : null);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load locations: $e')));
      }
    }
  }

  Future<void> _pickProduct() async {
    final product = await context.push<Product>(ProductPickerScreen.routeLocation);
    if (product != null) {
      setState(() {
        _selectedProduct = product;
      });
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a product')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final quantity = int.parse(_quantityController.text);

      // For RESTOCK and RETURN, quantity should be positive
      if ((_selectedType == InventoryTransactionType.restock || _selectedType == InventoryTransactionType.return_) &&
          quantity <= 0) {
        throw const FormatException('Quantity must be positive for restock/return');
      }

      await ref
          .read(inventoryControllerProvider.notifier)
          .createAdjustment(
            CreateTransactionDto(
              productId: _selectedProduct!.id,
              locationId: _selectedLocation?.id,
              type: _selectedType,
              quantity: quantity,
              reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock adjustment created successfully'), backgroundColor: Colors.green),
        );
        ref.read(inventoryControllerProvider.notifier).refresh();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Adjust Stock',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Selector using Picker
              InkWell(
                onTap: _pickProduct,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.lightOutline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.brandPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(AppIcons.products, color: AppColors.brandPurple, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.lightMutedText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedProduct?.name ?? 'Select Product',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: _selectedProduct == null ? AppColors.lightMutedText : AppColors.lightText,
                                fontWeight: _selectedProduct == null ? FontWeight.normal : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(AppIcons.forward, color: AppColors.lightMutedText),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<Location>(
                value: _selectedLocation,
                decoration: const InputDecoration(labelText: 'Location', hintText: 'Select a location'),
                items: _locations.map((l) {
                  return DropdownMenuItem(
                    value: l,
                    child: Text(l.isDefault ? '${l.name} (Default)' : l.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (l) => setState(() => _selectedLocation = l),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<InventoryTransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: InventoryTransactionType.adjustment, child: Text('Adjustment')),
                  DropdownMenuItem(value: InventoryTransactionType.restock, child: Text('Restock')),
                  DropdownMenuItem(value: InventoryTransactionType.return_, child: Text('Return')),
                ],
                onChanged: (t) => setState(() => _selectedType = t ?? InventoryTransactionType.adjustment),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _quantityController,
                label: _selectedType == InventoryTransactionType.adjustment
                    ? 'Quantity (positive or negative)'
                    : 'Quantity',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if ((v ?? '').isEmpty) return 'Quantity is required';
                  final quantity = int.tryParse(v ?? '');
                  if (quantity == null) return 'Enter a valid number';
                  if (_selectedType == InventoryTransactionType.restock ||
                      _selectedType == InventoryTransactionType.return_) {
                    if (quantity <= 0) return 'Quantity must be positive';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  hintText: 'Enter reason for adjustment',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              PrimaryButton(label: 'Apply Adjustment', isLoading: _isLoading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
