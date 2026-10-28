import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/storage/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenStorage', () {
    late TokenStorage tokenStorage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      tokenStorage = TokenStorage();
    });

    test('saveSession sets token and active user id', () async {
      await tokenStorage.saveSession('user_42', 'jwt_token_abc');

      final session = await tokenStorage.getActiveSession();
      expect(session, isNotNull);
      expect(session?.userId, equals('user_42'));
      expect(session?.token, equals('jwt_token_abc'));

      final token = await tokenStorage.getToken('user_42');
      expect(token, equals('jwt_token_abc'));
    });

    test(
      'clearSession clears both active_user_id and active user token',
      () async {
        await tokenStorage.saveSession('user_42', 'jwt_token_abc');
        expect(await tokenStorage.getActiveSession(), isNotNull);

        await tokenStorage.clearSession();

        expect(await tokenStorage.getActiveSession(), isNull);
        expect(await tokenStorage.getToken('user_42'), isNull);
      },
    );

    test(
      'deleteToken clears specific user token and active session if matching',
      () async {
        await tokenStorage.saveSession('user_1', 'token_1');
        await tokenStorage.deleteToken('user_1');

        expect(await tokenStorage.getActiveSession(), isNull);
        expect(await tokenStorage.getToken('user_1'), isNull);
      },
    );
  });
}
