import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../onboarding_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/localized_copy.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _total = 3;

  void _next() {
    if (_page < _total - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).markDone();
    if (mounted) context.go('/expenses');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: PageView(
          controller: _controller,
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            _WelcomeSlide(onNext: _next, page: _page, total: _total),
            _ScanSlide(
              onNext: _next,
              onSkip: _finish,
              page: _page,
              total: _total,
            ),
            _BudgetSlide(onFinish: _finish, page: _page, total: _total),
          ],
        ),
      ),
    );
  }
}

// ─── Slide 1: Welcome ──────────────────────────────────────────────
class _WelcomeSlide extends StatelessWidget {
  final VoidCallback onNext;
  final int page;
  final int total;

  const _WelcomeSlide({
    required this.onNext,
    required this.page,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandMark(),
          const Spacer(),
          const _ReceiptStackIllo(),
          const Spacer(),
          Text(
            t.onboardingWelcomeTitle,
            style: AppTypography.displaySm.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.05,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.onboardingWelcomeBody,
            style: AppTypography.bodyMd.copyWith(
              color: context.colors.textMid,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: Text(t.actionContinue),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_PageDots(count: total, current: page)],
          ),
        ],
      ),
    );
  }
}

// ─── Slide 2: Scan feature ─────────────────────────────────────────
class _ScanSlide extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final int page;
  final int total;

  const _ScanSlide({
    required this.onNext,
    required this.onSkip,
    required this.page,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandMark(),
          const Spacer(),
          const _ScanIllo(),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 12,
                  color: context.colors.onPrimaryContainer,
                ),
                const SizedBox(width: 5),
                Text(
                  'Gemini Vision',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.onboardingScanTitle,
            style: AppTypography.displaySm.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.onboardingScanBody,
            style: AppTypography.bodyMd.copyWith(
              color: context.colors.textMid,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: Text(t.actionContinue),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onSkip,
                child: Text(
                  t.actionSkip,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textMid,
                  ),
                ),
              ),
              _PageDots(count: total, current: page),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Slide 3: Budgets ──────────────────────────────────────────────
class _BudgetSlide extends StatelessWidget {
  final VoidCallback onFinish;
  final int page;
  final int total;

  const _BudgetSlide({
    required this.onFinish,
    required this.page,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandMark(),
          const Spacer(),
          const _BudgetIllo(),
          const Spacer(),
          Text(
            t.onboardingBudgetTitle,
            style: AppTypography.displaySm.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.05,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.onboardingBudgetBody,
            style: AppTypography.bodyMd.copyWith(
              color: context.colors.textMid,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onFinish,
              child: Text(t.actionStart),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: _PageDots(count: total, current: page),
          ),
        ],
      ),
    );
  }
}

// ─── Brand mark ────────────────────────────────────────────────────
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(painter: _ReceiptIconPainter()),
        ),
        const SizedBox(width: 10),
        Text(
          'Fişly',
          style: AppTypography.titleMd.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _ReceiptIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final notch = h * 0.08;

    // Receipt shape with jagged bottom
    path.moveTo(w * 0.25, h * 0.1);
    path.lineTo(w * 0.75, h * 0.1);
    path.lineTo(w * 0.75, h * 0.9);
    path.lineTo(w * 0.625, h * 0.9 - notch);
    path.lineTo(w * 0.5, h * 0.9);
    path.lineTo(w * 0.375, h * 0.9 - notch);
    path.lineTo(w * 0.25, h * 0.9);
    path.close();
    canvas.drawPath(path, paint);

    // Two lines on the receipt
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.35, h * 0.42),
      Offset(w * 0.65, h * 0.42),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.35, h * 0.56),
      Offset(w * 0.58, h * 0.56),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Page dots ─────────────────────────────────────────────────────
class _PageDots extends StatelessWidget {
  final int count;
  final int current;
  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.outline,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}

// ─── Illustration 1: Receipt stack ────────────────────────────────
class _ReceiptStackIllo extends StatelessWidget {
  const _ReceiptStackIllo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Back receipt — rotated right
          Positioned(
            left: 20,
            top: 20,
            child: Transform.rotate(
              angle: 8 * pi / 180,
              child: _ReceiptCard(
                merchant: 'Migros',
                tint: const Color(0xFF10B981),
                icon: Icons.shopping_cart_outlined,
                amount: '₺234,80',
              ),
            ),
          ),
          // Front receipt — rotated left
          Positioned(
            left: 60,
            top: 30,
            child: Transform.rotate(
              angle: -6 * pi / 180,
              child: _ReceiptCard(
                merchant: 'Lunapark',
                tint: const Color(0xFF8B5CF6),
                icon: Icons.movie_outlined,
                amount: '₺500,00',
              ),
            ),
          ),
          // AI sparkle badge
          Positioned(
            right: 8,
            top: 0,
            child: Transform.rotate(
              angle: 8 * pi / 180,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final String merchant;
  final Color tint;
  final IconData icon;
  final String amount;

  const _ReceiptCard({
    required this.merchant,
    required this.tint,
    required this.icon,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 220,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            merchant,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.colors.textMid,
            ),
          ),
          Text(
            amount,
            style: AppTypography.titleLg.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          ...([0.6, 0.85, 0.45, 0.7].map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: 6,
                width: 148 * w,
                decoration: BoxDecoration(
                  color: context.colors.outline,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Illustration 2: Scan ─────────────────────────────────────────
class _ScanIllo extends StatelessWidget {
  const _ScanIllo();

  @override
  Widget build(BuildContext context) {
    final items = [
      (copyForLocale(context, en: 'Milk 1L', tr: 'Süt 1L'), '₺28,50'),
      (copyForLocale(context, en: 'Bread', tr: 'Ekmek'), '₺12,00'),
      (copyForLocale(context, en: 'Chocolate', tr: 'Çikolata'), '₺45,00'),
      (copyForLocale(context, en: 'Tomatoes', tr: 'Domates'), '₺18,75'),
    ];

    return SizedBox(
      width: 280,
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Receipt card
          Positioned(
            left: 55,
            top: 10,
            child: Container(
              width: 170,
              height: 230,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.outline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BİM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: context.colors.textMid,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '15.05.2026 · 18:32',
                    style: TextStyle(fontSize: 9, color: context.colors.textLo),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: context.colors.outline),
                  ),
                  ...items.map(
                    (it) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.ok,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                it.$1,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.textHi,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            it.$2,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textHi,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Divider(height: 1, color: context.colors.outline),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Toplam',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textHi,
                        ),
                      ),
                      Text(
                        '₺104,25',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textHi,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Scan line
          Positioned(
            left: 45,
            top: 148,
            child: Container(
              width: 190,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primary,
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),

          // Corner markers
          ..._cornerPositions.map(
            (c) => Positioned(
              left: c.$1,
              top: c.$2,
              child: CustomPaint(
                size: const Size(18, 18),
                painter: _CornerPainter(isTop: c.$3, isLeft: c.$4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _cornerPositions = [
    (35.0, 2.0, true, true),
    (228.0, 2.0, true, false),
    (35.0, 240.0, false, true),
    (228.0, 240.0, false, false),
  ];
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  const _CornerPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    if (isLeft && isTop) {
      canvas.drawLine(Offset(2, h * 0.7), const Offset(2, 2), paint);
      canvas.drawLine(const Offset(2, 2), Offset(w * 0.7, 2), paint);
    } else if (!isLeft && isTop) {
      canvas.drawLine(Offset(w - 2, h * 0.7), Offset(w - 2, 2), paint);
      canvas.drawLine(Offset(w - 2, 2), Offset(w * 0.3, 2), paint);
    } else if (isLeft && !isTop) {
      canvas.drawLine(Offset(2, h * 0.3), Offset(2, h - 2), paint);
      canvas.drawLine(Offset(2, h - 2), Offset(w * 0.7, h - 2), paint);
    } else {
      canvas.drawLine(Offset(w - 2, h * 0.3), Offset(w - 2, h - 2), paint);
      canvas.drawLine(Offset(w - 2, h - 2), Offset(w * 0.3, h - 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Illustration 3: Budget ────────────────────────────────────────
class _BudgetIllo extends StatelessWidget {
  const _BudgetIllo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Budget card
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.colors.outline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.ok.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: AppColors.ok,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Market',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textHi,
                              ),
                            ),
                            Text(
                              '₺2.400 / ₺3.000',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.colors.textMid,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '80%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ok,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: 0.8,
                      minHeight: 6,
                      backgroundColor: AppColors.ok.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.ok),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Subscription card
          Positioned(
            left: 14,
            top: 108,
            right: 14,
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.colors.outline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'N',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Netflix',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textHi,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warn.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                copyForLocale(
                                  context,
                                  en: '2 days',
                                  tr: '2 gün',
                                ),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warn,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${periodLabel(context, 'monthly')} · 17.05',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₺149,99',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textHi,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bell badge
          Positioned(
            right: -2,
            bottom: -4,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
