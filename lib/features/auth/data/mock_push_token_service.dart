import '../domain/push_token_service.dart';

/// In-memory mock implementation of [PushTokenService] for verification in tests.
class MockPushTokenService implements PushTokenService {
  final Set<String> registeredUserIds = {};

  @override
  Future<void> registerToken(String userId) async {
    registeredUserIds.add(userId);
  }

  @override
  Future<void> unregisterToken(String userId) async {
    registeredUserIds.remove(userId);
  }
}
