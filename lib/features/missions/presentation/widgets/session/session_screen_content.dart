import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/layout/content_width_limiter.dart';
import '../../../../../core/layout/responsive_builder.dart';
import '../../../../settings/presentation/providers/app_settings_provider.dart';
import '../../../domain/conversation_state.dart';
import '../../../domain/session_config.dart';
import '../../providers/mission_session_provider.dart';
import '../../screens/mission_session_actions.dart';
import 'session_body.dart';
import 'session_expanded_layout.dart';

/// Hosts the responsive view switching between [SessionBody] and [SessionExpandedLayout].
///
/// Follows AGENTS.md §3 & §4: Keeps screen file under 100 lines.
class SessionScreenContent extends ConsumerWidget {
  const SessionScreenContent({
    super.key,
    required this.state,
    required this.notifier,
    required this.config,
    required this.targetLanguageName,
    required this.scrollController,
    required this.textController,
    required this.isOffline,
  });

  final ConversationState state;
  final MissionSessionNotifier notifier;
  final SessionConfig config;
  final String targetLanguageName;
  final ScrollController scrollController;
  final TextEditingController textController;
  final bool isOffline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captionsOn = ref.watch(
      appSettingsProvider.select((s) => s.captionsAlwaysOn),
    );

    return ResponsiveBuilder(
      compact: (context) => SessionBody(
        state: state,
        config: config,
        targetLanguageName: targetLanguageName,
        scrollController: scrollController,
        textController: textController,
        isOffline: isOffline,
        captionsOn: captionsOn,
        onHelpTap: () => MissionSessionActions.showHelp(
          context: context,
          ref: ref,
          state: state,
          notifier: notifier,
        ),
        onCharacterTap: () => MissionSessionActions.showAiDisclosure(
          context: context,
          characterName: state.characterName,
        ),
        onPlayAudio: notifier.playMessageAudio,
        onReport: (r) => notifier.reportMessage(messageId: 'char_msg', reason: r),
        onRetry: notifier.retryFailedMessage,
        onDelete: notifier.deleteFailedMessage,
        onSelectSuggestion: notifier.sendUserMessage,
        onTextChanged: notifier.updateDraftText,
        onSend: () {
          notifier.sendUserMessage(textController.text);
          textController.clear();
        },
        onMicTap: () {},
        onTypeInsteadTap: () {},
        onSayInMyLanguageTap: () => MissionSessionActions.showSayInMyLanguage(
          context: context,
          notifier: notifier,
          textController: textController,
        ),
        onCaptionsToggle: () => ref
            .read(appSettingsProvider.notifier)
            .setCaptionsAlwaysOn(!captionsOn),
        onFinishTap: () => MissionSessionActions.handleFinish(
          context: context,
          state: state,
          notifier: notifier,
        ),
      ),
      medium: (context) => ContentWidthLimiter(
        maxWidth: 720.0,
        child: SessionBody(
          state: state,
          config: config,
          targetLanguageName: targetLanguageName,
          scrollController: scrollController,
          textController: textController,
          isOffline: isOffline,
          captionsOn: captionsOn,
          onHelpTap: () => MissionSessionActions.showHelp(
            context: context,
            ref: ref,
            state: state,
            notifier: notifier,
          ),
          onCharacterTap: () => MissionSessionActions.showAiDisclosure(
            context: context,
            characterName: state.characterName,
          ),
          onPlayAudio: notifier.playMessageAudio,
          onReport: (r) => notifier.reportMessage(messageId: 'char_msg', reason: r),
          onRetry: notifier.retryFailedMessage,
          onDelete: notifier.deleteFailedMessage,
          onSelectSuggestion: notifier.sendUserMessage,
          onTextChanged: notifier.updateDraftText,
          onSend: () {
            notifier.sendUserMessage(textController.text);
            textController.clear();
          },
          onMicTap: () {},
          onTypeInsteadTap: () {},
          onSayInMyLanguageTap: () => MissionSessionActions.showSayInMyLanguage(
            context: context,
            notifier: notifier,
            textController: textController,
          ),
          onCaptionsToggle: () => ref
              .read(appSettingsProvider.notifier)
              .setCaptionsAlwaysOn(!captionsOn),
          onFinishTap: () => MissionSessionActions.handleFinish(
            context: context,
            state: state,
            notifier: notifier,
          ),
        ),
      ),
      expanded: (context) => SessionExpandedLayout(
        state: state,
        config: config,
        targetLanguageName: targetLanguageName,
        scrollController: scrollController,
        textController: textController,
        isOffline: isOffline,
        captionsOn: captionsOn,
        onHelpTap: () => MissionSessionActions.showHelp(
          context: context,
          ref: ref,
          state: state,
          notifier: notifier,
        ),
        onCharacterTap: () => MissionSessionActions.showAiDisclosure(
          context: context,
          characterName: state.characterName,
        ),
        onPlayAudio: notifier.playMessageAudio,
        onReport: (r) => notifier.reportMessage(messageId: 'char_msg', reason: r),
        onRetry: notifier.retryFailedMessage,
        onDelete: notifier.deleteFailedMessage,
        onSelectSuggestion: notifier.sendUserMessage,
        onTextChanged: notifier.updateDraftText,
        onSend: () {
          notifier.sendUserMessage(textController.text);
          textController.clear();
        },
        onMicTap: () {},
        onTypeInsteadTap: () {},
        onSayInMyLanguageTap: () => MissionSessionActions.showSayInMyLanguage(
          context: context,
          notifier: notifier,
          textController: textController,
        ),
        onCaptionsToggle: () => ref
            .read(appSettingsProvider.notifier)
            .setCaptionsAlwaysOn(!captionsOn),
        onFinishTap: () => MissionSessionActions.handleFinish(
          context: context,
          state: state,
          notifier: notifier,
        ),
      ),
    );
  }
}
