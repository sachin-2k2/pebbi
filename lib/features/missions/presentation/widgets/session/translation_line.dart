import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../settings/presentation/providers/app_settings_provider.dart';

/// Small muted translation subtitle rendered under conversation messages.
///
/// Follows AGENTS.md §8:
/// - Shown only when captions are ON and translation text is provided
/// - Animated opacity/size respecting Reduce Motion setting
class TranslationLine extends ConsumerWidget {
  const TranslationLine({
    super.key,
    required this.translation,
    this.color,
  });

  final String? translation;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = translation;
    if (text == null || text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final captionsOn = ref.watch(
      appSettingsProvider.select((s) => s.captionsAlwaysOn),
    );
    if (!captionsOn) return const SizedBox.shrink();

    final palette = context.palette;

    return Text(
      text,
      style: AppTypography.caption.copyWith(
        color: color ?? palette.textMuted,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
    );
  }
}
