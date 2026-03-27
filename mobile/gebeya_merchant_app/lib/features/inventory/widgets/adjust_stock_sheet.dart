import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../models/inventory_transaction.dart';
import '../../../models/location.dart';
import '../../../models/product.dart';
import '../inventory_controller.dart';
import '../inventory_repository.dart';
import '../dto/create_transaction_dto.dart';

class AdjustStockSheet extends ConsumerStatefulWidget {
  const AdjustStockSheet({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  ConsumerState<AdjustStockSheet> createState() => _AdjustStockSheetState();
}

class _AdjustStockSheetState extends ConsumerState<AdjustStockSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  Product? _selectedProduct;
  Location? _selectedLocation;
  InventoryTransactionType _selectedType = InventoryTransactionType.adjustment;
  bool _isLoading = false;
  List<Product> _products = [];
  List<Location> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final results = await Future.wait([
        repo.fetchProducts(isActive: true),
        repo.fetchLocations(),
      ]);

      final products = results[0] as List<Product>;
      final locations = results[1] as List<Location>;

      final defaultLocation = locations.where((l) => l.isDefault).firstOrNull;

      setState(() {
        _products = products;
        _locations = locations;
        _selectedLocation = defaultLocation ?? (locations.isNotEmpty ? locations.first : null);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final quantity = int.parse(_quantityController.text);
      
      // For RESTOCK and RETURN, quantity should be positive
      if ((_selectedType == InventoryTransactionType.restock ||
              _selectedType == InventoryTransactionType.return_) &&
          quantity <= 0) {
        throw const FormatException('Quantity must be positive for restock/return');
      }

      await ref.read(inventoryControllerProvider.notifier).createAdjustment(
            CreateTransactionDto(
              productId: _selectedProduct!.id,
              locationId: _selectedLocation?.id,
              type: _selectedType,
              quantity: quantity,
              reason: _reasonController.text.trim().isEmpty
                  ? null
                  : _reasonController.text.trim(),
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock adjustment created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Adjust Stock', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading && _products.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DropdownButtonFormField<Product>(
                              value: _selectedProduct,
                              decoration: const InputDecoration(
                                labelText: 'Product',
                                hintText: 'Select a product',
                              ),
                              items: _products
                                  .map((p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(p.name),
                                      ))
                                  .toList(),
                              onChanged: (p) => setState(() => _selectedProduct = p),
                              validator: (v) => v == null ? 'Product is required' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<Location>(
                              value: _selectedLocation,
                              decoration: const InputDecoration(
                                labelText: 'Location',
                                hintText: 'Select a location',
                              ),
                              items: _locations
                                  .map((l) => DropdownMenuItem(
                                        value: l,
                                        child: Row(
                                          children: [
                                            Text(l.name),
                                            if (l.isDefault) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Default',
                                                  style: TextStyle(fontSize: 10, color: Colors.blue),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (l) => setState(() => _selectedLocation = l),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<InventoryTransactionType>(
                              value: _selectedType,
                              decoration: const InputDecoration(labelText: 'Type'),
                              items: const [
                                DropdownMenuItem(
                                  value: InventoryTransactionType.adjustment,
                                  child: Text('Adjustment'),
                                ),
                                DropdownMenuItem(
                                  value: InventoryTransactionType.restock,
                                  child: Text('Restock'),
                                ),
                                DropdownMenuItem(
                                  value: InventoryTransactionType.return_,
                                  child: Text('Return'),
                                ),
                              ],
                              onChanged: (t) => setState(() => _selectedType = t ?? InventoryTransactionType.adjustment),
                            ),
                            const SizedBox(height: 12),
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
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _reasonController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Reason (optional)',
                                hintText: 'Enter reason for adjustment',
                              ),
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
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'Apply Adjustment',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
