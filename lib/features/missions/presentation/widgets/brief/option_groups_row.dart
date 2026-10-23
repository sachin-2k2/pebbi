import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/mission_mode.dart';
import '../../../domain/mission_support.dart';
import 'option_group.dart';
import 'option_pill.dart';

/// Responsive container displaying Mode and Support option groups side-by-side or stacked.
///
/// Follows AGENTS.md §4:
/// - Shares a row when sufficient width is available
/// - Automatically stacks vertically on narrow devices or large text scale (up to 200%)
class OptionGroupsRow extends StatelessWidget {
  const OptionGroupsRow({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    required this.selectedSupport,
    required this.onSupportChanged,
    this.isVoiceAvailable = true,
    this.voiceDisabledReason,
    this.onVoiceDisabledTap,
  });

  final MissionMode selectedMode;
  final ValueChanged<MissionMode> onModeChanged;
  final MissionSupport selectedSupport;
  final ValueChanged<MissionSupport> onSupportChanged;
  final bool isVoiceAvailable;
  final String? voiceDisabledReason;
  final VoidCallback? onVoiceDisabledTap;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldStack = constraints.maxWidth < 340.0 || textScale > 1.25;

        final modeGroup = OptionGroup(
          title: AppStrings.modeSectionLabel,
          children: [
            OptionPill(
              label: AppStrings.modeChat,
              icon: Icons.chat_bubble_rounded,
              isSelected: selectedMode == MissionMode.chat,
              onTap: () => onModeChanged(MissionMode.chat),
            ),
            OptionPill(
              label: AppStrings.modeVoice,
              icon: Icons.mic_rounded,
              isSelected: selectedMode == MissionMode.voice,
              isDisabled: !isVoiceAvailable,
              disabledReason: voiceDisabledReason,
              onTap: isVoiceAvailable
                  ? () => onModeChanged(MissionMode.voice)
                  : () => onVoiceDisabledTap?.call(),
            ),
          ],
        );

        final supportGroup = OptionGroup(
          title: AppStrings.supportSectionLabel,
          children: [
            OptionPill(
              label: AppStrings.supportLightHints,
              isSelected: selectedSupport == MissionSupport.lightHints,
              onTap: () => onSupportChanged(MissionSupport.lightHints),
            ),
            OptionPill(
              label: AppStrings.supportGuided,
              isSelected: selectedSupport == MissionSupport.guided,
              onTap: () => onSupportChanged(MissionSupport.guided),
            ),
          ],
        );

        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              modeGroup,
              const SizedBox(height: AppSpacing.md),
              supportGroup,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: modeGroup),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: supportGroup),
          ],
        );
      },
    );
  }
}
