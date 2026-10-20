import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/presentation/providers/app_settings_provider.dart';
import 'router.dart';

/// Root application widget for Pebbi.
class PebbiApp extends ConsumerWidget {
  const PebbiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentColor = ref.watch(accentColorProvider);

    return MaterialApp.router(
      title: 'Pebbi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accentColor),
      darkTheme: AppTheme.dark(accentColor),
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
