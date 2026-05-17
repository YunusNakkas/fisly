import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/categories/categories_provider.dart';
import 'package:mobile/features/expenses/expense_filters.dart';

void main() {
  const food = Category(
    id: 'food',
    userId: null,
    name: 'Yiyecek',
    icon: 'restaurant',
    color: '#22C55E',
    isSystem: true,
  );
  const transport = Category(
    id: 'transport',
    userId: null,
    name: 'Ulaşım',
    icon: 'directions_car',
    color: '#3B82F6',
    isSystem: true,
  );
  const categories = {'food': food, 'transport': transport};

  final expenses = [
    {
      'id': '1',
      'category_id': 'food',
      'amount': '120.50',
      'merchant': 'Çağrı Market',
      'note': 'Kahvaltı',
      'spent_at': '2026-05-10T08:30:00Z',
      'receipt_id': 'receipt-1',
    },
    {
      'id': '2',
      'category_id': 'transport',
      'amount': '60',
      'merchant': 'Metro',
      'note': null,
      'spent_at': '2026-05-11T12:00:00Z',
      'receipt_id': null,
    },
    {
      'id': '3',
      'category_id': null,
      'amount': '900',
      'merchant': 'Elektronik',
      'note': 'Kulaklık',
      'spent_at': '2026-05-12T18:45:00Z',
      'receipt_id': null,
    },
  ];

  test('normalizes Turkish characters in search queries', () {
    final result = filterExpenses(
      expenses,
      categories,
      'cagri kahvalti',
      const ExpenseFilters(),
    );

    expect(result.map((e) => e['id']), ['1']);
  });

  test('filters by category and amount range', () {
    final result = filterExpenses(
      expenses,
      categories,
      '',
      const ExpenseFilters(
        categoryId: 'transport',
        minAmount: 50,
        maxAmount: 100,
      ),
    );

    expect(result.map((e) => e['id']), ['2']);
  });

  test('filters receipt-backed expenses only', () {
    final result = filterExpenses(
      expenses,
      categories,
      '',
      const ExpenseFilters(receiptOnly: true),
    );

    expect(result.map((e) => e['id']), ['1']);
  });

  test('parses decimal values with comma separator', () {
    expect(parseExpenseAmount('42,75'), 42.75);
    expect(parseExpenseAmount(''), isNull);
    expect(parseExpenseAmount('abc'), isNull);
  });

  test('counts active filters', () {
    const filters = ExpenseFilters(
      categoryId: 'food',
      minAmount: 10,
      maxAmount: 200,
      receiptOnly: true,
    );

    expect(filters.activeCount, 4);
    expect(filters.isActive, isTrue);
  });
}
