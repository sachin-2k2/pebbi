import 'package:flutter/material.dart';
import '../../../../core/layout/responsive_grid.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/premium_feature.dart';
import 'premium_feature_card.dart';

/// 2-to-3 column grid of premium value proposition cards.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// maxItemWidth auto-adapts columns, dynamically adjusts aspect ratio for 200% text scale.
class PremiumFeatureGrid extends StatelessWidget {
  const PremiumFeatureGrid({
    super.key,
    this.features = PremiumFeature.defaultFeatures,
  });

  final List<PremiumFeature> features;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    // Dynamically adjust aspect ratio so cards gracefully expand vertically at 200% scale
    final childAspectRatio = switch (textScale) {
      >= 1.8 => 0.45,
      >= 1.4 => 0.58,
      >= 1.2 => 0.72,
      _ => 0.88,
    };

    return ResponsiveGrid(
      itemCount: features.length,
      maxItemWidth: 240.0,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final feature = features[index];
        return PremiumFeatureCard(
          emoji: feature.emoji,
          title: _titleFor(feature),
          caption: _captionFor(feature),
        );
      },
    );
  }

  String _titleFor(PremiumFeature feature) => switch (feature.id) {
    'units' => AppStrings.premiumFeatureUnitsTitle,
    'languages' => AppStrings.premiumFeatureLanguagesTitle,
    'missions' => AppStrings.premiumFeatureMissionsTitle,
    'no_ads' => AppStrings.premiumFeatureNoAdsTitle,
    'offline' => AppStrings.premiumFeatureOfflineTitle,
    'exams' => AppStrings.premiumFeatureExamsTitle,
    _ => feature.titleKey,
  };

  String _captionFor(PremiumFeature feature) => switch (feature.id) {
    'units' => AppStrings.premiumFeatureUnitsCaption,
    'languages' => AppStrings.premiumFeatureLanguagesCaption,
    'missions' => AppStrings.premiumFeatureMissionsCaption,
    'no_ads' => AppStrings.premiumFeatureNoAdsCaption,
    'offline' => AppStrings.premiumFeatureOfflineCaption,
    'exams' => AppStrings.premiumFeatureExamsCaption,
    _ => feature.captionKey,
  };
}
