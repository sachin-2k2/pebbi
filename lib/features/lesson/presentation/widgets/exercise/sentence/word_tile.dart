import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../domain/word_tile_item.dart';

/// Visual state of a word tile within sentence arrangement.
enum WordTileVisualState { inBank, inAnswer, placeholderSlot, locked }

/// Tactile word tile card representing a draggable/tappable word.
///
/// Follows AGENTS.md §3 & §4: 48dp minimum tap target, flexible sizing,
/// WCAG AAA contrast, under 100 lines.
class WordTile extends StatelessWidget {
  const WordTile({
    super.key,
    required this.tile,
    required this.visualState,
    this.onTap,
    this.semanticsLabel,
  });

  final WordTileItem tile;
  final WordTileVisualState visualState;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  static const Color _tileBorder = Color(0xFFE2E8F0);
  static const Color _tileBevel = Color(0xFFCBD5E1);
  static const Color _placeholderBg = Color(0xFFF1F5F9);
  static const Color _placeholderBorder = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = visualState == WordTileVisualState.placeholderSlot;
    final isLocked = visualState == WordTileVisualState.locked;

    if (isPlaceholder) {
      return ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: _placeholderBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _placeholderBorder, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: 0.0,
                child: Text(
                  tile.text,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final tileContent = Container(
      constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _tileBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(color: _tileBevel, offset: Offset(0, 3), blurRadius: 0),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tile.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: semanticsLabel ?? tile.text,
      button: !isLocked,
      child: GestureDetector(
        onTap: isLocked ? null : onTap,
        behavior: HitTestBehavior.opaque,
        child: tileContent,
      ),
    );
  }
}
