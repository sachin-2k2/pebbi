import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/layout/adaptive_shell.dart';
import '../features/missions/presentation/screens/missions_screen.dart';
import '../features/path/presentation/screens/path_screen.dart';
import '../features/onboarding/presentation/screens/age_step_screen.dart';
import '../features/onboarding/presentation/screens/goal_step_screen.dart';
import '../features/onboarding/presentation/screens/reminder_step_screen.dart';
import '../features/onboarding/presentation/screens/meet_pebbi_step_screen.dart';
import '../features/onboarding/presentation/screens/premium_offer_step_screen.dart';
import '../features/onboarding/presentation/screens/path_ready_step_screen.dart';
import '../features/lesson/presentation/screens/lesson_complete_screen.dart';
import '../features/premium/presentation/screens/premium_screen.dart';
import '../features/onboarding/presentation/screens/language_step_screen.dart';
import '../features/onboarding/presentation/screens/learn_language_step_screen.dart';
import '../features/lesson/presentation/screens/exercise_screen.dart';
import '../features/onboarding/presentation/screens/placement_result_screen.dart';
import '../features/onboarding/presentation/screens/placement_intro_screen.dart';
import '../features/onboarding/presentation/screens/placement_quiz_screen.dart';
import '../features/onboarding/presentation/screens/reason_step_screen.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';
import '../features/review/presentation/screens/review_screen.dart';
import '../features/rewards/presentation/screens/rewards_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/verify_otp_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/missions/domain/correction_style.dart';
import '../features/missions/domain/mission_mode.dart';
import '../features/missions/domain/mission_support.dart';
import '../features/missions/domain/session_config.dart';
import '../features/missions/presentation/screens/mission_brief_screen.dart';
import '../features/emergency/presentation/screens/emergency_screen.dart';
import '../features/missions/presentation/screens/free_talk_screen.dart';
import '../features/missions/domain/debrief_ref.dart';
import '../features/missions/presentation/screens/mission_session_screen.dart';
import '../features/missions/presentation/screens/mission_debrief_screen.dart';
import '../features/review/presentation/screens/note_detail_placeholder_screen.dart';
import '../features/review/presentation/screens/practice_placeholder_screen.dart';
import '../features/rewards/presentation/screens/sticker_book_placeholder_screen.dart';
import '../features/settings/presentation/screens/about_placeholder_screen.dart';
import '../features/settings/presentation/screens/help_placeholder_screen.dart';
import '../core/storage/token_storage.dart';
import '../features/settings/presentation/screens/privacy_placeholder_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNav',
);

/// Route redirect guard implementing Rule 6.
///
/// Follows Rule 6:
/// - signed in: opening welcome, onboarding, register, code or login redirects to Path.
///   Back must never return to those screens or to the splash.
/// - not signed in: Path, other tabs and any signed-in screen redirect to the welcome flow.
/// - after login or sign-up the user goes to Path and never back into onboarding.
String? appRouterRedirect({
  required String location,
  required bool isSignedIn,
  bool splashCompleted = true,
  String? draftResumeRoute,
}) {
  if (location == '/splash') {
    if (!splashCompleted) return null;
    return isSignedIn ? '/path' : (draftResumeRoute ?? '/welcome');
  }

  final isAuthOrOnboarding = location == '/welcome' ||
      location.startsWith('/onboarding') ||
      location == '/login' ||
      location == '/register' ||
      location == '/verify-otp' ||
      location == '/forgot-password';

  if (isSignedIn) {
    if (isAuthOrOnboarding) {
      return '/path';
    }
    return null;
  } else {
    if (!isAuthOrOnboarding) {
      return draftResumeRoute ?? '/welcome';
    }
    return null;
  }
}

bool _isAppSplashCompleted = false;

/// Whether the cold-start splash has finished for the current app process.
bool get isAppSplashCompleted => _isAppSplashCompleted;

/// Marks the splash as completed so route guards can redirect from /splash to /path or /welcome.
void markSplashCompleted() {
  _isAppSplashCompleted = true;
}

/// Resets the splash completion flag (e.g. for testing).
void resetSplashCompleted() {
  _isAppSplashCompleted = false;
}

/// Factory building the application [GoRouter] with Rule 6 redirect guard.
GoRouter createAppRouter({
  TokenStorage? tokenStorage,
  GlobalKey<NavigatorState>? navigatorKey,
  String initialLocation = '/splash',
  bool? overrideSignedIn,
  bool? splashCompleted,
  String? draftResumeRoute,
}) {
  final storage = tokenStorage ?? globalTokenStorage;

  return GoRouter(
    navigatorKey: navigatorKey ?? _rootNavigatorKey,
    initialLocation: initialLocation,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isSignedIn = overrideSignedIn ?? storage.isSignedIn;
      final effectiveSplashCompleted = splashCompleted ?? _isAppSplashCompleted;
      return appRouterRedirect(
        location: loc,
        isSignedIn: isSignedIn,
        splashCompleted: effectiveSplashCompleted,
        draftResumeRoute: draftResumeRoute,
      );
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/', redirect: (context, state) => '/path'),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
    GoRoute(
      path: '/onboarding/setup',
      redirect: (context, state) => '/onboarding/setup/step-2',
    ),
    GoRoute(
      path: '/onboarding/setup/step-2',
      builder: (context, state) => const AgeStepScreen(),
    ),
    GoRoute(
      path: '/onboarding/setup/step-3',
      builder: (context, state) => const LanguageStepScreen(),
    ),
    GoRoute(
      path: '/onboarding/setup/step-4',
      builder: (context, state) => const LearnLanguageStepScreen(),
    ),
    GoRoute(
      path: '/onboarding/setup/step-5',
      builder: (context, state) => const ReasonStepScreen(),
    ),
    GoRoute(
      path: '/onboarding/setup/step-6',
      builder: (context, state) => const PlacementIntroScreen(),
    ),
    GoRoute(
      path: '/onboarding/placement-quiz',
      builder: (context, state) => const PlacementQuizScreen(),
    ),
    GoRoute(
      path: '/onboarding/placement-results',
      builder: (context, state) => const PlacementResultScreen(),
    ),
    GoRoute(
      path: '/onboarding/setup/step-7',
      builder: (context, state) => const GoalStepScreen(),
    ),
    GoRoute(
      path: '/onboarding/setup/step-8',
      builder: (context, state) => const ReminderStepScreen(),
    ),
    GoRoute(
      path: '/onboarding/setup/step-9',
      builder: (context, state) => const MeetPebbiStepScreen(),
    ),
    GoRoute(
      path: '/onboarding/setup/step-10',
      builder: (context, state) => const PremiumOfferStepScreen(),
    ),
    GoRoute(
      path: '/onboarding/setup/step-11',
      builder: (context, state) => const PathReadyStepScreen(),
    ),
    GoRoute(
      path: '/lesson/:id',
      builder: (context, state) =>
          ExerciseScreen(stopId: state.pathParameters['id'] ?? '1'),
    ),
    GoRoute(
      path: '/lesson/:id/finish',
      builder: (context, state) =>
          LessonCompleteScreen(stopId: state.pathParameters['id'] ?? '1'),
    ),
    GoRoute(
      path: '/premium/options',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final returnTo = state.uri.queryParameters['returnTo'];
        final email = state.uri.queryParameters['email'];
        return LoginScreen(returnTo: returnTo, initialEmail: email);
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        final returnTo = state.uri.queryParameters['returnTo'];
        return RegisterScreen(returnTo: returnTo);
      },
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        final returnTo = state.uri.queryParameters['returnTo'];
        return VerifyOtpScreen(email: email, returnTo: returnTo);
      },
    ),

    GoRoute(
      path: '/forgot-password',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'];
        return ForgotPasswordScreen(initialEmail: email);
      },
    ),
    GoRoute(
      path: '/missions/brief/:id',
      builder: (context, state) =>
          MissionBriefScreen(missionId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/missions/emergency-phrasebook',
      builder: (context, state) => const EmergencyScreen(),
    ),
    GoRoute(
      path: '/missions/free-talk',
      builder: (context, state) => const FreeTalkScreen(),
    ),
    GoRoute(
      path: '/missions/session',
      builder: (context, state) {
        final topicId = state.uri.queryParameters['topicId'] ?? '';
        final style = state.uri.queryParameters['style'] ?? 'gentle';
        final config = state.extra as SessionConfig?;
        final isFreeTalk = topicId.isNotEmpty;
        final decodedTopic = isFreeTalk ? Uri.decodeComponent(topicId) : null;
        final effectiveConfig =
            config ??
            SessionConfig(
              missionId: isFreeTalk ? 'freetalk_$topicId' : 'order_coffee',
              mode: MissionMode.chat,
              support: MissionSupport.guided,
              correctionStyle: CorrectionStyle.fromId(style),
              captionsOn: true,
              targetLanguageCode: 'es',
              explanationLanguageCode: 'en',
              freeTalkTopic: decodedTopic,
            );
        return MissionSessionScreen(config: effectiveConfig);
      },
    ),
    GoRoute(
      path: '/missions/debrief',
      builder: (context, state) => MissionDebriefScreen(
        debriefRef: state.extra as DebriefRef?,
      ),
    ),
    GoRoute(
      path: '/review/practice',
      builder: (context, state) {
        final mode = state.uri.queryParameters['mode'] ?? 'mix2min';
        return PracticePlaceholderScreen(mode: mode);
      },
    ),
    GoRoute(
      path: '/review/note/:id',
      builder: (context, state) {
        final noteId = state.pathParameters['id'] ?? '';
        return NoteDetailPlaceholderScreen(noteId: noteId);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AdaptiveShell(
          currentIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          child: navigationShell,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/path',
              builder: (context, state) => const PathScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/missions',
              builder: (context, state) => const MissionsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/review',
              builder: (context, state) => const ReviewScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rewards',
              builder: (context, state) => const RewardsScreen(),
              routes: [
                GoRoute(
                  path: 'sticker-book',
                  builder: (context, state) =>
                      const StickerBookPlaceholderScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'privacy',
                  builder: (context, state) => const PrivacyPlaceholderScreen(),
                ),
                GoRoute(
                  path: 'help',
                  builder: (context, state) => const HelpPlaceholderScreen(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutPlaceholderScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
}

/// Global GoRouter application instance.
final GoRouter appRouter = createAppRouter();
