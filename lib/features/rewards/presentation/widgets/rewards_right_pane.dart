import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/rewards_summary.dart';
import 'badges_section.dart';
import 'next_chapter_note.dart';
import 'rewards_invite_card.dart';
import 'sticker_book_button.dart';

/// Secondary pane hosting invite card, badges section, sticker book, and footnote.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.3.
class RewardsRightPane extends StatelessWidget {
  const RewardsRightPane({
    super.key,
    required this.summary,
    required this.onOpenStickerBook,
  });

  final RewardsSummary summary;
  final VoidCallback onOpenStickerBook;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const RewardsInviteCard(),
        const SizedBox(height: AppSpacing.md),
        BadgesSection(
          badges: summary.badges,
          earnedCount: summary.earnedBadgesCount,
        ),
        const SizedBox(height: AppSpacing.md),
        StickerBookButton(
          stickerCount: summary.stickerCount,
          onPressed: onOpenStickerBook,
        ),
        const SizedBox(height: AppSpacing.md),
        const NextChapterNote(),
      ],
    );
  }
}
