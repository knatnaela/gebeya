// Shared date shortcuts for list/dashboard filters (local calendar).

/// First day of the current month through now (same end semantics as rolling "last N days").
({DateTime start, DateTime end}) thisMonthRangeLocal() {
  final now = DateTime.now();
  return (start: DateTime(now.year, now.month, 1), end: now);
}

/// True when [start]/[end] match [thisMonthRangeLocal] within tolerance (clock skew).
bool matchesThisMonthRange(DateTime start, DateTime end) {
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  return (start.difference(monthStart).inSeconds).abs() <= 120 &&
      (end.difference(now).inSeconds).abs() <= 120;
}
