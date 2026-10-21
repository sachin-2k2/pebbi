import '../domain/invite_link.dart';
import '../domain/invite_repository.dart';

/// Mock implementation of [InviteRepository].
///
/// Follows AGENTS.md §1: Uses Base44 prototype link as placeholder until backend referral contract.
class MockInviteRepository implements InviteRepository {
  MockInviteRepository({
    this.baseUrl = 'https://pebbi-growth-path.base44.app',
    this.shouldFail = false,
  });

  final String baseUrl;
  final bool shouldFail;

  @override
  Future<InviteLink> getInviteLink({required String userId}) async {
    if (shouldFail) {
      throw StateError('Unable to generate invite link.');
    }
    return InviteLink(
      url: baseUrl,
      code: userId,
      shareText: 'Join me on Pebbi to speak languages for real! $baseUrl',
    );
  }
}
