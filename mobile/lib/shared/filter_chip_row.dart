import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';

class FilterChipItem {
  final String value;
  final String label;
  const FilterChipItem({required this.value, required this.label});
}

class FilterChipRow extends StatelessWidget {
  final List<FilterChipItem> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const FilterChipRow({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = items[i];
          final active = c.value == selectedValue;
          return InkWell(
            onTap: () => onChanged(active ? null : c.value),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.textHi : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: active
                    ? null
                    : Border.all(color: AppColors.outline),
              ),
              child: Center(
                child: Text(
                  c.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.textInv : AppColors.textHi,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
