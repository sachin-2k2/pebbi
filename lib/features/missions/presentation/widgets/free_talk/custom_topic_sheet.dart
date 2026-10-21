import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/free_talk_safety_rules.dart';

/// Modal sheet for custom user-entered topic input ("My own").
///
/// Follows AGENTS.md §3 (<150 lines), §6 (privacy: zero logging of typed text),
/// and enforces [maxCustomTopicLength] character limit.
///
/// TODO(question: final design specification needed for the custom topic input modal).
class CustomTopicSheet extends StatefulWidget {
  const CustomTopicSheet({super.key, required this.onStartTopic});

  final ValueChanged<String> onStartTopic;

  @override
  State<CustomTopicSheet> createState() => _CustomTopicSheetState();
}

class _CustomTopicSheetState extends State<CustomTopicSheet> {
  late final TextEditingController _controller;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_updateCanSubmit);
  }

  void _updateCanSubmit() {
    final valid = FreeTalkSafetyRules.isTopicAllowed(_controller.text);
    if (valid != _canSubmit) {
      setState(() => _canSubmit = valid);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCanSubmit);
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final trimmed = _controller.text.trim();
    if (FreeTalkSafetyRules.isTopicAllowed(trimmed)) {
      Navigator.of(context).pop();
      widget.onStartTopic(trimmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.lg,
        bottom: AppSpacing.xl + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: const Text(
                  AppStrings.customTopicSheetTitle,
                  style: AppTypography.cardTitle,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: AppStrings.close,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: maxCustomTopicLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: AppStrings.customTopicFieldLabel,
              hintText: AppStrings.customTopicFieldHint,
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
            ),
            onSubmitted: (_) {
              if (_canSubmit) _handleSubmit();
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Button3D(
            label: AppStrings.customTopicStart,
            onPressed: _canSubmit ? _handleSubmit : null,
          ),
        ],
      ),
    );
  }
}
