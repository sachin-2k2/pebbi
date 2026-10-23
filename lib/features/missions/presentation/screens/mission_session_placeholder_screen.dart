import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

import '../../domain/session_config.dart';

/// Placeholder screen for an active role-play or Free Talk conversation session.
///
/// Follows AGENTS.md §2 & §3.
///
/// TODO(question: full conversation session with speech/TTS/AI debrief not yet designed).
class MissionSessionPlaceholderScreen extends StatelessWidget {
  const MissionSessionPlaceholderScreen({
    super.key,
    required this.topicId,
    required this.correctionStyle,
    this.sessionConfig,
  });

  final String topicId;
  final String correctionStyle;
  final SessionConfig? sessionConfig;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Conversation Session'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 64,
                  color: palette.brand,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Topic: $topicId',
                  style: AppTypography.cardTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Correction style: $correctionStyle',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Role-play AI conversation session interface will appear here.',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
