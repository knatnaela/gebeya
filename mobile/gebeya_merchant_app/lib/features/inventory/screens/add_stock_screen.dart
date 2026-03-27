import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../models/location.dart';
import '../../../models/payment_status.dart';
import '../../../models/product.dart';
import '../../products/screens/product_picker_screen.dart';
import '../dto/add_stock_dto.dart';
import '../inventory_repository.dart';
import '../stock_entries_controller.dart';

class AddStockScreen extends ConsumerStatefulWidget {
  const AddStockScreen({super.key});

  static const routeLocation = '/app/inventory/entries/add';

  @override
  ConsumerState<AddStockScreen> createState() => _AddStockScreenState();
}

class _AddStockScreenState extends ConsumerState<AddStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final _supplierNameController = TextEditingController();
  final _supplierContactController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _paidAmountController = TextEditingController();

  Product? _selectedProduct;
  Location? _selectedLocation;
  Location? _defaultLocation;
  PaymentStatus _paymentStatus = PaymentStatus.paid;
  DateTime? _expirationDate;
  DateTime? _paymentDueDate;
  DateTime _receivedDate = DateTime.now();

  bool _isLoading = false;
  bool _isLoadingDefaults = false;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _batchNumberController.dispose();
    _notesController.dispose();
    _supplierNameController.dispose();
    _supplierContactController.dispose();
    _totalCostController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadDefaults() async {
    setState(() => _isLoadingDefaults = true);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final defaultLoc = await repo.fetchDefaultLocation();
      setState(() {
        _defaultLocation = defaultLoc;
        _selectedLocation = defaultLoc;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load default location: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoadingDefaults = false);
    }
  }

  Future<void> _selectProduct() async {
    final selected = await context.push<Product>(ProductPickerScreen.routeLocation);
    if (selected != null) {
      setState(() => _selectedProduct = selected);
    }
  }

  Future<void> _selectLocation() async {
    final repo = ref.read(inventoryRepositoryProvider);
    final locations = await repo.fetchLocations();

    if (!mounted) return;

    final selected = await showDialog<Location>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Select Location', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: locations.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return ListTile(
                    title: Text(location.name, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
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

    if (selected != null) {
      setState(() => _selectedLocation = selected);
    }
  }

  Future<void> _selectDate(
    BuildContext context, {
    required DateTime initialDate,
    required ValueChanged<DateTime> onDateSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.lightText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a product')));
      return;
    }

    if (_paymentStatus == PaymentStatus.partial) {
      final totalCost = double.tryParse(_totalCostController.text);
      final paidAmount = double.tryParse(_paidAmountController.text);
      if (totalCost == null || paidAmount == null || paidAmount >= totalCost) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Paid amount must be less than total cost')));
        return;
      }
    }

    if (_paymentStatus == PaymentStatus.credit && _paymentDueDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment due date is required for CREDIT')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dto = AddStockDto(
        productId: _selectedProduct!.id,
        locationId: _selectedLocation?.id,
        quantity: int.parse(_quantityController.text),
        batchNumber: _batchNumberController.text.trim().isEmpty ? null : _batchNumberController.text.trim(),
        expirationDate: _expirationDate,
        receivedDate: _receivedDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        paymentStatus: _paymentStatus,
        supplierName: _supplierNameController.text.trim().isEmpty ? null : _supplierNameController.text.trim(),
        supplierContact: _supplierContactController.text.trim().isEmpty ? null : _supplierContactController.text.trim(),
        totalCost: _totalCostController.text.trim().isEmpty ? null : double.tryParse(_totalCostController.text),
        paidAmount: _paidAmountController.text.trim().isEmpty ? null : double.tryParse(_paidAmountController.text),
        paymentDueDate: _paymentDueDate,
      );

      await ref.read(stockEntriesControllerProvider.notifier).addStock(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock added successfully'), backgroundColor: AppColors.brandGreen),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add stock: $e'), backgroundColor: AppColors.lightError));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Add Stock',
      body: _isLoadingDefaults
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Product & Location ---
                    _SectionHeader(title: 'Stock Details'),
                    const SizedBox(height: 12),

                    _SelectionCard(
                      icon: AppIcons.products,
                      title: 'Product',
                      value: _selectedProduct?.name,
                      placeholder: 'Select Product',
                      onTap: _selectProduct,
                      hasError: false, // Could add validation state here
                    ),
                    const SizedBox(height: 12),

                    _SelectionCard(
                      icon: AppIcons.location,
                      title: 'Location',
                      value: _selectedLocation?.name ?? _defaultLocation?.name,
                      placeholder: 'Select Location',
                      onTap: _selectLocation,
                    ),
                    const SizedBox(height: 24),

                    // --- Quantity & Batch ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ModernTextField(
                            controller: _quantityController,
                            label: 'Quantity',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final q = int.tryParse(v);
                              if (q == null || q <= 0) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ModernTextField(
                            controller: _batchNumberController,
                            label: 'Batch #',
                            hint: 'Optional',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ModernTextField(
                      controller: _notesController,
                      label: 'Notes',
                      hint: 'Add any remarks...',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 32),

                    // --- Dates ---
                    _SectionHeader(title: 'Dates'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DateSelectionCard(
                            label: 'Received',
                            date: _receivedDate,
                            onTap: () => _selectDate(
                              context,
                              initialDate: _receivedDate,
                              onDateSelected: (d) => setState(() => _receivedDate = d),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateSelectionCard(
                            label: 'Expires',
                            date: _expirationDate,
                            placeholder: 'Optional',
                            onTap: () => _selectDate(
                              context,
                              initialDate: _expirationDate ?? DateTime.now(),
                              onDateSelected: (d) => setState(() => _expirationDate = d),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // --- Payment & Costs ---
                    _SectionHeader(title: 'Payment & Costs'),
                    const SizedBox(height: 12),

                    // Payment Status Segment
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightOutline),
                      ),
                      child: Row(
                        children: PaymentStatus.values.map((status) {
                          final isSelected = _paymentStatus == status;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _paymentStatus = status;
                                  if (status == PaymentStatus.paid) {
                                    _paidAmountController.clear();
                                    _paymentDueDate = null;
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  status.name.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: isSelected ? AppColors.brandPurple : AppColors.lightMutedText,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _ModernTextField(
                            controller: _totalCostController,
                            label: 'Total Cost',
                            prefixIcon: AppIcons.money,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        if (_paymentStatus == PaymentStatus.partial) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ModernTextField(
                              controller: _paidAmountController,
                              label: 'Paid Amount',
                              prefixIcon: AppIcons.money,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) {
                                if (_paymentStatus == PaymentStatus.partial && (v == null || v.isEmpty)) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (_paymentStatus != PaymentStatus.paid) ...[
                      const SizedBox(height: 16),
                      _DateSelectionCard(
                        label: 'Payment Due Date',
                        date: _paymentDueDate,
                        placeholder: 'Select Date',
                        isError: _paymentStatus == PaymentStatus.credit && _paymentDueDate == null,
                        onTap: () => _selectDate(
                          context,
                          initialDate: _paymentDueDate ?? DateTime.now(),
                          onDateSelected: (d) => setState(() => _paymentDueDate = d),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    _ModernTextField(controller: _supplierNameController, label: 'Supplier Name', hint: 'Optional'),
                    const SizedBox(height: 12),
                    _ModernTextField(
                      controller: _supplierContactController,
                      label: 'Supplier Contact',
                      hint: 'Optional',
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 32),
                    PrimaryButton(onPressed: _submit, label: 'Add Stock', isLoading: _isLoading),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightText),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.icon,
    required this.title,
    this.value,
    this.placeholder,
    required this.onTap,
    this.hasError = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String? placeholder;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: hasError ? AppColors.lightError : AppColors.lightOutline),
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
              child: Icon(icon, color: AppColors.brandPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: AppColors.lightMutedText)),
                  const SizedBox(height: 4),
                  Text(
                    value ?? placeholder ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
                      color: value != null ? AppColors.lightText : AppColors.lightMutedText,
                    ),
                  ),
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

class _DateSelectionCard extends StatelessWidget {
  const _DateSelectionCard({
    required this.label,
    this.date,
    this.placeholder,
    required this.onTap,
    this.isError = false,
  });

  final String label;
  final DateTime? date;
  final String? placeholder;
  final VoidCallback onTap;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isError ? AppColors.lightError : AppColors.lightOutline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(AppIcons.calendar, size: 14, color: AppColors.lightMutedText),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightMutedText)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              date != null ? AppFormatters.formatDate(date!).split(' ')[0] : (placeholder ?? '-'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                color: date != null ? AppColors.lightText : AppColors.lightMutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernTextField extends StatelessWidget {
  const _ModernTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.lightMutedText, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.lightMutedText, fontWeight: FontWeight.normal),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: AppColors.lightMutedText) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightOutline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightOutline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brandPurple),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightError),
            ),
          ),
        ),
      ],
    );
  }
}
