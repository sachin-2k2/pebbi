import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/button_3d.dart';
import '../../../../core/design_system/notice_banner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/phrase.dart';
import '../providers/review_provider.dart';

/// Modal bottom sheet for translating and adding a custom phrase.
///
/// Follows AGENTS.md §3 (<150 lines, build <50 lines) and strict privacy rules
/// (zero analytics or logging of user-entered text).
class AddPhraseSheet extends ConsumerStatefulWidget {
  const AddPhraseSheet({super.key});

  @override
  ConsumerState<AddPhraseSheet> createState() => _AddPhraseSheetState();
}

class _AddPhraseSheetState extends ConsumerState<AddPhraseSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  Phrase? _translatedPhrase;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTranslate() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    final isOffline = ref.read(reviewOfflineProvider);
    if (isOffline) {
      setState(() => _errorMessage = AppStrings.translationRequiresInternet);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(translationRepositoryProvider);
      final targetLang = ref.read(reviewTargetLanguageCodeProvider);
      final result = await repo.translate(
        query: query,
        targetLanguageCode: targetLang,
        explanationLanguageCode: 'en',
      );
      if (mounted) {
        setState(() {
          _translatedPhrase = Phrase(
            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
            languageCode: targetLang,
            targetText: result,
            meaning: query,
            status: PhraseStatus.newPhrase,
          );
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = AppStrings.translationFailed;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSave() async {
    if (_translatedPhrase == null) return;
    final phraseRepo = ref.read(phraseRepositoryProvider);
    await phraseRepo.savePhrase(_translatedPhrase!);
    ref.invalidate(phrasesListProvider);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.phraseSavedSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(reviewOfflineProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SheetHeader(onClose: () => Navigator.of(context).pop()),
              const SizedBox(height: AppSpacing.md),
              if (isOffline) ...[
                const NoticeBanner(
                  message: AppStrings.translationRequiresInternet,
                  tone: NoticeBannerTone.warning,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              _InputField(
                controller: _controller,
                isLoading: _isLoading,
                onSubmitted: (_) => _handleTranslate(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13.0),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              if (_translatedPhrase != null) ...[
                _ResultPreview(phrase: _translatedPhrase!),
                const SizedBox(height: AppSpacing.md),
                Button3D(
                  label: AppStrings.savePhraseToBook,
                  onPressed: _handleSave,
                ),
              ] else
                Button3D(
                  label: _isLoading
                      ? AppStrings.translating
                      : AppStrings.translateAction,
                  onPressed: _isLoading ? null : _handleTranslate,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.addPhraseSheetTitle,
                style: AppTypography.cardTitle.copyWith(fontSize: 18.0),
              ),
              const SizedBox(height: 2.0),
              Text(
                AppStrings.addPhraseSheetSubtitle,
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.close_rounded), onPressed: onClose),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.isLoading,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: !isLoading,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: AppStrings.addPhraseHint,
        prefixIcon: const Icon(Icons.translate_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
      ),
    );
  }
}

class _ResultPreview extends StatelessWidget {
  const _ResultPreview({required this.phrase});

  final Phrase phrase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.tintLavender,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phrase.targetText,
            style: AppTypography.cardTitle.copyWith(
              color: AppColors.brandPurple,
              fontSize: 18.0,
            ),
          ),
          if (phrase.helperLine != null)
            Text(
              phrase.helperLine!,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 13.0,
              ),
            ),
          const SizedBox(height: 4.0),
          Text(phrase.meaning, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
