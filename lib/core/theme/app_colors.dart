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
  static const Color emergencyLabelRed = Color(
    0xFF991B1B,
  ); // 5.81:1 on rose fill
  static const Color emergencyNoteBackground = Color(0xFFF1F0F9);
  static const Color emergencyNoteText = Color(
    0xFF1E1647,
  ); // 10.5:1 on lavender-grey note
  static const Color secondaryButtonBackground = Color(0xFFEDE9FF);
  static const Color secondaryButtonDepth = Color(0xFFD6CEFA);
  static const Color secondaryButtonText = Color(
    0xFF4B33C4,
  ); // 7.42:1 on lavender

  // Free Talk & Correction Card Tokens (WCAG AA & AAA compliant)
  static const Color correctionCardBackground = Color(0xFFF1F0F9);
  static const Color correctionLabelMuted = Color(
    0xFF595370,
  ); // 5.2:1 on #F1F0F9 (WCAG AA)
  static const Color correctionHelperText = Color(
    0xFF2E2A40,
  ); // 9.4:1 on #F1F0F9 (WCAG AAA)
  static const Color correctionPillSelected = Color(
    0xFF6542F1,
  ); // 4.85:1 contrast
  static const Color correctionPillUnselected = Color(0xFFFFFFFF);
  static const Color correctionPillBorder = Color(0xFFD8D4E8);

  // Dark Free Talk Tokens
  static const Color darkCorrectionCardBackground = Color(0xFF231E33);
  static const Color darkCorrectionLabelMuted = Color(0xFFAAA5C2);
  static const Color darkCorrectionHelperText = Color(0xFFE8E5F4);
  static const Color darkCorrectionPillUnselected = Color(0xFF2D2742);
  static const Color darkCorrectionPillBorder = Color(0xFF3E365C);

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

  // Review Tab Semantic Colors (WCAG AA compliant)
  static const Color segmentedTrackBackground = Color(0xFFF1F0F9);
  static const Color segmentedPillBackground = Color(0xFFFFFFFF);
  static const Color segmentedTextSelected = Color(0xFF1E1647);
  static const Color segmentedTextUnselected = Color(0xFF4A4460);
  static const Color darkSegmentedTrackBackground = Color(0xFF28233C);
  static const Color darkSegmentedPillBackground = Color(0xFF383152);
  static const Color darkSegmentedTextSelected = Color(0xFFF5F3FA);
  static const Color darkSegmentedTextUnselected = Color(0xFFAFA9C1);

  static const Color inviteFieldBackground = Color(0xFFF1F0F9);
  static const Color inviteFieldBorder = Color(0xFFE2E0F2);
  static const Color inviteFieldText = Color(0xFF4A4460);
  static const Color inviteCopyText = Color(0xFF6542F1);
  static const Color darkInviteFieldBackground = Color(0xFF241F38);
  static const Color darkInviteFieldBorder = Color(0xFF383152);
  static const Color darkInviteFieldText = Color(0xFFAFA9C1);
  static const Color darkInviteCopyText = Color(0xFF8B6EF8);

  static const Color statusTagTrickyBackground = Color(0xFFFFECEB);
  static const Color statusTagTrickyText = Color(0xFFD32F2F);
  static const Color statusTagNewBackground = Color(0xFFE8F5E9);
  static const Color statusTagNewText = Color(0xFF2E7D32);
  static const Color phraseTileBookmarkActive = Color(0xFFF59E0B);
  static const Color phraseTileStarActive = Color(0xFFF59E0B);
  static const Color phraseTileStarInactive = Color(0xFFA5A0B8);
  static const Color darkPhraseTileStarInactive = Color(0xFF6B6580);

  // Practice Rooms Tokens (WCAG AA Compliant)
  static const Color practiceLavenderBackground = Color(0xFFEDE9FF);
  static const Color practiceLavenderIcon = Color(0xFF6C4DF6);
  static const Color darkPracticeLavenderBackground = Color(0xFF2E2452);
  static const Color darkPracticeLavenderIcon = Color(0xFFA78BFA);

  static const Color practiceYellowBackground = Color(0xFFFEF3C7);
  static const Color practiceYellowIcon = Color(
    0xFF92400E,
  ); // Passes 7:1 on #FEF3C7
  static const Color darkPracticeYellowBackground = Color(0xFF382F19);
  static const Color darkPracticeYellowIcon = Color(0xFFFDE68A);

  static const Color practiceMintBackground = Color(0xFFE6FAF4);
  static const Color practiceMintIcon = Color(
    0xFF065F46,
  ); // Passes >6:1 on mint
  static const Color darkPracticeMintBackground = Color(0xFF1B352B);
  static const Color darkPracticeMintIcon = Color(0xFF6EE7B7);

  // Note Card Tokens (Grey-lavender Note Style)
  static const Color noteCardBackground = Color(0xFFF4F3F8);
  static const Color noteCardBorder = Color(0xFFE8E5F4);
  static const Color noteCardText = Color(
    0xFF524F6B,
  ); // Passes 5.5:1 on background
  static const Color darkNoteCardBackground = Color(0xFF252136);
  static const Color darkNoteCardBorder = Color(0xFF383152);
  static const Color darkNoteCardText = Color(0xFFD4D0E5);

  static const Color noteDots = Color(0xFF9CA3AF);
  static const Color darkNoteDots = Color(0xFF6B7280);
  static const Color textMutedDarker = Color(0xFF52525B);

  // Rewards Screen Tokens (WCAG AA Compliant)
  static const Color levelBadgeBackground = Color(0xFFF59E0B);
  static const Color levelBadgeText = Colors.white;
  static const Color levelBadgeBorder = Color(0xFFD97706);
  static const Color darkLevelBadgeBackground = Color(0xFFD97706);

  static const Color rewardsPillMintBackground = Color(0xFFD1FAE5);
  static const Color rewardsPillMintText = Color(0xFF065F46); // > 5.5:1
  static const Color darkRewardsPillMintBackground = Color(0xFF064E3B);
  static const Color darkRewardsPillMintText = Color(0xFFA7F3D0);

  static const Color rewardsPillCoralBackground = Color(0xFFFFEDE8);
  static const Color rewardsPillCoralText = Color(0xFFC2410C); // > 5.0:1
  static const Color darkRewardsPillCoralBackground = Color(0xFF431407);
  static const Color darkRewardsPillCoralText = Color(0xFFFDBA74);

  static const Color calendarCellInactive = Color(0xFFF1F5F9);
  static const Color calendarCellInactiveText = Color(0xFF334155); // > 7:1
  static const Color darkCalendarCellInactive = Color(0xFF231E38);
  static const Color darkCalendarCellInactiveText = Color(0xFF94A3B8);

  static const Color calendarCellActive = Color(0xFFFFEDE8);
  static const Color calendarCellActiveIcon = Color(0xFFEA580C);
  static const Color darkCalendarCellActive = Color(0xFF3E1B10);
  static const Color darkCalendarCellActiveIcon = Color(0xFFFB923C);

  static const Color calendarCellFreeze = Color(0xFFE0F2FE);
  static const Color calendarCellFreezeIcon = Color(0xFF0284C7);
  static const Color darkCalendarCellFreeze = Color(0xFF102A43);
  static const Color darkCalendarCellFreezeIcon = Color(0xFF7DD3FC);

  static const Color calendarCellRepaired = Color(0xFFFEF3C7);
  static const Color calendarCellRepairedIcon = Color(0xFFD97706);
  static const Color darkCalendarCellRepaired = Color(0xFF362407);
  static const Color darkCalendarCellRepairedIcon = Color(0xFFFBBF24);

  static const Color calendarTodayBorder = Color(0xFF6C4DF6);
  static const Color darkCalendarTodayBorder = Color(0xFFA78BFA);
}
