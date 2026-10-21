import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../l10n/app_strings.dart';

/// Full-width 3D purple button for starting a quick tricky phrase practice session.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §4.6.
class PractiseTrickyButton extends StatelessWidget {
  const PractiseTrickyButton({
    super.key,
    required this.trickyCount,
    required this.onStartPractice,
    required this.onNoTrickyPhrases,
  });

  final int trickyCount;
  final VoidCallback onStartPractice;
  final VoidCallback onNoTrickyPhrases;

  @override
  Widget build(BuildContext context) {
    return Button3D(
      label: AppStrings.practiseTrickyPhrasesButton,
      onPressed: () {
        if (trickyCount > 0) {
          onStartPractice();
        } else {
          onNoTrickyPhrases();
        }
      },
    );
  }
}
