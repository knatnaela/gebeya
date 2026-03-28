import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../models/product_measure_unit.dart';
import '../products_controller.dart';
import '../products_repository.dart';
import '../dto/create_product_dto.dart';
import '../dto/update_product_dto.dart';

class ProductCreateEditScreen extends ConsumerStatefulWidget {
  const ProductCreateEditScreen({super.key, this.productId});

  static const routeLocation = '/app/products/new';

  final String? productId;

  @override
  ConsumerState<ProductCreateEditScreen> createState() =>
      _ProductCreateEditScreenState();
}

class _ProductCreateEditScreenState
    extends ConsumerState<ProductCreateEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _sizeController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lowStockThresholdController = TextEditingController(text: '5');
  final _imageUrlController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  bool _isEditMode = false;
  /// UI default for new products only (not a server default).
  ProductMeasureUnit _measureUnit = ProductMeasureUnit.ML;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.productId != null;
    if (_isEditMode) {
      _loadProduct();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _lowStockThresholdController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    if (widget.productId == null) return;

    setState(() => _isLoading = true);
    try {
      final product = await ref
          .read(productsRepositoryProvider)
          .fetchProductById(widget.productId!);

      _nameController.text = product.name;
      _brandController.text = product.brand ?? '';
      _sizeController.text = product.size ?? '';
      _priceController.text = product.price.toString();
      _costPriceController.text = product.costPrice.toString();
      _skuController.text = product.sku ?? '';
      _barcodeController.text = product.barcode ?? '';
      _descriptionController.text = product.description ?? '';
      _lowStockThresholdController.text = product.lowStockThreshold.toString();
      _imageUrlController.text = product.imageUrl ?? '';
      _isActive = product.isActive;
      _measureUnit = product.measureUnit;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load product: $e')),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isEditMode) {
        await ref.read(productsControllerProvider.notifier).updateProduct(
              widget.productId!,
              UpdateProductDto(
                name: _nameController.text.trim(),
                brand: _brandController.text.trim().isEmpty
                    ? null
                    : _brandController.text.trim(),
                size: _sizeController.text.trim().isEmpty
                    ? null
                    : _sizeController.text.trim(),
                measureUnit: _measureUnit,
                price: num.tryParse(_priceController.text),
                costPrice: num.tryParse(_costPriceController.text),
                sku: _skuController.text.trim().isEmpty
                    ? null
                    : _skuController.text.trim(),
                barcode: _barcodeController.text.trim().isEmpty
                    ? null
                    : _barcodeController.text.trim(),
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                lowStockThreshold: int.tryParse(_lowStockThresholdController.text),
                imageUrl: _imageUrlController.text.trim().isEmpty
                    ? null
                    : _imageUrlController.text.trim(),
                isActive: _isActive,
              ),
            );
      } else {
        await ref.read(productsControllerProvider.notifier).createProduct(
              CreateProductDto(
                name: _nameController.text.trim(),
                brand: _brandController.text.trim().isEmpty
                    ? null
                    : _brandController.text.trim(),
                size: _sizeController.text.trim().isEmpty
                    ? null
                    : _sizeController.text.trim(),
                measureUnit: _measureUnit,
                price: num.parse(_priceController.text),
                costPrice: num.parse(_costPriceController.text),
                sku: _skuController.text.trim().isEmpty
                    ? null
                    : _skuController.text.trim(),
                barcode: _barcodeController.text.trim().isEmpty
                    ? null
                    : _barcodeController.text.trim(),
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                lowStockThreshold: int.tryParse(_lowStockThresholdController.text),
                imageUrl: _imageUrlController.text.trim().isEmpty
                    ? null
                    : _imageUrlController.text.trim(),
              ),
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Product updated' : 'Product created'),
          ),
        );
        context.pop();
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
    if (_isLoading && _isEditMode) {
      return const AppScaffold(
        title: 'Edit Product',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: _isEditMode ? 'Edit Product' : 'New Product',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Product name',
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Product name is required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _brandController,
                label: 'Brand (optional)',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _sizeController,
                label: 'Size (optional)',
                hintText: 'e.g. 100 — shown with measure unit',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ProductMeasureUnit>(
                value: _measureUnit,
                decoration: const InputDecoration(
                  labelText: 'Measure unit (for size label)',
                  helperText: 'Stock is still counted in bottles/units',
                ),
                items: ProductMeasureUnit.values
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(u.formLabel),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _measureUnit = v);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _priceController,
                      label: 'Price',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if ((v ?? '').isEmpty) return 'Price is required';
                        if (num.tryParse(v ?? '') == null) return 'Invalid number';
                        if (num.parse(v!) <= 0) return 'Price must be positive';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _costPriceController,
                      label: 'Cost price',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if ((v ?? '').isEmpty) return 'Cost price is required';
                        if (num.tryParse(v ?? '') == null) return 'Invalid number';
                        if (num.parse(v!) <= 0) return 'Cost price must be positive';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _skuController,
                label: 'SKU (optional)',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _barcodeController,
                label: 'Barcode (optional)',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _lowStockThresholdController,
                label: 'Low stock threshold',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if ((v ?? '').isEmpty) return 'Threshold is required';
                  final val = int.tryParse(v ?? '');
                  if (val == null || val < 0) return 'Must be a non-negative integer';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _imageUrlController,
                label: 'Image URL (optional)',
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final uri = Uri.tryParse(v);
                  if (uri == null || !uri.hasScheme) return 'Enter a valid URL';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Inactive products won\'t appear in sales'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _isEditMode ? 'Update Product' : 'Create Product',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
