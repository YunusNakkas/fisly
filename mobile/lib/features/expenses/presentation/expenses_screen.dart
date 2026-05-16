import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../expenses_provider.dart';
import '../../categories/categories_provider.dart';
import '../../subscriptions/subscriptions_provider.dart';
import '../../budgets/budgets_provider.dart';
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

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(expensesProvider.notifier).load();
      ref.read(subscriptionsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final subState = ref.watch(subscriptionsProvider);
    final budgetProgressAsync = ref.watch(budgetsProgressProvider);

    final categories = categoriesAsync.valueOrNull ?? const <Category>[];
    final categoriesById = <String, Category>{for (final c in categories) c.id: c};

    final viewedMonth = state.month;
    final monthSubs = subState.items.where((s) {
      if (s.status != 'active') return false;
      try {
        final d = DateTime.parse(s.nextBillingDate);
        return d.year == viewedMonth.year && d.month == viewedMonth.month;
      } catch (_) {
        return false;
      }
    }).toList();

    final totals = <String, double>{};
    double grandTotal = 0;
    for (final e in state.expenses) {
      final amount = double.tryParse(e['amount'].toString()) ?? 0;
      grandTotal += amount;
      final cid = e['category_id'] as String?;
      if (cid != null) totals[cid] = (totals[cid] ?? 0) + amount;
    }

    final groups = _groupExpensesByDay(state.expenses);
    final exceededBudgets = budgetProgressAsync.valueOrNull
            ?.where((b) => b.percent >= 100)
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: InkWell(
          onTap: () => _pickMonth(context),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${_months[state.month.month - 1]} ${state.month.year}',
                    style: AppTypography.titleLg),
                const SizedBox(width: 2),
                Icon(Icons.expand_more_rounded,
                    size: 22, color: context.colors.textHi),
              ],
            ),
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(expensesProvider.notifier).load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                children: [
                  _HeroSummary(
                    grandTotal: grandTotal,
                    expenseCount: state.expenses.length,
                    categories: categories,
                    totals: totals,
                  ),
                  if (exceededBudgets.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _BudgetWarningBanner(exceeded: exceededBudgets),
                  ],
                  const SizedBox(height: 18),
                  if (state.expenses.isEmpty && monthSubs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text('Bu ay için harcama yok',
                            style: TextStyle(color: context.colors.textMid)),
                      ),
                    ),
                  for (final g in groups) ...[
                    _DayGroupHeader(label: g.label, total: g.total),
                    const SizedBox(height: 6),
                    _ExpenseGroupCard(
                      expenses: g.items,
                      categoriesById: categoriesById,
                      onTap: (e) => _showExpenseSheet(context, existing: e),
                      onDismissed: _onDismissed,
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (monthSubs.isNotEmpty) ...[
                    const SectionLabel('Abonelik ödemeleri'),
                    _SubscriptionsCard(
                      subs: monthSubs,
                      categoriesById: categoriesById,
                    ),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_expenses',
        onPressed: () => _showExpenseSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onDismissed(Map<String, dynamic> e) {
    final id = e['id'] as String;
    final notifier = ref.read(expensesProvider.notifier);
    notifier.removeOptimistic(id);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text('Harcama silindi'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Geri al',
            onPressed: () => notifier.undoRemove(e),
          ),
        ),
      ).closed.then((reason) {
        if (reason != SnackBarClosedReason.action) {
          notifier.confirmRemove(id);
        }
      });
  }

  Future<void> _pickMonth(BuildContext context) async {
    final current = ref.read(expensesProvider).month;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Ay seç',
    );
    if (picked != null) {
      await ref.read(expensesProvider.notifier).setMonth(picked);
    }
  }

  void _showExpenseSheet(BuildContext context, {Map<String, dynamic>? existing}) {
    final isEdit = existing != null;
    final amountController = TextEditingController(
      text: isEdit ? existing['amount'].toString() : '',
    );
    final merchantController = TextEditingController(
      text: isEdit ? (existing['merchant'] ?? '') : '',
    );
    final noteController = TextEditingController(
      text: isEdit ? (existing['note'] ?? '') : '',
    );
    String? selectedCategoryId = isEdit ? existing['category_id'] as String? : null;
    DateTime selectedDate = isEdit
        ? (DateTime.tryParse(existing['spent_at'] as String? ?? '')?.toLocal() ??
            DateTime.now())
        : DateTime.now();
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            final categoriesAsync = ref.watch(categoriesProvider);

            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              setSheetState(() => saving = true);
              final messenger = ScaffoldMessenger.of(context);
              try {
                if (isEdit) {
                  await ref.read(expensesProvider.notifier).update(
                        existing['id'] as String,
                        amount: amountController.text.trim(),
                        categoryId: selectedCategoryId,
                        merchant: merchantController.text.trim().isEmpty
                            ? null
                            : merchantController.text.trim(),
                        note: noteController.text.trim().isEmpty
                            ? null
                            : noteController.text.trim(),
                        spentAt: selectedDate,
                      );
                } else {
                  await ref.read(expensesProvider.notifier).add(
                        amount: amountController.text.trim(),
                        categoryId: selectedCategoryId,
                        merchant: merchantController.text.trim().isEmpty
                            ? null
                            : merchantController.text.trim(),
                        note: noteController.text.trim().isEmpty
                            ? null
                            : noteController.text.trim(),
                      );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Harcama güncellendi' : 'Harcama eklendi')),
                );
              } catch (err) {
                setSheetState(() => saving = false);
                messenger.showSnackBar(
                  SnackBar(content: Text('Kaydedilemedi: $err')),
                );
              }
            }

            Future<void> confirmDelete() async {
              final ok = await showDialog<bool>(
                context: ctx,
                builder: (d) => AlertDialog(
                  title: const Text('Harcamayı sil'),
                  content: const Text('Bu harcama kalıcı olarak silinecek.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(d, false),
                        child: const Text('Vazgeç')),
                    TextButton(
                      onPressed: () => Navigator.pop(d, true),
                      child: Text('Sil',
                          style: TextStyle(color: ctx.colors.danger)),
                    ),
                  ],
                ),
              );
              if (ok != true) return;
              setSheetState(() => saving = true);
              try {
                await ref
                    .read(expensesProvider.notifier)
                    .delete(existing!['id'] as String);
                if (ctx.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Harcama silindi')),
                );
              } catch (err) {
                setSheetState(() => saving = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Silinemedi: $err'),
                      backgroundColor: context.colors.danger),
                );
              }
            }

            final dateFmt =
                '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}';

            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEdit ? 'Harcamayı Düzenle' : 'Harcama Ekle',
                          style: AppTypography.titleLg,
                        ),
                      ),
                      if (isEdit)
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded,
                              color: ctx.colors.danger, size: 22),
                          tooltip: 'Sil',
                          onPressed: saving ? null : confirmDelete,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Tutar (TL)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'Tutar gerekli';
                      final d = double.tryParse(s.replaceAll(',', '.'));
                      if (d == null) return 'Geçerli bir sayı gir';
                      if (d <= 0) return '0\'dan büyük olmalı';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Kategoriler yüklenemedi: $e'),
                    data: (cats) => DropdownButtonFormField<String>(
                      initialValue: selectedCategoryId,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: cats
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                          .toList(),
                      onChanged: (v) => setSheetState(() => selectedCategoryId = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text('Tarih: $dateFmt'),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (d != null) {
                        setSheetState(() => selectedDate = d);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: merchantController,
                    decoration: const InputDecoration(labelText: 'Market / Mağaza'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'Not'),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: saving ? null : save,
                    child: saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(isEdit ? 'Güncelle' : 'Kaydet'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Hero summary card ─────────────────────────────────────────────
class _HeroSummary extends StatelessWidget {
  final double grandTotal;
  final int expenseCount;
  final List<Category> categories;
  final Map<String, double> totals;

  const _HeroSummary({
    required this.grandTotal,
    required this.expenseCount,
    required this.categories,
    required this.totals,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = categories.where((c) => (totals[c.id] ?? 0) > 0).toList()
      ..sort((a, b) => (totals[b.id] ?? 0).compareTo(totals[a.id] ?? 0));

    return HeroCard(
      padding: const EdgeInsets.all(18),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeroLabel('Toplam Harcama'),
          const SizedBox(height: 4),
          Text(_fmtTRY(grandTotal), style: AppTypography.displayMd.copyWith(color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            '$expenseCount harcama · ${sorted.length} kategori',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xA6FFFFFF),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (sorted.isNotEmpty) ...[
            const SizedBox(height: 18),
            // Stacked horizontal segments by category
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                height: 10,
                color: Colors.white.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    for (final c in sorted)
                      Expanded(
                        flex:
                            ((totals[c.id] ?? 0) / grandTotal * 1000).round(),
                        child: Container(color: colorFromHex(c.color)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                for (final c in sorted.take(4))
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorFromHex(c.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(c.name,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xCCFFFFFF),
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Day grouping ──────────────────────────────────────────────────
class _DayGroup {
  final String label;
  final double total;
  final List<Map<String, dynamic>> items;
  _DayGroup({required this.label, required this.total, required this.items});
}

List<_DayGroup> _groupExpensesByDay(List<Map<String, dynamic>> expenses) {
  final byDate = <String, List<Map<String, dynamic>>>{};
  final today = DateTime.now();
  final todayKey = _dateKey(today);
  final yesterdayKey = _dateKey(today.subtract(const Duration(days: 1)));

  for (final e in expenses) {
    final iso = e['spent_at'] as String?;
    final key = iso != null ? _dateKey(DateTime.tryParse(iso)?.toLocal() ?? today) : '0000-00-00';
    byDate.putIfAbsent(key, () => []).add(e);
  }

  final sortedKeys = byDate.keys.toList()..sort((a, b) => b.compareTo(a));

  return sortedKeys.map((k) {
    final items = byDate[k]!;
    final total = items.fold<double>(
      0,
      (s, e) => s + (double.tryParse(e['amount'].toString()) ?? 0),
    );
    String label;
    if (k == todayKey) {
      label = 'Bugün · ${_dayLabel(k)}';
    } else if (k == yesterdayKey) {
      label = 'Dün · ${_dayLabel(k)}';
    } else {
      label = _dayLabel(k);
    }
    return _DayGroup(label: label, total: total, items: items);
  }).toList();
}

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _dayLabel(String key) {
  try {
    final d = DateTime.parse(key);
    return '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]}';
  } catch (_) {
    return key;
  }
}

class _DayGroupHeader extends StatelessWidget {
  final String label;
  final double total;
  const _DayGroupHeader({required this.label, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: context.colors.textMid,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Text(
            _fmtTRY(total),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.textLo,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Group card ────────────────────────────────────────────────────
class _ExpenseGroupCard extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;
  final Map<String, Category> categoriesById;
  final void Function(Map<String, dynamic>) onTap;
  final void Function(Map<String, dynamic>) onDismissed;

  const _ExpenseGroupCard({
    required this.expenses,
    required this.categoriesById,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            for (int i = 0; i < expenses.length; i++) ...[
              if (i > 0)
                Divider(height: 1, color: context.colors.outlineSoft),
              _ExpenseRow(
                expense: expenses[i],
                category: categoriesById[expenses[i]['category_id']],
                onTap: () => onTap(expenses[i]),
                onDismissed: () => onDismissed(expenses[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final Map<String, dynamic> expense;
  final Category? category;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _ExpenseRow({
    required this.expense,
    required this.category,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(expense['amount'].toString()) ?? 0;
    final time = _timeStr(expense['spent_at'] as String?);
    final id = expense['id'] as String;

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: context.colors.danger,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismissed(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CategoryAvatar(
                iconKey: category?.icon,
                colorHex: category?.color,
                size: 40,
                radius: 12,
                style: CategoryAvatarStyle.tinted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (expense['merchant'] as String?) ?? 'Bilinmiyor',
                      style: AppTypography.bodyLg
                          .copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${category?.name ?? '—'} · $time',
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(_fmtTRY(amount), style: AppTypography.amountLg),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Subscription rows (in expenses view) ──────────────────────────
class _SubscriptionsCard extends StatelessWidget {
  final List<Subscription> subs;
  final Map<String, Category> categoriesById;

  const _SubscriptionsCard({
    required this.subs,
    required this.categoriesById,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (int i = 0; i < subs.length; i++) ...[
            if (i > 0) Divider(height: 1, color: context.colors.outlineSoft),
            _SubRow(
              sub: subs[i],
              category: subs[i].categoryId != null
                  ? categoriesById[subs[i].categoryId]
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _SubRow extends StatelessWidget {
  final Subscription sub;
  final Category? category;
  const _SubRow({required this.sub, required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          category != null
              ? CategoryAvatar(
                  iconKey: category!.icon,
                  colorHex: category!.color,
                  size: 40,
                  radius: 12,
                  style: CategoryAvatarStyle.tinted,
                )
              : Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.repeat,
                      color: context.colors.primary, size: 20),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sub.name,
                    style: AppTypography.bodyLg
                        .copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Text(
                  '${category?.name ?? 'Abonelik'} · ${sub.periodLabel}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Text('₺${_fmt(sub.amount)}', style: AppTypography.amountLg),
        ],
      ),
    );
  }
}

// ─── Budget warning banner ─────────────────────────────────────────
class _BudgetWarningBanner extends StatelessWidget {
  final List<BudgetProgress> exceeded;
  const _BudgetWarningBanner({required this.exceeded});

  @override
  Widget build(BuildContext context) {
    final label = exceeded.length == 1
        ? '"${exceeded.first.categoryName ?? 'Genel'}" bütçen aşıldı'
        : '${exceeded.length} bütçen aşıldı';

    final overList = exceeded
        .map((b) =>
            '${b.categoryName ?? 'Genel'}: ${_fmtTRY(b.spent - b.amount)} fazla')
        .join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md + 2),
        border: Border.all(color: context.colors.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(Icons.warning_amber_rounded,
                size: 18, color: context.colors.danger),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodyMd.copyWith(
                      color: context.colors.danger, fontWeight: FontWeight.w600),
                ),
                if (exceeded.length > 1) ...[
                  const SizedBox(height: 2),
                  Text(overList,
                      style: AppTypography.caption
                          .copyWith(color: context.colors.danger.withValues(alpha: 0.8))),
                ],
              ],
            ),
          ),
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

String _timeStr(String? iso) {
  if (iso == null) return '';
  try {
    final d = DateTime.parse(iso).toLocal();
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return '';
  }
}
