import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/name_safety_rules.dart';

/// Accessible rounded text input field for the learner's optional first name.
///
/// Follows AGENTS.md §3 & §6: debounced save on type/done/blur/back, word capitalization, no logging.
class NameField extends StatefulWidget {
  const NameField({
    super.key,
    required this.initialName,
    required this.onSaved,
  });

  final String? initialName;
  final ValueChanged<String?> onSaved;

  @override
  State<NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<NameField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounceTimer;
  String? _lastSavedName;

  @override
  void initState() {
    super.initState();
    _lastSavedName = widget.initialName;
    _controller = TextEditingController(text: widget.initialName ?? '');
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(NameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialName != widget.initialName) {
      _lastSavedName = widget.initialName;
      if (!_focusNode.hasFocus) {
        _controller.text = widget.initialName ?? '';
      }
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _commitName();
    }
  }

  void _onTextChanged(String _) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), _commitName);
  }

  void _commitName() {
    _debounceTimer?.cancel();
    final sanitized = NameSafetyRules.sanitize(_controller.text);
    final valueToSave = sanitized.isEmpty ? null : sanitized;
    if (valueToSave != _lastSavedName) {
      _lastSavedName = valueToSave;
      widget.onSaved(valueToSave);
    }
  }

  @override
  void dispose() {
    _commitName();
    _debounceTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AppColors.darkNameFieldBackground
        : AppColors.nameFieldBackground;

    return Container(
      constraints: const BoxConstraints(minHeight: 52.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autocorrect: false,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onChanged: _onTextChanged,
        onTapOutside: (_) => _focusNode.unfocus(),
        onSubmitted: (_) => _commitName(),
        style: AppTypography.cardTitle.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: AppStrings.settingsFirstNamePlaceholder,
          hintStyle: AppTypography.cardTitle.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
