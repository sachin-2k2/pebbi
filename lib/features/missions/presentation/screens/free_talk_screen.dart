import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/back_link.dart';
import '../../../../core/design_system/notice_banner.dart';
import '../../../../core/layout/adaptive_sheet.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/correction_style.dart';
import '../../domain/free_talk_access_rules.dart';
import '../../domain/free_talk_topic.dart';
import '../providers/free_talk_provider.dart';
import '../widgets/free_talk/correction_style_card.dart';
import '../widgets/free_talk/custom_topic_sheet.dart';
import '../widgets/free_talk/free_talk_header.dart';
import '../widgets/free_talk/topic_chip_wrap.dart';

/// Free Talk screen for open-ended conversational topic selection.
///
/// Follows AGENTS.md §3.1 (<100 lines, build <50 lines), §4.1 (max width 580), and §7.3.
class FreeTalkScreen extends ConsumerWidget {
  const FreeTalkScreen({super.key});

  void _startSession(
    BuildContext context,
    String topicId,
    CorrectionStyle style,
  ) {
    context.push(
      '/missions/session?topicId=${Uri.encodeComponent(topicId)}&style=${style.id}',
    );
  }

  void _onTopicTap(BuildContext context, WidgetRef ref, FreeTalkTopic topic) {
    if (ref.read(freeTalkIsOfflineProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.freeTalkOfflineNotice)),
      );
      return;
    }

    if (FreeTalkAccessRules.evaluate(ref.read(currentUserProvider)) ==
        FreeTalkAccess.needsPremium) {
      context.push('/premium');
      return;
    }

    final style = ref.read(freeTalkCorrectionStyleProvider);
    if (topic.isCustom) {
      AdaptiveSheet.show<void>(
        context: context,
        builder: (_) => CustomTopicSheet(
          onStartTopic: (text) => _startSession(context, text, style),
        ),
      );
    } else {
      _startSession(context, topic.id, style);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetLangName = ref.watch(freeTalkTargetLanguageNameProvider);
    final topicsAsync = ref.watch(freeTalkTopicsProvider);
    final style = ref.watch(freeTalkCorrectionStyleProvider);
    final isOffline = ref.watch(freeTalkIsOfflineProvider);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ContentWidthLimiter(
          maxWidth: 580,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            children: [
              BackLink(
                label: AppStrings.missionsLink,
                onTap: () => context.pop(),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (isOffline) ...[
                const NoticeBanner(
                  message: AppStrings.freeTalkOfflineNotice,
                  tone: NoticeBannerTone.warning,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              FreeTalkHeader(targetLanguageName: targetLangName),
              const SizedBox(height: AppSpacing.xl),
              topicsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (err, stack) => Text(
                  AppStrings.freeTalkLanguageUnsupported,
                  style: TextStyle(color: palette.textMuted),
                ),
                data: (topics) => TopicChipWrap(
                  topics: topics,
                  onTopicTap: (topic) => _onTopicTap(context, ref, topic),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CorrectionStyleCard(
                selectedStyle: style,
                onStyleSelected: (newStyle) => ref
                    .read(freeTalkCorrectionStyleProvider.notifier)
                    .selectStyle(newStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
