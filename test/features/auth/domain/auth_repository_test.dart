import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/auth/data/mock_auth_repository.dart';
import 'package:peddi/features/auth/data/mock_secure_session_store.dart';
import 'package:peddi/features/auth/domain/auth_result.dart';

void main() {
  group('MockAuthRepository', () {
    late MockSecureSessionStore secureStore;
    late MockAuthRepository authRepo;

    setUp(() {
      secureStore = MockSecureSessionStore();
      authRepo = MockAuthRepository(secureStore: secureStore);
    });

    test(
      'signInWithEmail succeeds with valid credentials and stores tokens',
      () async {
        final result = await authRepo.signInWithEmail(
          email: 'you@example.com',
          password: 'validpassword',
        );

        expect(result, isA<AuthSuccess>());
        final success = result as AuthSuccess;
        expect(success.session.email, 'you@example.com');
        expect(success.session.userId, startsWith('user_'));

        expect(await secureStore.getAccessToken(), isNotNull);
        expect(await secureStore.getRefreshToken(), isNotNull);
        expect(await secureStore.getUserId(), success.session.userId);

        final current = await authRepo.getCurrentSession();
        expect(current?.userId, success.session.userId);
      },
    );

    test(
      'signInWithEmail returns invalidCredentials for test triggers',
      () async {
        final result = await authRepo.signInWithEmail(
          email: 'wrong@example.com',
          password: 'validpassword',
        );

        expect(result, isA<AuthFailure>());
        final failure = result as AuthFailure;
        expect(failure.reason, AuthFailureReason.invalidCredentials);
        expect(await secureStore.getAccessToken(), isNull);
      },
    );

    test('signInWithEmail respects forced failure reasons', () async {
      authRepo.forceFailureReason = AuthFailureReason.network;

      final result = await authRepo.signInWithEmail(
        email: 'you@example.com',
        password: 'password',
      );

      expect(result, isA<AuthFailure>());
      expect((result as AuthFailure).reason, AuthFailureReason.network);
    });

    test('signInWithGoogle succeeds and saves tokens', () async {
      final result = await authRepo.signInWithGoogle();

      expect(result, isA<AuthSuccess>());
      final success = result as AuthSuccess;
      expect(success.session.userId, 'user_google_999');
      expect(await secureStore.getAccessToken(), isNotNull);
    });

    test('signInWithGoogle handles cancellation', () async {
      authRepo.forceGoogleCancel = true;

      final result = await authRepo.signInWithGoogle();

      expect(result, isA<AuthFailure>());
      expect((result as AuthFailure).reason, AuthFailureReason.cancelled);
      expect(await secureStore.getAccessToken(), isNull);
    });

    test(
      'signOut clears current session and wipes tokens from secure store',
      () async {
        await authRepo.signInWithEmail(
          email: 'you@example.com',
          password: 'password',
        );

        expect(await secureStore.getAccessToken(), isNotNull);
        expect(await authRepo.getCurrentSession(), isNotNull);

        await authRepo.signOut();

        expect(await secureStore.getAccessToken(), isNull);
        expect(await secureStore.getRefreshToken(), isNull);
        expect(await secureStore.getUserId(), isNull);
        expect(await authRepo.getCurrentSession(), isNull);
      },
    );

    test('mergeGuestProgress records merge calls', () async {
      await authRepo.mergeGuestProgress(
        guestId: 'guest_123',
        userId: 'user_456',
      );

      expect(authRepo.mergedGuestProgressCalls['guest_123'], 'user_456');
    });

    test(
      'mergeGuestProgress throws when forceMigrationFailure is true',
      () async {
        authRepo.forceMigrationFailure = true;

        expect(
          () => authRepo.mergeGuestProgress(
            guestId: 'guest_123',
            userId: 'user_456',
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'registerWithEmail succeeds with valid credentials and stores tokens',
      () async {
        final result = await authRepo.registerWithEmail(
          email: 'newuser@example.com',
          password: 'validpassword',
        );

        expect(result, isA<AuthSuccess>());
        final success = result as AuthSuccess;
        expect(success.session.email, 'newuser@example.com');
        expect(success.session.userId, startsWith('user_'));

        expect(await secureStore.getAccessToken(), isNotNull);
        expect(await secureStore.getRefreshToken(), isNotNull);
        expect(await secureStore.getUserId(), success.session.userId);

        final current = await authRepo.getCurrentSession();
        expect(current?.userId, success.session.userId);
      },
    );

    test(
      'registerWithEmail returns emailAlreadyInUse for already registered trigger',
      () async {
        final result = await authRepo.registerWithEmail(
          email: 'alreadyregistered@example.com',
          password: 'validpassword',
        );

        expect(result, isA<AuthFailure>());
        final failure = result as AuthFailure;
        expect(failure.reason, AuthFailureReason.emailAlreadyInUse);
        expect(await secureStore.getAccessToken(), isNull);
      },
    );

    test('registerWithEmail respects forced failure reasons', () async {
      authRepo.forceFailureReason = AuthFailureReason.network;

      final result = await authRepo.registerWithEmail(
        email: 'newuser@example.com',
        password: 'validpassword',
      );

      expect(result, isA<AuthFailure>());
      expect((result as AuthFailure).reason, AuthFailureReason.network);
    });
  });
}
