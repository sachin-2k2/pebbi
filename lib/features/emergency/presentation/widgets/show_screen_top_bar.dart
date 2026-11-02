import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'show_screen_close_button.dart';

/// Top bar for the Show Screen view featuring close button and page counter.
///
/// Follows AGENTS.md §3 (<150 lines).
class ShowScreenTopBar extends StatelessWidget {
  const ShowScreenTopBar({
    super.key,
    required this.currentIndex,
    required this.total,
  });

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const ShowScreenCloseButton(),
        if (total > 1)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.brandPurple.withAlpha(25),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text(
              '${currentIndex + 1} / $total',
              style: const TextStyle(
                color: AppColors.brandPurple,
                fontWeight: FontWeight.w700,
                fontSize: 14.0,
              ),
            ),
          ),
      ],
    );
  }
}

