/// Mirrors Prisma `ExpenseCategory` (backend).
enum ExpenseCategory {
  MARKETING,
  RENT,
  FUEL,
  UTILITIES,
  SALARIES,
  MAINTENANCE,
  SUPPLIES,
  INSURANCE,
  TAXES,
  OTHER,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.MARKETING:
        return 'Marketing';
      case ExpenseCategory.RENT:
        return 'Rent';
      case ExpenseCategory.FUEL:
        return 'Fuel';
      case ExpenseCategory.UTILITIES:
        return 'Utilities';
      case ExpenseCategory.SALARIES:
        return 'Salaries';
      case ExpenseCategory.MAINTENANCE:
        return 'Maintenance';
      case ExpenseCategory.SUPPLIES:
        return 'Supplies';
      case ExpenseCategory.INSURANCE:
        return 'Insurance';
      case ExpenseCategory.TAXES:
        return 'Taxes';
      case ExpenseCategory.OTHER:
        return 'Other';
    }
  }
}

ExpenseCategory expenseCategoryFromApi(String raw) {
  for (final e in ExpenseCategory.values) {
    if (e.name == raw) return e;
  }
  return ExpenseCategory.OTHER;
}
