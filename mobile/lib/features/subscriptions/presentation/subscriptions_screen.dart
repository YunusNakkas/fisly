import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import '../subscriptions_provider.dart';
import '../../categories/categories_provider.dart';
import '../../../shared/category_avatar.dart';
import '../../../shared/category_chip_picker.dart';
import '../../../shared/category_icons.dart';
import '../../../shared/currency_input_formatter.dart';
import '../../../shared/days_pill.dart';
import '../../../shared/hero_card.dart';
import '../../../shared/section_label.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/localized_copy.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(subscriptionsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryById = <String, Category>{
      for (final c in categoriesAsync.valueOrNull ?? const <Category>[])
        c.id: c,
    };

    final active = state.items.where((s) => s.status == 'active').toList()
      ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    final cancelled = state.items
        .where((s) => s.status == 'cancelled')
        .toList();

    final monthlyTotal = active.fold<double>(0, (sum, s) {
      return sum +
          switch (s.period) {
            'monthly' => s.amount,
            'yearly' => s.amount / 12,
            'weekly' => s.amount * 4.33,
            _ => s.amount,
          };
    });

    // Upcoming this week (next 7 days)
    final now = DateTime.now();
    final weekEnd = now.add(const Duration(days: 7));
    final upcoming = active.where((s) {
      try {
        final d = DateTime.parse(s.nextBillingDate);
        return !d.isBefore(DateTime(now.year, now.month, now.day)) &&
            !d.isAfter(weekEnd);
      } catch (_) {
        return false;
      }
    }).toList();
    final upcomingTotal = upcoming.fold<double>(0, (s, x) => s + x.amount);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).subscriptionsTitle,
          style: AppTypography.titleLg,
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(subscriptionsProvider.notifier).load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                children: [
                  _HeroBanner(
                    monthlyTotal: monthlyTotal,
                    upcomingCount: upcoming.length,
                    upcomingTotal: upcomingTotal,
                  ),
                  const SizedBox(height: 18),
                  if (active.isNotEmpty) ...[
                    _SubsDonutCard(
                      active: active,
                      categoryById: categoryById,
                      monthlyTotal: monthlyTotal,
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (active.isEmpty && cancelled.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).subscriptionsEmptyState,
                          style: AppTypography.bodyMd.copyWith(
                            color: context.colors.textMid,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    if (active.isNotEmpty) ...[
                      SectionLabel(
                        '${AppLocalizations.of(context).subscriptionsActive} (${active.length})',
                      ),
                      _SubsCard(
                        subs: active,
                        categoryById: categoryById,
                        onEdit: (s) => _showEditSheet(context, s),
                        onCancel: (s) => _confirmCancel(context, s),
                        onDelete: (s) => _confirmDelete(context, s),
                      ),
                      const SizedBox(height: 18),
                    ],
                    if (cancelled.isNotEmpty) ...[
                      SectionLabel(
                        AppLocalizations.of(context).subscriptionsCancelled,
                      ),
                      _SubsCard(
                        subs: cancelled,
                        categoryById: categoryById,
                        onEdit: (s) => _showEditSheet(context, s),
                        onCancel: null,
                        onDelete: (s) => _confirmDelete(context, s),
                      ),
                    ],
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_subscriptions',
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, Subscription sub) async {
    final messenger = ScaffoldMessenger.of(context);
    final warn = context.colors.warn;
    final danger = context.colors.danger;
    final cancelledText = copyForLocale(
      context,
      en: '${sub.name} cancelled',
      tr: '${sub.name} iptal edildi',
    );
    final cancelFailed = copyForLocale(
      context,
      en: 'Could not cancel',
      tr: 'İptal edilemedi',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          copyForLocale(
            context,
            en: 'Cancel ${sub.name}?',
            tr: '${sub.name} iptal edilsin mi?',
          ),
        ),
        content: Text(
          copyForLocale(
            context,
            en: 'Past payments will not be affected.',
            tr: 'Geçmiş ödemeler etkilenmez.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              AppLocalizations.of(context).subscriptionsCancelAction,
              style: TextStyle(color: warn),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(subscriptionsProvider.notifier).cancel(sub.id);
        if (mounted) {
          messenger.showSnackBar(SnackBar(content: Text(cancelledText)));
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('$cancelFailed: $e'),
              backgroundColor: danger,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, Subscription sub) async {
    final messenger = ScaffoldMessenger.of(context);
    final danger = context.colors.danger;
    final deleteFailed = copyForLocale(
      context,
      en: 'Could not delete',
      tr: 'Silinemedi',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          copyForLocale(
            context,
            en: 'Delete subscription',
            tr: 'Aboneliği sil',
          ),
        ),
        content: Text(
          copyForLocale(
            context,
            en: 'Delete "${sub.name}" permanently?',
            tr: '"${sub.name}" tamamen silinsin mi?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              AppLocalizations.of(context).actionDelete,
              style: TextStyle(color: danger),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(subscriptionsProvider.notifier).remove(sub.id);
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('$deleteFailed: $e'),
              backgroundColor: danger,
            ),
          );
        }
      }
    }
  }

  void _showEditSheet(BuildContext context, Subscription sub) {
    final nameController = TextEditingController(text: sub.name);
    final amountController = TextEditingController(
      text: formatAmountForInput(sub.amount),
    );
    final messenger = ScaffoldMessenger.of(context);
    final danger = context.colors.danger;
    String? categoryId = sub.categoryId;
    DateTime nextDate =
        DateTime.tryParse(sub.nextBillingDate) ?? DateTime.now();
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheet) {
            final categoriesAsync = ref.watch(categoriesProvider);

            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              setSheet(() => saving = true);
              try {
                await ref
                    .read(subscriptionsProvider.notifier)
                    .update(
                      id: sub.id,
                      name: nameController.text.trim(),
                      amount: amountController.text.trim(),
                      nextBillingDate: _fmtDate(nextDate),
                      categoryId: categoryId,
                    );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(ctx).subscriptionsUpdated,
                    ),
                  ),
                );
              } catch (e) {
                if (ctx.mounted) setSheet(() => saving = false);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      '${copyForLocale(ctx, en: 'Could not save', tr: 'Kaydedilemedi')}: $e',
                    ),
                    backgroundColor: danger,
                  ),
                );
              }
            }

            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(ctx).subscriptionsEditTitle,
                    style: AppTypography.titleLg,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx).subscriptionsName,
                    ),
                    validator: (v) => (v?.trim().isEmpty ?? true)
                        ? AppLocalizations.of(ctx).commonRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx).subscriptionsAmount,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [CurrencyInputFormatter()],
                    validator: (v) {
                      final d = double.tryParse(v?.replaceAll(',', '.') ?? '');
                      if (d == null || d <= 0) {
                        return AppLocalizations.of(ctx).validationAmountInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => const SizedBox(),
                    data: (cats) => CategoryChipPicker(
                      categories: cats,
                      selectedId: categoryId,
                      onChanged: (v) => setSheet(() => categoryId = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(
                      '${AppLocalizations.of(ctx).subscriptionsNextPayment}: ${_fmtDisplay(nextDate)}',
                    ),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: nextDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 366)),
                      );
                      if (d != null) setSheet(() => nextDate = d);
                    },
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
                            copyForLocale(ctx, en: 'Update', tr: 'Güncelle'),
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

  void _showAddSheet(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final danger = context.colors.danger;
    final warn = context.colors.warn;
    String period = 'monthly';
    String? categoryId;
    DateTime startDate = DateTime.now();
    DateTime nextDate = DateTime.now().add(const Duration(days: 30));
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
          builder: (ctx, setSheet) {
            final categoriesAsync = ref.watch(categoriesProvider);

            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              setSheet(() => saving = true);
              try {
                await ref
                    .read(subscriptionsProvider.notifier)
                    .add(
                      name: nameController.text.trim(),
                      amount: amountController.text.trim(),
                      period: period,
                      startDate: _fmtDate(startDate),
                      nextBillingDate: _fmtDate(nextDate),
                      categoryId: categoryId,
                    );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(ctx).subscriptionsSaved),
                  ),
                );
              } on DioException catch (e) {
                final data = e.response?.data;
                String msg;
                if (data is Map) {
                  final detail = data['detail'];
                  msg = detail is List
                      ? detail.map((d) => d['msg']).join(', ')
                      : '${copyForLocale(ctx, en: 'Error', tr: 'Hata')}: $detail';
                } else if (data is String && data.isNotEmpty) {
                  msg = data;
                } else {
                  msg =
                      '${copyForLocale(ctx, en: 'Server error', tr: 'Sunucu hatası')}: ${e.response?.statusCode} — ${e.message}';
                }
                messenger.showSnackBar(
                  SnackBar(content: Text(msg), backgroundColor: danger),
                );
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      '${copyForLocale(ctx, en: 'Saved, but the list could not refresh', tr: 'Kaydedildi ama liste yenilenirken hata')}: $e',
                    ),
                    backgroundColor: warn,
                  ),
                );
              } finally {
                if (ctx.mounted) setSheet(() => saving = false);
              }
            }

            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(ctx).subscriptionsAddTitle,
                    style: AppTypography.titleLg,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx).subscriptionsName,
                    ),
                    validator: (v) => (v?.trim().isEmpty ?? true)
                        ? AppLocalizations.of(ctx).commonRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(ctx).subscriptionsAmount,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [CurrencyInputFormatter()],
                    validator: (v) {
                      final d = double.tryParse(v?.replaceAll(',', '.') ?? '');
                      if (d == null || d <= 0) {
                        return AppLocalizations.of(ctx).validationAmountInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: period,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        ctx,
                      ).subscriptionsPeriodLabel,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text(
                          AppLocalizations.of(ctx).subscriptionsPeriodMonthly,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'yearly',
                        child: Text(
                          AppLocalizations.of(ctx).subscriptionsPeriodYearly,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'weekly',
                        child: Text(
                          AppLocalizations.of(ctx).subscriptionsPeriodWeekly,
                        ),
                      ),
                    ],
                    onChanged: (v) => setSheet(() => period = v ?? 'monthly'),
                  ),
                  const SizedBox(height: 12),
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => const SizedBox(),
                    data: (cats) => CategoryChipPicker(
                      categories: cats,
                      selectedId: categoryId,
                      onChanged: (v) => setSheet(() => categoryId = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(
                      '${AppLocalizations.of(ctx).subscriptionsNextPayment}: ${_fmtDisplay(nextDate)}',
                    ),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: nextDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 366)),
                      );
                      if (d != null) setSheet(() => nextDate = d);
                    },
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
                        : Text(AppLocalizations.of(ctx).actionSave),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtDisplay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

// ─── Hero banner ───────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final double monthlyTotal;
  final int upcomingCount;
  final double upcomingTotal;

  const _HeroBanner({
    required this.monthlyTotal,
    required this.upcomingCount,
    required this.upcomingTotal,
  });

  @override
  Widget build(BuildContext context) {
    return HeroCard(
      padding: const EdgeInsets.all(20),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroLabel(
            copyForLocale(
              context,
              en: 'Monthly Subscription Total',
              tr: 'Aylık Abonelik Toplamı',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _fmtTRY(monthlyTotal),
            style: AppTypography.displayMd.copyWith(color: Colors.white),
          ),
          if (upcomingCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(top: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          copyForLocale(
                            context,
                            en: 'THIS WEEK',
                            tr: 'BU HAFTA',
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          copyForLocale(
                            context,
                            en: '$upcomingCount payments · ${_fmtTRY(upcomingTotal)}',
                            tr: '$upcomingCount ödeme · ${_fmtTRY(upcomingTotal)}',
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.notifications_outlined,
                    color: context.colors.heroAccent,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Subs card / row ───────────────────────────────────────────────
class _SubsCard extends StatelessWidget {
  final List<Subscription> subs;
  final Map<String, Category> categoryById;
  final void Function(Subscription) onEdit;
  final void Function(Subscription)? onCancel;
  final void Function(Subscription) onDelete;

  const _SubsCard({
    required this.subs,
    required this.categoryById,
    required this.onEdit,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: Column(
        children: [
          for (int i = 0; i < subs.length; i++) ...[
            if (i > 0) Divider(height: 1, color: context.colors.outlineSoft),
            _SubRow(
              sub: subs[i],
              category: subs[i].categoryId != null
                  ? categoryById[subs[i].categoryId]
                  : null,
              onEdit: () => onEdit(subs[i]),
              onCancel: onCancel == null ? null : () => onCancel!(subs[i]),
              onDelete: () => onDelete(subs[i]),
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
  final VoidCallback onEdit;
  final VoidCallback? onCancel;
  final VoidCallback onDelete;

  const _SubRow({
    required this.sub,
    required this.category,
    required this.onEdit,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCancelled = sub.status == 'cancelled';
    final daysUntil = _daysUntil(sub.nextBillingDate);

    final Widget leading;
    if (category != null && !isCancelled) {
      leading = CategoryAvatar(
        iconKey: category!.icon,
        colorHex: category!.color,
        size: 40,
        radius: AppRadius.md,
        style: CategoryAvatarStyle.tinted,
      );
    } else {
      leading = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isCancelled
              ? context.colors.outline
              : context.colors.primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: Text(
            sub.name.isNotEmpty ? sub.name.substring(0, 1).toUpperCase() : '?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isCancelled
                  ? context.colors.textLo
                  : context.colors.primary,
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: isCancelled ? 0.55 : 1,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            sub.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyLg.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: isCancelled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (!isCancelled && daysUntil != null) ...[
                          const SizedBox(width: 8),
                          DaysPill(days: daysUntil),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      isCancelled
                          ? '${periodLabel(context, sub.period)} · ${AppLocalizations.of(context).subscriptionsCancelled}'
                          : '${periodLabel(context, sub.period)} · ${AppLocalizations.of(context).subscriptionsNextPayment}: ${_displayDate(sub.nextBillingDate)}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(_fmtTRY(sub.amount), style: AppTypography.amountLg),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: context.colors.textLo,
                ),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'cancel' && onCancel != null) onCancel!();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(AppLocalizations.of(context).actionEdit),
                  ),
                  if (!isCancelled)
                    PopupMenuItem(
                      value: 'cancel',
                      child: Text(
                        AppLocalizations.of(context).subscriptionsCancelAction,
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      AppLocalizations.of(context).actionDelete,
                      style: TextStyle(color: context.colors.danger),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    } catch (_) {
      return iso;
    }
  }

  int? _daysUntil(String iso) {
    try {
      final next = DateTime.parse(iso);
      final today = DateTime.now();
      final n = DateTime(next.year, next.month, next.day);
      final t = DateTime(today.year, today.month, today.day);
      return n.difference(t).inDays;
    } catch (_) {
      return null;
    }
  }
}

// ─── Subs donut chart ──────────────────────────────────────────────
class _SubBreakdown {
  final String label;
  final String colorHex;
  final String? iconKey;
  final String? categoryId;
  final double monthly;

  const _SubBreakdown({
    required this.label,
    required this.colorHex,
    this.iconKey,
    this.categoryId,
    required this.monthly,
  });
}

class _SubsDonutCard extends StatefulWidget {
  final List<Subscription> active;
  final Map<String, Category> categoryById;
  final double monthlyTotal;

  const _SubsDonutCard({
    required this.active,
    required this.categoryById,
    required this.monthlyTotal,
  });

  @override
  State<_SubsDonutCard> createState() => _SubsDonutCardState();
}

class _SubsDonutCardState extends State<_SubsDonutCard> {
  int _touched = -1;

  List<_SubBreakdown> _buildBreakdown() {
    final Map<String, double> byKey = {};
    final Map<String, String?> idByKey = {};
    final Map<String, Category?> catByKey = {};

    for (final s in widget.active) {
      final monthly = switch (s.period) {
        'monthly' => s.amount,
        'yearly' => s.amount / 12,
        'weekly' => s.amount * 4.33,
        _ => s.amount,
      };
      final key = s.categoryId ?? '__none__';
      byKey[key] = (byKey[key] ?? 0) + monthly;
      idByKey[key] = s.categoryId;
      catByKey[key] = s.categoryId != null
          ? widget.categoryById[s.categoryId]
          : null;
    }

    final fallbackColors = categoryColorPalette;
    int fi = 0;
    final result = byKey.entries.map((e) {
      final cat = catByKey[e.key];
      final color = cat?.color ?? fallbackColors[fi++ % fallbackColors.length];
      return _SubBreakdown(
        label: localizedCategoryName(
          context,
          cat?.name,
          fallbackEn: 'Uncategorized',
          fallbackTr: 'Kategorisiz',
        ),
        colorHex: color,
        iconKey: cat?.icon,
        categoryId: idByKey[e.key],
        monthly: e.value,
      );
    }).toList()..sort((a, b) => b.monthly.compareTo(a.monthly));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = _buildBreakdown();
    if (breakdown.isEmpty) return const SizedBox();

    final sections = breakdown.asMap().entries.map((entry) {
      final i = entry.key;
      final b = entry.value;
      final isTouched = i == _touched;
      return PieChartSectionData(
        value: b.monthly,
        color: colorFromHex(b.colorHex),
        radius: isTouched ? 30 : 24,
        title: '',
        showTitle: false,
      );
    }).toList();

    final selected = _touched >= 0 && _touched < breakdown.length
        ? breakdown[_touched]
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).reportsCategoryBreakdown,
            style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 58,
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
                          Text(
                            selected.label,
                            style: AppTypography.caption,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fmtTRY(selected.monthly),
                            style: AppTypography.displaySm,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${((selected.monthly / widget.monthlyTotal) * 100).toStringAsFixed(1)}%',
                            style: AppTypography.labelXs.copyWith(
                              color: context.colors.textLo,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]
                      : [
                          Text(
                            AppLocalizations.of(
                              context,
                            ).subscriptionsPeriodMonthly.toUpperCase(),
                            style: AppTypography.labelSm,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fmtTRY(widget.monthlyTotal),
                            style: AppTypography.displaySm,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            copyForLocale(
                              context,
                              en: '${breakdown.length} categories',
                              tr: '${breakdown.length} kategori',
                            ),
                            style: AppTypography.caption.copyWith(fontSize: 11),
                          ),
                        ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: context.colors.outlineSoft),
          const SizedBox(height: 4),
          for (int i = 0; i < breakdown.length; i++) ...[
            _SubBreakdownRow(
              item: breakdown[i],
              total: widget.monthlyTotal,
              isSelected: i == _touched,
            ),
          ],
        ],
      ),
    );
  }
}

class _SubBreakdownRow extends StatelessWidget {
  final _SubBreakdown item;
  final double total;
  final bool isSelected;

  const _SubBreakdownRow({
    required this.item,
    required this.total,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? (item.monthly / total).clamp(0.0, 1.0) : 0.0;
    final pct = (fraction * 100).toStringAsFixed(1);
    final color = colorFromHex(item.colorHex);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: AppTypography.caption.copyWith(
                  color: context.colors.textLo,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _fmtTRY(item.monthly),
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
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
