import 'package:json_annotation/json_annotation.dart';

import '../../../models/expense.dart';
import '../../../models/expense_category.dart';

part 'expense_dto.g.dart';

num _numFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value;
  if (value is String) {
    final parsed = num.tryParse(value);
    if (parsed != null) return parsed;
  }
  return 0;
}

@JsonSerializable(createToJson: false)
class ExpenseUserDto {
  const ExpenseUserDto({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;

  factory ExpenseUserDto.fromJson(Map<String, dynamic> json) =>
      _$ExpenseUserDtoFromJson(json);

  String? get displayName {
    final parts = [
      firstName,
      lastName,
    ].whereType<String>().where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return email;
    return parts.join(' ');
  }
}

@JsonSerializable(createToJson: false)
class ExpenseDto {
  const ExpenseDto({
    required this.id,
    required this.merchantId,
    required this.userId,
    required this.category,
    required this.amount,
    this.description,
    required this.expenseDate,
    required this.createdAt,
    required this.updatedAt,
    this.users,
  });

  final String id;
  final String merchantId;
  final String userId;
  final String category;
  @JsonKey(fromJson: _numFromJson)
  final num amount;
  final String? description;
  final DateTime expenseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ExpenseUserDto? users;

  factory ExpenseDto.fromJson(Map<String, dynamic> json) =>
      _$ExpenseDtoFromJson(json);

  Expense toDomain() {
    final u = users;
    return Expense(
      id: id,
      merchantId: merchantId,
      userId: userId,
      category: expenseCategoryFromApi(category),
      amount: amount.toDouble(),
      description: description,
      expenseDate: expenseDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      recordedByName: u?.displayName,
    );
  }
}
