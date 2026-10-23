import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Modal sheet for translating an explanation-language phrase into the target language.
///
/// Follows AGENTS.md §8:
/// - "Use this" populates text into the session input without auto-sending
/// - TODO(question: Say it in my language sheet is estimated)
class SayInMyLanguageSheet extends StatefulWidget {
  const SayInMyLanguageSheet({
    super.key,
    required this.onTranslate,
    required this.onPlayAudio,
    required this.onUseThis,
  });

  final Future<String> Function(String text) onTranslate;
  final Future<void> Function(String text) onPlayAudio;
  final ValueChanged<String> onUseThis;

  @override
  State<SayInMyLanguageSheet> createState() => _SayInMyLanguageSheetState();
}

class _SayInMyLanguageSheetState extends State<SayInMyLanguageSheet> {
  final _controller = TextEditingController();
  bool _isTranslating = false;
  String? _translatedText;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTranslate() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.onTranslate(query);
      if (!mounted) return;
      setState(() {
        _isTranslating = false;
        _translatedText = result;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTranslating = false;
        _errorMessage = AppStrings.sayInMyLanguageError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.sayInMyLanguageTitle,
                    style: AppTypography.cardTitle.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: palette.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppStrings.close,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppStrings.sayInMyLanguageSubtitle,
              style: AppTypography.bodyMedium.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: palette.isDark ? palette.surfaceVariant : palette.surfaceRaised,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: palette.outline, width: 1.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: TextField(
                controller: _controller,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: AppStrings.sayInMyLanguageInputPlaceholder,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Button3D(
              label: _isTranslating
                  ? AppStrings.sayInMyLanguageTranslating
                  : AppStrings.sayInMyLanguageTranslateButton,
              backgroundColor: palette.brand,
              depthColor: palette.brandDepth,
              textColor: palette.textOnBrand,
              onPressed: _isTranslating ? null : _handleTranslate,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _errorMessage!,
                style: AppTypography.caption.copyWith(color: palette.errorText),
              ),
            ],
            if (_translatedText != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: palette.brandTint,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: palette.brand, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _translatedText!,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: palette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => widget.onPlayAudio(_translatedText!),
                          icon: Icon(Icons.volume_up_rounded, color: palette.brand, size: 18.0),
                          label: Text(
                            AppStrings.sayInMyLanguageHearIt,
                            style: TextStyle(color: palette.brand, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Spacer(),
                        Button3D(
                          label: AppStrings.sayInMyLanguageUseThis,
                          backgroundColor: palette.mint,
                          depthColor: palette.mintDepth,
                          textColor: palette.textOnBrand,
                          isFullWidth: false,
                          width: 140.0,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          onPressed: () {
                            widget.onUseThis(_translatedText!);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
