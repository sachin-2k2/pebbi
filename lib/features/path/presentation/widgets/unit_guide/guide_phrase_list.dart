import 'package:flutter/material.dart';
import '../../../../../core/design_system/section_label.dart';
import '../../../../../core/layout/window_class.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/guide_phrase.dart';
import 'guide_phrase_row.dart';

/// Responsive list or grid displaying unit guidebook key phrases.
///
/// Follows AGENTS.md §4: single column on Compact/Medium, two columns on Expanded.
class GuidePhraseList extends StatelessWidget {
  const GuidePhraseList({
    super.key,
    required this.phrases,
    required this.playingPhraseId,
    required this.rowKeys,
    required this.onPhraseTap,
    this.showHelperLine = false,
  });

  final List<GuidePhrase> phrases;
  final String? playingPhraseId;
  final Map<String, GlobalKey> rowKeys;
  final ValueChanged<GuidePhrase> onPhraseTap;
  final bool showHelperLine;

  @override
  Widget build(BuildContext context) {
    if (phrases.isEmpty) return const SizedBox.shrink();

    final isExpanded = context.isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const SectionLabel(text: AppStrings.keyPhrasesSection),
        const SizedBox(height: AppSpacing.md),
        if (isExpanded)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: phrases.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360.0,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.md,
              mainAxisExtent: 68.0,
            ),
            itemBuilder: (context, index) => _buildRow(phrases[index]),
          )
        else
          for (int i = 0; i < phrases.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            _buildRow(phrases[i]),
          ],
      ],
    );
  }

  Widget _buildRow(GuidePhrase phrase) {
    final key = rowKeys[phrase.id];
    return GuidePhraseRow(
      key: key,
      phrase: phrase,
      isPlaying: playingPhraseId == phrase.id,
      showHelperLine: showHelperLine,
      onTap: () => onPhraseTap(phrase),
    );
  }
}
