import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/invite_link.dart';
import '../providers/review_provider.dart';
import 'invite_card.dart';

/// Top-level shell widget reading invite state and delegating to [InviteCard].
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) and §6.
class ReviewInviteCard extends ConsumerWidget {
  const ReviewInviteCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
