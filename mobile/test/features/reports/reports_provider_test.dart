import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reports/reports_provider.dart';

void main() {
  test('ReportSummary parses category breakdown safely', () {
    final summary = ReportSummary.fromJson({
      'year': 2026,
      'month': 5,
      'total': '1234.56',
      'expense_count': 7,
      'category_breakdown': [
        {
          'category_id': 'cat-1',
          'name': 'Market',
          'icon': 'shopping_cart',
          'color': '#22C55E',
          'total': '900.10',
          'count': 4,
        },
      ],
    });

    expect(summary.year, 2026);
    expect(summary.month, 5);
    expect(summary.total, 1234.56);
    expect(summary.expenseCount, 7);
    expect(summary.breakdown.single.name, 'Market');
    expect(summary.breakdown.single.total, 900.10);
  });

  test('TrendPoint parses numeric totals from strings', () {
    final point = TrendPoint.fromJson({
      'year': 2026,
      'month': 4,
      'total': '45.70',
      'count': 3,
    });

    expect(point.year, 2026);
    expect(point.month, 4);
    expect(point.total, 45.70);
    expect(point.count, 3);
  });
}
