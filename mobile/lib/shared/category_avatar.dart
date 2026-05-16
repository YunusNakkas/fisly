import 'package:flutter/material.dart';
import '../core/theme/app_radius.dart';
import 'category_icons.dart';

enum CategoryAvatarStyle { tinted, solid }

class CategoryAvatar extends StatelessWidget {
  final String? iconKey;
  final String? colorHex;
  final double size;
  final double radius;
  final CategoryAvatarStyle style;

  const CategoryAvatar({
    super.key,
    required this.iconKey,
    required this.colorHex,
    this.size = 40,
    this.radius = AppRadius.md,
    this.style = CategoryAvatarStyle.tinted,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorHex != null ? colorFromHex(colorHex!) : Colors.grey;
    final bg = style == CategoryAvatarStyle.solid
        ? color
        : color.withValues(alpha: 0.14);
    final fg = style == CategoryAvatarStyle.solid ? Colors.white : color;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(iconForCategory(iconKey), color: fg, size: size * 0.5),
    );
  }
}
