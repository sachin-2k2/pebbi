import 'package:flutter/material.dart';
import '../../../../../core/design_system/selectable_pill_chip.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/free_talk_topic.dart';

/// Single conversational topic chip reusing [SelectablePillChip].
///
/// Follows AGENTS.md §3 & §4.6:
/// - Reuses core design system chip without code duplication.
/// - Guarantees >=48dp tap target for accessibility.
class TopicChip extends StatelessWidget {
  const TopicChip({super.key, required this.topic, required this.onTap});

  final FreeTalkTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SelectablePillChip(
      label: topic.label,
      isSelected: false,
      onTap: onTap,
      size: SelectablePillChipSize.medium,
      semanticsLabel: AppStrings.topicChipSemantics(
        topic: topic.label,
        isCustom: topic.isCustom,
      ),
    );
  }
}
