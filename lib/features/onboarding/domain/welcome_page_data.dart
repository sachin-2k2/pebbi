import 'package:flutter/material.dart';
import '../../../core/design_system/pebbi_mascot.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_strings.dart';

/// Data model for the onboarding welcome pages.
///
/// Follows AGENTS.md §2 and user spec: data-driven, allowing WelcomeScreen
/// to display page 1, 2, or 3 seamlessly.
class WelcomePageData {
  const WelcomePageData({
    required this.title,
    required this.subtitle,
    required this.chips,
    this.cardTint = AppColors.tintLavender,
    this.mascotOutfit = PebbiOutfit.defaultPurple,
    this.mascotExpression = PebbiExpression.happyClosed,
    required this.buttonLabel,
    this.buttonColor = AppColors.brandPurple,
    this.buttonDepthColor = AppColors.brandPurpleDepth,
    this.buttonTrailingIcon,
    this.footerCaption,
  });

  final String title;
  final String subtitle;
  final List<String> chips;
  final Color cardTint;
  final PebbiOutfit mascotOutfit;
  final PebbiExpression mascotExpression;
  final String buttonLabel;
  final Color buttonColor;
  final Color buttonDepthColor;
  final Widget? buttonTrailingIcon;
  final String? footerCaption;

  /// Mock data list containing Pages 1, 2, and 3.
  static const List<WelcomePageData> mockPages = [
    WelcomePageData(
      title: AppStrings.welcome1Title,
      subtitle: AppStrings.welcome1Subtitle,
      chips: [
        AppStrings.welcome1Chip1,
        AppStrings.welcome1Chip2,
        AppStrings.welcome1Chip3,
      ],
      cardTint: AppColors.tintLavender,
      mascotOutfit: PebbiOutfit.defaultPurple,
      mascotExpression: PebbiExpression.happyClosed,
      buttonLabel: AppStrings.next,
      buttonColor: AppColors.brandPurple,
      buttonDepthColor: AppColors.brandPurpleDepth,
      buttonTrailingIcon: Icon(
        Icons.chevron_right_rounded,
        color: Colors.white,
        size: 24.0,
      ),
    ),
    WelcomePageData(
      title: AppStrings.welcome2Title,
      subtitle: AppStrings.welcome2Subtitle,
      chips: [
        AppStrings.welcome2Chip1,
        AppStrings.welcome2Chip2,
        AppStrings.welcome2Chip3,
      ],
      cardTint: AppColors.tintMint,
      mascotOutfit: PebbiOutfit.backpack,
      mascotExpression: PebbiExpression.happy,
      buttonLabel: AppStrings.next,
      buttonColor: AppColors.brandPurple,
      buttonDepthColor: AppColors.brandPurpleDepth,
      buttonTrailingIcon: Icon(
        Icons.chevron_right_rounded,
        color: Colors.white,
        size: 24.0,
      ),
    ),
    WelcomePageData(
      title: AppStrings.welcome3Title,
      subtitle: AppStrings.welcome3Subtitle,
      chips: [
        AppStrings.welcome3Chip1,
        AppStrings.welcome3Chip2,
        AppStrings.welcome3Chip3,
      ],
      cardTint: AppColors.tintSky,
      mascotOutfit: PebbiOutfit.scarf,
      mascotExpression: PebbiExpression.happy,
      buttonLabel: AppStrings.getStarted,
      buttonColor: AppColors.mint,
      buttonDepthColor: AppColors.mintDepth,
      buttonTrailingIcon: null,
      footerCaption: AppStrings.welcome3Caption,
    ),
  ];
}
