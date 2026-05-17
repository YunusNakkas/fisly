import 'package:flutter/material.dart';
import '../features/categories/categories_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../l10n/localized_copy.dart';
import 'category_icons.dart';

class CategoryChipPicker extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  /// When set, shows a leading chip with this label for null selection.
  final String? allOptionLabel;

  const CategoryChipPicker({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onChanged,
    this.allOptionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copyForLocale(context, en: 'Category', tr: 'Kategori'),
          style: AppTypography.labelSm.copyWith(color: colors.textMid),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (allOptionLabel != null)
              _Chip(
                label: allOptionLabel!,
                icon: Icons.apps_rounded,
                color: colors.primary,
                selected: selectedId == null,
                onTap: () => onChanged(null),
              ),
            ...categories.map((cat) {
              final selected = cat.id == selectedId;
              final catColor = colorFromHex(cat.color);
              return _Chip(
                label: localizedCategoryName(context, cat.name),
                icon: iconForCategory(cat.icon),
                color: catColor,
                selected: selected,
                onTap: () => onChanged(
                  selected && allOptionLabel == null ? null : cat.id,
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : colors.surface,
          border: Border.all(
            color: selected ? color : colors.outline,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: selected ? Colors.white : color),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: selected ? Colors.white : colors.textHi,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
