import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:peddi/core/design_system/button_3d.dart';
import 'package:peddi/core/theme/app_colors.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/providers/path_ready_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/path_ready_step_actions.dart';
import 'package:peddi/features/onboarding/presentation/widgets/path_ready/path_ready_body.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_bottom_bar.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_scaffold.dart';
import 'package:peddi/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:peddi/l10n/app_strings.dart';

/// Onboarding Setup Step 11 of 11: Path Ready ("Your path is ready").
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// thin composition-only screen, delegated action handlers.
class PathReadyStepScreen extends ConsumerStatefulWidget {
  const PathReadyStepScreen({super.key});

  @override
  ConsumerState<PathReadyStepScreen> createState() =>
      _PathReadyStepScreenState();
}

class _PathReadyStepScreenState extends ConsumerState<PathReadyStepScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccessGuard();
    });
  }

  void _checkAccessGuard() {
    final onboarding = ref.read(onboardingFlowProvider);
    // Guarantees this step is only accessed after Step 10's "Start free" action
    if (onboarding.selectedPlan != 'free' || onboarding.currentStep < 11) {
      if (mounted) {
        context.go('/onboarding/setup/step-10');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final readyState = ref.watch(pathReadyProvider);
    final reduceMotion = ref.watch(
      appSettingsProvider.select((s) => s.reduceMotion),
    );

    final canStart = readyState.canStartLesson;
    final lessonNumber = readyState.firstLessonInfo.lessonNumber;

    return StepScaffold(
      showSkip: false,
      header: null, // Header & back button hidden per design screenshot
      body: PathReadyBody(
        state: readyState,
        reduceMotion: reduceMotion,
        onRetry: () => PathReadyStepActions.onRetry(ref),
      ),
      bottomBar: StepBottomBar(
        button: Button3D(
          label: AppStrings.startLessonAction(lessonNumber),
          backgroundColor: canStart ? AppColors.mint : AppColors.disabled,
          depthColor: canStart ? AppColors.mintDepth : AppColors.disabledDepth,
          textColor: canStart ? Colors.white : AppColors.disabledText,
          isFullWidth: true,
          onPressed: canStart
              ? () => PathReadyStepActions.onStartLesson(
                  context: context,
                  ref: ref,
                  lessonInfo: readyState.firstLessonInfo,
                )
              : null,
        ),
      ),
    );
  }
}
