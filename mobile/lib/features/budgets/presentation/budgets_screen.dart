import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../budgets_provider.dart';
import '../../categories/categories_provider.dart';
import '../../../shared/category_avatar.dart';
import '../../../shared/section_label.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(budgetsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetsProvider);
    final progressAsync = ref.watch(budgetsProgressProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryById = <String, Category>{
      for (final c in categoriesAsync.value ?? const <Category>[]) c.id: c,
    };
    final budgetById = <String, Budget>{
      for (final b in state.items) b.id: b,
    };

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(title: Text('Bütçeler', style: AppTypography.titleLg)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(budgetsProvider.notifier).load(),
              child: state.items.isEmpty
                  ? _emptyState()
                  : progressAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(
                          child: Text('Yüklenemedi: $e',
                              style: AppTypography.caption)),
                      data: (items) {
                        items.sort((a, b) {
                          if (a.categoryId == null && b.categoryId != null) {
                            return -1;
                          }
                          if (b.categoryId == null && a.categoryId != null) {
                            return 1;
                          }
                          return b.percent.compareTo(a.percent);
                        });

                        final total = items.fold<double>(
                            0, (s, b) => s + b.amount);
                        final overCount =
                            items.where((b) => b.percent >= 100).length;

                        return ListView(
                          padding:
                              const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          children: [
                            _SummaryCard(
                              total: total,
                              count: items.length,
                              overCount: overCount,
                            ),
                            const SizedBox(height: 18),
                            const SectionLabel('Aktif bütçeler'),
                            const SizedBox(height: 4),
                            for (final p in items)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _BudgetCard(
                                  progress: p,
                                  budget: budgetById[p.budgetId],
                                  category: p.categoryId != null
                                      ? categoryById[p.categoryId]
                                      : null,
                                  onEdit: () {
                                    final b = budgetById[p.budgetId];
                                    if (b != null) _showEditSheet(context, b);
                                  },
                                  onDelete: () {
                                    final b = budgetById[p.budgetId];
                                    if (b != null) {
                                      _confirmDelete(context, b);
                                    }
                                  },
                                ),
                              ),
                            const SizedBox(height: 12),
                            _TipCard(),
                          ],
                        );
                      }),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_budgets',
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(Icons.account_balance_wallet_outlined,
                      size: 28, color: context.colors.primary),
                ),
                const SizedBox(height: 16),
                Text('Henüz bütçe yok',
                    style: AppTypography.titleMd),
                const SizedBox(height: 6),
                Text('Genel veya kategori bazlı limit ekle.',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Budget b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Bütçeyi sil'),
        content: const Text('Bu bütçe silinsin mi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text('Sil',
                style: TextStyle(color: context.colors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(budgetsProvider.notifier).remove(b.id);
        ref.invalidate(budgetsProgressProvider);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Silinemedi: $e'),
                backgroundColor: context.colors.danger),
          );
        }
      }
    }
  }

  void _showEditSheet(BuildContext context, Budget b) {
    final amountController =
        TextEditingController(text: b.amount.toStringAsFixed(2));
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              setSheet(() => saving = true);
              try {
                await ref.read(budgetsProvider.notifier).update(
                      id: b.id,
                      amount: amountController.text.trim(),
                    );
                ref.invalidate(budgetsProgressProvider);
                if (ctx.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bütçe güncellendi')),
                );
              } catch (e) {
                if (ctx.mounted) setSheet(() => saving = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Kaydedilemedi: $e'),
                      backgroundColor: context.colors.danger),
                );
              }
            }

            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Bütçeyi Düzenle', style: AppTypography.titleLg),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Tutar (TL)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final d =
                          double.tryParse(v?.replaceAll(',', '.') ?? '');
                      if (d == null || d <= 0) return 'Geçerli tutar gir';
                      return null;
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
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Güncelle'),
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
    final amountController = TextEditingController();
    String period = 'monthly';
    String? categoryId;
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
                await ref.read(budgetsProvider.notifier).add(
                      amount: amountController.text.trim(),
                      period: period,
                      categoryId: categoryId,
                    );
                ref.invalidate(budgetsProgressProvider);
                if (ctx.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bütçe eklendi')),
                );
              } on DioException catch (e) {
                final data = e.response?.data;
                String msg;
                if (data is Map) {
                  final detail = data['detail'];
                  msg = detail is List
                      ? detail.map((d) => d['msg']).join(', ')
                      : 'Hata: $detail';
                } else if (data is String && data.isNotEmpty) {
                  msg = data;
                } else {
                  msg =
                      'Sunucu hatası: ${e.response?.statusCode} — ${e.message}';
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(msg),
                      backgroundColor: context.colors.danger),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: context.colors.danger),
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
                  Text('Bütçe Ekle', style: AppTypography.titleLg),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Tutar (TL)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final d =
                          double.tryParse(v?.replaceAll(',', '.') ?? '');
                      if (d == null || d <= 0) return 'Geçerli tutar gir';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: period,
                    decoration: const InputDecoration(labelText: 'Periyot'),
                    items: const [
                      DropdownMenuItem(value: 'monthly', child: Text('Aylık')),
                      DropdownMenuItem(
                          value: 'weekly', child: Text('Haftalık')),
                    ],
                    onChanged: (v) =>
                        setSheet(() => period = v ?? 'monthly'),
                  ),
                  const SizedBox(height: 12),
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => const SizedBox(),
                    data: (cats) => DropdownButtonFormField<String?>(
                      initialValue: categoryId,
                      decoration:
                          const InputDecoration(labelText: 'Kategori'),
                      items: [
                        const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Genel (tüm harcamalar)')),
                        ...cats.map((c) => DropdownMenuItem<String?>(
                            value: c.id, child: Text(c.name))),
                      ],
                      onChanged: (v) => setSheet(() => categoryId = v),
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
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Kaydet'),
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

// ─── Summary card ──────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final double total;
  final int count;
  final int overCount;
  const _SummaryCard({
    required this.total,
    required this.count,
    required this.overCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BU AY TOPLAM BÜTÇEN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.textMid,
              letterSpacing: 0.96,
            ),
          ),
          const SizedBox(height: 4),
          Text(_fmtTRY(total),
              style: AppTypography.displaySm.copyWith(fontSize: 30)),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTypography.bodySm
                  .copyWith(color: context.colors.textMid, fontSize: 13),
              children: [
                TextSpan(text: '$count bütçe'),
                if (overCount > 0) ...[
                  const TextSpan(text: ' · '),
                  TextSpan(
                    text: '$overCount aşıldı',
                    style: TextStyle(
                        color: context.colors.warn, fontWeight: FontWeight.w600),
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

// ─── Budget card ───────────────────────────────────────────────────
class _BudgetCard extends StatelessWidget {
  final BudgetProgress progress;
  final Budget? budget;
  final Category? category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.progress,
    required this.budget,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress.percent / 100).clamp(0.0, 1.0);
    final isGeneral = progress.categoryId == null;
    final label = isGeneral ? 'Genel bütçe' : (category?.name ?? 'Kategori');
    final periodLabel = budget?.period == 'weekly' ? 'Haftalık' : 'Aylık';

    final Color statusColor;
    if (progress.percent >= 100) {
      statusColor = context.colors.danger;
    } else if (progress.percent >= 80) {
      statusColor = context.colors.warn;
    } else {
      statusColor = context.colors.ok;
    }

    final Widget leading;
    if (isGeneral) {
      leading = Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(Icons.account_balance_wallet,
            color: context.colors.onPrimaryContainer, size: 18),
      );
    } else {
      leading = CategoryAvatar(
        iconKey: category?.icon,
        colorHex: category?.color,
        size: 38,
        radius: AppRadius.md,
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
                        style: AppTypography.bodyLg
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '$periodLabel · ${_fmtTRY(progress.amount)} limit',
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${progress.percent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      )),
                  const SizedBox(height: 1),
                  Text(
                    progress.remaining >= 0
                        ? '${_fmtTRY(progress.remaining)} kaldı'
                        : '${_fmtTRY(-progress.remaining)} aşıldı',
                    style: AppTypography.labelXs.copyWith(
                      fontSize: 10,
                      color: progress.remaining >= 0
                          ? context.colors.textLo
                          : context.colors.danger,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    size: 16, color: context.colors.textLo),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                  PopupMenuItem(
                      value: 'delete',
                      child: Text('Sil',
                          style: TextStyle(color: context.colors.danger))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: statusColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmtTRY(progress.spent),
                  style: AppTypography.caption.copyWith(fontSize: 11)),
              Text(_fmtTRY(progress.amount),
                  style: AppTypography.caption.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Tip card ──────────────────────────────────────────────────────
class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md + 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome,
              size: 16, color: context.colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  height: 1.5,
                  color: context.colors.textMid,
                ),
                children: [
                  TextSpan(
                    text: 'İpucu: ',
                    style: TextStyle(
                      color: context.colors.textHi,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Her kategoriye ayrı bütçe koyarsan harcama dağılımın daha net olur.',
                  ),
                ],
              ),
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
