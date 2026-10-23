import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

/// Reusable informational pill badge with mint background and accessible text.
///
/// Follows AGENTS.md §4.6: Flexible size from constraints and tokens.
/// Used for non-intrusive tips such as "Tiles fly up when you tap them".
class TipPill extends StatelessWidget {
  const TipPill({super.key, required this.message, this.icon});

  /// The text displayed inside the pill.
  final String message;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bg = palette.successSurface;
    final border = palette.successBorder;
    final text = palette.successText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: text),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
