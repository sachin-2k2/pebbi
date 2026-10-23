import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/splash/splash_config.dart';

/// In-memory session flag: whether the cold-start splash has already completed.
///
/// Follows AGENTS.md §2.3 and User Rule 6:
/// - Initialized to `false` on cold start of the application process.
/// - Set to `true` once the splash screen completes and navigates.
/// - Preserved across background/resume, logout, login, locale, theme, or screen rotation.
final splashCompletedProvider = StateProvider<bool>((ref) => false);

/// Non-user shared preferences provider for global device/app settings.
final nonUserSharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

/// Whether the full decorative splash art should be displayed on this cold start.
///
/// Follows User Rule 7:
/// - Uses [SplashConfig.splashArtOnEveryLaunchDefault].
/// - When false, reads non-user SharedPreferences key [SplashConfig.hasSeenSplashArtPrefKey].
final splashShouldShowArtProvider = FutureProvider<bool>((ref) async {
  if (SplashConfig.splashArtOnEveryLaunchDefault) {
    return true;
  }
  final prefs = await ref.watch(nonUserSharedPreferencesProvider.future);
  final hasSeen = prefs.getBool(SplashConfig.hasSeenSplashArtPrefKey) ?? false;
  return !hasSeen;
});

/// Real application startup notifier that performs non-blocking initialization
/// and resolves the destination route without artificial lag.
///
/// Follows User Rules 4, 5, 6, 7:
/// - Initializes non-user prefs and checks user session state.
/// - Enforces minimum display time matching entrance animation (900ms) only when art is shown;
///   0ms when art is off.
/// - Marks hasSeenSplashArtPrefKey so subsequent cold starts skip art if config is false.
final appStartupProvider = FutureProvider<String>((ref) async {
  final stopwatch = Stopwatch()..start();

  final prefs = await ref.watch(nonUserSharedPreferencesProvider.future);
  final shouldShowArt = await ref.watch(splashShouldShowArtProvider.future);

  // Check user profile for routing destination
  final user = ref.read(currentUserProvider);

  // Persist that splash art has been displayed
  if (shouldShowArt) {
    await prefs.setBool(SplashConfig.hasSeenSplashArtPrefKey, true);
  }

  // Resolve target route
  final String targetRoute;
  if (user != null && user.targetLanguageCode.isNotEmpty) {
    targetRoute = '/path';
  } else {
    targetRoute = '/welcome';
  }

  // Enforce minimum time budget so entrance animation is not truncated mid-sequence
  final minTime = shouldShowArt
      ? SplashConfig.minDisplayTimeWithArt
      : SplashConfig.minDisplayTimeWithoutArt;

  final elapsed = stopwatch.elapsed;
  if (elapsed < minTime) {
    await Future.delayed(minTime - elapsed);
  }

  return targetRoute;
});
