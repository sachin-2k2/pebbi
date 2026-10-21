import 'package:flutter/material.dart';
import '../../../../core/design_system/empty_state.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../l10n/app_strings.dart';

/// Placeholder body view for the "Library" sub-tab.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines).
/// Real library view (grammar notes, cultural tips) is marked TODO(question).
class LibraryPlaceholderBody extends StatelessWidget {
  const LibraryPlaceholderBody({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      illustration: const PebbiMascot(
        expression: PebbiExpression.happy,
        size: 84.0,
      ),
      title: AppStrings.tabLibrary,
      subtitle: AppStrings.libraryPlaceholderDescription,
    );
  }
}
