import 'package:flutter/material.dart';

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

  static const Color _mintBg = Color(0xFFE8FDF5);
  static const Color _mintBorder = Color(0xFFD1FAE5);
  static const Color _mintText = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _mintBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _mintBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: _mintText),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: _mintText,
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
