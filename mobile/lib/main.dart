import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: FislyApp()));
}

class FislyApp extends ConsumerWidget {
  const FislyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Fişly',
      theme: buildFislyTheme(),
      darkTheme: buildFislyDarkTheme(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
