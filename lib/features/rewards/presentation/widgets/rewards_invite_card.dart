import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../review/domain/invite_link.dart';
import '../../../review/presentation/providers/review_provider.dart';
import '../../../review/presentation/widgets/invite_card.dart';
import '../../domain/rewards_safety_rules.dart';

/// Top-level rewards container delegating to shared [InviteCard].
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §6.
class RewardsInviteCard extends ConsumerWidget {
  const RewardsInviteCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (!RewardsSafetyRules.shouldShowInvite(user?.ageBand)) {
      return const SizedBox.shrink();
    }

    final inviteAsync = ref.watch(inviteLinkProvider);
    final invite = inviteAsync.maybeWhen(
      data: (data) => data,
      orElse: () => const InviteLink(
        url: 'https://pebbi.app/join/guest',
        shareText: 'Learn languages with me on Pebbi!',
      ),
    );

    return InviteCard(
      invite: invite,
      onSharePressed: () async {
        final shareService = ref.read(shareServiceProvider);
        await shareService.share(text: invite.shareText, linkUrl: invite.url);
      },
    );
  }
}
