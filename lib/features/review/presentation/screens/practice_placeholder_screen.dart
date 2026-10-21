import 'package:flutter/material.dart';
import '../../../../core/design_system/back_link.dart';
import '../../../../core/design_system/empty_state.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';

/// Screen route destination for practice drills (mix2min, flashcards, tricky).
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.
class PracticePlaceholderScreen extends StatelessWidget {
  const PracticePlaceholderScreen({super.key, this.mode = 'mix2min'});

  final String mode;

  String _titleForMode() {
    switch (mode) {
      case 'mix2min':
        return AppStrings.practice2MinTitle(2);
      case 'flashcards':
        return AppStrings.practiceFlashcardsTitle;
      case 'tricky':
        return AppStrings.practiceTrickyTitle;
      default:
        return AppStrings.practicePlaceholderTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ContentWidthLimiter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackLink(label: AppStrings.backToReview),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: Center(
                    child: EmptyState(
                      illustration: const PebbiMascot(
                        expression: PebbiExpression.relaxed,
                        size: 96.0,
                      ),
                      title: _titleForMode(),
                      subtitle:
                          '${AppStrings.practicePlaceholderDescription}\n(Mode: $mode - TODO(question))',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
