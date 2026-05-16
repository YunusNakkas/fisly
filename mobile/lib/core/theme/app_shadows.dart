import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color.fromRGBO(15, 15, 20, 0.04),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color.fromRGBO(15, 15, 20, 0.04),
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color.fromRGBO(15, 15, 20, 0.08),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
    BoxShadow(
      color: Color.fromRGBO(15, 15, 20, 0.04),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];
}
