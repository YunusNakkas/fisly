import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../l10n/localized_copy.dart';

class DaysPill extends StatelessWidget {
  final int days;
  const DaysPill({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;

    if (days < 0) {
      label = days == -1
          ? copyForLocale(context, en: 'Overdue yesterday', tr: 'Dün gecikti')
          : copyForLocale(
              context,
              en: '${-days} days overdue',
              tr: '${-days} gün gecikti',
            );
      color = AppColors.danger;
    } else if (days == 0) {
      label = copyForLocale(context, en: 'Today', tr: 'Bugün');
      color = AppColors.danger;
    } else if (days == 1) {
      label = copyForLocale(context, en: 'Tomorrow', tr: 'Yarın');
      color = const Color(0xFFEA580C);
    } else if (days <= 3) {
      label = copyForLocale(context, en: '$days days', tr: '$days gün');
      color = AppColors.warn;
    } else if (days <= 7) {
      label = copyForLocale(context, en: '$days days', tr: '$days gün');
      color = AppColors.primary;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
