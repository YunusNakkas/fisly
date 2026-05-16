import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';

class DaysPill extends StatelessWidget {
  final int days;
  const DaysPill({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;

    if (days < 0) {
      label = days == -1 ? 'Dün gecikti' : '${-days} gün gecikti';
      color = AppColors.danger;
    } else if (days == 0) {
      label = 'Bugün';
      color = AppColors.danger;
    } else if (days == 1) {
      label = 'Yarın';
      color = const Color(0xFFEA580C);
    } else if (days <= 3) {
      label = '$days gün';
      color = AppColors.warn;
    } else if (days <= 7) {
      label = '$days gün';
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
