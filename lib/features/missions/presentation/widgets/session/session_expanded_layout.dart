import 'package:flutter/material.dart';
import '../../../../../core/design_system/notice_banner.dart';
import '../../../../../core/layout/two_pane_layout.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/chat_message.dart';
import '../../../domain/conversation_state.dart';
import '../../../domain/mission_mode.dart';
import '../../../domain/session_config.dart';
import 'character_avatar.dart';
import 'chat_message_list.dart';
import 'session_bottom_bar.dart';
import 'suggestion_list.dart';

/// Two-pane adaptive layout for Expanded screen sizes (tablets and desktops).
///
/// Follows AGENTS.md §4.3:
/// - Left pane: Character profile card, goals checklist, and Help
/// - Right pane: Chat feed, suggestions, and input bar
class SessionExpandedLayout extends StatelessWidget {
  const SessionExpandedLayout({
    super.key,
    required this.state,
    required this.config,
    required this.targetLanguageName,
    required this.scrollController,
    required this.textController,
    required this.isOffline,
    required this.captionsOn,
    required this.onHelpTap,
    required this.onCharacterTap,
    required this.onPlayAudio,
    required this.onReport,
    required this.onRetry,
    required this.onDelete,
    required this.onSelectSuggestion,
    required this.onTextChanged,
    required this.onSend,
    required this.onMicTap,
    required this.onTypeInsteadTap,
    required this.onVoiceInsteadTap,
    required this.onSayInMyLanguageTap,
    required this.onCaptionsToggle,
    required this.onFinishTap,
  });

  final ConversationState state;
  final SessionConfig config;
  final String targetLanguageName;
  final ScrollController scrollController;
  final TextEditingController textController;
  final bool isOffline;
  final bool captionsOn;
  final VoidCallback onHelpTap;
  final VoidCallback onCharacterTap;
  final ValueChanged<ChatMessage> onPlayAudio;
  final ValueChanged<String> onReport;
  final ValueChanged<ChatMessage> onRetry;
  final ValueChanged<String> onDelete;
  final ValueChanged<String> onSelectSuggestion;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onSend;
  final VoidCallback onMicTap;
  final VoidCallback onTypeInsteadTap;
  final VoidCallback onVoiceInsteadTap;
  final VoidCallback onSayInMyLanguageTap;
  final VoidCallback onCaptionsToggle;
  final VoidCallback onFinishTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isWaiting =
        state.status == ConversationStatus.starting ||
        state.status == ConversationStatus.waitingForCharacter ||
        state.status == ConversationStatus.sending;

    final leftPane = Container(
      color: palette.surface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: palette.surfaceRaised,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: palette.outline),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: onCharacterTap,
                  borderRadius: BorderRadius.circular(24.0),
                  child: CharacterAvatar(
                    emoji: state.emoji,
                    size: 48.0,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.characterName,
                        style: AppTypography.cardTitle.copyWith(
                          color: palette.textPrimary,
                        ),
                      ),
                      Text(
                        AppStrings.sessionCharacterOnline(state.characterRole),
                        style: AppTypography.caption.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppStrings.sessionGoalsSheetTitle,
            style: AppTypography.cardTitle.copyWith(color: palette.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              itemCount: state.goals.length,
              separatorBuilder: (_, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final g = state.goals[i];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: palette.surfaceRaised,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    border: Border.all(
                      color: g.isDone ? palette.mint : palette.outline,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        g.isDone
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: g.isDone ? palette.mint : palette.textMuted,
                        size: 20.0,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          g.text,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          OutlinedButton.icon(
            onPressed: onHelpTap,
            icon: const Icon(Icons.help_outline_rounded, size: 18.0),
            label: const Text(AppStrings.sessionHelpButtonLabel),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48.0),
              foregroundColor: palette.textPrimary,
              side: BorderSide(color: palette.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              ),
            ),
          ),
        ],
      ),
    );

    final rightPane = Column(
      children: [
        if (isOffline)
          const NoticeBanner(
            message: AppStrings.offlineBannerNotice,
            icon: Icon(Icons.wifi_off_rounded, size: 20.0),
          ),
        if (state.errorMessage != null)
          NoticeBanner(
            message: state.errorMessage!,
            tone: NoticeBannerTone.warning,
          ),
        Expanded(
          child: ChatMessageList(
            messages: state.messages,
            characterName: state.characterName,
            scrollController: scrollController,
            isWaitingForCharacter: isWaiting,
            areAllGoalsDone: state.areAllGoalsDone,
            onPlayAudio: onPlayAudio,
            onReport: onReport,
            onRetry: onRetry,
            onDelete: onDelete,
          ),
        ),
        if (config.mode != MissionMode.voice &&
            config.support.id == 'guided' &&
            state.suggestions.isNotEmpty)
          SuggestionList(
            suggestions: state.suggestions,
            onSelect: onSelectSuggestion,
          ),
        const SizedBox(height: AppSpacing.xs),
        SessionBottomBar(
          state: state,
          config: config,
          targetLanguageName: targetLanguageName,
          textController: textController,
          captionsOn: captionsOn,
          onFinishTap: onFinishTap,
          onMicTap: onMicTap,
          onTypeInsteadTap: onTypeInsteadTap,
          onVoiceInsteadTap: onVoiceInsteadTap,
          onTextChanged: onTextChanged,
          onSend: onSend,
          onSayInMyLanguageTap: onSayInMyLanguageTap,
          onCaptionsToggle: onCaptionsToggle,
        ),
      ],
    );

    return TwoPaneLayout(
      primaryPane: leftPane,
      secondaryPane: rightPane,
      primaryFlex: 4,
      secondaryFlex: 7,
    );
  }
}
