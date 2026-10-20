import 'package:flutter/material.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'step_top_bar.dart';

/// Reusable onboarding setup scaffold with responsive container, safe areas,
/// optional header, scrollable body, and pinned bottom action area.
///
/// Follows AGENTS.md §3 and §4: under 100 lines, build under 50 lines,
/// no helper widget methods, ContentWidthLimiter.
class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.body,
    this.header,
    this.footer,
    this.bottomBar,
    this.onSkip,
    this.showSkip = true,
    this.isScrollable = true,
    this.useIntrinsicHeight = false,
  });

  final Widget body;
  final Widget? header;
  final Widget? footer;
  final Widget? bottomBar;
  final VoidCallback? onSkip;
  final bool showSkip;
  final bool isScrollable;
  final bool useIntrinsicHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final activeFooter = footer ?? bottomBar;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ContentWidthLimiter(
          maxWidth: AppSpacing.maxContentWidthCompact,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              if (header != null)
                header!
              else if (showSkip)
                StepTopBar(onSkip: onSkip, showSkip: showSkip),
              Expanded(
                child: isScrollable
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          final scrollChild = useIntrinsicHeight
                              ? ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: IntrinsicHeight(child: body),
                                )
                              : body;
                          return SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: scrollChild,
                          );
                        },
                      )
                    : body,
              ),
              if (activeFooter != null) ...[
                const SizedBox(height: AppSpacing.md),
                activeFooter,
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
