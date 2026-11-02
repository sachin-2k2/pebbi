import 'package:flutter/material.dart';
import '../../../../../core/design_system/notice_banner.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/chat_message.dart';
import '../../../domain/conversation_state.dart';
import '../../../domain/mission_mode.dart';
import '../../../domain/session_config.dart';
import 'chat_message_list.dart';
import 'goals_strip.dart';
import 'session_bottom_bar.dart';
import 'session_header.dart';
import 'suggestion_list.dart';

/// Single-column layout for Compact and Medium screen sizes.
///
/// Follows AGENTS.md §3 (< 150 lines, build < 50 lines) & §4.
class SessionBody extends StatelessWidget {
  const SessionBody({
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
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final isWaiting =
        state.status == ConversationStatus.starting ||
        state.status == ConversationStatus.waitingForCharacter ||
        state.status == ConversationStatus.sending;

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final shouldCollapseSuggestions = isKeyboardOpen || textScale > 1.35;
    final showSuggestions =
        config.mode != MissionMode.voice &&
        config.support.id == 'guided' &&
        state.suggestions.isNotEmpty;

    return Column(
      children: [
        SessionHeader(
          characterName: state.characterName,
          characterRole: state.characterRole,
          emoji: state.emoji,
          onHelpTap: onHelpTap,
          onCharacterTap: onCharacterTap,
        ),
        GoalsStrip(goals: state.goals),
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
        if (showSuggestions)
          SuggestionList(
            suggestions: state.suggestions,
            onSelect: onSelectSuggestion,
            isKeyboardOpen: shouldCollapseSuggestions,
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
  }
}
