import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/path_node.dart';
import 'dashed_connector.dart';

/// Renders the dashed winding connector lines between learning path nodes.
///
/// Follows AGENTS.md §3: Extracted widget keeping [PathRail] under 150 lines.
class PathRailConnectors extends StatelessWidget {
  const PathRailConnectors({
    super.key,
    required this.centers,
    required this.nodes,
    required this.palette,
  });

  final List<Offset> centers;
  final List<PathNode> nodes;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(centers.length - 1, (i) {
        final isDone = nodes[i].isDone;
        return Positioned.fill(
          child: CustomPaint(
            painter: DashedConnectorPainter(
              start: centers[i],
              end: centers[i + 1],
              isCompleted: isDone,
              color: isDone ? palette.connectorDone : palette.connectorPending,
            ),
          ),
        );
      }),
    );
  }
}

