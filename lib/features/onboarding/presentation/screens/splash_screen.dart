import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../providers/app_startup_provider.dart';
import '../widgets/splash/splash_config.dart';
import '../widgets/splash/splash_content.dart';

/// Full-screen cold start splash screen for Pebbi.
///
/// Follows AGENTS.md §3 (< 100 lines), §4, and User Rules 1–7.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _loopCtrl;
  Timer? _accessibilityTimer;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: SplashConfig.entranceDuration,
    )..forward();

    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _accessibilityTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          'Starting Pebbi',
          TextDirection.ltr,
        );
      }
    });
  }

  @override
  void dispose() {
    _accessibilityTimer?.cancel();
    _entranceCtrl.dispose();
    _loopCtrl.dispose();
    super.dispose();
  }

  void _onStartupDone(String route) {
    if (!mounted) return;
    ref.read(splashCompletedProvider.notifier).state = true;
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = ref.watch(reduceMotionProvider);
    final showArt = ref.watch(splashShouldShowArtProvider).value ?? true;
    final startupAsync = ref.watch(appStartupProvider);

    ref.listen<AsyncValue<String>>(appStartupProvider, (prev, next) {
      next.whenData(_onStartupDone);
    });

    if (startupAsync is AsyncData<String>) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onStartupDone(startupAsync.value);
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: AnimatedBuilder(
          animation: Listenable.merge([_entranceCtrl, _loopCtrl]),
          builder: (context, _) {
            final t = reduceMotion ? 1.0 : _entranceCtrl.value;
            final loopT = _loopCtrl.value;
            final dashIndex = reduceMotion ? 1 : (loopT * 3).floor() % 3;
            final driftY = reduceMotion
                ? 0.0
                : (loopT < 0.5 ? loopT : 1.0 - loopT) * 4.0;

            return SplashContent(
              gradientOpacity: (t / SplashAnimationConfig.gradientFadeEnd)
                  .clamp(0.0, 1.0),
              wordmarkOpacity:
                  ((t - SplashAnimationConfig.wordmarkFadeStart) /
                          (SplashAnimationConfig.wordmarkFadeEnd -
                              SplashAnimationConfig.wordmarkFadeStart))
                      .clamp(0.0, 1.0),
              wordmarkSlide: (1.0 - t) * 8.0,
              decorationsOpacity:
                  ((t - SplashAnimationConfig.decorationsFadeStart) /
                          (SplashAnimationConfig.decorationsFadeEnd -
                              SplashAnimationConfig.decorationsFadeStart))
                      .clamp(0.0, 1.0),
              sparkleOpacity: t >= 0.6 ? 1.0 : 0.0,
              dashHighlightIndex: dashIndex,
              driftOffset: Offset(0, driftY),
              showArt: showArt,
            );
          },
        ),
      ),
    );
  }
}
