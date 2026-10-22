import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../domain/phrase_token.dart';
import 'phrase_token_widget.dart';

/// Wrap container displaying tokens of a phrase for phrasebook bookmarking.
///
/// Follows AGENTS.md §3 & §4: under 80 lines, responsive wrapping.
class TappablePhrase extends StatelessWidget {
  const TappablePhrase({
    super.key,
    required this.tokens,
    required this.savedTokenIds,
    required this.onTokenTap,
  });

  final List<PhraseToken> tokens;
  final Set<String> savedTokenIds;
  final ValueChanged<PhraseToken> onTokenTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final token in tokens)
          PhraseTokenWidget(
            token: token,
            isSaved: savedTokenIds.contains(token.id),
            onTap: () => onTokenTap(token),
          ),
      ],
    );
  }
}
