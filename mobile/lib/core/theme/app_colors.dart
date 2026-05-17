import 'package:flutter/material.dart';

// ─── Static light constants (backward compat + const contexts) ─────
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF5B5BD6);
  static const Color primaryHover = Color(0xFF4848C2);
  static const Color primaryContainer = Color(0xFFE8E9FF);
  static const Color onPrimaryContainer = Color(0xFF1B1B6F);
  static const Color primaryDim = Color(0xFF9494E6);

  static const Color heroBg = Color(0xFF16161E);
  static const Color heroBgGradient = Color(0xFF232336);
  static const Color heroAccent = Color(0xFFA3A3F5);

  static const Color bg = Color(0xFFF4F4F7);
  static const Color bgAlt = Color(0xFFEFEFF3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF8F8FB);
  static const Color outline = Color(0xFFE8E8EE);
  static const Color outlineSoft = Color(0xFFF0F0F4);

  static const Color textHi = Color(0xFF0F0F14);
  static const Color textMid = Color(0xFF5C5C68);
  static const Color textLo = Color(0xFF9090A0);
  static const Color textInv = Color(0xFFFFFFFF);

  static const Color danger = Color(0xFFDC2626);
  static const Color warn = Color(0xFFD97706);
  static const Color ok = Color(0xFF059669);
}

// ─── ThemeExtension — adaptive tokens ─────────────────────────────
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color primary;
  final Color primaryHover;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color primaryDim;

  final Color heroBg;
  final Color heroBgGradient;
  final Color heroAccent;

  final Color bg;
  final Color bgAlt;
  final Color surface;
  final Color surfaceContainer;
  final Color outline;
  final Color outlineSoft;

  final Color textHi;
  final Color textMid;
  final Color textLo;
  final Color textInv;

  final Color danger;
  final Color warn;
  final Color ok;

  const AppColorScheme({
    required this.primary,
    required this.primaryHover,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primaryDim,
    required this.heroBg,
    required this.heroBgGradient,
    required this.heroAccent,
    required this.bg,
    required this.bgAlt,
    required this.surface,
    required this.surfaceContainer,
    required this.outline,
    required this.outlineSoft,
    required this.textHi,
    required this.textMid,
    required this.textLo,
    required this.textInv,
    required this.danger,
    required this.warn,
    required this.ok,
  });

  static const light = AppColorScheme(
    primary: Color(0xFF5B5BD6),
    primaryHover: Color(0xFF4848C2),
    primaryContainer: Color(0xFFE8E9FF),
    onPrimaryContainer: Color(0xFF1B1B6F),
    primaryDim: Color(0xFF9494E6),
    heroBg: Color(0xFF16161E),
    heroBgGradient: Color(0xFF232336),
    heroAccent: Color(0xFFA3A3F5),
    bg: Color(0xFFF4F4F7),
    bgAlt: Color(0xFFEFEFF3),
    surface: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFF8F8FB),
    outline: Color(0xFFE8E8EE),
    outlineSoft: Color(0xFFF0F0F4),
    textHi: Color(0xFF0F0F14),
    textMid: Color(0xFF5C5C68),
    textLo: Color(0xFF9090A0),
    textInv: Color(0xFFFFFFFF),
    danger: Color(0xFFDC2626),
    warn: Color(0xFFD97706),
    ok: Color(0xFF059669),
  );

  static const dark = AppColorScheme(
    primary: Color(0xFF7B7BE8),
    primaryHover: Color(0xFF6868D8),
    primaryContainer: Color(0xFF1E1E52),
    onPrimaryContainer: Color(0xFFB0B0F5),
    primaryDim: Color(0xFF5B5BA8),
    heroBg: Color(0xFF16161E),
    heroBgGradient: Color(0xFF232336),
    heroAccent: Color(0xFFA3A3F5),
    bg: Color(0xFF0F0F14),
    bgAlt: Color(0xFF131318),
    surface: Color(0xFF1A1A24),
    surfaceContainer: Color(0xFF1E1E2C),
    outline: Color(0xFF2E2E3E),
    outlineSoft: Color(0xFF252535),
    textHi: Color(0xFFF0F0F8),
    textMid: Color(0xFF9090A8),
    textLo: Color(0xFF5C5C70),
    textInv: Color(0xFF0F0F14),
    danger: Color(0xFFEF4444),
    warn: Color(0xFFF59E0B),
    ok: Color(0xFF10B981),
  );

  @override
  AppColorScheme copyWith({
    Color? primary,
    Color? primaryHover,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? primaryDim,
    Color? heroBg,
    Color? heroBgGradient,
    Color? heroAccent,
    Color? bg,
    Color? bgAlt,
    Color? surface,
    Color? surfaceContainer,
    Color? outline,
    Color? outlineSoft,
    Color? textHi,
    Color? textMid,
    Color? textLo,
    Color? textInv,
    Color? danger,
    Color? warn,
    Color? ok,
  }) {
    return AppColorScheme(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      primaryDim: primaryDim ?? this.primaryDim,
      heroBg: heroBg ?? this.heroBg,
      heroBgGradient: heroBgGradient ?? this.heroBgGradient,
      heroAccent: heroAccent ?? this.heroAccent,
      bg: bg ?? this.bg,
      bgAlt: bgAlt ?? this.bgAlt,
      surface: surface ?? this.surface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      outline: outline ?? this.outline,
      outlineSoft: outlineSoft ?? this.outlineSoft,
      textHi: textHi ?? this.textHi,
      textMid: textMid ?? this.textMid,
      textLo: textLo ?? this.textLo,
      textInv: textInv ?? this.textInv,
      danger: danger ?? this.danger,
      warn: warn ?? this.warn,
      ok: ok ?? this.ok,
    );
  }

  @override
  AppColorScheme lerp(AppColorScheme other, double t) {
    return AppColorScheme(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      primaryDim: Color.lerp(primaryDim, other.primaryDim, t)!,
      heroBg: Color.lerp(heroBg, other.heroBg, t)!,
      heroBgGradient: Color.lerp(heroBgGradient, other.heroBgGradient, t)!,
      heroAccent: Color.lerp(heroAccent, other.heroAccent, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      bgAlt: Color.lerp(bgAlt, other.bgAlt, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineSoft: Color.lerp(outlineSoft, other.outlineSoft, t)!,
      textHi: Color.lerp(textHi, other.textHi, t)!,
      textMid: Color.lerp(textMid, other.textMid, t)!,
      textLo: Color.lerp(textLo, other.textLo, t)!,
      textInv: Color.lerp(textInv, other.textInv, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
    );
  }
}

// ─── BuildContext shortcut ─────────────────────────────────────────
extension AppColorsX on BuildContext {
  AppColorScheme get colors =>
      Theme.of(this).extension<AppColorScheme>() ?? AppColorScheme.light;
}
