import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/node_layout.dart';
import '../../domain/path_node.dart';
import 'dashed_connector.dart';
import 'path_mascot_marker.dart';
import 'path_node_tile.dart';

/// Interactive winding learning path rail with dynamic zigzag geometry.
///
/// Follows AGENTS.md §3 & §4: Row height sized so labels never collide with NEXT tags.
class PathRail extends StatefulWidget {
  const PathRail({
    super.key,
    required this.nodes,
    required this.onNodeTap,
    this.completedStopId,
    this.onAnimationComplete,
    this.rowHeight = 148.0,
    this.nodeDiameter = 68.0,
  });
  final List<PathNode> nodes;
  final ValueChanged<PathNode> onNodeTap;
  final String? completedStopId;
  final VoidCallback? onAnimationComplete;
  final double rowHeight;
  final double nodeDiameter;

  @override
  State<PathRail> createState() => _PathRailState();
}

class _PathRailState extends State<PathRail> {
  int? _mascotIndex;

  @override
  void initState() {
    super.initState();
    _initMascotIndex();
  }

  @override
  void didUpdateWidget(covariant PathRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentIdx = widget.nodes.indexWhere((n) => n.isCurrent);
    if (_mascotIndex != currentIdx && currentIdx != -1) {
      setState(() => _mascotIndex = currentIdx);
    }
  }

  void _initMascotIndex() {
    final currentIdx = widget.nodes.indexWhere((n) => n.isCurrent);
    final completedId = widget.completedStopId;
    if (completedId != null) {
      final completedIdx = widget.nodes.indexWhere((n) => n.id == completedId);
      if (completedIdx != -1 && completedIdx != currentIdx) {
        _mascotIndex = completedIdx;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted) {
              setState(() => _mascotIndex = currentIdx);
              widget.onAnimationComplete?.call();
            }
          });
        });
        return;
      }
    }
    _mascotIndex = currentIdx;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes.isEmpty) return const SizedBox.shrink();
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final palette = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final railWidth = constraints.maxWidth;
        final totalHeight = widget.nodes.length * widget.rowHeight + 20.0;
        final centers = List.generate(widget.nodes.length, (i) {
          final frac = NodeLayout.getFraction(i, isRtl: isRtl);
          final cx = NodeLayout.computeCenterX(railWidth, frac);
          final cy = i * widget.rowHeight + widget.nodeDiameter / 2 + 10.0;
          return Offset(cx, cy);
        });
        return SizedBox(
          width: railWidth,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ..._buildConnectors(centers, palette),
              ..._buildMascot(centers),
              ..._buildNodes(centers),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildConnectors(List<Offset> centers, AppPalette palette) {
    return List.generate(centers.length - 1, (i) {
      final isDone = widget.nodes[i].isDone;
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
    });
  }

  List<Widget> _buildMascot(List<Offset> centers) {
    final activeIdx =
        _mascotIndex ?? widget.nodes.indexWhere((n) => n.isCurrent);
    if (activeIdx == -1 || activeIdx >= centers.length) return const [];
    final center = centers[activeIdx];
    final isOnRight = center.dx < 120.0;
    return [
      AnimatedPositioned(
        key: const ValueKey('path_mascot_pebbi'),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
        left: isOnRight ? center.dx + 44.0 : center.dx - 88.0,
        top: center.dy - 20.0,
        child: PathMascotMarker(isOnRight: isOnRight),
      ),
    ];
  }

  List<Widget> _buildNodes(List<Offset> centers) {
    const tileWidth = 110.0;
    return List.generate(widget.nodes.length, (i) {
      final center = centers[i];
      final node = widget.nodes[i];
      return Positioned(
        left: center.dx - tileWidth / 2,
        top: i * widget.rowHeight,
        width: tileWidth,
        child: Center(
          child: PathNodeTile(node: node, onTap: () => widget.onNodeTap(node)),
        ),
      );
    });
  }
}
