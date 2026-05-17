import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/config/env.dart';
import 'core/locale/locale_provider.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/notification_service.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();

  final dsn = Env.sentryDsn;
  if (dsn.isNotEmpty) {
    await SentryFlutter.init((options) {
      options.dsn = dsn;
      options.tracesSampleRate = 0.1;
      options.environment = Env.environment;
    }, appRunner: () => runApp(const ProviderScope(child: FislyApp())));
  } else {
    runApp(const ProviderScope(child: FislyApp()));
  }
}

class FislyApp extends ConsumerWidget {
  const FislyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'Fişly',
      theme: buildFislyTheme(),
      darkTheme: buildFislyDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
    );
  }
}
