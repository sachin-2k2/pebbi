import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/storage/token_storage.dart';
import 'onboarding_flow_provider.dart';
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
/// and resolves the destination route without artificial lag or network blocking.
///
/// Follows Rules 1, 2, 7, 8, 9:
/// - Decides signed-in status ONLY from local secure storage.
/// - Fresh install guard: clears leftover Keychain tokens if first_run_done is missing.
/// - Signed in -> /path (online or offline).
/// - Not signed in -> /onboarding/setup/step-$N if draft exists, else /welcome.
/// - Measures and logs startup execution time without leaking private tokens or IDs.
final appStartupProvider = FutureProvider<String>((ref) async {
  final stopwatch = Stopwatch()..start();

  final prefs = await ref.watch(nonUserSharedPreferencesProvider.future);
  final shouldShowArt = await ref.watch(splashShouldShowArtProvider.future);
  final tokenStorage = ref.watch(tokenStorageProvider);

  // 1. Fresh install guard (Rule 7): iOS keeps secure storage after uninstall
  final isFirstRunDone = prefs.getBool('first_run_done') ?? false;
  if (!isFirstRunDone) {
    await tokenStorage.clearAll();
    await prefs.setBool('first_run_done', true);
  }

  // 2. Decide signed-in status ONLY from local secure storage (Rule 1)
  final session = await tokenStorage.getActiveSession();
  final isSignedIn = session != null && session.token.isNotEmpty && session.userId.isNotEmpty;

  // Persist that splash art has been displayed
  if (shouldShowArt) {
    await prefs.setBool(SplashConfig.hasSeenSplashArtPrefKey, true);
  }

  // 3. Resolve target route (Rule 2)
  final String targetRoute;
  if (isSignedIn) {
    targetRoute = '/path';
  } else {
    final draftStorage = ref.read(onboardingDraftStorageProvider);
    final draft = await draftStorage.load();
    if (draft != null && draft.currentStep > 1 && draft.currentStep <= 11) {
      targetRoute = '/onboarding/setup/step-${draft.currentStep}';
    } else {
      targetRoute = '/welcome';
    }
  }

  stopwatch.stop();
  if (kDebugMode) {
    debugPrint(
      '[STARTUP_TIMING] Route decision resolved in ${stopwatch.elapsedMilliseconds}ms -> $targetRoute',
    );
  }

  return targetRoute;
});
