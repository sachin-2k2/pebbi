import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_strings.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../../domain/start_mission_gate.dart';
import '../providers/free_talk_provider.dart';
import '../providers/mission_brief_provider.dart';

/// Presentation actions and dialogs for MissionBriefScreen.
///
/// Follows AGENTS.md §3.1: keeps screen file under 100 lines.
abstract final class MissionBriefActions {
  static Future<void> handleStart(
    BuildContext context,
    WidgetRef ref,
    MissionBriefNotifier notifier,
  ) async {
    final isOffline = ref.read(missionBriefIsOfflineProvider);
    final correctionStyle = ref.read(freeTalkCorrectionStyleProvider);
    final captionsOn = ref.read(
      appSettingsProvider.select((s) => s.captionsAlwaysOn),
    );

    final outcome = await notifier.startMission(
      isOfflineCheck: isOffline,
      correctionStyle: correctionStyle,
      captionsOn: captionsOn,
    );

    if (!context.mounted) return;

    switch (outcome.type) {
      case StartMissionOutcomeType.needsInternet:
        _showOfflineDialog(context);
      case StartMissionOutcomeType.needsPremium:
        context.push('/premium/options');
      case StartMissionOutcomeType.limitReached:
        _showLimitDialog(context);
      case StartMissionOutcomeType.childSafetyBlocked:
        _showSafetyDialog(context);
      case StartMissionOutcomeType.voicePermissionDeniedFallbackToChat:
        // Do not navigate; fallback notice is displayed and mode is switched to Chat.
        break;
      case StartMissionOutcomeType.ready:
        final config = outcome.sessionConfig!;
        if (GoRouter.maybeOf(context) != null) {
          context.push(
            '/missions/session?topicId=${config.missionId}&style=${config.correctionStyle.id}',
            extra: config,
          );
        }
    }
  }

  static void _showOfflineDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.offlineMissionBlockedTitle),
        content: const Text(AppStrings.offlineMissionBlockedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showLimitDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daily limit reached'),
        content: const Text('You have completed your free missions for today.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showSafetyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Safety Notice'),
        content: const Text('This mission is unavailable for this account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
