import 'package:flutter/widgets.dart';

/// Window size classes defined by AGENTS.md §4.2.
///
/// Decisions are based solely on window width, never on device model or OS.
enum WindowClass { compact, medium, expanded }

abstract final class Breakpoints {
  /// Width under 600: Phones (portrait), small split-screen windows.
  static const double compactMax = 599.9;

  /// Width 600 to 839: Large phones landscape, small tablets, foldables.
  static const double mediumMin = 600.0;
  static const double mediumMax = 839.9;

  /// Width 840 and up: Tablets, iPads, landscape tablets, large windows.
  static const double expandedMin = 840.0;
}

/// Helper method to classify any given width into a [WindowClass].
WindowClass windowClassFromWidth(double width) {
  if (width < Breakpoints.mediumMin) {
    return WindowClass.compact;
  } else if (width < Breakpoints.expandedMin) {
    return WindowClass.medium;
  }
  return WindowClass.expanded;
}

/// Context extension for quick access to window class and responsive helpers.
extension WindowClassContext on BuildContext {
  /// Current [WindowClass] computed from `MediaQuery.sizeOf(this).width`.
  WindowClass get windowClass =>
      windowClassFromWidth(MediaQuery.sizeOf(this).width);

  bool get isCompact => windowClass == WindowClass.compact;
  bool get isMedium => windowClass == WindowClass.medium;
  bool get isExpanded => windowClass == WindowClass.expanded;
}
