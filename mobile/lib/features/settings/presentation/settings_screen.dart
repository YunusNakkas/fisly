import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_provider.dart';
import '../../auth/profile_provider.dart';
import '../../../shared/section_label.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/localized_copy.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(title: Text(t.navSettings, style: AppTypography.titleLg)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          const _ProfileCard(),
          const SizedBox(height: 18),
          SectionLabel(t.settingsAppearance),
          _ThemeModeCard(
            mode: themeMode,
            onChanged: (mode) =>
                ref.read(themeModeProvider.notifier).setMode(mode),
          ),
          const SizedBox(height: 10),
          _LanguageCard(
            current: locale,
            onChanged: (l) => ref.read(localeProvider.notifier).set(l),
          ),
          const SizedBox(height: 18),
          SectionLabel(t.settingsAccountSection),
          _SettingsCard(
            rows: [
              _SettingsRow(
                icon: Icons.person_outline,
                title: t.settingsProfile,
                subtitle: t.settingsProfileSubtitle,
                onTap: () => context.push('/settings/profile'),
              ),
              _SettingsRow(
                icon: Icons.lock_outline,
                title: t.settingsPasswordChange,
                onTap: () => context.push('/settings/password'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SectionLabel(t.settingsBudgetSection),
          _SettingsCard(
            rows: [
              _SettingsRow(
                icon: Icons.account_balance_wallet_outlined,
                title: t.settingsBudgets,
                subtitle: t.settingsBudgetsSubtitle,
                onTap: () => context.push('/settings/budgets'),
              ),
              _SettingsRow(
                icon: Icons.category_outlined,
                title: t.settingsCategories,
                subtitle: t.settingsCategoriesSubtitle,
                onTap: () => context.push('/settings/categories'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SectionLabel(t.settingsSupportSection),
          _SettingsCard(
            rows: [
              _SettingsRow(
                icon: Icons.feedback_outlined,
                title: t.settingsFeedback,
                subtitle: t.settingsFeedbackSubtitle,
                onTap: () => context.push('/settings/feedback'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _LogoutCard(onTap: () => _confirmLogout(context, ref)),
          const SizedBox(height: 20),
          const _VersionFooter(),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(t.actionLogout),
        content: Text(t.settingsLogoutQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(t.settingsLogoutDismiss),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              t.settingsLogoutAction,
              style: TextStyle(color: context.colors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    }
  }
}

// ─── Theme mode ────────────────────────────────────────────────────
class _ThemeModeCard extends StatelessWidget {
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeCard({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: ThemeMode.system,
            icon: const Icon(Icons.phone_iphone_rounded, size: 18),
            label: Text(AppLocalizations.of(context).settingsThemeSystem),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: const Icon(Icons.light_mode_rounded, size: 18),
            label: Text(AppLocalizations.of(context).settingsThemeLight),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: const Icon(Icons.dark_mode_rounded, size: 18),
            label: Text(AppLocalizations.of(context).settingsThemeDark),
          ),
        ],
        selected: {mode},
        onSelectionChanged: (selection) => onChanged(selection.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(AppTypography.labelXs),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return context.colors.onPrimaryContainer;
            }
            return context.colors.textMid;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return context.colors.primaryContainer;
            }
            return context.colors.surface;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.selected)
                ? context.colors.primary.withValues(alpha: 0.55)
                : context.colors.outline;
            return BorderSide(color: color);
          }),
        ),
      ),
    );
  }
}

// ─── Language card ─────────────────────────────────────────────────
class _LanguageCard extends StatelessWidget {
  final Locale current;
  final ValueChanged<Locale> onChanged;

  const _LanguageCard({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: 'tr',
            icon: const Text('🇹🇷', style: TextStyle(fontSize: 16)),
            label: Text(AppLocalizations.of(context).settingsLanguageTr),
          ),
          ButtonSegment(
            value: 'en',
            icon: const Text('🇬🇧', style: TextStyle(fontSize: 16)),
            label: Text(AppLocalizations.of(context).settingsLanguageEn),
          ),
        ],
        selected: {current.languageCode},
        onSelectionChanged: (selection) => onChanged(Locale(selection.first)),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(AppTypography.labelXs),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return context.colors.onPrimaryContainer;
            }
            return context.colors.textMid;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return context.colors.primaryContainer;
            }
            return context.colors.surface;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.selected)
                ? context.colors.primary.withValues(alpha: 0.55)
                : context.colors.outline;
            return BorderSide(color: color);
          }),
        ),
      ),
    );
  }
}

// ─── Profile card ──────────────────────────────────────────────────
class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profileProvider);

    return async.when(
      loading: () => _ProfileSkeleton(),
      error: (_, _) => const SizedBox(),
      data: (p) {
        final displayName =
            (p.fullName != null && p.fullName!.trim().isNotEmpty)
            ? p.fullName!
            : p.email.split('@').first;
        final initial = displayName.isNotEmpty
            ? displayName.substring(0, 1).toUpperCase()
            : '?';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg + 2),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [context.colors.primary, context.colors.primaryDim],
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTypography.titleMd,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.email,
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _PlanPill(plan: p.plan),
                        if (p.quotaLimit != null)
                          _QuotaPill(used: p.quotaUsed, limit: p.quotaLimit!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.outlineSoft,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 14,
                  decoration: BoxDecoration(
                    color: context.colors.outlineSoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 11,
                  decoration: BoxDecoration(
                    color: context.colors.outlineSoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanPill extends StatelessWidget {
  final String plan;
  const _PlanPill({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isPremium = plan.toLowerCase() == 'premium';
    final label = isPremium
        ? 'Pro'
        : copyForLocale(context, en: 'Free', tr: 'Ücretsiz');
    final bg = isPremium
        ? context.colors.primaryContainer
        : context.colors.surfaceContainer;
    final fg = isPremium
        ? context.colors.onPrimaryContainer
        : context.colors.textMid;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPremium)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.auto_awesome, size: 10, color: fg),
            ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotaPill extends StatelessWidget {
  final int used;
  final int limit;
  const _QuotaPill({required this.used, required this.limit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        copyForLocale(
          context,
          en: '$used / $limit scans',
          tr: '$used / $limit tarama',
        ),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: context.colors.textMid,
        ),
      ),
    );
  }
}

// ─── Settings card / row ───────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<_SettingsRow> rows;
  const _SettingsCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(height: 1, color: context.colors.outlineSoft),
              rows[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, size: 18, color: context.colors.textHi),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTypography.caption),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.textLo, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Logout card ───────────────────────────────────────────────────
class _LogoutCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.colors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 18,
                    color: context.colors.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).settingsLogoutAction,
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.danger,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Version footer ────────────────────────────────────────────────
class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        copyForLocale(
          context,
          en: 'Fisly v1.0.0 · Made in Istanbul',
          tr: 'Fişly v1.0.0 · İstanbul’dan sevgilerle',
        ),
        style: TextStyle(
          fontSize: 11,
          color: context.colors.textLo,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
