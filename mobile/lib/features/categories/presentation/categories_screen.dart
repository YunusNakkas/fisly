import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../categories_provider.dart';
import '../../../shared/category_avatar.dart';
import '../../../shared/category_icons.dart';
import '../../../shared/section_label.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(title: Text('Kategoriler', style: AppTypography.titleLg)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Yüklenemedi: $e', style: AppTypography.caption),
        ),
        data: (cats) {
          final system = cats.where((c) => c.isSystem).toList();
          final mine = cats.where((c) => !c.isSystem).toList();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(categoriesProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                if (system.isNotEmpty) ...[
                  const SectionLabel('Sistem kategorileri'),
                  _CategoriesCard(categories: system),
                  const SizedBox(height: 18),
                ],
                SectionLabel(
                  mine.isNotEmpty
                      ? 'Kendi kategorilerin (${mine.length})'
                      : 'Kendi kategorilerin',
                ),
                if (mine.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg + 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Henüz özel kategorin yok',
                          style: AppTypography.bodyLg
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Alttan + ile yeni kategori ekleyebilirsin.',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  )
                else
                  _CategoriesCard(
                    categories: mine,
                    onEdit: (c) => _showFormSheet(context, ref,
                        title: 'Kategoriyi Düzenle', existing: c),
                    onDelete: (c) => _confirmDelete(context, ref, c),
                  ),
                const SizedBox(height: 18),
                const SectionLabel('Renk paleti'),
                _ColorPaletteCard(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_categories',
        onPressed: () =>
            _showFormSheet(context, ref, title: 'Kategori Ekle'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Category c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Kategoriyi sil'),
        content: Text(
            '"${c.name}" silinsin mi? Bu kategoriye bağlı harcamalar etkilenebilir.'),
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
    if (ok != true) return;
    try {
      await ref.read(categoriesProvider.notifier).remove(c.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Silinemedi: $e'),
              backgroundColor: context.colors.danger),
        );
      }
    }
  }

  void _showFormSheet(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    Category? existing,
  }) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    String selectedIcon = existing?.icon ?? 'tag';
    String selectedColor = existing?.color ?? categoryColorPalette[0];
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
            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              setSheet(() => saving = true);
              try {
                final notifier = ref.read(categoriesProvider.notifier);
                if (existing == null) {
                  await notifier.create(
                    name: nameController.text.trim(),
                    icon: selectedIcon,
                    color: selectedColor,
                  );
                } else {
                  await notifier.edit(
                    id: existing.id,
                    name: nameController.text.trim(),
                    icon: selectedIcon,
                    color: selectedColor,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(existing == null
                          ? 'Kategori eklendi'
                          : 'Kategori güncellendi'),
                    ),
                  );
                }
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
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(msg),
                        backgroundColor: context.colors.danger),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Hata: $e'),
                        backgroundColor: context.colors.danger),
                  );
                }
              } finally {
                if (ctx.mounted) setSheet(() => saving = false);
              }
            }

            return SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: AppTypography.titleLg),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorFromHex(selectedColor),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(iconForCategory(selectedIcon),
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: nameController,
                            decoration:
                                const InputDecoration(labelText: 'İsim'),
                            textCapitalization: TextCapitalization.sentences,
                            validator: (v) {
                              final t = v?.trim() ?? '';
                              if (t.isEmpty) return 'İsim gerekli';
                              if (t.length > 100) return 'En fazla 100 karakter';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('İkon',
                        style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textMid)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final entry in categoryIconSet.entries)
                          _IconChoice(
                            icon: entry.value,
                            selected: entry.key == selectedIcon,
                            color: colorFromHex(selectedColor),
                            onTap: () =>
                                setSheet(() => selectedIcon = entry.key),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Renk',
                        style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textMid)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final hex in categoryColorPalette)
                          _ColorChoice(
                            hex: hex,
                            selected: hex == selectedColor,
                            onTap: () =>
                                setSheet(() => selectedColor = hex),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: saving ? null : save,
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(existing == null ? 'Kaydet' : 'Güncelle'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Categories list card ──────────────────────────────────────────
class _CategoriesCard extends StatelessWidget {
  final List<Category> categories;
  final void Function(Category)? onEdit;
  final void Function(Category)? onDelete;

  const _CategoriesCard({
    required this.categories,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        child: Column(
          children: [
            for (int i = 0; i < categories.length; i++) ...[
              if (i > 0)
                Divider(height: 1, color: context.colors.outlineSoft),
              _CategoryRow(
                category: categories[i],
                onEdit: onEdit == null ? null : () => onEdit!(categories[i]),
                onDelete:
                    onDelete == null ? null : () => onDelete!(categories[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final Category category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CategoryRow({
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CategoryAvatar(
              iconKey: category.icon,
              colorHex: category.color,
              size: 38,
              radius: AppRadius.md,
              style: CategoryAvatarStyle.tinted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.name,
                      style: AppTypography.bodyLg
                          .copyWith(fontWeight: FontWeight.w600)),
                  if (category.isSystem) ...[
                    const SizedBox(height: 2),
                    Text('Sistem',
                        style: AppTypography.caption.copyWith(fontSize: 11)),
                  ],
                ],
              ),
            ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    size: 18, color: context.colors.textLo),
                onSelected: (v) {
                  if (v == 'edit') onEdit?.call();
                  if (v == 'delete') onDelete?.call();
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
      ),
    );
  }
}

// ─── Color palette display card ────────────────────────────────────
class _ColorPaletteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: GridView.count(
        crossAxisCount: 6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final hex in categoryColorPalette)
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: colorFromHex(hex),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Icon / Color choice in form ───────────────────────────────────
class _IconChoice extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.16) : null,
          border: Border.all(
            color: selected ? color : context.colors.outline,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: selected ? color : context.colors.textMid),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  final String hex;
  final bool selected;
  final VoidCallback onTap;

  const _ColorChoice({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colorFromHex(hex);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? context.colors.textHi : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}
