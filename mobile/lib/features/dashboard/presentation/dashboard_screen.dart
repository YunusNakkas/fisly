import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/notifications/notification_service.dart';
import '../dashboard_provider.dart';
import '../../receipts/receipts_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/hero_card.dart';
import '../../../shared/section_label.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/localized_copy.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final t = AppLocalizations.of(context);
    ref.listen(dashboardProvider, (_, next) {
      next.whenData(
        (data) => NotificationService.instance.syncDashboardNotifications(
          data,
          isTurkish: isTurkishLocale(context),
        ),
      );
    });

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(title: Text(t.appName, style: AppTypography.titleLg)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.dashboardLoadFailed, style: AppTypography.bodyLg),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(dashboardProvider),
                child: Text(t.actionRetry),
              ),
            ],
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.refresh(dashboardProvider.future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              HeroCard(
                padding: const EdgeInsets.all(18),
                radius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeroLabel(t.dashboardThisMonth),
                    const SizedBox(height: 4),
                    Text(
                      _fmtTRY(data.summary.total),
                      style: AppTypography.displayMd.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.dashboardExpenseCount(
                        data.summary.expenseCount,
                        data.summary.breakdown.length,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xA6FFFFFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (data.alerts.isNotEmpty) ...[
                const SizedBox(height: 18),
                SectionLabel(t.dashboardAlerts),
                for (final alert in data.alerts) ...[
                  _AlertTile(alert: alert),
                  const SizedBox(height: 8),
                ],
              ],
              const SizedBox(height: 10),
              _DashboardGrid(data: data),
              const SizedBox(height: 18),
              SectionLabel(
                t.dashboardRecentExpenses,
                trailing: TextButton(
                  onPressed: () => context.go('/expenses'),
                  child: Text(t.dashboardSeeAll),
                ),
              ),
              _RecentExpenses(items: data.recentExpenses),
              const SizedBox(height: 18),
              SectionLabel(
                t.dashboardReceiptHistory,
                trailing: TextButton(
                  onPressed: () => context.push('/receipts'),
                  child: Text(t.dashboardOpen),
                ),
              ),
              _RecentReceipts(items: data.recentReceipts),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  final DashboardData data;
  const _DashboardGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final activeBudgets = data.budgets.length;
    final riskyBudgets = data.budgets.where((b) => b.percent >= 80).length;
    final subscriptionTotal = data.upcomingSubscriptions.fold<double>(
      0,
      (sum, sub) => sum + sub.amount,
    );

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        _MetricTile(
          icon: Icons.account_balance_wallet_outlined,
          label: AppLocalizations.of(context).settingsBudgetSection,
          value: activeBudgets == 0
              ? copyForLocale(context, en: 'None', tr: 'Yok')
              : copyForLocale(
                  context,
                  en: '$riskyBudgets risky',
                  tr: '$riskyBudgets riskli',
                ),
          color: riskyBudgets > 0 ? context.colors.warn : context.colors.ok,
          onTap: () => context.push('/settings/budgets'),
        ),
        _MetricTile(
          icon: Icons.repeat_rounded,
          label: copyForLocale(
            context,
            en: '7-day payments',
            tr: '7 gün ödeme',
          ),
          value: _fmtTRY(subscriptionTotal),
          color: context.colors.primary,
          onTap: () => context.go('/subscriptions'),
        ),
        _MetricTile(
          icon: Icons.document_scanner_outlined,
          label: copyForLocale(context, en: 'Last receipt', tr: 'Son fiş'),
          value: '${data.recentReceipts.length}',
          color: context.colors.primaryDim,
          onTap: () => context.push('/receipts'),
        ),
        _MetricTile(
          icon: Icons.bar_chart_rounded,
          label: AppLocalizations.of(context).reportsTitle,
          value: copyForLocale(
            context,
            en: '${data.summary.breakdown.length} categories',
            tr: '${data.summary.breakdown.length} kategori',
          ),
          color: context.colors.textMid,
          onTap: () => context.go('/reports'),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(label, style: AppTypography.caption),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.titleMd,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final DashboardAlert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = switch (alert.level) {
      'danger' => context.colors.danger,
      'warn' => context.colors.warn,
      _ => context.colors.primary,
    };

    return Material(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(AppRadius.md + 2),
      child: InkWell(
        onTap: () => context.push(alert.route),
        borderRadius: BorderRadius.circular(AppRadius.md + 2),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.notifications_active_outlined, color: color, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: AppTypography.bodyMd.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.message,
                      style: AppTypography.caption.copyWith(color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentExpenses extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _RecentExpenses({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyPanel(
        text: copyForLocale(
          context,
          en: 'No expenses this month',
          tr: 'Bu ay harcama yok',
        ),
      );
    }

    return _Panel(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) Divider(height: 1, color: context.colors.outlineSoft),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            title: Text(
              (items[i]['merchant'] as String?) ??
                  copyForLocale(context, en: 'Unknown', tr: 'Bilinmiyor'),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text((items[i]['note'] as String?) ?? _date(items[i])),
            trailing: Text(
              _fmtTRY(double.tryParse(items[i]['amount'].toString()) ?? 0),
              style: AppTypography.amountMd,
            ),
          ),
        ],
      ],
    );
  }
}

class _RecentReceipts extends StatelessWidget {
  final List<ReceiptHistoryItem> items;
  const _RecentReceipts({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyPanel(
        text: AppLocalizations.of(context).receiptHistoryEmpty,
      );
    }

    return _Panel(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) Divider(height: 1, color: context.colors.outlineSoft),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            title: Text(
              items[i].merchant ??
                  copyForLocale(
                    context,
                    en: 'Unknown receipt',
                    tr: 'Bilinmeyen fiş',
                  ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(items[i].receiptDate ?? items[i].status),
            trailing: Text(
              items[i].totalAmount == null
                  ? '-'
                  : _fmtTRY(items[i].totalAmount!),
              style: AppTypography.amountMd,
            ),
          ),
        ],
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final List<Widget> children;
  const _Panel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(children: children),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String text;
  const _EmptyPanel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: context.colors.textMid)),
      ),
    );
  }
}

String _date(Map<String, dynamic> expense) {
  final raw = expense['spent_at'] as String?;
  final d = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
  if (d == null) return '';
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

String _fmtTRY(double v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
    buf.write(intPart[i]);
  }
  return '₺${buf.toString()},${parts[1]}';
}
