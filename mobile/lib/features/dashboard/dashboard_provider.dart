import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/locale/locale_provider.dart';
import '../budgets/budgets_provider.dart';
import '../receipts/receipts_provider.dart';
import '../reports/reports_provider.dart';
import '../subscriptions/subscriptions_provider.dart';

class DashboardAlert {
  final String title;
  final String message;
  final String level;
  final String route;

  const DashboardAlert({
    required this.title,
    required this.message,
    required this.level,
    required this.route,
  });
}

class DashboardData {
  final ReportSummary summary;
  final List<Map<String, dynamic>> recentExpenses;
  final List<BudgetProgress> budgets;
  final List<Subscription> upcomingSubscriptions;
  final List<ReceiptHistoryItem> recentReceipts;
  final List<DashboardAlert> alerts;

  const DashboardData({
    required this.summary,
    required this.recentExpenses,
    required this.budgets,
    required this.upcomingSubscriptions,
    required this.recentReceipts,
    required this.alerts,
  });
}

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((
  ref,
) async {
  final api = ref.read(apiClientProvider);
  final isTr = ref.watch(localeProvider).languageCode == 'tr';
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month);
  final nextMonth = DateTime(now.year, now.month + 1);

  final responses = await Future.wait([
    api.dio.get(
      '/reports/summary',
      queryParameters: {'year': monthStart.year, 'month': monthStart.month},
    ),
    api.dio.get(
      '/expenses',
      queryParameters: {
        'from': monthStart.toUtc().toIso8601String(),
        'to': nextMonth.toUtc().toIso8601String(),
      },
    ),
    api.dio.get('/budgets/progress'),
    api.dio.get('/subscriptions'),
    api.dio.get('/receipts'),
  ]);

  final summary = ReportSummary.fromJson(
    responses[0].data as Map<String, dynamic>,
  );
  final expenses = List<Map<String, dynamic>>.from(responses[1].data as List);
  final budgets = (responses[2].data as List)
      .map((e) => BudgetProgress.fromJson(e as Map<String, dynamic>))
      .toList();
  final subscriptions = (responses[3].data as List)
      .map((e) => Subscription.fromJson(e as Map<String, dynamic>))
      .where((s) => s.status == 'active')
      .toList();
  final receipts = (responses[4].data as List)
      .map((e) => ReceiptHistoryItem.fromJson(e as Map<String, dynamic>))
      .toList();

  final alerts = <DashboardAlert>[];
  for (final budget in budgets) {
    if (budget.percent >= 100) {
      alerts.add(
        DashboardAlert(
          title: isTr
              ? '${_categoryName(budget.categoryName, isTr, fallback: 'Genel')} bütçesi aşıldı'
              : '${_categoryName(budget.categoryName, isTr, fallback: 'General')} budget exceeded',
          message: isTr
              ? '${budget.percent.toStringAsFixed(0)}% kullanıldı, ${_fmtTRY(budget.spent - budget.amount)} limit üstü.'
              : '${budget.percent.toStringAsFixed(0)}% used, ${_fmtTRY(budget.spent - budget.amount)} over the limit.',
          level: 'danger',
          route: '/settings/budgets',
        ),
      );
    } else if (budget.percent >= 80) {
      alerts.add(
        DashboardAlert(
          title: isTr
              ? '${_categoryName(budget.categoryName, isTr, fallback: 'Genel')} bütçesi yaklaşıyor'
              : '${_categoryName(budget.categoryName, isTr, fallback: 'General')} budget is close',
          message: isTr
              ? '${budget.percent.toStringAsFixed(0)}% kullanıldı, ${_fmtTRY(budget.remaining)} kaldı.'
              : '${budget.percent.toStringAsFixed(0)}% used, ${_fmtTRY(budget.remaining)} left.',
          level: 'warn',
          route: '/settings/budgets',
        ),
      );
    }
  }

  final nextWeek = now.add(const Duration(days: 7));
  final upcoming = <Subscription>[];
  for (final sub in subscriptions) {
    final due = DateTime.tryParse(sub.nextBillingDate);
    if (due == null) continue;
    if (!due.isBefore(DateTime(now.year, now.month, now.day)) &&
        !due.isAfter(nextWeek)) {
      upcoming.add(sub);
      alerts.add(
        DashboardAlert(
          title: isTr
              ? '${sub.name} ödeme tarihi yaklaşıyor'
              : '${sub.name} payment is coming up',
          message: '${_fmtTRY(sub.amount)} · ${_dateLabel(due)}',
          level: 'info',
          route: '/subscriptions',
        ),
      );
    }
  }

  return DashboardData(
    summary: summary,
    recentExpenses: expenses.take(5).toList(),
    budgets: budgets,
    upcomingSubscriptions: upcoming,
    recentReceipts: receipts.take(4).toList(),
    alerts: alerts.take(5).toList(),
  );
});

String _fmtTRY(double v) => '₺${v.toStringAsFixed(2).replaceAll('.', ',')}';

String _categoryName(String? name, bool isTr, {required String fallback}) {
  if (name == null || name.isEmpty) return fallback;
  const enToTr = {
    'Groceries': 'Market',
    'Transportation': 'Ulaşım',
    'Bills': 'Faturalar',
    'Food & Drink': 'Yeme-İçme',
    'Health': 'Sağlık',
    'Entertainment': 'Eğlence',
    'Other': 'Diğer',
  };
  const trToEn = {
    'Market': 'Groceries',
    'Ulaşım': 'Transportation',
    'Faturalar': 'Bills',
    'Yeme-İçme': 'Food & Drink',
    'Sağlık': 'Health',
    'Eğlence': 'Entertainment',
    'Diğer': 'Other',
  };
  return isTr ? (enToTr[name] ?? name) : (trToEn[name] ?? name);
}

String _dateLabel(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
