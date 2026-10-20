import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

/// Pinned bottom bar container for onboarding setup steps.
///
/// Follows AGENTS.md §3 & §4:
/// - Stacks an optional [topChild] (e.g. BackpackHint) above [button].
/// - Responsive: on constrained heights (< 500dp, e.g. landscape phones),
///   gracefully hides [topChild] so the main scrollable content remains accessible.
class StepBottomBar extends StatelessWidget {
  const StepBottomBar({
    super.key,
    required this.button,
    this.topChild,
    this.minHeightThreshold = 500.0,
  });

  final Widget button;
  final Widget? topChild;
  final double minHeightThreshold;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final showTopChild = topChild != null && screenHeight >= minHeightThreshold;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTopChild) ...[topChild!, const SizedBox(height: AppSpacing.md)],
        button,
      ],
    );
  }
}
