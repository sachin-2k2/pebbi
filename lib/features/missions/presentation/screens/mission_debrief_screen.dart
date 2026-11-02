import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/services/audio_feedback_service.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/debrief_ref.dart';
import '../widgets/debrief/debrief_goals_card.dart';
import '../widgets/debrief/debrief_hero.dart';
import '../widgets/debrief/debrief_rewards_row.dart';

/// Screen celebrating mission completion with celebration hero, rewards, and goals recap.
///
/// Follows AGENTS.md §3 (< 100 lines target) & §4 (responsive layout).
class MissionDebriefScreen extends ConsumerStatefulWidget {
  const MissionDebriefScreen({super.key, this.debriefRef});

  final DebriefRef? debriefRef;

  @override
  ConsumerState<MissionDebriefScreen> createState() => _MissionDebriefScreenState();
}

class _MissionDebriefScreenState extends ConsumerState<MissionDebriefScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(audioFeedbackServiceProvider).playSuccess();
      }
    });
  }

  void _onDone() {
    if (context.mounted) {
      if (GoRouter.maybeOf(context) != null) {
        context.go('/missions');
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final debrief = widget.debriefRef;

    final turns = debrief?.turnsCount ?? 3;
    final completedCount = debrief?.completedGoalIds.length ?? 3;
    final totalCount = debrief?.totalGoals ?? 3;
    final stars = debrief?.starsEarned ?? 25;
    final partner = debrief?.characterName ?? 'Lucía';
    final goals = debrief?.completedGoalTexts ?? const [];
    final missionId = debrief?.missionId ?? 'order-a-coffee';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onDone();
      },
      child: Scaffold(
        backgroundColor: palette.background,
        body: SafeArea(
          child: ContentWidthLimiter(
            maxWidth: 580.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          DebriefHero(characterName: partner),
                          const SizedBox(height: AppSpacing.xl),
                          DebriefRewardsRow(
                            starsEarned: stars,
                            completedGoalsCount: completedCount,
                            totalGoalsCount: totalCount,
                            turnsCount: turns,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          DebriefGoalsCard(goalTexts: goals, missionId: missionId),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                  Button3D(
                    label: 'Return to Missions',
                    backgroundColor: palette.brand,
                    depthColor: palette.brandDepth,
                    textColor: palette.textOnBrand,
                    onPressed: _onDone,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Backwards-compatible alias for existing router references.
typedef MissionDebriefPlaceholderScreen = MissionDebriefScreen;

