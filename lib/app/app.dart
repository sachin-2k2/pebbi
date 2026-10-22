import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/domain/text_size_rules.dart';
import '../features/settings/presentation/providers/app_settings_provider.dart';
import 'router.dart';

/// Root application widget for Pebbi.
class PebbiApp extends ConsumerWidget {
  const PebbiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentColor = ref.watch(accentColorProvider);
    final themeMode = ref.watch(themeModeProvider);
    final inAppScale = ref.watch(textScaleProvider);

    return MaterialApp.router(
      title: 'Pebbi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accentColor),
      darkTheme: AppTheme.dark(accentColor),
      themeMode: themeMode,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final systemFactor = mediaQuery.textScaler.scale(1.0);
        final combinedScale = TextSizeRules.clampCombinedScale(
          systemScale: systemFactor,
          inAppScale: inAppScale,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(combinedScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: appRouter,
    );
  }
}
