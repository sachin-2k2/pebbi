import 'package:flutter/material.dart';
import '../../domain/node_layout.dart';
import '../../domain/path_node.dart';
import 'dashed_connector.dart';
import 'path_mascot_marker.dart';
import 'path_node_tile.dart';

/// Interactive winding learning path rail with dynamic zigzag geometry.
class PathRail extends StatelessWidget {
  const PathRail({
    super.key,
    required this.nodes,
    required this.onNodeTap,
    this.rowHeight = 118.0,
    this.nodeDiameter = 68.0,
  });

  final List<PathNode> nodes;
  final ValueChanged<PathNode> onNodeTap;
  final double rowHeight;
  final double nodeDiameter;

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) return const SizedBox.shrink();

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final railWidth = constraints.maxWidth;
        final totalHeight = nodes.length * rowHeight + 20.0;
        final centers = _computeNodeCenters(railWidth, isRtl);

        return SizedBox(
          width: railWidth,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Dashed connectors between nodes
              ..._buildConnectors(centers),
              // Mascot marker beside current node
              ..._buildMascot(centers),
              // Path node interactive widgets
              ..._buildNodes(centers),
            ],
          ),
        );
      },
    );
  }

  List<Offset> _computeNodeCenters(double railWidth, bool isRtl) {
    return List.generate(nodes.length, (i) {
      final frac = NodeLayout.getFraction(i, isRtl: isRtl);
      final cx = NodeLayout.computeCenterX(railWidth, frac);
      final cy = i * rowHeight + nodeDiameter / 2 + 10.0;
      return Offset(cx, cy);
    });
  }

  List<Widget> _buildConnectors(List<Offset> centers) {
    final connectors = <Widget>[];
    for (int i = 0; i < centers.length - 1; i++) {
      final isDone = nodes[i].isDone;
      connectors.add(
        Positioned.fill(
          child: CustomPaint(
            painter: DashedConnectorPainter(
              start: centers[i],
              end: centers[i + 1],
              isCompleted: isDone,
            ),
          ),
        ),
      );
    }
    return connectors;
  }

  List<Widget> _buildMascot(List<Offset> centers) {
    final widgets = <Widget>[];
    final currentIdx = nodes.indexWhere((n) => n.isCurrent);
    if (currentIdx != -1) {
      final center = centers[currentIdx];
      final isOnRight = center.dx < 120.0;
      final mascotX = isOnRight ? center.dx + 44.0 : center.dx - 88.0;
      final mascotY = center.dy - 20.0;

      widgets.add(
        Positioned(
          left: mascotX,
          top: mascotY,
          child: PathMascotMarker(isOnRight: isOnRight),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _buildNodes(List<Offset> centers) {
    const tileWidth = 110.0;
    return List.generate(nodes.length, (i) {
      final center = centers[i];
      final node = nodes[i];

      return Positioned(
        left: center.dx - tileWidth / 2,
        top: i * rowHeight,
        width: tileWidth,
        child: Center(
          child: PathNodeTile(node: node, onTap: () => onNodeTap(node)),
        ),
      );
    });
  }
}
