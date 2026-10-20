import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/welcome_page_data.dart';
import 'page_indicator.dart';
import 'welcome_footer_caption.dart';

/// Bottom bar for welcome onboarding steps with page indicator, 3D action button,
/// and stable layout without page shifts.
///
/// Follows AGENTS.md §3: single widget per file, build under 50 lines.
class WelcomeBottomBar extends StatelessWidget {
  const WelcomeBottomBar({
    super.key,
    required this.currentIndex,
    required this.pageCount,
    required this.data,
    required this.onNext,
  });

  final int currentIndex;
  final int pageCount;
  final WelcomePageData data;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PageIndicator(
          currentIndex: currentIndex,
          pageCount: pageCount,
          activeColor: data.buttonColor,
        ),
        const SizedBox(height: AppSpacing.lg),
        Button3D(
          label: data.buttonLabel,
          backgroundColor: data.buttonColor,
          depthColor: data.buttonDepthColor,
          trailingIcon: data.buttonTrailingIcon,
          onPressed: onNext,
        ),
        const SizedBox(height: AppSpacing.sm),
        Visibility(
          visible: data.footerCaption != null,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: WelcomeFooterCaption(caption: data.footerCaption ?? ''),
        ),
      ],
    );
  }
}
