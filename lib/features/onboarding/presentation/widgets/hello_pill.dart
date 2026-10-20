import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/text_to_speech_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../providers/onboarding_flow_provider.dart';

/// Small interactive audio preview pill and caption displayed above the bottom action.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// respects sound setting, fails quietly if no voice available, accessible semantics.
class HelloPill extends ConsumerWidget {
  const HelloPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetCode = ref.watch(
      onboardingFlowProvider.select((s) => s.targetLanguageCode),
    );
    final languages = ref.watch(learnableLanguagesProvider);
    final currentLanguage = languages.firstWhere(
      (l) => l.code == targetCode,
      orElse: () => languages.first,
    );

    final isRtl = currentLanguage.code == 'ar' || currentLanguage.code == 'ur';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pillBg = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.tintLavender;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final captionColor = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    final semanticsLabel = AppStrings.helloPillSemantics(
      languageName: currentLanguage.englishName,
      phrase: currentLanguage.helloText,
    );

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: pillBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: InkWell(
              onTap: () async {
                final soundEnabled = ref.read(
                  appSettingsProvider.select((s) => s.soundEnabled),
                );
                if (soundEnabled) {
                  final tts = ref.read(textToSpeechServiceProvider);
                  await tts.speak(
                    currentLanguage.helloText,
                    locale: currentLanguage.ttsLocale,
                  );
                }
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSpacing.minTouchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.volume_up_rounded,
                        size: 16.0,
                        color: AppColors.brandPurple,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Directionality(
                        textDirection: isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: Text(
                          currentLanguage.helloText,
                          style: AppTypography.screenTitle.copyWith(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              AppStrings.firstSentenceCaption(currentLanguage.englishName),
              style: AppTypography.caption.copyWith(
                color: captionColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
