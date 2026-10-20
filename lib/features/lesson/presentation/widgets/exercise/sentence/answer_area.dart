import 'package:flutter/material.dart';
import '../../../../../../core/design_system/dashed_border_box.dart';
import '../../../../../../l10n/app_strings.dart';
import '../../../../domain/word_tile_item.dart';
import 'word_tile.dart';

/// Answer drop area displaying placed word tiles or an instructional placeholder hint.
///
/// Follows AGENTS.md §3: under 100 lines, build under 50 lines.
class AnswerArea extends StatelessWidget {
  const AnswerArea({
    super.key,
    required this.placedTiles,
    required this.onTileTap,
    this.isLocked = false,
  });

  final List<WordTileItem> placedTiles;
  final void Function(String tileId) onTileTap;
  final bool isLocked;

  static const Color _dashedBorderColor = Color(0xFFC4B5FD);
  static const Color _dashedBgColor = Color(0xFFFAF8FF);
  static const Color _hintTextColor = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return DashedBorderBox(
      color: _dashedBorderColor,
      backgroundColor: _dashedBgColor,
      strokeWidth: 1.5,
      dashWidth: 6.0,
      dashGap: 5.0,
      borderRadius: 16.0,
      child: Container(
        constraints: const BoxConstraints(minHeight: 74.0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        alignment: placedTiles.isEmpty
            ? Alignment.centerLeft
            : Alignment.topLeft,
        child: placedTiles.isEmpty
            ? const Text(
                AppStrings.tapWordsInOrderHint,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w500,
                  color: _hintTextColor,
                ),
              )
            : Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: [
                  for (var i = 0; i < placedTiles.length; i++)
                    WordTile(
                      key: ValueKey('placed_${placedTiles[i].id}'),
                      tile: placedTiles[i],
                      visualState: isLocked
                          ? WordTileVisualState.locked
                          : WordTileVisualState.inAnswer,
                      semanticsLabel: AppStrings.tileInAnswerSemantics(
                        placedTiles[i].text,
                        i + 1,
                        placedTiles.length,
                      ),
                      onTap: () => onTileTap(placedTiles[i].id),
                    ),
                ],
              ),
      ),
    );
  }
}
