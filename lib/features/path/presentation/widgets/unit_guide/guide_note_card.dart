import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/guide_note.dart';
import 'note_tag_pill.dart';

/// Display-only card presenting an individual grammar or cultural note.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines, responsive padding.
class GuideNoteCard extends StatelessWidget {
  const GuideNoteCard({super.key, required this.note});

  final GuideNote note;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final direction = note.isRtl ? TextDirection.rtl : TextDirection.ltr;

    return Semantics(
      container: true,
      label: '${note.tag} note: ${note.title}. ${note.body}',
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: palette.outline, width: 1.0),
          boxShadow: palette.cardShadow,
        ),
        child: Directionality(
          textDirection: direction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (note.emoji != null && note.emoji!.isNotEmpty) ...[
                    ExcludeSemantics(
                      child: Text(
                        note.emoji!,
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      note.title,
                      style: AppTypography.cardTitle.copyWith(
                        color: palette.textPrimary,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  NoteTagPill(tag: note.tag),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                note.body,
                style: AppTypography.bodyMedium.copyWith(
                  color: palette.textPrimary.withValues(alpha: 0.9),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
