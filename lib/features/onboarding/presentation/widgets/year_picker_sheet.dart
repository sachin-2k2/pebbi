import 'package:flutter/material.dart';
import '../../../../core/layout/adaptive_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/onboarding_config.dart';

/// Adaptive year picker displaying a scrollable list from current year
/// back ~100 years, opening pre-scrolled to the selected year.
///
/// Follows AGENTS.md §3 and §4: uses AdaptiveSheet, min 48dp tap targets,
/// under 150 lines, no hardcoded years.
class YearPickerSheet extends StatefulWidget {
  const YearPickerSheet({super.key, required this.selectedYear, this.years});

  final int selectedYear;
  final List<int>? years;

  /// Helper to display this picker via [AdaptiveSheet].
  static Future<int?> show({
    required BuildContext context,
    required int selectedYear,
    List<int>? years,
  }) {
    return AdaptiveSheet.show<int>(
      context: context,
      builder: (sheetContext) =>
          YearPickerSheet(selectedYear: selectedYear, years: years),
    );
  }

  @override
  State<YearPickerSheet> createState() => _YearPickerSheetState();
}

class _YearPickerSheetState extends State<YearPickerSheet> {
  static const double _itemHeight = 52.0;
  late final List<int> _years;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _years = widget.years ?? OnboardingConfig.generateSelectableYears();
    final selectedIndex = _years.indexOf(widget.selectedYear);
    final initialOffset = selectedIndex > 0
        ? (selectedIndex * _itemHeight) - (_itemHeight * 2)
        : 0.0;
    _scrollController = ScrollController(
      initialScrollOffset: initialOffset.clamp(0.0, double.infinity),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const Divider(color: AppColors.borderLight, height: 1.0),
            SizedBox(
              height: 320.0,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _years.length,
                itemExtent: _itemHeight,
                itemBuilder: (context, index) {
                  final year = _years[index];
                  final isSelected = year == widget.selectedYear;
                  return _buildYearTile(year, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.yearPickerTitle,
            style: AppTypography.cardTitle,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildYearTile(int year, bool isSelected) {
    return Material(
      color: isSelected ? AppColors.tintLavender : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => Navigator.of(context).pop(year),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                year.toString(),
                style: AppTypography.screenTitle.copyWith(
                  fontSize: 18.0,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.brandPurple
                      : AppColors.textPrimary,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: AppColors.brandPurple,
                  size: 20.0,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
