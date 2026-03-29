import 'package:freezed_annotation/freezed_annotation.dart';

import 'expense_category.dart';

part 'expense.freezed.dart';

@freezed
abstract class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String merchantId,
    required String userId,
    required ExpenseCategory category,
    required double amount,
    String? description,
    required DateTime expenseDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? recordedByName,
  }) = _Expense;
}
