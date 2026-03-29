import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/merchant_currency_provider.dart';
import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/widgets/app_empty_view.dart';
import '../../../core/ui/widgets/app_error_view.dart';
import '../../../core/ui/widgets/app_loading_skeleton.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/utils/date_period_shortcuts.dart';
import '../../../models/expense.dart';
import '../../../models/expense_category.dart';
import '../expenses_controller.dart';
import '../expenses_repository.dart';
import '../expenses_state.dart';
import 'expense_form_screen.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  static const routeLocation = '/app/expenses';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expensesControllerProvider);
    final currencyCode = ref.watch(merchantCurrencyProvider);

    return AppScaffold(
      title: 'Expenses',
      actions: [
        IconButton(
          onPressed: () => _openDateFilterSheet(context, ref),
          icon: const Icon(AppIcons.calendar),
          tooltip: 'Filter by date',
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_expenses',
        onPressed: () async {
          final changed = await context.push<bool>(
            ExpenseFormScreen.routeLocation,
          );
          if (changed == true && context.mounted) {
            await ref.read(expensesControllerProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: DropdownButtonFormField<ExpenseCategory?>(
              value: state.categoryFilter,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<ExpenseCategory?>(
                  value: null,
                  child: Text('All categories'),
                ),
                ...ExpenseCategory.values.map(
                  (c) => DropdownMenuItem(value: c, child: Text(c.label)),
                ),
              ],
              onChanged: (v) {
                ref
                    .read(expensesControllerProvider.notifier)
                    .setCategoryFilter(v);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _periodLabel(state.startDate, state.endDate),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _ExpensesBody(state: state, currencyCode: currencyCode),
          ),
        ],
      ),
    );
  }
}

class _ExpensesBody extends ConsumerWidget {
  const _ExpensesBody({required this.state, required this.currencyCode});

  final ExpensesState state;
  final String currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.expenses.isEmpty) {
      return const AppLoadingSkeletonList(rows: 10);
    }
    if (state.errorMessage != null && state.expenses.isEmpty) {
      return AppErrorView(
        title: 'Could not load expenses',
        message: state.errorMessage,
        onRetry: () => ref.read(expensesControllerProvider.notifier).refresh(),
      );
    }
    if (state.expenses.isEmpty) {
      return AppEmptyView(
        icon: AppIcons.money,
        title: 'No expenses',
        message: 'Add an expense or widen your date filter.',
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels > n.metrics.maxScrollExtent - 200) {
          ref.read(expensesControllerProvider.notifier).loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        itemCount: state.expenses.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= state.expenses.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final e = state.expenses[i];
          return _ExpenseTile(
            expense: e,
            currencyCode: currencyCode,
            onTap: () async {
              final changed = await context.push<bool>(
                '${ExpenseFormScreen.routeLocation}?id=${e.id}',
              );
              if (changed == true && context.mounted) {
                await ref.read(expensesControllerProvider.notifier).refresh();
              }
            },
            onDelete: () => _confirmDelete(context, ref, e),
          );
        },
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.currencyCode,
    required this.onTap,
    required this.onDelete,
  });

  final Expense expense;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(
          expense.category.label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          [
            AppFormatters.formatDate(expense.expenseDate),
            if ((expense.description ?? '').isNotEmpty) expense.description!,
            if ((expense.recordedByName ?? '').isNotEmpty)
              expense.recordedByName!,
          ].where((s) => s.isNotEmpty).join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              expense.amount.toCurrency(currencyCode),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Expense e,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete expense?'),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    await ref.read(expensesRepositoryProvider).deleteExpense(e.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
      await ref.read(expensesControllerProvider.notifier).refresh();
    }
  } catch (err) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$err')));
    }
  }
}

Future<void> _openDateFilterSheet(BuildContext context, WidgetRef ref) async {
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
              Text(
                'Filter by date',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.all_inclusive),
                title: const Text('All time'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await ref
                      .read(expensesControllerProvider.notifier)
                      .clearDateRange();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_week),
                title: const Text('Last 7 days'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await ref
                      .read(expensesControllerProvider.notifier)
                      .setLastDays(7);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_month),
                title: const Text('Last 30 days'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await ref
                      .read(expensesControllerProvider.notifier)
                      .setLastDays(30);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event_note),
                title: const Text('This month'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await ref.read(expensesControllerProvider.notifier).setThisMonth();
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Custom range'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked == null) return;
                  await ref
                      .read(expensesControllerProvider.notifier)
                      .setDateRange(
                        startDate: picked.start,
                        endDate: picked.end,
                      );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _periodLabel(DateTime? start, DateTime? end) {
  if (start == null || end == null) return 'All time';
  if (matchesThisMonthRange(start, end)) return 'This month';
  final s = start.toIso8601String().split('T')[0];
  final e = end.toIso8601String().split('T')[0];
  return 'Period: $s → $e';
}
