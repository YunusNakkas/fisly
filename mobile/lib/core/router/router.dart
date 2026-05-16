import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/onboarding/onboarding_provider.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/subscriptions/presentation/subscriptions_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/settings/presentation/feedback_screen.dart';
import '../../features/settings/presentation/password_change_screen.dart';
import '../../features/receipts/presentation/scan_screen.dart';
import '../../features/budgets/presentation/budgets_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../shared/main_shell.dart';

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

const _anonPaths = {'/login', '/register', '/forgot-password'};

final routerProvider = Provider<GoRouter>((ref) {
  // Single change counter — increments whenever auth or onboarding state changes.
  final notifier = ValueNotifier<int>(0);
  ref.listen<AuthStatus>(authProvider, (_, __) => notifier.value++);
  ref.listen<bool?>(onboardingProvider, (_, __) => notifier.value++);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final onboarding = ref.read(onboardingProvider);
      final loc = state.matchedLocation;

      // Auth still bootstrapping
      if (auth == AuthStatus.unknown || onboarding == null) {
        return loc == '/splash' ? null : '/splash';
      }

      // Anonymous users: only auth pages are allowed
      if (auth == AuthStatus.anonymous) {
        return _anonPaths.contains(loc) ? null : '/login';
      }

      // Authenticated: show onboarding once
      if (!onboarding) {
        return loc == '/onboarding' ? null : '/onboarding';
      }

      // Authenticated + onboarding done: send away from public/splash pages
      if (loc == '/splash' || _anonPaths.contains(loc) || loc == '/onboarding') {
        return '/expenses';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),
      ShellRoute(
        builder: (_, state, child) => MainShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/expenses', builder: (_, __) => const ExpensesScreen()),
          GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
          GoRoute(path: '/subscriptions', builder: (_, __) => const SubscriptionsScreen()),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
            routes: [
              GoRoute(path: 'profile', builder: (_, __) => const ProfileScreen()),
              GoRoute(path: 'feedback', builder: (_, __) => const FeedbackScreen()),
              GoRoute(path: 'password', builder: (_, __) => const PasswordChangeScreen()),
              GoRoute(path: 'budgets', builder: (_, __) => const BudgetsScreen()),
              GoRoute(path: 'categories', builder: (_, __) => const CategoriesScreen()),
            ],
          ),
        ],
      ),
    ],
  );
});
