import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/layout/adaptive_sheet.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../../domain/chat_message.dart';
import '../../domain/conversation_state.dart';
import '../providers/mission_session_provider.dart';
import '../widgets/session/ai_disclosure_sheet.dart';
import '../widgets/session/finish_prompt_sheet.dart';
import '../widgets/session/help_sheet.dart';
import '../widgets/session/leave_session_sheet.dart';
import '../widgets/session/say_in_my_language_sheet.dart';

/// Helper class organizing modal sheets and finish actions for the session screen.
///
/// Follows AGENTS.md §3: Keeps screen under 100 lines.
abstract final class MissionSessionActions {
  static Future<bool> handlePop(BuildContext context) async {
    return LeaveSessionSheet.show(context);
  }

  static Future<void> handleFinish({
    required BuildContext context,
    required ConversationState state,
    required MissionSessionNotifier notifier,
  }) async {
    if (!state.hasUserSpoken) {
      final shouldLeave = await FinishPromptSheet.show(context);
      if (shouldLeave && context.mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final debrief = await notifier.finishSession();
    if (context.mounted) {
      if (GoRouter.maybeOf(context) != null) {
        context.push('/missions/debrief', extra: debrief);
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  static void showSayInMyLanguage({
    required BuildContext context,
    required MissionSessionNotifier notifier,
    required TextEditingController textController,
  }) {
    AdaptiveSheet.show<void>(
      context: context,
      builder: (dialogCtx) => SayInMyLanguageSheet(
        onTranslate: notifier.translateForSayInMyLanguage,
        onPlayAudio: (text) async {
          await notifier.playMessageAudio(
            ChatMessage(
              id: 'say_phrase',
              author: MessageAuthor.character,
              targetText: text,
              timestamp: DateTime.now(),
            ),
          );
        },
        onUseThis: (phrase) {
          textController.text = phrase;
          notifier.updateDraftText(phrase);
        },
      ),
    );
  }

  static void showHelp({
    required BuildContext context,
    required WidgetRef ref,
    required ConversationState state,
    required MissionSessionNotifier notifier,
  }) {
    AdaptiveSheet.show<void>(
      context: context,
      builder: (dialogCtx) => HelpSheet(
        onShowHint: () {
          // Suggestion list displays active hints
        },
        onTranslateLast: () {
          ref.read(appSettingsProvider.notifier).setCaptionsAlwaysOn(true);
        },
        onLeave: () async {
          final leave = await LeaveSessionSheet.show(context);
          if (leave && context.mounted) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  static void showAiDisclosure({
    required BuildContext context,
    required String characterName,
  }) {
    AdaptiveSheet.show<void>(
      context: context,
      builder: (dialogCtx) => AiDisclosureSheet(characterName: characterName),
    );
  }
}
