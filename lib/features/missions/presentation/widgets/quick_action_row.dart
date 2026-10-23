import 'package:flutter/material.dart';
import '../../../../core/design_system/icon_tile.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import 'quick_action_card.dart';

/// Row of equal-height quick action cards that gracefully wraps to a column
/// on extremely narrow screens or under large accessibility text scaling.
class QuickActionRow extends StatelessWidget {
  const QuickActionRow({
    super.key,
    required this.onEmergencyTap,
    required this.onFreeTalkTap,
  });

  final VoidCallback onEmergencyTap;
  final VoidCallback onFreeTalkTap;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final palette = context.palette;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 320.0 || textScale > 1.6;

        final emergencyCard = QuickActionCard(
          iconTile: IconTile.emoji(
            '⚠️',
            backgroundColor: palette.tintRose,
            size: 42.0,
            fontSize: 20.0,
          ),
          title: AppStrings.emergencyPhrasebook,
          onTap: onEmergencyTap,
          semanticsLabel: AppStrings.emergencyPhrasebookSemantics,
        );

        final freeTalkCard = QuickActionCard(
          iconTile: IconTile.emoji(
            '💬',
            backgroundColor: palette.tintLavender,
            size: 42.0,
            fontSize: 20.0,
          ),
          title: AppStrings.freeTalk,
          onTap: onFreeTalkTap,
          semanticsLabel: AppStrings.freeTalkSemantics,
        );

        if (isNarrow) {
          return Column(
            children: [
              emergencyCard,
              const SizedBox(height: AppSpacing.sm),
              freeTalkCard,
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: emergencyCard),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: freeTalkCard),
            ],
          ),
        );
      },
    );
  }
}
