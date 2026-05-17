import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';

class CategoryBreakdown {
  final String? categoryId;
  final String name;
  final String icon;
  final String color;
  final double total;
  final int count;

  const CategoryBreakdown({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.color,
    required this.total,
    required this.count,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> j) =>
      CategoryBreakdown(
        categoryId: j['category_id'] as String?,
        name: j['name'] as String,
        icon: j['icon'] as String,
        color: j['color'] as String,
        total: double.parse(j['total'].toString()),
        count: j['count'] as int,
      );
}

class ReportSummary {
  final int year;
  final int month;
  final double total;
  final int expenseCount;
  final List<CategoryBreakdown> breakdown;

  const ReportSummary({
    required this.year,
    required this.month,
    required this.total,
    required this.expenseCount,
    required this.breakdown,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> j) => ReportSummary(
    year: j['year'] as int,
    month: j['month'] as int,
    total: double.parse(j['total'].toString()),
    expenseCount: j['expense_count'] as int,
    breakdown: (j['category_breakdown'] as List)
        .map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

final reportMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(DateTime.now().year, DateTime.now().month),
);

/// 'monthly' | 'weekly'
final reportPeriodProvider = StateProvider<String>((ref) => 'monthly');

/// Monday of the selected week (for weekly mode)
final reportWeekProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return _weekMonday(now);
});

DateTime _weekMonday(DateTime d) {
  final delta = d.weekday - DateTime.monday;
  return DateTime(d.year, d.month, d.day - delta);
}

final reportSummaryProvider = FutureProvider.autoDispose<ReportSummary>((
  ref,
) async {
  final period = ref.watch(reportPeriodProvider);
  final api = ref.read(apiClientProvider);

  if (period == 'weekly') {
    final weekStart = ref.watch(reportWeekProvider);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final res = await api.dio.get(
      '/reports/summary',
      queryParameters: {
        'period': 'weekly',
        'from': _fmtDate(weekStart),
        'to': _fmtDate(weekEnd),
      },
    );
    return ReportSummary.fromJson(res.data as Map<String, dynamic>);
  } else {
    final month = ref.watch(reportMonthProvider);
    final res = await api.dio.get(
      '/reports/summary',
      queryParameters: {
        'period': 'monthly',
        'year': month.year,
        'month': month.month,
      },
    );
    return ReportSummary.fromJson(res.data as Map<String, dynamic>);
  }
});

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class TrendPoint {
  final int year;
  final int month;
  final double total;
  final int count;

  const TrendPoint({
    required this.year,
    required this.month,
    required this.total,
    required this.count,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> j) => TrendPoint(
    year: j['year'] as int,
    month: j['month'] as int,
    total: double.parse(j['total'].toString()),
    count: j['count'] as int,
  );
}

final reportTrendsProvider = FutureProvider.autoDispose<List<TrendPoint>>((
  ref,
) async {
  final api = ref.read(apiClientProvider);
  final res = await api.dio.get(
    '/reports/trends',
    queryParameters: {'months': 6},
  );
  return (res.data as List)
      .map((e) => TrendPoint.fromJson(e as Map<String, dynamic>))
      .toList();
});

Future<String> exportReportCsv(WidgetRef ref, DateTime month) async {
  final api = ref.read(apiClientProvider);
  final res = await api.dio.get<String>(
    '/reports/export.csv',
    queryParameters: {'year': month.year, 'month': month.month},
  );
  return res.data ?? '';
}
