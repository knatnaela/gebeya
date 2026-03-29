import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/dto/api_response_dto.dart';
import '../../core/api/endpoints.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../products/dto/product_list_response_dto.dart';
import 'dto/expense_dto.dart';

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository(ref.watch(dioProvider));
});

class ExpensesRepository {
  ExpensesRepository(this._dio);

  final Dio _dio;

  Future<({List<Expense> expenses, PaginationDto pagination})> fetchExpenses({
    DateTime? startDate,
    DateTime? endDate,
    ExpenseCategory? category,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (startDate != null) {
      query['startDate'] = startDate.toUtc().toIso8601String();
    }
    if (endDate != null) {
      query['endDate'] = endDate.toUtc().toIso8601String();
    }
    if (category != null) {
      query['category'] = category.name;
    }

    final res = await _dio.get(Endpoints.expenses, queryParameters: query);

    final data = res.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>? ?? [];
    final paginationMap = data['pagination'] as Map<String, dynamic>?;

    final expenses = list
        .map(
          (json) =>
              ExpenseDto.fromJson(json as Map<String, dynamic>).toDomain(),
        )
        .toList();

    final pagination = paginationMap != null
        ? PaginationDto.fromJson(paginationMap)
        : const PaginationDto(page: 1, limit: 20, total: 0, totalPages: 0);

    return (expenses: expenses, pagination: pagination);
  }

  Future<Expense> fetchExpense(String id) async {
    final res = await _dio.get(Endpoints.expense(id));
    final envelope = ApiResponseDto<ExpenseDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => ExpenseDto.fromJson(json as Map<String, dynamic>),
    );
    final dto = envelope.data;
    if (dto == null)
      throw const ExpensesRepositoryException('Missing expense data.');
    return dto.toDomain();
  }

  Future<Expense> createExpense({
    required ExpenseCategory category,
    required double amount,
    String? description,
    DateTime? expenseDate,
  }) async {
    final body = <String, dynamic>{
      'category': category.name,
      'amount': amount,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (expenseDate != null) 'expenseDate': _expenseDateJson(expenseDate),
    };

    final res = await _dio.post(Endpoints.expenses, data: body);
    final envelope = ApiResponseDto<ExpenseDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => ExpenseDto.fromJson(json as Map<String, dynamic>),
    );
    final dto = envelope.data;
    if (dto == null)
      throw const ExpensesRepositoryException('Missing expense data.');
    return dto.toDomain();
  }

  Future<Expense> updateExpense(
    String id, {
    required ExpenseCategory category,
    required double amount,
    required String description,
    required DateTime expenseDate,
  }) async {
    final body = <String, dynamic>{
      'category': category.name,
      'amount': amount,
      'expenseDate': _expenseDateJson(expenseDate),
      'description': description,
    };

    final res = await _dio.put(Endpoints.expense(id), data: body);
    final envelope = ApiResponseDto<ExpenseDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => ExpenseDto.fromJson(json as Map<String, dynamic>),
    );
    final dto = envelope.data;
    if (dto == null)
      throw const ExpensesRepositoryException('Missing expense data.');
    return dto.toDomain();
  }

  Future<void> deleteExpense(String id) async {
    await _dio.delete(Endpoints.expense(id));
  }

  /// Backend accepts YYYY-MM-DD or ISO datetime strings.
  String _expenseDateJson(DateTime d) {
    final local = DateTime(d.year, d.month, d.day);
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}

class ExpensesRepositoryException implements Exception {
  const ExpensesRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
