// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseUserDto _$ExpenseUserDtoFromJson(Map<String, dynamic> json) =>
    ExpenseUserDto(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
    );

ExpenseDto _$ExpenseDtoFromJson(Map<String, dynamic> json) => ExpenseDto(
  id: json['id'] as String,
  merchantId: json['merchantId'] as String,
  userId: json['userId'] as String,
  category: json['category'] as String,
  amount: _numFromJson(json['amount']),
  description: json['description'] as String?,
  expenseDate: DateTime.parse(json['expenseDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  users: json['users'] == null
      ? null
      : ExpenseUserDto.fromJson(json['users'] as Map<String, dynamic>),
);
