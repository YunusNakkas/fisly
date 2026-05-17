import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/onboarding/onboarding_provider.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/subscriptions/presentation/subscriptions_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/settings/presentation/feedback_screen.dart';
import '../../features/settings/presentation/password_change_screen.dart';
import '../../features/receipts/presentation/scan_screen.dart';
import '../../features/receipts/presentation/receipt_history_screen.dart';
import '../../features/receipts/presentation/receipt_detail_screen.dart';
import '../../features/budgets/presentation/budgets_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../shared/main_shell.dart';

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

const _anonPaths = {
  '/login',
  '/register',
  '/forgot-password',
  '/reset-password',
};

final routerProvider = Provider<GoRouter>((ref) {
  // Single change counter — increments whenever auth or onboarding state changes.
  final notifier = ValueNotifier<int>(0);
  ref.listen<AuthStatus>(authProvider, (_, _) => notifier.value++);
  ref.listen<bool?>(onboardingProvider, (_, _) => notifier.value++);
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
      if (loc == '/splash' ||
          _anonPaths.contains(loc) ||
          loc == '/onboarding') {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, _) => const ResetPasswordScreen(),
      ),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/scan', builder: (_, _) => const ScanScreen()),
      ShellRoute(
        builder: (_, state, child) =>
            MainShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(path: '/expenses', builder: (_, _) => const ExpensesScreen()),
          GoRoute(path: '/reports', builder: (_, _) => const ReportsScreen()),
          GoRoute(
            path: '/subscriptions',
            builder: (_, _) => const SubscriptionsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (_, _) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (_, _) => const ProfileScreen(),
              ),
              GoRoute(
                path: 'feedback',
                builder: (_, _) => const FeedbackScreen(),
              ),
              GoRoute(
                path: 'password',
                builder: (_, _) => const PasswordChangeScreen(),
              ),
              GoRoute(
                path: 'budgets',
                builder: (_, _) => const BudgetsScreen(),
              ),
              GoRoute(
                path: 'categories',
                builder: (_, _) => const CategoriesScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/receipts',
            builder: (_, _) => const ReceiptHistoryScreen(),
          ),
          GoRoute(
            path: '/receipts/:id',
            builder: (_, state) =>
                ReceiptDetailScreen(receiptId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
