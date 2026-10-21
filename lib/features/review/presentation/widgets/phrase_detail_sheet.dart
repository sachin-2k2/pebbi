import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/phrase.dart';
import '../providers/review_provider.dart';

/// Modal sheet displaying comprehensive details and learning statistics for a phrase.
///
/// Follows AGENTS.md §3 (<150 lines, build <50 lines) and §4.6.
class PhraseDetailSheet extends ConsumerWidget {
  const PhraseDetailSheet({super.key, required this.phrase});

  final Phrase phrase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tts = ref.watch(textToSpeechServiceProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    phrase.targetText,
                    style: AppTypography.screenTitle.copyWith(fontSize: 22.0),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            if (phrase.helperLine != null) ...[
              Text(
                phrase.helperLine!,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Text(
              phrase.meaning,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 16.0,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _StatsRow(phrase: phrase),
            const SizedBox(height: AppSpacing.xl),
            Button3D.secondary(
              label: AppStrings.playAudio,
              icon: const Icon(
                Icons.volume_up_rounded,
                color: AppColors.brandPurple,
              ),
              onPressed: () => tts.speak(
                phrase.targetText,
                locale: phrase.languageCode == 'es'
                    ? 'es-ES'
                    : phrase.languageCode,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Button3D(
              label: phrase.isSaved
                  ? AppStrings.unsavePhraseAction
                  : AppStrings.savePhraseAction,
              onPressed: () async {
                final repo = ref.read(phraseRepositoryProvider);
                await repo.toggleSaved(phrase.id);
                ref.invalidate(phrasesListProvider);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.phrase});

  final Phrase phrase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.tintLavender,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Box', value: '${phrase.box}/3'),
          _StatItem(label: 'Seen', value: '${phrase.timesSeen}'),
          _StatItem(label: 'Correct', value: '${phrase.timesCorrect}'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
            color: AppColors.brandPurple,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
