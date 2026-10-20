import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import 'window_class.dart';

/// Presentation helper that displays a bottom sheet on compact screens
/// and an adaptive centered dialog on medium/expanded screens.
abstract final class AdaptiveSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    double maxWidth = AppSpacing.maxDialogWidth,
    bool isDismissible = true,
  }) {
    if (context.isCompact) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        isDismissible: isDismissible,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        builder: builder,
      );
    }

    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (dialogContext) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Material(
              color: Theme.of(dialogContext).colorScheme.surface,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: builder(dialogContext),
            ),
          ),
        );
      },
    );
  }
}
