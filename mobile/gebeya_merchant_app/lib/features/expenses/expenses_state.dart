import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../products/dto/product_list_response_dto.dart';

part 'expenses_state.freezed.dart';

@freezed
abstract class ExpensesState with _$ExpensesState {
  const factory ExpensesState({
    required bool isLoading,
    @Default(false) bool isLoadingMore,
    String? errorMessage,
    @Default(<Expense>[]) List<Expense> expenses,
    PaginationDto? pagination,
    DateTime? startDate,
    DateTime? endDate,

    /// `null` means all categories.
    ExpenseCategory? categoryFilter,
  }) = _ExpensesState;

  factory ExpensesState.initial() => const ExpensesState(isLoading: true);
}
