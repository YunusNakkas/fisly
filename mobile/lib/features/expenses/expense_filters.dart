import '../categories/categories_provider.dart';

class ExpenseFilters {
  final String? categoryId;
  final double? minAmount;
  final double? maxAmount;
  final bool receiptOnly;

  const ExpenseFilters({
    this.categoryId,
    this.minAmount,
    this.maxAmount,
    this.receiptOnly = false,
  });

  int get activeCount =>
      (categoryId == null ? 0 : 1) +
      (minAmount == null ? 0 : 1) +
      (maxAmount == null ? 0 : 1) +
      (receiptOnly ? 1 : 0);

  bool get isActive => activeCount > 0;
}

List<Map<String, dynamic>> filterExpenses(
  List<Map<String, dynamic>> expenses,
  Map<String, Category> categoriesById,
  String query,
  ExpenseFilters filters,
) {
  final q = normalizeExpenseSearch(query);
  final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  return expenses.where((expense) {
    final category = categoriesById[expense['category_id']];
    final amount = double.tryParse(expense['amount'].toString()) ?? 0;

    if (filters.categoryId != null &&
        expense['category_id'] != filters.categoryId) {
      return false;
    }
    if (filters.minAmount != null && amount < filters.minAmount!) {
      return false;
    }
    if (filters.maxAmount != null && amount > filters.maxAmount!) {
      return false;
    }
    if (filters.receiptOnly && expense['receipt_id'] == null) {
      return false;
    }
    if (tokens.isEmpty) return true;

    final iso = expense['spent_at'] as String?;
    final date = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    final haystack = [
      expense['merchant'],
      expense['note'],
      category?.name,
      expense['amount'],
      _fmt(amount),
      '₺${_fmt(amount)}',
      if (date != null) _dateKey(date),
      if (date != null) _dayLabel(date),
      if (date != null) _timeStr(date),
    ].whereType<Object>().map((v) => v.toString()).join(' ');

    final normalizedHaystack = normalizeExpenseSearch(haystack);
    return tokens.every(normalizedHaystack.contains);
  }).toList();
}

double? parseExpenseAmount(String value) {
  final normalized = value.trim().replaceAll(',', '.');
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

String normalizeExpenseSearch(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('ç', 'c')
      .replaceAll('ğ', 'g')
      .replaceAll('ı', 'i')
      .replaceAll('i̇', 'i')
      .replaceAll('ö', 'o')
      .replaceAll('ş', 's')
      .replaceAll('ü', 'u');
}

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _dayLabel(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]}';

String _timeStr(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _fmt(double v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
    buf.write(intPart[i]);
  }
  return '${buf.toString()},${parts[1]}';
}
