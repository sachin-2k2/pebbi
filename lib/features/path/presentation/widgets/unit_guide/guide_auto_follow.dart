import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Helper managing viewport auto-following for currently playing guidebook rows.
///
/// Follows AGENTS.md §4: viewport relative calculation, supports 2-column tablet layout.
abstract final class GuideAutoFollow {
  static void followRow({
    required GlobalKey rowKey,
    required ScrollController scrollController,
    required bool userScrolledManually,
    required bool reduceMotion,
    required VoidCallback onResumeFollowing,
  }) {
    final rowContext = rowKey.currentContext;
    if (rowContext == null) return;

    final renderBox = rowContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final viewport = RenderAbstractViewport.maybeOf(renderBox);
    if (viewport == null) return;

    final offsetToReveal = viewport.getOffsetToReveal(renderBox, 0.0);
    final currentScroll = scrollController.offset;
    final viewportHeight = viewport.paintBounds.height;

    final isOffScreen =
        offsetToReveal.offset < currentScroll ||
        offsetToReveal.offset >
            currentScroll + viewportHeight - renderBox.size.height;

    if (isOffScreen) {
      onResumeFollowing();
    }

    if (!userScrolledManually || isOffScreen) {
      Scrollable.ensureVisible(
        rowContext,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.25,
      );
    }
  }
}
