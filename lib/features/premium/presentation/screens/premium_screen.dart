import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/purchase_provider.dart';
import '../widgets/legal_footer.dart';
import '../widgets/plan_section.dart';
import '../widgets/premium_feature_grid.dart';
import '../widgets/premium_header.dart';

/// Main paywall screen ("Unlock all of Pebbi").
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// thin composition-only screen, transparent status bar overlay for edge-to-edge gradient.
class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final plansAsync = ref.watch(subscriptionPlansProvider);
    final firstPlan = plansAsync.valueOrNull?.firstOrNull;
    final trialDays = (firstPlan?.trialEligible ?? true)
        ? (firstPlan?.trialDays ?? 7)
        : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PremiumHeader(
                trialDays: trialDays,
                onClose: () => _handleReturn(context),
              ),
              ContentWidthLimiter(
                maxWidth: AppSpacing.maxContentWidthExpanded,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PremiumFeatureGrid(),
                    const SizedBox(height: AppSpacing.xl),
                    PlanSection(onSuccess: () => _handleReturn(context)),
                    const SizedBox(height: AppSpacing.md),
                    const LegalFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleReturn(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/onboarding/setup/step-10');
    }
  }
}
