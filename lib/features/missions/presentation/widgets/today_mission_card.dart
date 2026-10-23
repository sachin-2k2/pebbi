import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design_system/icon_tile.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/today_mission.dart';

/// 3D tactile card for Today's Featured Mission.
///
/// Follows AGENTS.md §4.6 & WCAG AA contrast:
/// - Built on Button3D surface depth translation logic.
/// - Uses [AppColors.coralHeroCard] (>5.0:1 contrast with white text).
/// - Tactile press translates the face down to the bottom depth edge.
class TodayMissionCard extends StatefulWidget {
  const TodayMissionCard({
    super.key,
    required this.todayMission,
    required this.onTap,
    this.depth = AppSpacing.depthLg,
  });

  final TodayMission todayMission;
  final VoidCallback onTap;
  final double depth;

  @override
  State<TodayMissionCard> createState() => _TodayMissionCardState();
}

class _TodayMissionCardState extends State<TodayMissionCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails _) => setState(() => _isPressed = false);
  void _handleTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final mission = widget.todayMission.mission;
    final isCompleted = widget.todayMission.isCompleted;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final topOffset = _isPressed ? widget.depth : 0.0;
    final radius = BorderRadius.circular(AppSpacing.radiusCard);

    final palette = context.palette;
    final semanticsLabel = AppStrings.todaysMissionSemantics(
      title: mission.title,
      characterName: mission.characterName,
      characterRole: mission.characterRole,
      minutes: mission.durationMinutes,
    );

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 3D Depth Layer (bottom darker edge)
              Positioned.fill(
                top: widget.depth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.coralHeroCardDepth,
                    borderRadius: radius,
                  ),
                ),
              ),
              // Tactile Face Layer
              AnimatedContainer(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 60),
                curve: Curves.easeOut,
                margin: EdgeInsets.only(
                  top: topOffset,
                  bottom: widget.depth - topOffset,
                ),
                decoration: BoxDecoration(
                  color: palette.coralHeroCard,
                  borderRadius: radius,
                  boxShadow: _isPressed
                      ? const []
                      : [
                          BoxShadow(
                            color: palette.coralHeroCardDepth.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    IconTile.emoji(
                      mission.emoji,
                      backgroundColor: palette.textOnBrand.withValues(
                        alpha: 0.22,
                      ),
                      size: 48.0,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: AppSpacing.xs,
                            runSpacing: 2.0,
                            children: [
                              Text(
                                AppStrings.todaysMissionOverline,
                                style: AppTypography.cardOverline.copyWith(
                                  color: palette.textOnBrand.withValues(
                                    alpha: 0.9,
                                  ),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.textOnBrand.withValues(
                                      alpha: 0.25,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusPill,
                                    ),
                                  ),
                                  child: Text(
                                    AppStrings.missionTagDone,
                                    style: TextStyle(
                                      color: palette.textOnBrand,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            mission.title,
                            style: AppTypography.cardTitle.copyWith(
                              color: palette.textOnBrand,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            '${mission.characterName}, ${mission.characterRole} · ${AppStrings.todaysMissionAboutMinutes(mission.durationMinutes)}',
                            style: AppTypography.caption.copyWith(
                              color: palette.coralHeroCardMutedText,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
