import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/back_link.dart';
import '../../../../../core/design_system/notice_banner.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../../settings/presentation/providers/app_settings_provider.dart';
import '../../../domain/mission_brief.dart';
import '../../../domain/mission_mode.dart';
import '../../providers/mission_brief_provider.dart';
import '../../screens/mission_brief_actions.dart';
import 'brief_header.dart';
import 'brief_info_chips.dart';
import 'brief_safety_notice.dart';
import 'captions_row.dart';
import 'goal_list.dart';
import 'hear_goals_button.dart';
import 'option_groups_row.dart';
import 'scene_line.dart';
import 'start_mission_button.dart';

/// Scrollable body for the Mission Brief screen.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4 (responsive layout).
class MissionBriefBody extends ConsumerWidget {
  const MissionBriefBody({
    super.key,
    required this.brief,
    required this.state,
    required this.notifier,
    required this.isOffline,
  });

  final MissionBrief brief;
  final MissionBriefState state;
  final MissionBriefNotifier notifier;
  final bool isOffline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final captionsOn = ref.watch(
      appSettingsProvider.select((s) => s.captionsAlwaysOn),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: BackLink(label: AppStrings.missionsLink),
          ),
          if (isOffline) ...[
            const SizedBox(height: AppSpacing.xs),
            NoticeBanner(
              message: AppStrings.offlineBannerNotice,
              icon: Icon(
                Icons.wifi_off_rounded,
                color: palette.warningText,
                size: 20.0,
              ),
            ),
          ],
          if (state.transientMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            NoticeBanner(
              message: state.transientMessage!,
              tone: NoticeBannerTone.warning,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          BriefHeader(
            emoji: brief.emoji,
            title: brief.title,
            characterName: brief.characterName,
            characterRole: brief.characterRole,
          ),
          if (brief.sceneLine != null && brief.sceneLine!.isNotEmpty)
            const SizedBox(height: AppSpacing.md),
          SceneLine(sceneLine: brief.sceneLine),
          const SizedBox(height: AppSpacing.lg),
          GoalList(goals: brief.goals),
          const SizedBox(height: AppSpacing.lg),
          OptionGroupsRow(
            selectedMode: state.selectedMode,
            onModeChanged: notifier.selectMode,
            selectedSupport: state.selectedSupport,
            onSupportChanged: notifier.selectSupport,
            isVoiceAvailable: state.isVoiceAvailable,
            voiceDisabledReason: state.voiceDisabledReason,
            onVoiceDisabledTap: () => notifier.selectMode(MissionMode.voice),
          ),
          const SizedBox(height: AppSpacing.md),
          BriefInfoChips(
            brief: brief,
            targetLanguageName: state.targetLanguageName,
            isSuggestedRepliesOn: state.isSuggestedRepliesOn,
          ),
          const SizedBox(height: AppSpacing.md),
          const BriefSafetyNotice(),
          const SizedBox(height: AppSpacing.lg),
          StartMissionButton(
            isStarting: state.isStarting,
            isCompleted: brief.isCompleted,
            onPressed: () =>
                MissionBriefActions.handleStart(context, ref, notifier),
          ),
          const SizedBox(height: AppSpacing.sm),
          HearGoalsButton(
            isPlaying: state.isPlayingAudio,
            onPressed: notifier.toggleHearGoals,
          ),
          const SizedBox(height: AppSpacing.md),
          CaptionsRow(captionsOn: captionsOn),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
