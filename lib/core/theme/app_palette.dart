import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Semantic color palette providing a unified single source of truth for Light and Dark modes.
///
/// Follows AGENTS.md §2 (core/theme), §3 (maintainable, clean), and WCAG AA contrast standards.
/// Accessible via [BuildContext.palette].
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceRaised,
    required this.outline,
    required this.divider,
    required this.textPrimary,
    required this.textMuted,
    required this.textTertiary,
    required this.textOnBrand,
    required this.textOnAccent,
    required this.brand,
    required this.brandDepth,
    required this.brandTint,
    required this.brandText,
    required this.accent,
    required this.accentDepth,
    required this.accentTint,
    required this.mint,
    required this.mintDepth,
    required this.mintTint,
    required this.coral,
    required this.coralDepth,
    required this.coralTint,
    required this.coralHeroCard,
    required this.coralHeroCardDepth,
    required this.coralHeroCardMutedText,
    required this.successSurface,
    required this.successBorder,
    required this.successText,
    required this.errorSurface,
    required this.errorBorder,
    required this.errorText,
    required this.warningSurface,
    required this.warningBorder,
    required this.warningText,
    required this.infoSurface,
    required this.infoBorder,
    required this.infoText,
    required this.tintLavender,
    required this.tintMint,
    required this.tintSky,
    required this.tintPeach,
    required this.tintRose,
    required this.tintYellow,
    required this.chipSelectedFill,
    required this.chipSelectedBorder,
    required this.chipSelectedText,
    required this.chipUnselectedFill,
    required this.chipUnselectedBorder,
    required this.chipUnselectedText,
    required this.inputFill,
    required this.inputBorder,
    required this.inputFocus,
    required this.disabledFill,
    required this.disabledDepth,
    required this.disabledText,
    required this.switchTrackActive,
    required this.switchTrackInactive,
    required this.sliderTrackActive,
    required this.sliderTrackInactive,
    required this.progressTrack,
    required this.nodeDone,
    required this.nodeDoneDepth,
    required this.nodeCurrent,
    required this.nodeCurrentDepth,
    required this.nodeLocked,
    required this.nodeLockedDepth,
    required this.connectorDone,
    required this.connectorPending,
    required this.tabBarBackground,
    required this.tabBarBorder,
    required this.tabBarIndicator,
    required this.tabBarSelected,
    required this.tabBarUnselected,
    required this.navRailBackground,
    required this.scrim,
    required this.gold,
    required this.goldDepth,
    required this.goldStarOutline,
    required this.cardShadow,
    required this.button3dEdge,
    required this.splashGradientTop,
    required this.splashGradientBottom,
    required this.splashBackgroundSolid,
  });

  final Brightness brightness;

  // Surfaces & layout
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceRaised;
  final Color outline;
  final Color divider;

  // Typography
  final Color textPrimary;
  final Color textMuted;
  final Color textTertiary;
  final Color textOnBrand;
  final Color textOnAccent;

  // Brand & Accent
  final Color brand;
  final Color brandDepth;
  final Color brandTint;
  final Color brandText;
  final Color accent;
  final Color accentDepth;
  final Color accentTint;

  // Secondaries / Gamification
  final Color mint;
  final Color mintDepth;
  final Color mintTint;
  final Color coral;
  final Color coralDepth;
  final Color coralTint;
  final Color coralHeroCard;
  final Color coralHeroCardDepth;
  final Color coralHeroCardMutedText;

  // Semantic statuses
  final Color successSurface;
  final Color successBorder;
  final Color successText;
  final Color errorSurface;
  final Color errorBorder;
  final Color errorText;
  final Color warningSurface;
  final Color warningBorder;
  final Color warningText;
  final Color infoSurface;
  final Color infoBorder;
  final Color infoText;

  // Tint tones
  final Color tintLavender;
  final Color tintMint;
  final Color tintSky;
  final Color tintPeach;
  final Color tintRose;
  final Color tintYellow;

  // Chips
  final Color chipSelectedFill;
  final Color chipSelectedBorder;
  final Color chipSelectedText;
  final Color chipUnselectedFill;
  final Color chipUnselectedBorder;
  final Color chipUnselectedText;

  // Inputs
  final Color inputFill;
  final Color inputBorder;
  final Color inputFocus;

  // Disabled / Inactive
  final Color disabledFill;
  final Color disabledDepth;
  final Color disabledText;

  // Controls
  final Color switchTrackActive;
  final Color switchTrackInactive;
  final Color sliderTrackActive;
  final Color sliderTrackInactive;
  final Color progressTrack;

  // Path Nodes & Connectors
  final Color nodeDone;
  final Color nodeDoneDepth;
  final Color nodeCurrent;
  final Color nodeCurrentDepth;
  final Color nodeLocked;
  final Color nodeLockedDepth;
  final Color connectorDone;
  final Color connectorPending;

  // Shell & Navigation
  final Color tabBarBackground;
  final Color tabBarBorder;
  final Color tabBarIndicator;
  final Color tabBarSelected;
  final Color tabBarUnselected;
  final Color navRailBackground;

  // Misc
  final Color scrim;
  final Color gold;
  final Color goldDepth;
  final Color goldStarOutline;
  final List<BoxShadow> cardShadow;
  final Color button3dEdge;

  // Splash Screen Tokens
  final Color splashGradientTop;
  final Color splashGradientBottom;
  final Color splashBackgroundSolid;

  bool get isDark => brightness == Brightness.dark;

  /// Creates a Light mode palette instance.
  factory AppPalette.light([Color accentColor = AppColors.brandPurple]) {
    final (accDepth, accTint) = _resolveAccentDerivatives(accentColor, false);

    return AppPalette(
      brightness: Brightness.light,
      background: AppColors.background, // #F5F4FB
      surface: AppColors.surface, // #FFFFFF
      surfaceVariant: const Color(0xFFF1F0F9),
      surfaceRaised: AppColors.surface,
      outline: AppColors.borderLight, // #E8E5F4
      divider: AppColors.borderLight,
      textPrimary: AppColors.textPrimary, // #1E1647
      textMuted: AppColors.textMuted, // #6E6A8A
      textTertiary: AppColors.textTertiary, // #A5A0B8
      textOnBrand: Colors.white,
      textOnAccent: Colors.white,
      brand: AppColors.brandPurple, // #6C4DF6
      brandDepth: AppColors.brandPurpleDepth, // #4B33C4
      brandTint: AppColors.tintLavender, // #EDE9FF
      brandText: AppColors.brandPurple,
      accent: accentColor,
      accentDepth: accDepth,
      accentTint: accTint,
      mint: AppColors.mint, // #2DD4A4
      mintDepth: AppColors.mintDepth, // #1CA67E
      mintTint: AppColors.tintMint, // #E6FAF4
      coral: AppColors.coral, // #FF7A5A
      coralDepth: AppColors.coralDepth, // #D9532F
      coralTint: AppColors.tintPeach, // #FFF0EA
      coralHeroCard: const Color(0xFFC7360E),
      coralHeroCardDepth: const Color(0xFFA02808),
      coralHeroCardMutedText: const Color(0xFFFFF2EE),
      successSurface: AppColors.successSurface, // #EAF9F5
      successBorder: AppColors.successBorder, // #A7F3D0
      successText: AppColors.successText, // #065F46
      errorSurface: AppColors.errorSurface, // #FFF1F2
      errorBorder: AppColors.errorBorder, // #FECDD3
      errorText: AppColors.errorText, // #9F1239
      warningSurface: AppColors.noticeWarningBackground, // #FFFBEB
      warningBorder: AppColors.noticeWarningBorder, // #FDE68A
      warningText: AppColors.noticeWarningText, // #92400E
      infoSurface: AppColors.infoSurface, // #E8F6FD
      infoBorder: AppColors.infoBorder, // #BAE6FD
      infoText: AppColors.infoText, // #0369A1
      tintLavender: AppColors.tintLavender, // #EDE9FF
      tintMint: AppColors.tintMint, // #E6FAF4
      tintSky: AppColors.tintSky, // #E8F6FD
      tintPeach: AppColors.tintPeach, // #FFF0EA
      tintRose: AppColors.tintRose, // #FFEBF0
      tintYellow: const Color(0xFFFEF3C7),
      chipSelectedFill: AppColors.brandPurple,
      chipSelectedBorder: AppColors.brandPurple,
      chipSelectedText: Colors.white,
      chipUnselectedFill: AppColors.surface,
      chipUnselectedBorder: AppColors.borderLight,
      chipUnselectedText: AppColors.textMuted,
      inputFill: const Color(0xFFF3F0FA),
      inputBorder: AppColors.borderLight,
      inputFocus: AppColors.brandPurple,
      disabledFill: AppColors.disabled, // #EAE8F2
      disabledDepth: AppColors.disabledDepth, // #D6D3E3
      disabledText: AppColors.disabledText, // #A5A0B8
      switchTrackActive: AppColors.settingsSwitchMintTrack, // #25C974
      switchTrackInactive: AppColors.settingsSwitchOffTrack, // #D6D3E3
      sliderTrackActive: AppColors.brandPurple,
      sliderTrackInactive: AppColors.settingsSliderInactiveTrack, // #DCD8E8
      progressTrack: AppColors.borderLight,
      nodeDone: AppColors.mint,
      nodeDoneDepth: AppColors.mintDepth,
      nodeCurrent: AppColors.brandPurple,
      nodeCurrentDepth: AppColors.brandPurpleDepth,
      nodeLocked: AppColors.disabled,
      nodeLockedDepth: AppColors.disabledDepth,
      connectorDone: AppColors.mint,
      connectorPending: AppColors.borderLight,
      tabBarBackground: AppColors.surface,
      tabBarBorder: AppColors.borderLight,
      tabBarIndicator: AppColors.tintLavender,
      tabBarSelected: AppColors.brandPurple,
      tabBarUnselected: AppColors.textMuted,
      navRailBackground: AppColors.surface,
      scrim: const Color(0x52000000),
      gold: AppColors.goldStar, // #D97706 passes 3.26:1 on white
      goldDepth: AppColors.goldDepth,
      goldStarOutline: AppColors.goldStarOutline,
      cardShadow: AppSpacing.cardShadow,
      button3dEdge: const Color(0x33000000),
      splashGradientTop: AppColors.splashGradientTop,
      splashGradientBottom: AppColors.splashGradientBottom,
      splashBackgroundSolid: AppColors.splashBackgroundSolid,
    );
  }

  /// Creates a Dark mode palette instance.
  ///
  /// TODO(question): Dark palette values are estimates anchored on deep navy-violet
  /// and must be confirmed by the design team when formal dark mockups are available.
  factory AppPalette.dark([Color accentColor = AppColors.brandPurple]) {
    final (accDepth, accTint) = _resolveAccentDerivatives(accentColor, true);

    return AppPalette(
      brightness: Brightness.dark,
      background: AppColors.darkBackground, // #13101E
      surface: AppColors.darkSurface, // #1E1A2E
      surfaceVariant: AppColors.darkSurfaceVariant, // #2B2540
      surfaceRaised: const Color(0xFF322B4A),
      outline: AppColors.darkBorder, // #383152
      divider: AppColors.darkBorder,
      textPrimary: AppColors.darkTextPrimary, // #F5F3FA
      textMuted: AppColors.darkTextMuted, // #AFA9C1
      textTertiary: const Color(0xFF867E9E),
      textOnBrand: Colors.white,
      textOnAccent: Colors.white,
      brand: AppColors.brandPurple, // #6C4DF6
      brandDepth: AppColors.brandPurpleDepth, // #4B33C4
      brandTint: const Color(0xFF2E2452),
      brandText: const Color(
        0xFFA78BFA,
      ), // Lightened brand purple for readable text on dark
      accent: accentColor,
      accentDepth: accDepth,
      accentTint: accTint,
      mint: AppColors.mint, // #2DD4A4
      mintDepth: const Color(0xFF1B8062),
      mintTint: const Color(0xFF1B352B),
      coral: AppColors.coral, // #FF7A5A
      coralDepth: const Color(0xFFB83E1E),
      coralTint: const Color(0xFF3E1B10),
      coralHeroCard: const Color(0xFFC7360E),
      coralHeroCardDepth: const Color(0xFFA02808),
      coralHeroCardMutedText: const Color(0xFFFFF2EE),
      successSurface: const Color(0xFF133529),
      successBorder: const Color(0xFF1F5A44),
      successText: const Color(0xFF6EE7B7),
      errorSurface: const Color(0xFF38141C),
      errorBorder: const Color(0xFF6B2332),
      errorText: const Color(0xFFFDA4AF),
      warningSurface: const Color(0xFF36270E),
      warningBorder: const Color(0xFF6B4F1B),
      warningText: const Color(0xFFFDE68A),
      infoSurface: AppColors.darkInfoSurface, // #102A3C
      infoBorder: AppColors.darkInfoBorder, // #1B4868
      infoText: AppColors.darkInfoText, // #7DD3FC
      tintLavender: const Color(0xFF2E2452),
      tintMint: const Color(0xFF1B352B),
      tintSky: const Color(0xFF162A38),
      tintPeach: const Color(0xFF361E14),
      tintRose: const Color(0xFF36151E),
      tintYellow: const Color(0xFF36270E),
      chipSelectedFill: AppColors.brandPurple,
      chipSelectedBorder: const Color(0xFFA78BFA),
      chipSelectedText: Colors.white,
      chipUnselectedFill: AppColors.darkSurfaceVariant, // #2B2540
      chipUnselectedBorder: AppColors.darkBorder, // #383152
      chipUnselectedText: AppColors.darkTextMuted,
      inputFill: const Color(0xFF28233D),
      inputBorder: AppColors.darkBorder,
      inputFocus: const Color(0xFFA78BFA),
      disabledFill: const Color(0xFF262136),
      disabledDepth: const Color(0xFF1B1727),
      disabledText: const Color(0xFF6B6580),
      switchTrackActive: AppColors.settingsSwitchMintTrack,
      switchTrackInactive: const Color(0xFF3B3450),
      sliderTrackActive: const Color(0xFFA78BFA),
      sliderTrackInactive: AppColors.darkBorder,
      progressTrack: AppColors.darkBorder,
      nodeDone: AppColors.mint,
      nodeDoneDepth: const Color(0xFF1B8062),
      nodeCurrent: AppColors.brandPurple,
      nodeCurrentDepth: AppColors.brandPurpleDepth,
      nodeLocked: const Color(0xFF262136),
      nodeLockedDepth: const Color(0xFF1B1727),
      connectorDone: AppColors.mint,
      connectorPending: AppColors.darkBorder,
      tabBarBackground: AppColors.darkSurface, // #1E1A2E
      tabBarBorder: AppColors.darkBorder, // #383152
      tabBarIndicator: const Color(0xFF2E2452),
      tabBarSelected: const Color(0xFFA78BFA),
      tabBarUnselected: AppColors.darkTextMuted,
      navRailBackground: AppColors.darkSurface,
      scrim: const Color(0x80000000),
      gold: const Color(0xFFFBBF24),
      goldDepth: const Color(0xFFD97706),
      goldStarOutline: AppColors.darkGoldStarOutline,
      cardShadow:
          const [], // Dark mode avoids muddy drop shadows, uses subtle borders
      button3dEdge: const Color(0x4D000000),
      splashGradientTop: AppColors.splashGradientTop,
      splashGradientBottom: AppColors.splashGradientBottom,
      splashBackgroundSolid: AppColors.splashBackgroundSolid,
    );
  }

  static (Color, Color) _resolveAccentDerivatives(Color accent, bool isDark) {
    if (accent == AppColors.brandPurple) {
      return (
        AppColors.brandPurpleDepth,
        isDark ? const Color(0xFF2E2452) : AppColors.tintLavender,
      );
    } else if (accent == AppColors.mint) {
      return (
        AppColors.mintDepth,
        isDark ? const Color(0xFF1B352B) : AppColors.tintMint,
      );
    } else if (accent == AppColors.accentOrange || accent == AppColors.coral) {
      return (
        AppColors.coralDepth,
        isDark ? const Color(0xFF3E1B10) : AppColors.tintPeach,
      );
    } else if (accent == AppColors.accentBlue) {
      return (
        const Color(0xFF0284C7),
        isDark ? const Color(0xFF162A38) : AppColors.tintSky,
      );
    } else if (accent == AppColors.accentRose) {
      return (
        const Color(0xFFBE123C),
        isDark ? const Color(0xFF36151E) : AppColors.tintRose,
      );
    } else if (accent == AppColors.accentAmber) {
      return (
        const Color(0xFFD97706),
        isDark ? const Color(0xFF36270E) : const Color(0xFFFEF3C7),
      );
    }
    return (
      AppColors.brandPurpleDepth,
      isDark ? const Color(0xFF2E2452) : AppColors.tintLavender,
    );
  }

  @override
  ThemeExtension<AppPalette> copyWith({
    Brightness? brightness,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? surfaceRaised,
    Color? outline,
    Color? divider,
    Color? textPrimary,
    Color? textMuted,
    Color? textTertiary,
    Color? textOnBrand,
    Color? textOnAccent,
    Color? brand,
    Color? brandDepth,
    Color? brandTint,
    Color? brandText,
    Color? accent,
    Color? accentDepth,
    Color? accentTint,
    Color? mint,
    Color? mintDepth,
    Color? mintTint,
    Color? coral,
    Color? coralDepth,
    Color? coralTint,
    Color? coralHeroCard,
    Color? coralHeroCardDepth,
    Color? coralHeroCardMutedText,
    Color? successSurface,
    Color? successBorder,
    Color? successText,
    Color? errorSurface,
    Color? errorBorder,
    Color? errorText,
    Color? warningSurface,
    Color? warningBorder,
    Color? warningText,
    Color? infoSurface,
    Color? infoBorder,
    Color? infoText,
    Color? tintLavender,
    Color? tintMint,
    Color? tintSky,
    Color? tintPeach,
    Color? tintRose,
    Color? tintYellow,
    Color? chipSelectedFill,
    Color? chipSelectedBorder,
    Color? chipSelectedText,
    Color? chipUnselectedFill,
    Color? chipUnselectedBorder,
    Color? chipUnselectedText,
    Color? inputFill,
    Color? inputBorder,
    Color? inputFocus,
    Color? disabledFill,
    Color? disabledDepth,
    Color? disabledText,
    Color? switchTrackActive,
    Color? switchTrackInactive,
    Color? sliderTrackActive,
    Color? sliderTrackInactive,
    Color? progressTrack,
    Color? nodeDone,
    Color? nodeDoneDepth,
    Color? nodeCurrent,
    Color? nodeCurrentDepth,
    Color? nodeLocked,
    Color? nodeLockedDepth,
    Color? connectorDone,
    Color? connectorPending,
    Color? tabBarBackground,
    Color? tabBarBorder,
    Color? tabBarIndicator,
    Color? tabBarSelected,
    Color? tabBarUnselected,
    Color? navRailBackground,
    Color? scrim,
    Color? gold,
    Color? goldDepth,
    Color? goldStarOutline,
    List<BoxShadow>? cardShadow,
    Color? button3dEdge,
    Color? splashGradientTop,
    Color? splashGradientBottom,
    Color? splashBackgroundSolid,
  }) {
    return AppPalette(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      outline: outline ?? this.outline,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      textTertiary: textTertiary ?? this.textTertiary,
      textOnBrand: textOnBrand ?? this.textOnBrand,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      brand: brand ?? this.brand,
      brandDepth: brandDepth ?? this.brandDepth,
      brandTint: brandTint ?? this.brandTint,
      brandText: brandText ?? this.brandText,
      accent: accent ?? this.accent,
      accentDepth: accentDepth ?? this.accentDepth,
      accentTint: accentTint ?? this.accentTint,
      mint: mint ?? this.mint,
      mintDepth: mintDepth ?? this.mintDepth,
      mintTint: mintTint ?? this.mintTint,
      coral: coral ?? this.coral,
      coralDepth: coralDepth ?? this.coralDepth,
      coralTint: coralTint ?? this.coralTint,
      coralHeroCard: coralHeroCard ?? this.coralHeroCard,
      coralHeroCardDepth: coralHeroCardDepth ?? this.coralHeroCardDepth,
      coralHeroCardMutedText:
          coralHeroCardMutedText ?? this.coralHeroCardMutedText,
      successSurface: successSurface ?? this.successSurface,
      successBorder: successBorder ?? this.successBorder,
      successText: successText ?? this.successText,
      errorSurface: errorSurface ?? this.errorSurface,
      errorBorder: errorBorder ?? this.errorBorder,
      errorText: errorText ?? this.errorText,
      warningSurface: warningSurface ?? this.warningSurface,
      warningBorder: warningBorder ?? this.warningBorder,
      warningText: warningText ?? this.warningText,
      infoSurface: infoSurface ?? this.infoSurface,
      infoBorder: infoBorder ?? this.infoBorder,
      infoText: infoText ?? this.infoText,
      tintLavender: tintLavender ?? this.tintLavender,
      tintMint: tintMint ?? this.tintMint,
      tintSky: tintSky ?? this.tintSky,
      tintPeach: tintPeach ?? this.tintPeach,
      tintRose: tintRose ?? this.tintRose,
      tintYellow: tintYellow ?? this.tintYellow,
      chipSelectedFill: chipSelectedFill ?? this.chipSelectedFill,
      chipSelectedBorder: chipSelectedBorder ?? this.chipSelectedBorder,
      chipSelectedText: chipSelectedText ?? this.chipSelectedText,
      chipUnselectedFill: chipUnselectedFill ?? this.chipUnselectedFill,
      chipUnselectedBorder: chipUnselectedBorder ?? this.chipUnselectedBorder,
      chipUnselectedText: chipUnselectedText ?? this.chipUnselectedText,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFocus: inputFocus ?? this.inputFocus,
      disabledFill: disabledFill ?? this.disabledFill,
      disabledDepth: disabledDepth ?? this.disabledDepth,
      disabledText: disabledText ?? this.disabledText,
      switchTrackActive: switchTrackActive ?? this.switchTrackActive,
      switchTrackInactive: switchTrackInactive ?? this.switchTrackInactive,
      sliderTrackActive: sliderTrackActive ?? this.sliderTrackActive,
      sliderTrackInactive: sliderTrackInactive ?? this.sliderTrackInactive,
      progressTrack: progressTrack ?? this.progressTrack,
      nodeDone: nodeDone ?? this.nodeDone,
      nodeDoneDepth: nodeDoneDepth ?? this.nodeDoneDepth,
      nodeCurrent: nodeCurrent ?? this.nodeCurrent,
      nodeCurrentDepth: nodeCurrentDepth ?? this.nodeCurrentDepth,
      nodeLocked: nodeLocked ?? this.nodeLocked,
      nodeLockedDepth: nodeLockedDepth ?? this.nodeLockedDepth,
      connectorDone: connectorDone ?? this.connectorDone,
      connectorPending: connectorPending ?? this.connectorPending,
      tabBarBackground: tabBarBackground ?? this.tabBarBackground,
      tabBarBorder: tabBarBorder ?? this.tabBarBorder,
      tabBarIndicator: tabBarIndicator ?? this.tabBarIndicator,
      tabBarSelected: tabBarSelected ?? this.tabBarSelected,
      tabBarUnselected: tabBarUnselected ?? this.tabBarUnselected,
      navRailBackground: navRailBackground ?? this.navRailBackground,
      scrim: scrim ?? this.scrim,
      gold: gold ?? this.gold,
      goldDepth: goldDepth ?? this.goldDepth,
      goldStarOutline: goldStarOutline ?? this.goldStarOutline,
      cardShadow: cardShadow ?? this.cardShadow,
      button3dEdge: button3dEdge ?? this.button3dEdge,
      splashGradientTop: splashGradientTop ?? this.splashGradientTop,
      splashGradientBottom: splashGradientBottom ?? this.splashGradientBottom,
      splashBackgroundSolid:
          splashBackgroundSolid ?? this.splashBackgroundSolid,
    );
  }

  @override
  ThemeExtension<AppPalette> lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;

    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textOnBrand: Color.lerp(textOnBrand, other.textOnBrand, t)!,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandDepth: Color.lerp(brandDepth, other.brandDepth, t)!,
      brandTint: Color.lerp(brandTint, other.brandTint, t)!,
      brandText: Color.lerp(brandText, other.brandText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDepth: Color.lerp(accentDepth, other.accentDepth, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      mintDepth: Color.lerp(mintDepth, other.mintDepth, t)!,
      mintTint: Color.lerp(mintTint, other.mintTint, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      coralDepth: Color.lerp(coralDepth, other.coralDepth, t)!,
      coralTint: Color.lerp(coralTint, other.coralTint, t)!,
      coralHeroCard: Color.lerp(coralHeroCard, other.coralHeroCard, t)!,
      coralHeroCardDepth: Color.lerp(
        coralHeroCardDepth,
        other.coralHeroCardDepth,
        t,
      )!,
      coralHeroCardMutedText: Color.lerp(
        coralHeroCardMutedText,
        other.coralHeroCardMutedText,
        t,
      )!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      successBorder: Color.lerp(successBorder, other.successBorder, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      errorSurface: Color.lerp(errorSurface, other.errorSurface, t)!,
      errorBorder: Color.lerp(errorBorder, other.errorBorder, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      infoSurface: Color.lerp(infoSurface, other.infoSurface, t)!,
      infoBorder: Color.lerp(infoBorder, other.infoBorder, t)!,
      infoText: Color.lerp(infoText, other.infoText, t)!,
      tintLavender: Color.lerp(tintLavender, other.tintLavender, t)!,
      tintMint: Color.lerp(tintMint, other.tintMint, t)!,
      tintSky: Color.lerp(tintSky, other.tintSky, t)!,
      tintPeach: Color.lerp(tintPeach, other.tintPeach, t)!,
      tintRose: Color.lerp(tintRose, other.tintRose, t)!,
      tintYellow: Color.lerp(tintYellow, other.tintYellow, t)!,
      chipSelectedFill: Color.lerp(
        chipSelectedFill,
        other.chipSelectedFill,
        t,
      )!,
      chipSelectedBorder: Color.lerp(
        chipSelectedBorder,
        other.chipSelectedBorder,
        t,
      )!,
      chipSelectedText: Color.lerp(
        chipSelectedText,
        other.chipSelectedText,
        t,
      )!,
      chipUnselectedFill: Color.lerp(
        chipUnselectedFill,
        other.chipUnselectedFill,
        t,
      )!,
      chipUnselectedBorder: Color.lerp(
        chipUnselectedBorder,
        other.chipUnselectedBorder,
        t,
      )!,
      chipUnselectedText: Color.lerp(
        chipUnselectedText,
        other.chipUnselectedText,
        t,
      )!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputFocus: Color.lerp(inputFocus, other.inputFocus, t)!,
      disabledFill: Color.lerp(disabledFill, other.disabledFill, t)!,
      disabledDepth: Color.lerp(disabledDepth, other.disabledDepth, t)!,
      disabledText: Color.lerp(disabledText, other.disabledText, t)!,
      switchTrackActive: Color.lerp(
        switchTrackActive,
        other.switchTrackActive,
        t,
      )!,
      switchTrackInactive: Color.lerp(
        switchTrackInactive,
        other.switchTrackInactive,
        t,
      )!,
      sliderTrackActive: Color.lerp(
        sliderTrackActive,
        other.sliderTrackActive,
        t,
      )!,
      sliderTrackInactive: Color.lerp(
        sliderTrackInactive,
        other.sliderTrackInactive,
        t,
      )!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      nodeDone: Color.lerp(nodeDone, other.nodeDone, t)!,
      nodeDoneDepth: Color.lerp(nodeDoneDepth, other.nodeDoneDepth, t)!,
      nodeCurrent: Color.lerp(nodeCurrent, other.nodeCurrent, t)!,
      nodeCurrentDepth: Color.lerp(
        nodeCurrentDepth,
        other.nodeCurrentDepth,
        t,
      )!,
      nodeLocked: Color.lerp(nodeLocked, other.nodeLocked, t)!,
      nodeLockedDepth: Color.lerp(nodeLockedDepth, other.nodeLockedDepth, t)!,
      connectorDone: Color.lerp(connectorDone, other.connectorDone, t)!,
      connectorPending: Color.lerp(
        connectorPending,
        other.connectorPending,
        t,
      )!,
      tabBarBackground: Color.lerp(
        tabBarBackground,
        other.tabBarBackground,
        t,
      )!,
      tabBarBorder: Color.lerp(tabBarBorder, other.tabBarBorder, t)!,
      tabBarIndicator: Color.lerp(tabBarIndicator, other.tabBarIndicator, t)!,
      tabBarSelected: Color.lerp(tabBarSelected, other.tabBarSelected, t)!,
      tabBarUnselected: Color.lerp(
        tabBarUnselected,
        other.tabBarUnselected,
        t,
      )!,
      navRailBackground: Color.lerp(
        navRailBackground,
        other.navRailBackground,
        t,
      )!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldDepth: Color.lerp(goldDepth, other.goldDepth, t)!,
      goldStarOutline: Color.lerp(goldStarOutline, other.goldStarOutline, t)!,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      button3dEdge: Color.lerp(button3dEdge, other.button3dEdge, t)!,
      splashGradientTop: Color.lerp(
        splashGradientTop,
        other.splashGradientTop,
        t,
      )!,
      splashGradientBottom: Color.lerp(
        splashGradientBottom,
        other.splashGradientBottom,
        t,
      )!,
      splashBackgroundSolid: Color.lerp(
        splashBackgroundSolid,
        other.splashBackgroundSolid,
        t,
      )!,
    );
  }
}

/// Convenience context extension for accessing the active [AppPalette].
extension AppPaletteContextX on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppPalette.dark()
          : AppPalette.light());
}
