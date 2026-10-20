import 'package:flutter/material.dart';
import 'package:peddi/features/onboarding/domain/preparation_task.dart';
import 'readiness_row.dart';

/// Checklist container rendering each preparation task row.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines.
class ReadinessChecklist extends StatelessWidget {
  const ReadinessChecklist({
    super.key,
    required this.tasks,
    this.reduceMotion = false,
    this.onRetry,
  });

  final List<PreparationTask> tasks;
  final bool reduceMotion;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final task in tasks)
          ReadinessRow(
            key: ValueKey(task.id),
            task: task,
            reduceMotion: reduceMotion,
            onRetry: onRetry,
          ),
      ],
    );
  }
}
