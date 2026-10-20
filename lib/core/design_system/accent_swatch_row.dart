import 'package:flutter/material.dart';
import '../../features/onboarding/domain/accent_option.dart';
import 'accent_swatch.dart';

/// Row of 6 circular accent swatches with wrapping support and accessible semantics.
///
/// Follows AGENTS.md §3 & §4: reusable design system component,
/// wraps gracefully on narrow viewports or large text scales, accessible single-choice group.
class AccentSwatchRow extends StatelessWidget {
  const AccentSwatchRow({
    super.key,
    required this.selectedAccentId,
    required this.onSelectAccent,
  });

  final String selectedAccentId;
  final ValueChanged<String> onSelectAccent;

  @override
  Widget build(BuildContext context) {
    final options = AccentOption.options;

    return Semantics(
      label: 'Accent colour',
      container: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final row = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < options.length; i++)
                AccentSwatch(
                  color: Color(options[i].colorValue),
                  name: options[i].name,
                  isSelected: options[i].id == selectedAccentId,
                  index: i + 1,
                  total: options.length,
                  onTap: () => onSelectAccent(options[i].id),
                ),
            ],
          );

          if (constraints.maxWidth < 288.0) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(width: 288.0, child: row),
            );
          }

          return row;
        },
      ),
    );
  }
}
