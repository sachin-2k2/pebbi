import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../providers/app_startup_provider.dart';
import '../widgets/splash/splash_config.dart';
import '../widgets/splash/splash_content.dart';
import '../widgets/splash/splash_timeout_view.dart';

/// Full-screen cold start splash screen for Pebbi.
///
/// Follows AGENTS.md §2 (providers, routing), §3 (< 150 lines), §4 (responsive),
/// and User Rules 1–8:
/// - First-frame anchored display time (no premature exit on slow JIT).
/// - Dynamically derived exit (startup + entrance completed + hold elapsed).
/// - Non-zero short display time (300ms) for reduceMotion and art-off to prevent flicker.
/// - Hard limit safety timeout (8s) with Retry & Guest bypass.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _dashesCtrl;

  Timer? _accessibilityTimer;
  Timer? _safetyTimeoutTimer;
  Timer? _holdTimer;
  Timer? _shortDisplayTimer;

  bool _firstFrameDrawn = false;
  bool _holdElapsed = false;
  bool _shortTimeElapsed = false;
  bool _hasTimedOut = false;
  bool _navigated = false;
  bool _showArt = true;
  bool _reduceMotion = false;
  String? _targetRoute;

  @override
  void initState() {
    super.initState();
    if (!kReleaseMode && SplashConfig.enableSplashTimingLogs) {
      debugPrint(
        '[SPLASH_TIMING] SplashScreen initState at ${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: SplashConfig.entranceDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (!kReleaseMode && SplashConfig.enableSplashTimingLogs) {
            debugPrint(
              '[SPLASH_TIMING] Entrance animation COMPLETED at ${DateTime.now().millisecondsSinceEpoch}',
            );
          }
          _startHoldTimer();
        }
      });

    _dashesCtrl = AnimationController(
      vsync: this,
      duration: SplashConfig.dashCycleDuration,
    );

    _accessibilityTimer = Timer(
      SplashConfig.accessibilityAnnouncementDelay,
      () {
        if (mounted) {
          SemanticsService.sendAnnouncement(
            View.of(context),
            'Starting Pebbi',
            TextDirection.ltr,
          );
        }
      },
    );

    _startSafetyTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onFirstFrameDrawn();
    });
  }

  void _onFirstFrameDrawn() {
    _firstFrameDrawn = true;
    if (!kReleaseMode && SplashConfig.enableSplashTimingLogs) {
      debugPrint(
        '[SPLASH_TIMING] First frame drawn at ${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    _entranceCtrl.forward();
    _dashesCtrl.repeat();

    _shortDisplayTimer = Timer(SplashConfig.minDisplayTimeShort, () {
      if (!mounted) return;
      if (!kReleaseMode && SplashConfig.enableSplashTimingLogs) {
        debugPrint(
          '[SPLASH_TIMING] Short display timer (300ms) elapsed at ${DateTime.now().millisecondsSinceEpoch}',
        );
      }
      _shortTimeElapsed = true;
      _checkReadyToNavigate();
    });
  }

  void _startHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = Timer(SplashConfig.holdDurationWithArt, () {
      if (!mounted) return;
      if (!kReleaseMode && SplashConfig.enableSplashTimingLogs) {
        debugPrint(
          '[SPLASH_TIMING] Hold timer (300ms) elapsed at ${DateTime.now().millisecondsSinceEpoch}',
        );
      }
      _holdElapsed = true;
      _checkReadyToNavigate();
    });
  }

  void _startSafetyTimer() {
    _safetyTimeoutTimer?.cancel();
    _safetyTimeoutTimer = Timer(SplashConfig.startupTimeout, () {
      if (!mounted || _targetRoute != null || _navigated) return;
      setState(() => _hasTimedOut = true);
    });
  }

  void _checkReadyToNavigate() {
    if (_navigated || !mounted || _targetRoute == null || !_firstFrameDrawn) {
      return;
    }

    if (_showArt && !_reduceMotion) {
      if (!_entranceCtrl.isCompleted || !_holdElapsed) return;
    } else {
      if (!_shortTimeElapsed) return;
    }

    _navigated = true;
    _onStartupDone(_targetRoute!);
  }

  void _onStartupDone(String route) {
    if (!mounted) return;
    if (!kReleaseMode && SplashConfig.enableSplashTimingLogs) {
      debugPrint(
        '[SPLASH_TIMING] Navigation to $route START at ${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    ref.read(splashCompletedProvider.notifier).state = true;
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go(route);
    }
  }

  @override
  void dispose() {
    _accessibilityTimer?.cancel();
    _safetyTimeoutTimer?.cancel();
    _holdTimer?.cancel();
    _shortDisplayTimer?.cancel();
    _entranceCtrl.dispose();
    _dashesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = ref.watch(reduceMotionProvider) ||
        MediaQuery.of(context).disableAnimations;
    final showArt = ref.watch(splashShouldShowArtProvider).value ?? true;
    _reduceMotion = reduceMotion;
    _showArt = showArt;
    final startupAsync = ref.watch(appStartupProvider);

    if (kDebugMode && SplashConfig.enableSplashTimingLogs) {
      final systemNoAnim = WidgetsBinding
          .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
      if (systemNoAnim && !reduceMotion) {
        debugPrint('[SPLASH] System animations disabled (animator_duration_scale=0)');
      }
    }

    ref.listen<AsyncValue<String>>(appStartupProvider, (prev, next) {
      next.whenData((route) {
        _targetRoute = route;
        _checkReadyToNavigate();
      });
    });

    if (startupAsync is AsyncData<String>) {
      _targetRoute = startupAsync.value;
      if (_firstFrameDrawn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkReadyToNavigate();
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _entranceCtrl,
              builder: (context, _) {
                final t = reduceMotion ? 1.0 : _entranceCtrl.value;

                return SplashContent(
                  gradientOpacity: (t / SplashAnimationConfig.gradientFadeEnd)
                      .clamp(0.0, 1.0),
                  wordmarkOpacity: ((t - SplashAnimationConfig.wordmarkFadeStart) /
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
                  dashesOpacity: (t / SplashAnimationConfig.dashesFadeEnd)
                      .clamp(0.0, 1.0),
                  dashAnimation: _dashesCtrl,
                  driftOffset: Offset(0, (1.0 - t) * 4.0),
                  showArt: showArt,
                  reduceMotion: reduceMotion,
                );
              },
            ),
            if (_hasTimedOut && _targetRoute == null)
              SplashTimeoutView(
                onRetry: () {
                  setState(() => _hasTimedOut = false);
                  _startSafetyTimer();
                  ref.invalidate(appStartupProvider);
                },
                onContinueGuest: () => _onStartupDone('/welcome'),
              ),
          ],
        ),
      ),
    );
  }
}
