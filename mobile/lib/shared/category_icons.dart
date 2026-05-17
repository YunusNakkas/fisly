import 'package:flutter/material.dart';

const categoryIconSet = <String, IconData>{
  'shopping_cart': Icons.shopping_cart,
  'directions_car': Icons.directions_car,
  'receipt_long': Icons.receipt_long,
  'restaurant': Icons.restaurant,
  'local_hospital': Icons.local_hospital,
  'movie': Icons.movie,
  'home': Icons.home,
  'school': Icons.school,
  'fitness_center': Icons.fitness_center,
  'pets': Icons.pets,
  'flight': Icons.flight,
  'card_giftcard': Icons.card_giftcard,
  'work': Icons.work,
  'phone_android': Icons.phone_android,
  'sports_esports': Icons.sports_esports,
  'savings': Icons.savings,
  'more_horiz': Icons.more_horiz,
  'tag': Icons.label_outline,
};

const categoryColorPalette = <String>[
  '#10b981',
  '#3b82f6',
  '#f59e0b',
  '#ef4444',
  '#ec4899',
  '#8b5cf6',
  '#6b7280',
  '#14b8a6',
  '#f97316',
  '#0ea5e9',
  '#a855f7',
  '#84cc16',
];

IconData iconForCategory(String? key) =>
    categoryIconSet[key] ?? Icons.label_outline;

Color colorFromHex(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}
