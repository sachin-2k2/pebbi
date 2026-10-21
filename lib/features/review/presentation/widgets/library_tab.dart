import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import 'notes_section.dart';
import 'phrasebook_section.dart';

/// Presentation widget composing the "Library" sub-tab view.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.
class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        PhrasebookSection(),
        SizedBox(height: AppSpacing.lg),
        NotesSection(),
      ],
    );
  }
}
