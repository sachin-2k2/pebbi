import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/chat_message.dart';
import 'character_bubble.dart';
import 'system_note.dart';
import 'typing_indicator.dart';
import 'user_bubble.dart';

/// Scrollable message feed for the active conversation session.
///
/// Follows AGENTS.md §3 & §8:
/// - Sticks to bottom on new messages without jumping if user scrolled up
/// - Composes CharacterBubble, UserBubble, TypingIndicator, and SystemNote
class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    required this.characterName,
    required this.scrollController,
    required this.isWaitingForCharacter,
    required this.areAllGoalsDone,
    required this.onPlayAudio,
    required this.onReport,
    required this.onRetry,
    required this.onDelete,
  });

  final List<ChatMessage> messages;
  final String characterName;
  final ScrollController scrollController;
  final bool isWaitingForCharacter;
  final bool areAllGoalsDone;
  final ValueChanged<ChatMessage> onPlayAudio;
  final ValueChanged<String> onReport;
  final ValueChanged<ChatMessage> onRetry;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: messages.length +
          (areAllGoalsDone ? 1 : 0) +
          (isWaitingForCharacter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < messages.length) {
          final msg = messages[index];
          if (msg.isFromCharacter) {
            return CharacterBubble(
              message: msg,
              characterName: characterName,
              onPlayAudio: () => onPlayAudio(msg),
              onReport: onReport,
            );
          }
          return UserBubble(
            message: msg,
            onRetry: () => onRetry(msg),
            onDelete: () => onDelete(msg.id),
          );
        }

        if (areAllGoalsDone && index == messages.length) {
          return const SystemNote();
        }

        return TypingIndicator(characterName: characterName);
      },
    );
  }
}
