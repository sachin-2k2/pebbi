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
import '../features/lesson/presentation/screens/lesson_placeholder_screen.dart';
import '../features/premium/presentation/screens/premium_screen.dart';
import '../features/onboarding/presentation/screens/language_step_screen.dart';
import '../features/onboarding/presentation/screens/learn_language_step_screen.dart';
import '../features/lesson/presentation/screens/exercise_screen.dart';
import '../features/onboarding/presentation/screens/placement_result_screen.dart';
import '../features/onboarding/presentation/screens/placement_intro_screen.dart';
import '../features/onboarding/presentation/screens/reason_step_screen.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/review/presentation/screens/review_screen.dart';
import '../features/rewards/presentation/screens/rewards_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/missions/presentation/screens/mission_brief_placeholder_screen.dart';
import '../features/emergency/presentation/screens/emergency_screen.dart';
import '../features/missions/presentation/screens/free_talk_placeholder_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNav',
);

/// Application router with responsive [AdaptiveShell] bottom tab & rail branches.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
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
      builder: (context, state) => const ExerciseScreen(),
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
      builder: (context, state) => LessonPlaceholderScreen(
        lessonNumber: int.tryParse(state.pathParameters['id'] ?? '1') ?? 1,
      ),
    ),
    GoRoute(
      path: '/premium/options',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final returnTo = state.uri.queryParameters['returnTo'];
        return LoginScreen(returnTo: returnTo);
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
      path: '/forgot-password',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'];
        return ForgotPasswordScreen(initialEmail: email);
      },
    ),
    GoRoute(
      path: '/missions/brief/:id',
      builder: (context, state) => MissionBriefPlaceholderScreen(
        missionId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/missions/emergency-phrasebook',
      builder: (context, state) => const EmergencyScreen(),
    ),
    GoRoute(
      path: '/missions/free-talk',
      builder: (context, state) => const FreeTalkPlaceholderScreen(),
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
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
