import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/learning_reason.dart';
import 'reason_card.dart';

/// Responsive grid of learning reason cards with equal height per row.
///
/// Follows AGENTS.md §3 & §4:
/// - Adapts column count (2 on phones, 3+ on tablets/iPads).
/// - Equal height per row using IntrinsicHeight + CrossAxisAlignment.stretch.
/// - Unfilled slots in last row filled with empty space.
class ReasonGrid extends StatelessWidget {
  const ReasonGrid({
    super.key,
    required this.reasons,
    required this.selectedIds,
    required this.onToggle,
    this.spacing = AppSpacing.md,
  });

  final List<LearningReason> reasons;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.reasonsSelectionGroupSemantics,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = (constraints.maxWidth / 160.0).floor().clamp(2, 4);
          final rows = <List<LearningReason>>[];

          for (var i = 0; i < reasons.length; i += columns) {
            final end = (i + columns < reasons.length)
                ? i + columns
                : reasons.length;
            rows.add(reasons.sublist(i, end));
          }

          return Column(
            children: [
              for (int r = 0; r < rows.length; r++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: r == rows.length - 1 ? 0 : spacing,
                  ),
                  child: _buildRow(rows[r], columns),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(List<LearningReason> rowReasons, int columns) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < columns; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Expanded(
              child: i < rowReasons.length
                  ? ReasonCard(
                      reason: rowReasons[i],
                      isSelected: selectedIds.contains(rowReasons[i].id),
                      onTap: () => onToggle(rowReasons[i].id),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}
