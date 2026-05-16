import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        title: Text('Şifremi Unuttum', style: AppTypography.titleLg),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.lg + 4),
                ),
                child: const Center(
                  child: Icon(
                    Icons.mail_lock_outlined,
                    size: 32,
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Şifre sıfırlama',
                style: AppTypography.displaySm
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                'E-posta ile şifre sıfırlama özelliği yakında eklenecek.',
                style: AppTypography.bodyLg.copyWith(color: context.colors.textMid),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md + 2),
                  border: Border.all(color: context.colors.outlineSoft),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 18, color: context.colors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hesabına erişemiyorsan Ayarlar › Geri Bildirim ekranından bize ulaşabilirsin, yardımcı oluruz.',
                        style: AppTypography.bodyMd.copyWith(
                            color: context.colors.textMid, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Girişe dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
