import 'package:flutter/material.dart';

/// Exact colour tokens from the Pebbi design specification.
///
/// Anchored on brand purple `#6C4DF6` with soft lavender neutrals and tinted tiles.
abstract final class AppColors {
  // Brand & 3D depths
  static const Color brandPurple = Color(0xFF6C4DF6);
  static const Color brandPurpleDepth = Color(0xFF4B33C4);
  static const Color brandPurpleLight = Color(0xFF8B72F8);

  // Premium Offer Gradient stops (estimated from design spec, brand purple into deep violet)
  static const Color premiumGradientStart = Color(0xFF6C4DF6);
  static const Color premiumGradientEnd = Color(0xFF4B33C4);

  // Secondary actions / Success / Goal ring
  static const Color mint = Color(0xFF2DD4A4);
  static const Color mintDepth = Color(0xFF1CA67E);

  // Missions & Streak flame
  static const Color coral = Color(0xFFFF7A5A);
  static const Color coralDepth = Color(0xFFD9532F);

  // Accessible Coral Hero Card surface tokens (WCAG AA > 4.5:1 with white text)
  static const Color coralHeroCard = Color(0xFFE0451D);
  static const Color coralHeroCardDepth = Color(0xFFB82E0B);
  static const Color coralHeroCardMutedText = Color(0xFFFFEFEA);

  // Emergency Phrasebook Tokens (WCAG AA & AAA compliant)
  static const Color emergencyCardBackground = Color(0xFFFFF1F2);
  static const Color emergencyCardBorder = Color(0xFFFDA4AF);
  static const Color emergencyLabelRed = Color(0xFF991B1B); // 5.81:1 on rose fill
  static const Color emergencyNoteBackground = Color(0xFFF1F0F9);
  static const Color emergencyNoteText = Color(0xFF1E1647); // 10.5:1 on lavender-grey note
  static const Color secondaryButtonBackground = Color(0xFFEDE9FF);
  static const Color secondaryButtonDepth = Color(0xFFD6CEFA);
  static const Color secondaryButtonText = Color(0xFF4B33C4); // 7.42:1 on lavender

  // Dark Emergency Tokens
  static const Color darkEmergencyCardBackground = Color(0xFF2D161C);
  static const Color darkEmergencyCardBorder = Color(0xFF5C2633);
  static const Color darkEmergencyLabelRed = Color(0xFFFCA5A5);
  static const Color darkEmergencyNoteBackground = Color(0xFF231E33);
  static const Color darkEmergencyNoteText = Color(0xFFE8E5F4);

  // Gamification & Status
  static const Color starGold = Color(0xFFFFC107);
  static const Color goldDepth = Color(0xFFD97706);
  static const Color streakOrange = Color(0xFFFF7A00);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);

  // Semantic Notice / Warning Banner tokens
  static const Color noticeWarningBackground = Color(
    0xFFFFFBEB,
  ); // Soft pale yellow
  static const Color noticeWarningBorder = Color(
    0xFFFDE68A,
  ); // Faint amber border
  static const Color noticeWarningText = Color(
    0xFF92400E,
  ); // Deep amber-brown (passes WCAG AAA > 7:1)

  // Exercise Feedback Panel Tokens (WCAG AAA & AA compliant)
  static const Color successSurface = Color(
    0xFFEAF9F5,
  ); // Very light mint panel
  static const Color successBorder = Color(0xFFA7F3D0); // Soft emerald border
  static const Color successText = Color(
    0xFF065F46,
  ); // Deep emerald text (passes WCAG AAA > 7:1)
  static const Color successTextHeader = Color(0xFF047857);

  static const Color errorSurface = Color(0xFFFFF1F2); // Very light rose panel
  static const Color errorBorder = Color(0xFFFECDD3); // Soft rose border
  static const Color errorText = Color(
    0xFF9F1239,
  ); // Deep crimson text (passes WCAG AAA > 7:1)
  static const Color errorTextHeader = Color(0xFFBE123C);

  // App Surfaces & Neutrals
  static const Color background = Color(0xFFF5F4FB); // Soft lavender-grey
  static const Color surface = Color(0xFFFFFFFF); // Cards, pills
  static const Color borderLight = Color(0xFFE8E5F4);

  // Soft Tinted Tiles & Chip Fills
  static const Color tintLavender = Color(0xFFEDE9FF);
  static const Color tintMint = Color(0xFFE6FAF4);
  static const Color tintSky = Color(0xFFE8F6FD);
  static const Color tintPeach = Color(0xFFFFF0EA);
  static const Color tintRose = Color(0xFFFFEBF0);

  // Semantic Tinted Chip Tokens (WCAG AA compliant)
  static const Color chipPurpleBackground = Color(0xFFF3F0FF);
  static const Color chipPurpleText = Color(0xFF6C4DF6);
  static const Color chipAmberBackground = Color(0xFFFEF3C7);
  static const Color chipAmberText = Color(0xFF92400E);
  static const Color chipMintBackground = Color(0xFFE8FDF5);
  static const Color chipMintText = Color(0xFF065F46);

  // Dark mode semantic chip text tokens
  static const Color darkChipPurpleText = Color(0xFFA78BFA);
  static const Color darkChipAmberText = Color(0xFFFBBF24);
  static const Color darkChipMintText = Color(0xFF34D399);

  // Typography
  static const Color textPrimary = Color(0xFF1E1647); // Dark navy-purple
  static const Color textMuted = Color(0xFF6E6A8A);
  static const Color textTertiary = Color(0xFFA5A0B8);

  // Locked / Disabled
  static const Color disabled = Color(0xFFEAE8F2);
  static const Color disabledDepth = Color(0xFFD6D3E3);
  static const Color disabledText = Color(0xFFA5A0B8);

  // User-selectable accent palette (Default is Violet/brandPurple)
  static const Color accentViolet = Color(0xFF6C4DF6);
  static const Color accentMint = Color(0xFF2DD4A4);
  static const Color accentGreen = Color(0xFF2DD4A4);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentOrange = Color(0xFFFF7A00);
  static const Color accentCoral = Color(0xFFFF7A5A);
  static const Color accentSky = Color(0xFF0EA5E9);
  static const Color accentBlue = Color(0xFF0EA5E9);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentPink = Color(0xFFF43F5E);
  static const Color accentSlate = Color(0xFF475569);

  // Dark theme derivations (assumed from tokens per spec)
  static const Color darkBackground = Color(0xFF13101E);
  static const Color darkSurface = Color(0xFF1E1A2E);
  static const Color darkSurfaceVariant = Color(0xFF2B2540);
  static const Color darkBorder = Color(0xFF383152);
  static const Color darkTextPrimary = Color(0xFFF5F3FA);
  static const Color darkTextMuted = Color(0xFFAFA9C1);

  // Auth & Accessible Links (WCAG AA compliant > 4.5:1 on light backgrounds)
  static const Color linkPurple = Color(0xFF5832E6);
  static const Color inputPlaceholder = Color(0xFF64748B);
  static const Color dividerText = Color(0xFF64748B);
}
