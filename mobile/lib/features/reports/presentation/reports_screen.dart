import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../reports_provider.dart';
import '../../budgets/budgets_provider.dart';
import '../../categories/categories_provider.dart';
import '../../../shared/category_icons.dart';
import '../../../shared/category_avatar.dart';
import '../../../shared/hero_card.dart';
import '../../../shared/section_label.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

const _months = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final month = ref.watch(reportMonthProvider);
    final weekStart = ref.watch(reportWeekProvider);
    final summaryAsync = ref.watch(reportSummaryProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: Text('Raporlar', style: AppTypography.titleLg),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _PeriodBar(
              period: period,
              month: month,
              weekStart: weekStart,
              onPeriodChanged: (p) =>
                  ref.read(reportPeriodProvider.notifier).state = p,
              onMonthChanged: (m) =>
                  ref.read(reportMonthProvider.notifier).state = m,
              onWeekChanged: (w) =>
                  ref.read(reportWeekProvider.notifier).state = w,
              onPickMonth: () => _pickMonth(context, ref, month),
            ),
          ),
          Expanded(
            child: summaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Yüklenemedi', style: AppTypography.bodyLg),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(reportSummaryProvider),
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              ),
              data: (summary) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(budgetsProgressProvider);
                  await ref.refresh(reportSummaryProvider.future);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                  children: [
                    _HeroSummary(
                      summary: summary,
                      period: period,
                      month: month,
                      weekStart: weekStart,
                    ),
                    const SizedBox(height: 18),
                    const _TrendCard(),
                    const SizedBox(height: 18),
                    const _BudgetsSection(),
                    if (summary.breakdown.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            period == 'weekly'
                                ? 'Bu hafta için harcama verisi yok'
                                : 'Bu ay için harcama verisi yok',
                            style: AppTypography.bodyMd
                                .copyWith(color: context.colors.textMid),
                          ),
                        ),
                      )
                    else ...[
                      const SectionLabel('Kategori Dağılımı'),
                      _DonutCard(
                          breakdown: summary.breakdown,
                          total: summary.total),
                      const SizedBox(height: 18),
                      _BreakdownCard(
                        breakdown: summary.breakdown,
                        total: summary.total,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth(
      BuildContext context, WidgetRef ref, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Ay seç',
    );
    if (picked != null) {
      ref.read(reportMonthProvider.notifier).state =
          DateTime(picked.year, picked.month);
    }
  }
}

// ─── Period bar ────────────────────────────────────────────────────
class _PeriodBar extends StatelessWidget {
  final String period;
  final DateTime month;
  final DateTime weekStart;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onWeekChanged;
  final VoidCallback onPickMonth;

  const _PeriodBar({
    required this.period,
    required this.month,
    required this.weekStart,
    required this.onPeriodChanged,
    required this.onMonthChanged,
    required this.onWeekChanged,
    required this.onPickMonth,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canGoNextMonth = DateTime(month.year, month.month)
        .isBefore(DateTime(now.year, now.month));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final canGoNextWeek = weekEnd.isBefore(DateTime(now.year, now.month, now.day));

    return Row(
      children: [
        // Period toggle
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PeriodChip(
                label: 'Aylık',
                selected: period == 'monthly',
                onTap: () => onPeriodChanged('monthly'),
              ),
              _PeriodChip(
                label: 'Haftalık',
                selected: period == 'weekly',
                onTap: () => onPeriodChanged('weekly'),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Date navigation
        _NavArrow(
          icon: Icons.chevron_left,
          onTap: period == 'monthly'
              ? () => onMonthChanged(DateTime(month.year, month.month - 1))
              : () => onWeekChanged(
                    weekStart.subtract(const Duration(days: 7))),
        ),
        GestureDetector(
          onTap: period == 'monthly' ? onPickMonth : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              period == 'monthly'
                  ? '${_months[month.month - 1]} ${month.year}'
                  : _weekLabel(weekStart),
              style: AppTypography.bodyMd
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        _NavArrow(
          icon: Icons.chevron_right,
          onTap: (period == 'monthly' ? canGoNextMonth : canGoNextWeek)
              ? (period == 'monthly'
                  ? () => onMonthChanged(DateTime(month.year, month.month + 1))
                  : () => onWeekChanged(
                        weekStart.add(const Duration(days: 7))))
              : null,
        ),
      ],
    );
  }

  String _weekLabel(DateTime monday) {
    final sunday = monday.add(const Duration(days: 6));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisMonday = today.subtract(Duration(days: today.weekday - 1));
    final lastMonday = thisMonday.subtract(const Duration(days: 7));

    if (monday == thisMonday) return 'Bu Hafta';
    if (monday == lastMonday) return 'Geçen Hafta';

    final sm = _months[monday.month - 1].substring(0, 3);
    final em = _months[sunday.month - 1].substring(0, 3);
    return '${monday.day} $sm – ${sunday.day} $em';
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? context.colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMd.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? Colors.white : context.colors.textMid,
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Icon(
          icon,
          size: 22,
          color: onTap == null ? context.colors.outline : context.colors.textHi,
        ),
      ),
    );
  }
}

// ─── Hero summary ──────────────────────────────────────────────────
class _HeroSummary extends StatelessWidget {
  final ReportSummary summary;
  final String period;
  final DateTime month;
  final DateTime weekStart;

  const _HeroSummary({
    required this.summary,
    required this.period,
    required this.month,
    required this.weekStart,
  });

  String _heroLabel() {
    if (period == 'weekly') {
      final sunday = weekStart.add(const Duration(days: 6));
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisMonday = today.subtract(Duration(days: today.weekday - 1));
      if (weekStart == thisMonday) return 'Bu Hafta Toplam';
      final sm = _months[weekStart.month - 1].substring(0, 3);
      final em = _months[sunday.month - 1].substring(0, 3);
      return '${weekStart.day} $sm – ${sunday.day} $em Toplam';
    }
    return '${_months[month.month - 1]} ${month.year} Toplam';
  }

  @override
  Widget build(BuildContext context) {
    return HeroCard(
      padding: const EdgeInsets.all(20),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroLabel(_heroLabel()),
          const SizedBox(height: 4),
          Text(_fmtTRY(summary.total),
              style: AppTypography.displayLg.copyWith(color: Colors.white)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _HeroStat(value: '${summary.expenseCount}', label: 'harcama'),
              _HeroStat(
                  value: '${summary.breakdown.length}', label: 'kategori'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xB3FFFFFF),
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: ' $label'),
        ],
      ),
    );
  }
}

// ─── Budgets ───────────────────────────────────────────────────────
class _BudgetsSection extends ConsumerWidget {
  const _BudgetsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(budgetsProgressProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryById = <String, Category>{
      for (final c in categoriesAsync.valueOrNull ?? const <Category>[])
        c.id: c,
    };

    return async.when(
      loading: () => const SizedBox(),
      error: (e, _) => const SizedBox(),
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _EmptyBudgetsCard(),
          );
        }

        items.sort((a, b) {
          if (a.categoryId == null && b.categoryId != null) return -1;
          if (b.categoryId == null && a.categoryId != null) return 1;
          return b.percent.compareTo(a.percent);
        });

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(
                'Bütçeler',
                trailing: InkWell(
                  onTap: () => context.push('/settings/budgets'),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune,
                            size: 14, color: context.colors.primary),
                        const SizedBox(width: 4),
                        Text('Yönet',
                            style: AppTypography.labelXs.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BudgetRow(
                    item: item,
                    category: item.categoryId != null
                        ? categoryById[item.categoryId]
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyBudgetsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: InkWell(
        onTap: () => context.push('/settings/budgets'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.account_balance_wallet,
                    color: context.colors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Henüz bütçe yok',
                        style: AppTypography.bodyLg
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Aylık limit eklemek için dokun',
                        style: AppTypography.caption),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.colors.textLo),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final BudgetProgress item;
  final Category? category;
  const _BudgetRow({required this.item, required this.category});

  @override
  Widget build(BuildContext context) {
    final pct = (item.percent / 100).clamp(0.0, 1.0);
    final isGeneral = item.categoryId == null;
    final label = isGeneral ? 'Genel' : (category?.name ?? 'Kategori');

    final Color statusColor;
    if (item.percent >= 100) {
      statusColor = context.colors.danger;
    } else if (item.percent >= 80) {
      statusColor = context.colors.warn;
    } else {
      statusColor = context.colors.ok;
    }

    final Widget leading;
    if (isGeneral) {
      leading = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        ),
        child: Icon(Icons.account_balance_wallet,
            color: context.colors.primary, size: 18),
      );
    } else {
      leading = CategoryAvatar(
        iconKey: category?.icon,
        colorHex: category?.color,
        size: 36,
        radius: AppRadius.sm + 2,
        style: CategoryAvatarStyle.tinted,
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTypography.bodyMd
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 1),
                    Text('${_fmtTRY(item.spent)} / ${_fmtTRY(item.amount)}',
                        style: AppTypography.caption
                            .copyWith(fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${item.percent.toStringAsFixed(0)}%',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: statusColor)),
                  const SizedBox(height: 1),
                  Text(
                    item.remaining >= 0
                        ? 'Kalan ${_fmtTRY(item.remaining)}'
                        : 'Aşım ${_fmtTRY(-item.remaining)}',
                    style: AppTypography.labelXs.copyWith(
                        fontSize: 10,
                        color: item.remaining >= 0
                            ? context.colors.textLo
                            : context.colors.danger,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: statusColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trend bar chart ───────────────────────────────────────────────
class _TrendCard extends ConsumerStatefulWidget {
  const _TrendCard();

  @override
  ConsumerState<_TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends ConsumerState<_TrendCard> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final trendsAsync = ref.watch(reportTrendsProvider);

    return trendsAsync.when(
      loading: () => const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox(),
      data: (points) {
        if (points.isEmpty) return const SizedBox();
        final maxVal = points.fold<double>(0, (m, p) => p.total > m ? p.total : m);
        final now = DateTime.now();

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg + 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Son 6 Ay',
                    style: AppTypography.bodyLg
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (_touched >= 0 && _touched < points.length)
                    Text(
                      _fmtTRY(points[_touched].total),
                      style: AppTypography.bodyMd.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w700),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: BarChart(
                  BarChartData(
                    maxY: maxVal * 1.25,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.transparent,
                        tooltipPadding: EdgeInsets.zero,
                        getTooltipItem: (_, __, ___, ____) => null,
                      ),
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.spot == null) {
                            _touched = -1;
                          } else {
                            _touched = response.spot!.touchedBarGroupIndex;
                          }
                        });
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= points.length) {
                              return const SizedBox();
                            }
                            final p = points[i];
                            final label = _months[p.month - 1]
                                .substring(0, 3);
                            final isCurrent = p.year == now.year &&
                                p.month == now.month;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isCurrent
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isCurrent
                                      ? context.colors.primary
                                      : context.colors.textLo,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxVal > 0 ? maxVal / 3 : 1,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: context.colors.outlineSoft,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: points.asMap().entries.map((entry) {
                      final i = entry.key;
                      final p = entry.value;
                      final isCurrent =
                          p.year == now.year && p.month == now.month;
                      final isTouched = i == _touched;
                      final color = isCurrent
                          ? context.colors.primary
                          : context.colors.primary.withValues(alpha: 0.35);

                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: p.total,
                            color: isTouched
                                ? context.colors.primary
                                : color,
                            width: 22,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Donut chart card ──────────────────────────────────────────────
class _DonutCard extends StatefulWidget {
  final List<CategoryBreakdown> breakdown;
  final double total;
  const _DonutCard({required this.breakdown, required this.total});

  @override
  State<_DonutCard> createState() => _DonutCardState();
}

class _DonutCardState extends State<_DonutCard> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final sections = widget.breakdown.asMap().entries.map((entry) {
      final i = entry.key;
      final c = entry.value;
      final isTouched = i == _touched;
      final color = colorFromHex(c.color);
      return PieChartSectionData(
        value: c.total,
        color: color,
        radius: isTouched ? 30 : 24,
        title: '',
        showTitle: false,
      );
    }).toList();

    final selected = _touched >= 0 && _touched < widget.breakdown.length
        ? widget.breakdown[_touched]
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 60,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touched = -1;
                          } else {
                            _touched =
                                response.touchedSection!.touchedSectionIndex;
                          }
                        });
                      },
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: selected != null
                      ? [
                          Text(selected.name,
                              style: AppTypography.caption,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 2),
                          Text(_fmtTRY(selected.total),
                              style: AppTypography.displaySm),
                          const SizedBox(height: 2),
                          Text(
                            '${((selected.total / widget.total) * 100).toStringAsFixed(1)}%',
                            style: AppTypography.labelXs.copyWith(
                                color: context.colors.textLo,
                                fontWeight: FontWeight.w600),
                          ),
                        ]
                      : [
                          Text('Toplam'.toUpperCase(),
                              style: AppTypography.labelSm),
                          const SizedBox(height: 2),
                          Text(_fmtTRY(widget.total),
                              style: AppTypography.displaySm),
                          const SizedBox(height: 2),
                          Text('${widget.breakdown.length} kategori',
                              style: AppTypography.caption
                                  .copyWith(fontSize: 11)),
                        ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Breakdown list ────────────────────────────────────────────────
class _BreakdownCard extends StatelessWidget {
  final List<CategoryBreakdown> breakdown;
  final double total;
  const _BreakdownCard({required this.breakdown, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            for (int i = 0; i < breakdown.length; i++) ...[
              if (i > 0)
                Divider(height: 1, color: context.colors.outlineSoft),
              _BreakdownRow(
                  item: breakdown[i],
                  total: total),
            ],
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final CategoryBreakdown item;
  final double total;
  const _BreakdownRow({required this.item, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction =
        total > 0 ? (item.total / total).clamp(0.0, 1.0) : 0.0;
    final pct = (fraction * 100).toStringAsFixed(1);
    final color = colorFromHex(item.color);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryAvatar(
                iconKey: item.icon,
                colorHex: item.color,
                size: 32,
                radius: AppRadius.sm + 2,
                style: CategoryAvatarStyle.tinted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item.name,
                    style: AppTypography.bodyMd
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
              Text('$pct%',
                  style: AppTypography.caption.copyWith(fontSize: 12)),
              const SizedBox(width: 10),
              SizedBox(
                width: 80,
                child: Text(_fmtTRY(item.total),
                    textAlign: TextAlign.right,
                    style: AppTypography.amountMd),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm / 2),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 2),
          Text('${item.count} harcama',
              style: AppTypography.labelXs
                  .copyWith(fontSize: 10, color: context.colors.textLo)),
        ],
      ),
    );
  }
}

// ─── Formatters ────────────────────────────────────────────────────
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

String _fmtTRY(double v) => '₺${_fmt(v)}';
