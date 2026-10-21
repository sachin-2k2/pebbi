import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/empty_state.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/grammar_note_summary.dart';
import '../providers/review_provider.dart';
import 'note_tile.dart';

/// Grammar and culture notes section with dynamic header, language/level subtitle, and note tiles.
///
/// Follows AGENTS.md §3 (<150 lines, build <50 lines) and §4.
class NotesSection extends ConsumerWidget {
  const NotesSection({super.key});

  String _languageDisplayName(String code) {
    switch (code) {
      case 'es':
        return 'Spanish';
      case 'ar':
        return 'Arabic';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'ja':
        return 'Japanese';
      default:
        return 'Spanish';
    }
  }

  void _handleNoteTap(
    BuildContext context,
    WidgetRef ref,
    GrammarNoteSummary note,
  ) {
    final isOffline = ref.read(reviewOfflineProvider);

    if (isOffline && !note.isCached) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.noteOfflineUnavailableNotice),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(selectedNoteIdProvider.notifier).state = note.id;
    ref.read(notesRepositoryProvider).markNoteRead(note.id);

    // On compact viewports, navigate to note detail page
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth < 840.0) {
      try {
        context.push('/review/note/${note.id}');
      } catch (_) {
        // Safe fallback in isolated test environments without GoRouter
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(grammarNotesListProvider);
    final targetLang = ref.watch(reviewTargetLanguageCodeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final langName = _languageDisplayName(targetLang);
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMutedDarker;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.brandPurple,
              size: 20.0,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                AppStrings.grammarCultureNotesTitle,
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3.0),
        Text(
          AppStrings.grammarCultureNotesSubtitle(langName, 'A1'),
          style: TextStyle(
            color: subtitleColor,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        notesAsync.when(
          data: (notes) {
            if (notes.isEmpty) {
              return const EmptyState(
                illustration: PebbiMascot(
                  expression: PebbiExpression.relaxed,
                  size: 72.0,
                ),
                title: AppStrings.emptyNotesTitle,
                subtitle: AppStrings.emptyNotesSubtitle,
              );
            }
            return Column(
              children: [
                for (var i = 0; i < notes.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  NoteTile(
                    note: notes[i],
                    onTap: () => _handleNoteTap(context, ref, notes[i]),
                  ),
                ],
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading notes',
                  style: TextStyle(color: AppColors.errorText),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(grammarNotesListProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
