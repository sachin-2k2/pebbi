import 'package:flutter/material.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/free_talk_topic.dart';
import 'topic_chip.dart';

/// Responsive 4-column grid layout of conversational topic chips.
///
/// Follows AGENTS.md §3, §4.1, and the visual design reference (2 rows of 4 chips).
/// Adapts to 2 columns on very high accessibility text scaling.
class TopicChipWrap extends StatelessWidget {
  const TopicChipWrap({
    super.key,
    required this.topics,
    required this.onTopicTap,
  });

  final List<FreeTalkTopic> topics;
  final ValueChanged<FreeTalkTopic> onTopicTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final crossAxisCount = (textScale > 1.4 || constraints.maxWidth < 280)
            ? 2
            : 4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisExtent: 44.0,
          ),
          itemBuilder: (context, index) {
            final topic = topics[index];
            return TopicChip(topic: topic, onTap: () => onTopicTap(topic));
          },
        );
      },
    );
  }
}
