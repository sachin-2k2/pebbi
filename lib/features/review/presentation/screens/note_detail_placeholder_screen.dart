import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/back_link.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/grammar_note.dart';
import '../providers/review_provider.dart';

/// Screen displaying the plain-text body of an opened grammar or culture note.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.
class NoteDetailPlaceholderScreen extends ConsumerWidget {
  const NoteDetailPlaceholderScreen({super.key, required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(notesRepositoryProvider);
    final isOffline = ref.watch(reviewOfflineProvider);

    return Scaffold(
      body: SafeArea(
        child: ContentWidthLimiter(
          maxWidth: 680.0,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: FutureBuilder<GrammarNote?>(
              future: repo.openNote(noteId, isOnline: !isOffline),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                final note = snapshot.data;
                if (note == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BackLink(label: AppStrings.backToReview),
                      const SizedBox(height: AppSpacing.xl),
                      Center(
                        child: Text(
                          isOffline
                              ? AppStrings.noteOfflineUnavailableNotice
                              : 'Note not found.',
                          style: TextStyle(
                            color: AppColors.textMutedDarker,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BackLink(label: AppStrings.backToReview),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Text(
                            note.emoji,
                            style: const TextStyle(fontSize: 32.0),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              note.title,
                              style: AppTypography.screenTitle.copyWith(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        note.body,
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 15.5,
                          height: 1.6,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
