import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/layout/adaptive_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Presentation helper displaying native-feel time picker:
/// Cupertino time wheel on iOS, Material time picker on Android/other platforms.
///
/// Follows AGENTS.md §4: under 100 lines, build under 50 lines, adaptive layout.
abstract final class AdaptiveTimePicker {
  static Future<TimeOfDay?> show({
    required BuildContext context,
    required TimeOfDay initialTime,
  }) async {
    final is24Hour = MediaQuery.alwaysUse24HourFormatOf(context);

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _showCupertinoTimePicker(
        context: context,
        initialTime: initialTime,
        use24hFormat: is24Hour,
      );
    }

    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (pickerContext, child) {
        return MediaQuery(
          data: MediaQuery.of(
            pickerContext,
          ).copyWith(alwaysUse24HourFormat: is24Hour),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  static Future<TimeOfDay?> _showCupertinoTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    required bool use24hFormat,
  }) {
    var selected = initialTime;
    final now = DateTime.now();
    var currentDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      initialTime.hour,
      initialTime.minute,
    );

    return AdaptiveSheet.show<TimeOfDay>(
      context: context,
      maxWidth: 400.0,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;

        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.brandPurpleLight
                              : AppColors.brandPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(selected),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1.0),
              SizedBox(
                height: 216.0,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: currentDateTime,
                  use24hFormat: use24hFormat,
                  onDateTimeChanged: (newDateTime) {
                    selected = TimeOfDay(
                      hour: newDateTime.hour,
                      minute: newDateTime.minute,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
