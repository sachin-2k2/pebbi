import 'package:flutter/material.dart';
import '../../../../../core/design_system/section_label.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/guide_note.dart';
import 'guide_note_card.dart';

/// Section rendering the "NOTES" label with book icon and list of [GuideNoteCard]s.
///
/// Follows AGENTS.md §3: under 100 lines, build under 50 lines.
class GuideNotesSection extends StatelessWidget {
  const GuideNotesSection({super.key, required this.notes});

  final List<GuideNote> notes;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();

    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Icon(Icons.menu_book_rounded, size: 16.0, color: palette.textMuted),
            const SizedBox(width: AppSpacing.xs),
            const SectionLabel(text: AppStrings.notesSection),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...notes.map(
          (note) => GuideNoteCard(key: ValueKey(note.id), note: note),
        ),
      ],
    );
  }
}
