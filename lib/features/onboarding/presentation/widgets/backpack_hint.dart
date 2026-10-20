import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Row displaying small backpack-wearing Pebbi mascot and dynamic speech pill.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, accessible live region,
/// animated transition respecting reduce-motion setting.
class BackpackHint extends StatelessWidget {
  const BackpackHint({
    super.key,
    this.selectedCount,
    this.selectedEmojis = const [],
    this.maxCount = 3,
  });

  final int? selectedCount;
  final List<String> selectedEmojis;
  final int maxCount;

  int get count => selectedCount ?? selectedEmojis.length;

  @override
  Widget build(BuildContext context) {
    final disableAnim = MediaQuery.disableAnimationsOf(context);
    final message = count == 0
        ? AppStrings.backpackEmpty
        : AppStrings.backpackPacked(count, max: maxCount);

    return Semantics(
      liveRegion: true,
      label: message,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: disableAnim
                ? Duration.zero
                : const Duration(milliseconds: 250),
            scale: count > 0 ? 1.05 : 1.0,
            curve: Curves.easeOutBack,
            child: const PebbiMascot(
              size: 44.0,
              outfit: PebbiOutfit.backpack,
              expression: PebbiExpression.happy,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44.0),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EEF8),
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedSwitcher(
                duration: disableAnim
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: count == 0
                    ? Text(
                        message,
                        key: const ValueKey<int>(0),
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : Column(
                        key: ValueKey<String>(
                          '$count-${selectedEmojis.join()}',
                        ),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message,
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (selectedEmojis.isNotEmpty) ...[
                            const SizedBox(height: 3.0),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final emoji in selectedEmojis) ...[
                                  Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 18.0),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
