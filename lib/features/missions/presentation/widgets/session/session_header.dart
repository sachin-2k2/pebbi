import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import 'character_avatar.dart';
import 'help_pill.dart';

/// Top session header bar: character avatar, name with online dot & role, and Help pill.
///
/// Follows AGENTS.md §3 (< 100 lines, build < 50 lines) and §8:
/// - Semantic header role on character name
/// - Tapping character identity opens AI disclosure sheet
/// - Thin bottom divider separating header from goals strip
class SessionHeader extends StatelessWidget {
  const SessionHeader({
    super.key,
    required this.characterName,
    required this.characterRole,
    required this.emoji,
    required this.onHelpTap,
    required this.onCharacterTap,
  });

  final String characterName;
  final String characterRole;
  final String emoji;
  final VoidCallback onHelpTap;
  final VoidCallback onCharacterTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: InkWell(
              onTap: onCharacterTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    CharacterAvatar(emoji: emoji),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              characterName,
                              style: AppTypography.cardTitle.copyWith(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7.0,
                                height: 7.0,
                                decoration: BoxDecoration(
                                  color: palette.mint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  AppStrings.sessionCharacterOnline(characterRole),
                                  style: AppTypography.caption.copyWith(
                                    color: palette.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          HelpPill(onTap: onHelpTap),
        ],
      ),
    );
  }
}
