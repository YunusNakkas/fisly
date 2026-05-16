import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../onboarding_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      icon: Icons.document_scanner_outlined,
      iconColor: AppColors.primary,
      iconBg: Color(0xFF3D3D8F),
      title: 'Fişini tara,\nharcamanı kaydet',
      description:
          'Kameranla fişi çek — Fişly tutarı, marketi ve kategoriyi otomatik algılar. Manuel giriş yok.',
    ),
    _Slide(
      icon: Icons.pie_chart_outline_rounded,
      iconColor: Color(0xFF10B981),
      iconBg: Color(0xFF0D5C42),
      title: 'Kategorilere\ngöre takip et',
      description:
          'Her harcaman doğru kategoriye gider. Market, ulaşım, faturalar — aylık dağılımını anlık gör.',
    ),
    _Slide(
      icon: Icons.shield_outlined,
      iconColor: Color(0xFFF59E0B),
      iconBg: Color(0xFF5C3D0D),
      title: 'Bütçeni\nkontrol altında tut',
      description:
          'Kategori bazlı veya genel aylık limitler koy. Aşmadan önce uyar, ay sonunda sürpriz olmasın.',
    ),
  ];

  void _next() {
    if (_page < _slides.length - 1) {
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
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: logo + skip ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  _FislyLogo(),
                  const Spacer(),
                  if (!isLast)
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Atla',
                        style: AppTypography.bodyMd
                            .copyWith(color: AppColors.textLo),
                      ),
                    ),
                ],
              ),
            ),

            // ── PageView slides ───────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),

            // ── Dots + button ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  _PageDots(count: _slides.length, current: _page),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(isLast ? 'Başla' : 'Devam'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Slide data ───────────────────────────────────────────────────
class _Slide {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;

  const _Slide({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
  });
}

// ─── Slide view ───────────────────────────────────────────────────
class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Illustration area
          Expanded(
            flex: 5,
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF16161E),
                  borderRadius: BorderRadius.circular(AppRadius.xl + 8),
                ),
                child: Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: slide.iconBg,
                      borderRadius: BorderRadius.circular(AppRadius.lg + 4),
                    ),
                    child: Icon(slide.icon, color: slide.iconColor, size: 48),
                  ),
                ),
              ),
            ),
          ),
          // Text content
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  slide.title,
                  style: AppTypography.displaySm
                      .copyWith(fontWeight: FontWeight.w700, height: 1.2),
                ),
                const SizedBox(height: 14),
                Text(
                  slide.description,
                  style: AppTypography.bodyLg.copyWith(
                      color: AppColors.textMid, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page dots ────────────────────────────────────────────────────
class _PageDots extends StatelessWidget {
  final int count;
  final int current;
  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.outline,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        );
      }),
    );
  }
}

// ─── Fişly logo mark ─────────────────────────────────────────────
class _FislyLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDim],
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm + 2),
          ),
          child: const Center(
            child: Text(
              'F',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Fişly',
          style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
