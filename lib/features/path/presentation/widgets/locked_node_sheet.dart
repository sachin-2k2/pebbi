import 'package:flutter/material.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/layout/adaptive_sheet.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/path_node.dart';

/// Shows adaptive sheet / dialog when a user taps a locked path node.
Future<void> showLockedNodeSheet(BuildContext context, PathNode node) {
  return AdaptiveSheet.show<void>(
    context: context,
    builder: (ctx) => LockedNodeSheet(node: node),
  );
}

/// Sheet content for locked path stop offering "Go back" or "Test out".
class LockedNodeSheet extends StatelessWidget {
  const LockedNodeSheet({super.key, required this.node});

  final PathNode node;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              color: palette.brandTint,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              Icons.lock_rounded,
              color: palette.brandText,
              size: 28.0,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            node.title,
            style: AppTypography.screenTitle.copyWith(
              fontSize: 20.0,
              color: palette.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.lockedNodeSheetDescription,
            style: AppTypography.bodyMedium.copyWith(
              color: palette.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Button3D(
            label: AppStrings.lockedNodeTestOutAction,
            onPressed: () {
              Navigator.of(context).pop();
              // TODO(question): Backend test-out challenge API endpoint and scoring rules.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'TODO(question): Test-out challenge coming soon!',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            backgroundColor: palette.brand,
            depthColor: palette.brandDepth,
            icon: Icon(
              Icons.bolt_rounded,
              color: palette.textOnBrand,
              size: 20.0,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48.0),
            ),
            child: Text(
              AppStrings.lockedNodeGoBackAction,
              style: TextStyle(
                color: palette.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
