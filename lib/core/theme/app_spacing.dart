import 'package:flutter/widgets.dart';

/// Layout spacing, padding, radius, and sizing tokens for Pebbi.
///
/// Matches the playful rounded aesthetic defined in the design specification.
abstract final class AppSpacing {
  // Spacing & Gaps
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0; // Standard screen padding and card gap
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Radii tokens
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusIconTile = 16.0; // Rounded square icon tiles
  static const double radiusButton = 18.0; // Buttons (16 to 20 range)
  static const double radiusLg = 18.0; // Alias for radiusButton
  static const double radiusCard = 22.0; // Large cards (20 to 24 range)
  static const double radiusXl = 22.0; // Alias for radiusCard
  static const double radiusPill = 999.0; // Full pill for chips & top pills

  // Touch Target & Heights (AGENTS.md §4.6 & §12.9)
  static const double minTouchTarget = 48.0;
  static const double buttonHeightSm = 44.0;
  static const double buttonHeightMd = 52.0;
  static const double buttonHeightLg = 58.0;

  // 3D Depth Offsets
  static const double depthSm = 3.0;
  static const double depthMd = 4.0;
  static const double depthLg = 6.0;

  // Responsive Content Widths (AGENTS.md §4.3)
  static const double maxContentWidthCompact = 560.0;
  static const double maxContentWidthMedium = 640.0;
  static const double maxContentWidthExpanded = 720.0;
  static const double maxDialogWidth = 500.0;

  // Soft Card Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0D1E1647), blurRadius: 16.0, offset: Offset(0, 4)),
  ];
}
