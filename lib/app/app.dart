import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import '../features/settings/domain/text_size_rules.dart';
import '../features/settings/presentation/providers/app_settings_provider.dart';
import 'router.dart';

/// Root application widget for Pebbi with lifecycle observation for draft flushing.
///
/// Follows AGENTS.md §2 (MaterialApp wiring), §4 (edge-to-edge system UI, scaling).
class PebbiApp extends ConsumerStatefulWidget {
  const PebbiApp({super.key});

  @override
  ConsumerState<PebbiApp> createState() => _PebbiAppState();
}

class _PebbiAppState extends ConsumerState<PebbiApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      ref.read(onboardingFlowProvider.notifier).flushDraft();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = ref.watch(accentColorProvider);
    final themeMode = ref.watch(themeModeProvider);
    final inAppScale = ref.watch(textScaleProvider);

    return MaterialApp.router(
      title: 'Tutotoco',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accentColor),
      darkTheme: AppTheme.dark(accentColor),
      themeMode: themeMode,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final mediaQuery = MediaQuery.of(context);
        final systemFactor = mediaQuery.textScaler.scale(1.0);
        final combinedScale = TextSizeRules.clampCombinedScale(
          systemScale: systemFactor,
          inAppScale: inAppScale,
        );

        final systemUiOverlay = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemUiOverlay,
          child: MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(combinedScale),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      routerConfig: appRouter,
    );
  }
}
