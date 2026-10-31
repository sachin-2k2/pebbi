import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/node_layout.dart';
import '../../domain/path_node.dart';
import 'path_node_tile.dart';
import 'path_rail_connectors.dart';
import 'path_rail_mascot_layer.dart';

/// Interactive winding learning path rail with dynamic zigzag geometry.
///
/// Follows AGENTS.md §3 & §4: Row height sized so labels never collide with NEXT tags.
class PathRail extends StatefulWidget {
  const PathRail({
    super.key, required this.nodes, required this.onNodeTap,
    this.completedStopId, this.onAnimationComplete,
    this.rowHeight = 148.0, this.nodeDiameter = 68.0,
  });
  final List<PathNode> nodes;
  final ValueChanged<PathNode> onNodeTap;
  final String? completedStopId;
  final VoidCallback? onAnimationComplete;
  final double rowHeight, nodeDiameter;

  @override
  State<PathRail> createState() => _PathRailState();
}

class _PathRailState extends State<PathRail> {
  final _activeNodeKey = GlobalKey();
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
    final completedId = widget.completedStopId;
    if (completedId != null && (completedId != oldWidget.completedStopId || oldWidget.nodes != widget.nodes)) {
      final completedIdx = widget.nodes.indexWhere((n) => n.id == completedId);
      if (completedIdx != -1 && completedIdx != currentIdx) {
        return _animateMascot(completedIdx, currentIdx);
      }
    }
    if (_mascotIndex != currentIdx && currentIdx != -1 && widget.completedStopId == null) {
      setState(() => _mascotIndex = currentIdx);
    }
  }

  void _initMascotIndex() {
    final currentIdx = widget.nodes.indexWhere((n) => n.isCurrent);
    final completedId = widget.completedStopId;
    if (completedId != null) {
      final completedIdx = widget.nodes.indexWhere((n) => n.id == completedId);
      if (completedIdx != -1 && completedIdx != currentIdx) {
        return _animateMascot(completedIdx, currentIdx);
      }
    }
    _mascotIndex = currentIdx;
  }

  void _animateMascot(int fromIdx, int toIdx) {
    _mascotIndex = fromIdx;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        HapticFeedback.lightImpact();
        setState(() => _mascotIndex = toIdx);
        _scrollToNode();
        Future.delayed(const Duration(milliseconds: 950), () {
          if (!mounted) return;
          HapticFeedback.mediumImpact();
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) widget.onAnimationComplete?.call();
          });
        });
      });
    });
  }

  void _scrollToNode() {
    final ctx = _activeNodeKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx, duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic, alignment: 0.45,
      );
    }
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
        final activeIdx = _mascotIndex ?? widget.nodes.indexWhere((n) => n.isCurrent);
        return SizedBox(
          width: railWidth, height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PathRailConnectors(centers: centers, nodes: widget.nodes, palette: palette),
              PathRailMascotLayer(centers: centers, activeIndex: activeIdx),
              ..._buildNodes(centers),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildNodes(List<Offset> centers) {
    const tileWidth = 110.0;
    final currentIdx = widget.nodes.indexWhere((n) => n.isCurrent);
    return List.generate(widget.nodes.length, (i) {
      final center = centers[i];
      final node = widget.nodes[i];
      final isTarget = (_mascotIndex == currentIdx)
          ? node.isCurrent
          : (widget.completedStopId != null && node.id == widget.completedStopId);
      return Positioned(
        left: center.dx - tileWidth / 2,
        top: i * widget.rowHeight,
        width: tileWidth,
        child: Center(
          child: PathNodeTile(
            key: isTarget ? _activeNodeKey : null,
            node: node, onTap: () => widget.onNodeTap(node),
          ),
        ),
      );
    });
  }
}
