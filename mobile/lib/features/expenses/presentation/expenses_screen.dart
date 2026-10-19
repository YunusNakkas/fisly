import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../expense_filters.dart';
import '../expenses_provider.dart';
import '../../categories/categories_provider.dart';
import '../../subscriptions/subscriptions_provider.dart';
import '../../budgets/budgets_provider.dart';
import '../../../shared/category_icons.dart';
import '../../../shared/currency_input_formatter.dart';
import '../../../shared/category_avatar.dart';
import '../../../shared/category_chip_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/hero_card.dart';
import '../../../shared/section_label.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/localized_copy.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ExpenseFilters _filters = const ExpenseFilters();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final next = _searchController.text;
      if (next == _searchQuery) return;
      setState(() => _searchQuery = next);
    });
    Future.microtask(() {
      ref.read(expensesProvider.notifier).load();
      ref.read(subscriptionsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final subState = ref.watch(subscriptionsProvider);
    final budgetProgressAsync = ref.watch(budgetsProgressProvider);

    final categories = categoriesAsync.valueOrNull ?? const <Category>[];
    final categoriesById = <String, Category>{
      for (final c in categories) c.id: c,
    };
    final filteredExpenses = filterExpenses(
      state.expenses,
      categoriesById,
      _searchQuery,
      _filters,
    );
    final isFiltering = _searchQuery.trim().isNotEmpty || _filters.isActive;

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
    for (final e in filteredExpenses) {
      final amount = double.tryParse(e['amount'].toString()) ?? 0;
      grandTotal += amount;
      final cid = e['category_id'] as String?;
      if (cid != null) totals[cid] = (totals[cid] ?? 0) + amount;
    }

    final groups = _groupExpensesByDay(context, filteredExpenses);
    final exceededBudgets =
        budgetProgressAsync.valueOrNull
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
                Text(
                  '${monthName(context, state.month.month)} ${state.month.year}',
                  style: AppTypography.titleLg,
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.expand_more_rounded,
                  size: 22,
                  color: context.colors.textHi,
                ),
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
                    label: isFiltering
                        ? copyForLocale(
                            context,
                            en: 'Filtered Total',
                            tr: 'Filtre Sonucu',
                          )
                        : copyForLocale(
                            context,
                            en: 'Total Spending',
                            tr: 'Toplam Harcama',
                          ),
                    grandTotal: grandTotal,
                    expenseCount: filteredExpenses.length,
                    categories: categories,
                    totals: totals,
                  ),
                  if (exceededBudgets.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _BudgetWarningBanner(exceeded: exceededBudgets),
                  ],
                  const SizedBox(height: 18),
                  if (state.expenses.isNotEmpty || isFiltering) ...[
                    _ExpenseSearchField(
                      controller: _searchController,
                      resultCount: filteredExpenses.length,
                      isFiltering: isFiltering,
                      activeFilterCount: _filters.activeCount,
                      onFilterTap: () => _showFilterSheet(context, categories),
                      onClear: _clearFilters,
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (isFiltering && filteredExpenses.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          copyForLocale(
                            context,
                            en: 'No expenses match your search',
                            tr: 'Aramaya uygun harcama bulunamadı',
                          ),
                          style: TextStyle(color: context.colors.textMid),
                        ),
                      ),
                    )
                  else if (state.expenses.isEmpty && monthSubs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          copyForLocale(
                            context,
                            en: 'No expenses for this month',
                            tr: 'Bu ay için harcama yok',
                          ),
                          style: TextStyle(color: context.colors.textMid),
                        ),
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
                  if (!isFiltering && monthSubs.isNotEmpty) ...[
                    SectionLabel(
                      copyForLocale(
                        context,
                        en: 'Subscription payments',
                        tr: 'Abonelik ödemeleri',
                      ),
                    ),
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
          content: Text(AppLocalizations.of(context).expensesDeleted),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: copyForLocale(context, en: 'Undo', tr: 'Geri al'),
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
      helpText: copyForLocale(context, en: 'Select month', tr: 'Ay seç'),
    );
    if (picked != null) {
      await ref.read(expensesProvider.notifier).setMonth(picked);
    }
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() => _filters = const ExpenseFilters());
  }

  void _showFilterSheet(BuildContext context, List<Category> categories) {
    final minController = TextEditingController(
      text: _filters.minAmount?.toStringAsFixed(0) ?? '',
    );
    final maxController = TextEditingController(
      text: _filters.maxAmount?.toStringAsFixed(0) ?? '',
    );
    String? categoryId = _filters.categoryId;
    bool receiptOnly = _filters.receiptOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheet) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(ctx).expensesFilterTitle,
                        style: AppTypography.titleLg,
                      ),
                    ),
                    IconButton(
                      tooltip: copyForLocale(context, en: 'Close', tr: 'Kapat'),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                CategoryChipPicker(
                  categories: categories,
                  selectedId: categoryId,
                  allOptionLabel: copyForLocale(context, en: 'All', tr: 'Tümü'),
                  onChanged: (v) => setSheet(() => categoryId = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(ctx).expensesFilterMin,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: maxController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(ctx).expensesFilterMax,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    AppLocalizations.of(ctx).expensesFilterReceiptOnly,
                  ),
                  value: receiptOnly,
                  onChanged: (v) => setSheet(() => receiptOnly = v),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _filters = const ExpenseFilters());
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          AppLocalizations.of(ctx).expensesFilterClear,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _filters = ExpenseFilters(
                              categoryId: categoryId,
                              minAmount: parseExpenseAmount(minController.text),
                              maxAmount: parseExpenseAmount(maxController.text),
                              receiptOnly: receiptOnly,
                            );
                          });
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          AppLocalizations.of(ctx).expensesFilterApply,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showExpenseSheet(
    BuildContext context, {
    Map<String, dynamic>? existing,
  }) {
    final isEdit = existing != null;
    final amountController = TextEditingController(
      text: isEdit
          ? formatAmountForInput(
              double.tryParse(existing['amount'].toString()) ?? 0,
            )
          : '',
    );
    final merchantController = TextEditingController(
      text: isEdit ? (existing['merchant'] ?? '') : '',
    );
    final noteController = TextEditingController(
      text: isEdit ? (existing['note'] ?? '') : '',
    );
    String? selectedCategoryId = isEdit
        ? existing['category_id'] as String?
        : null;
    DateTime selectedDate = isEdit
        ? (DateTime.tryParse(
                existing['spent_at'] as String? ?? '',
              )?.toLocal() ??
              DateTime.now())
        : DateTime.now();
    final messenger = ScaffoldMessenger.of(context);
    final danger = context.colors.danger;
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
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            final categoriesAsync = ref.watch(categoriesProvider);

            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final loc = AppLocalizations.of(ctx);
              setSheetState(() => saving = true);
              try {
                if (isEdit) {
                  await ref
                      .read(expensesProvider.notifier)
                      .update(
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
                  await ref
                      .read(expensesProvider.notifier)
                      .add(
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
                  SnackBar(
                    content: Text(
                      isEdit ? loc.expensesUpdated : loc.expensesSaved,
                    ),
                  ),
                );
              } catch (err) {
                setSheetState(() => saving = false);
                messenger.showSnackBar(
                  SnackBar(content: Text(loc.expensesSaveFailed)),
                );
              }
            }

            Future<void> confirmDelete() async {
              final ok = await showDialog<bool>(
                context: ctx,
                builder: (d) => AlertDialog(
                  title: Text(AppLocalizations.of(ctx).expensesDeleteTitle),
                  content: Text(AppLocalizations.of(ctx).expensesDeleteBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(d, false),
                      child: Text(AppLocalizations.of(ctx).actionCancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(d, true),
                      child: Text(
                        AppLocalizations.of(ctx).actionDelete,
                        style: TextStyle(color: danger),
                      ),
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
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(ctx).expensesDeleted),
                  ),
                );
              } catch (err) {
                setSheetState(() => saving = false);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Could not delete: $err'),
                    backgroundColor: danger,
                  ),
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
                          isEdit
                              ? AppLocalizations.of(ctx).expensesEditTitle
                              : AppLocalizations.of(ctx).expensesAddTitle,
                          style: AppTypography.titleLg,
                        ),
                      ),
                      if (isEdit)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: ctx.colors.danger,
                            size: 22,
                          ),
                          tooltip: AppLocalizations.of(ctx).actionDelete,
                          onPressed: saving ? null : confirmDelete,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx).expensesAmount,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [CurrencyInputFormatter()],
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) {
                        return AppLocalizations.of(ctx).commonRequired;
                      }
                      final d = double.tryParse(s.replaceAll(',', '.'));
                      if (d == null) {
                        return AppLocalizations.of(ctx).validationAmountInvalid;
                      }
                      if (d <= 0) {
                        return AppLocalizations.of(
                          ctx,
                        ).validationAmountPositive;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text(
                      '${copyForLocale(context, en: 'Could not load categories', tr: 'Kategoriler yüklenemedi')}: $e',
                    ),
                    data: (cats) => CategoryChipPicker(
                      categories: cats,
                      selectedId: selectedCategoryId,
                      onChanged: (v) =>
                          setSheetState(() => selectedCategoryId = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(
                      '${AppLocalizations.of(ctx).expensesDateLabel}: $dateFmt',
                    ),
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx).expensesMerchant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx).expensesNote,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: saving ? null : save,
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEdit
                                ? copyForLocale(
                                    ctx,
                                    en: 'Update',
                                    tr: 'Güncelle',
                                  )
                                : AppLocalizations.of(ctx).actionSave,
                          ),
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
  final String label;
  final double grandTotal;
  final int expenseCount;
  final List<Category> categories;
  final Map<String, double> totals;

  const _HeroSummary({
    required this.label,
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
          HeroLabel(label),
          const SizedBox(height: 4),
          Text(
            _fmtTRY(grandTotal),
            style: AppTypography.displayMd.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(
              context,
            ).dashboardExpenseCount(expenseCount, sorted.length),
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
                        flex: ((totals[c.id] ?? 0) / grandTotal * 1000).round(),
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
                      Text(
                        localizedCategoryName(context, c.name),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xCCFFFFFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

// ─── Expense search ────────────────────────────────────────────────
class _ExpenseSearchField extends StatelessWidget {
  final TextEditingController controller;
  final int resultCount;
  final bool isFiltering;
  final int activeFilterCount;
  final VoidCallback onFilterTap;
  final VoidCallback onClear;

  const _ExpenseSearchField({
    required this.controller,
    required this.resultCount,
    required this.isFiltering,
    required this.activeFilterCount,
    required this.onFilterTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: copyForLocale(
          context,
          en: 'Search merchant, category, note or amount',
          tr: 'Market, kategori, not veya tutar ara',
        ),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: copyForLocale(context, en: 'Filters', tr: 'Filtreler'),
              icon: Badge.count(
                count: activeFilterCount,
                isLabelVisible: activeFilterCount > 0,
                child: const Icon(Icons.tune_rounded),
              ),
              onPressed: onFilterTap,
            ),
            if (isFiltering)
              IconButton(
                tooltip: copyForLocale(
                  context,
                  en: 'Clear filters',
                  tr: 'Filtreleri temizle',
                ),
                icon: const Icon(Icons.close_rounded),
                onPressed: onClear,
              ),
          ],
        ),
        helperText: isFiltering
            ? copyForLocale(
                context,
                en: '$resultCount results',
                tr: '$resultCount sonuç',
              )
            : null,
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

List<_DayGroup> _groupExpensesByDay(
  BuildContext context,
  List<Map<String, dynamic>> expenses,
) {
  final byDate = <String, List<Map<String, dynamic>>>{};
  final today = DateTime.now();
  final todayKey = _dateKey(today);
  final yesterdayKey = _dateKey(today.subtract(const Duration(days: 1)));

  for (final e in expenses) {
    final iso = e['spent_at'] as String?;
    final key = iso != null
        ? _dateKey(DateTime.tryParse(iso)?.toLocal() ?? today)
        : '0000-00-00';
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
      label =
          '${copyForLocale(context, en: 'Today', tr: 'Bugün')} · ${_dayLabel(context, k)}';
    } else if (k == yesterdayKey) {
      label =
          '${copyForLocale(context, en: 'Yesterday', tr: 'Dün')} · ${_dayLabel(context, k)}';
    } else {
      label = _dayLabel(context, k);
    }
    return _DayGroup(label: label, total: total, items: items);
  }).toList();
}

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _dayLabel(BuildContext context, String key) {
  try {
    final d = DateTime.parse(key);
    return '${d.day.toString().padLeft(2, '0')} ${monthName(context, d.month)}';
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
              if (i > 0) Divider(height: 1, color: context.colors.outlineSoft),
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
                      (expense['merchant'] as String?) ??
                          copyForLocale(
                            context,
                            en: 'Unknown',
                            tr: 'Bilinmiyor',
                          ),
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${localizedCategoryName(context, category?.name, fallbackEn: '—', fallbackTr: '—')} · $time',
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

  const _SubscriptionsCard({required this.subs, required this.categoriesById});

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
                  child: Icon(
                    Icons.repeat,
                    color: context.colors.primary,
                    size: 20,
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.name,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  '${localizedCategoryName(context, category?.name, fallbackEn: 'Subscription', fallbackTr: 'Abonelik')} · ${periodLabel(context, sub.period)}',
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
        ? copyForLocale(
            context,
            en: '"${localizedCategoryName(context, exceeded.first.categoryName, fallbackEn: 'General', fallbackTr: 'Genel')}" budget exceeded',
            tr: '"${localizedCategoryName(context, exceeded.first.categoryName, fallbackEn: 'Genel', fallbackTr: 'Genel')}" bütçen aşıldı',
          )
        : copyForLocale(
            context,
            en: '${exceeded.length} budgets exceeded',
            tr: '${exceeded.length} bütçen aşıldı',
          );

    final overList = exceeded
        .map(
          (b) => copyForLocale(
            context,
            en: '${localizedCategoryName(context, b.categoryName, fallbackEn: 'General', fallbackTr: 'Genel')}: ${_fmtTRY(b.spent - b.amount)} over',
            tr: '${localizedCategoryName(context, b.categoryName, fallbackEn: 'Genel', fallbackTr: 'Genel')}: ${_fmtTRY(b.spent - b.amount)} fazla',
          ),
        )
        .join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md + 2),
        border: Border.all(
          color: context.colors.danger.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 18,
              color: context.colors.danger,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodyMd.copyWith(
                    color: context.colors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (exceeded.length > 1) ...[
                  const SizedBox(height: 2),
                  Text(
                    overList,
                    style: AppTypography.caption.copyWith(
                      color: context.colors.danger.withValues(alpha: 0.8),
                    ),
                  ),
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
