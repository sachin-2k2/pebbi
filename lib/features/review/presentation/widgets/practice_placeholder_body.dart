import 'package:flutter/material.dart';
import '../../../../core/design_system/empty_state.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../l10n/app_strings.dart';

/// Placeholder body view for the "Practice" sub-tab.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines).
/// Real practice sessions (flashcards, 2-minute mix) are marked TODO(question).
class PracticePlaceholderBody extends StatelessWidget {
  const PracticePlaceholderBody({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      illustration: const PebbiMascot(
        expression: PebbiExpression.relaxed,
        size: 84.0,
      ),
      title: AppStrings.tabPractice,
      subtitle: AppStrings.practicePlaceholderDescription,
    );
  }
}
