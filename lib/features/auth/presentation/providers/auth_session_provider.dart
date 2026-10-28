import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_mode.dart';
import '../../data/mock_auth_repository.dart';
import '../../data/mock_push_token_service.dart';
import '../../data/mock_secure_session_store.dart';
import '../../data/remote_auth_repository.dart';
import '../../domain/auth_repository.dart';
import '../../domain/push_token_service.dart';
import '../../domain/secure_session_store.dart';

/// Provider for the secure session store (tokens only).
final secureSessionStoreProvider = Provider<SecureSessionStore>((ref) {
  return MockSecureSessionStore();
});

/// Provider for the push notification token registration service.
final pushTokenServiceProvider = Provider<PushTokenService>((ref) {
  return MockPushTokenService();
});

/// Provider for the [AuthRepository].
///
/// Follows AGENTS.md §2: Injects [RemoteAuthRepository] when
/// [ApiConfig.authApiMode] is `ApiMode.real`, otherwise [MockAuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final secureStore = ref.watch(secureSessionStoreProvider);
  final config = ApiConfig.instance;

  if (config.authApiMode == ApiMode.real) {
    final client = ref.watch(apiClientProvider);
    return RemoteAuthRepository(apiClient: client, secureStore: secureStore);
  }

  return MockAuthRepository(secureStore: secureStore);
});
