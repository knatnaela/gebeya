import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../models/expense_category.dart';
import '../expenses_repository.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.expenseId});

  static const routeLocation = '/app/expenses/new';

  final String? expenseId;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.OTHER;
  DateTime _expenseDate = DateTime.now();
  bool _loading = false;
  bool _loadExisting = false;
  String? _loadError;

  bool get _isEdit => widget.expenseId != null && widget.expenseId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadExisting = true;
      _load();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final exp = await ref
          .read(expensesRepositoryProvider)
          .fetchExpense(widget.expenseId!);
      if (!mounted) return;
      setState(() {
        _category = exp.category;
        _amountController.text = exp.amount.toString();
        _descriptionController.text = exp.description ?? '';
        _expenseDate = exp.expenseDate;
        _loadExisting = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _loadExisting = false;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _expenseDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = ref.read(expensesRepositoryProvider);
      if (_isEdit) {
        await repo.updateExpense(
          widget.expenseId!,
          category: _category,
          amount: amount,
          description: _descriptionController.text.trim(),
          expenseDate: _expenseDate,
        );
      } else {
        await repo.createExpense(
          category: _category,
          amount: amount,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          expenseDate: _expenseDate,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Expense updated' : 'Expense created'),
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadExisting) {
      return AppScaffold(
        title: _isEdit ? 'Edit expense' : 'New expense',
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return AppScaffold(
        title: 'Expense',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_loadError!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return AppScaffold(
      title: _isEdit ? 'Edit expense' : 'New expense',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<ExpenseCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: ExpenseCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                  .toList(),
              onChanged: _loading
                  ? null
                  : (v) =>
                        setState(() => _category = v ?? ExpenseCategory.OTHER),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: '0.00',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount is required';
                final n = double.tryParse(v.trim());
                if (n == null || n <= 0) return 'Enter a positive number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Expense date'),
              subtitle: Text(_expenseDate.toIso8601String().split('T').first),
              trailing: const Icon(Icons.calendar_today),
              onTap: _loading ? null : _pickDate,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _isEdit ? 'Save' : 'Create',
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
