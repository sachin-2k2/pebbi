import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/app/router.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/core/network/network_status_provider.dart';
import 'package:peddi/core/storage/token_storage.dart';
import 'package:peddi/features/auth/data/remote_profile_repository.dart';
import 'package:peddi/features/auth/domain/profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/onboarding/data/device_onboarding_draft_storage.dart';
import 'package:peddi/features/onboarding/domain/onboarding_state.dart';
import 'package:peddi/features/onboarding/presentation/providers/app_startup_provider.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeConnectivity extends Fake implements Connectivity {
  final _controller = StreamController<List<ConnectivityResult>>.broadcast(sync: true);

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller.stream;

  void emit(List<ConnectivityResult> results) {
    _controller.add(results);
  }

  void dispose() {
    _controller.close();
  }
}

class FakeApiClient extends ApiClient {
  FakeApiClient({
    required super.tokenStorage,
    this.onGet,
  });

  Future<Response<dynamic>> Function(String path)? onGet;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (onGet != null) {
      final res = await onGet!(path);
      return res as Response<T>;
    }
    throw UnimplementedError('onGet not provided for path: $path');
  }
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository([this.profile]);

  UserProfile? profile;

  @override
  Future<UserProfile?> getCurrentProfile() async => profile;

  @override
  Future<void> saveProfile(UserProfile newProfile) async {
    profile = newProfile;
  }

  @override
  Future<void> clearProfile() async {
    profile = null;
  }
}

class ThrowingSecureStorage extends FlutterSecureStorage {
  const ThrowingSecureStorage();

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw PlatformException(
      code: 'KEYCHAIN_UNAVAILABLE',
      message: 'Failed to decrypt secure storage',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Start Routing and Offline Notice Tests', () {
    test('1. signed in, online -> Path', () async {
      SharedPreferences.setMockInitialValues({'first_run_done': true});
      FlutterSecureStorage.setMockInitialValues({
        'active_user_id': 'user_123',
        'token_user_123': 'jwt_abc_123',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final targetRoute = await container.read(appStartupProvider.future);
      expect(targetRoute, equals('/path'));
      expect(container.read(tokenStorageProvider).isSignedIn, isTrue);
    });

    testWidgets(
      '2. signed in, offline -> Path and the offline notice appears once; going online hides it',
      (tester) async {
        SharedPreferences.setMockInitialValues({'first_run_done': true});
        FlutterSecureStorage.setMockInitialValues({
          'active_user_id': 'user_123',
          'token_user_123': 'jwt_abc_123',
        });

        final container = ProviderContainer();
        addTearDown(container.dispose);

        final targetRoute = await container.read(appStartupProvider.future);
        expect(targetRoute, equals('/path'));

        final fakeConnectivity = FakeConnectivity();
        addTearDown(fakeConnectivity.dispose);

        final notifier = NetworkStatusNotifier(connectivity: fakeConnectivity);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              isOfflineProvider.overrideWith((ref) => notifier),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Consumer(
                      builder: _NoticeBannerConsumer.build,
                    ),
                    Text('Path Screen Content'),
                  ],
                ),
              ),
            ),
          ),
        );

        // Initially online: banner is hidden
        expect(find.byType(OfflineNoticeBanner), findsNothing);
        expect(
          find.text("You're offline. Some features need internet."),
          findsNothing,
        );

        // Connection lost
        fakeConnectivity.emit([ConnectivityResult.none]);
        await tester.pump();

        // Banner appears
        expect(find.byType(OfflineNoticeBanner), findsOneWidget);
        expect(
          find.text("You're offline. Some features need internet."),
          findsOneWidget,
        );

        // Connection restored
        fakeConnectivity.emit([ConnectivityResult.wifi]);
        await tester.pump();

        // Banner hidden
        expect(find.byType(OfflineNoticeBanner), findsNothing);
      },
    );

    test('3. not signed in -> welcome; with a draft -> resumes the saved step', () async {
      SharedPreferences.setMockInitialValues({'first_run_done': true});
      FlutterSecureStorage.setMockInitialValues({});

      final containerA = ProviderContainer();
      addTearDown(containerA.dispose);

      final routeNoDraft = await containerA.read(appStartupProvider.future);
      expect(routeNoDraft, equals('/welcome'));

      final prefs = await SharedPreferences.getInstance();
      final draftStorage = DeviceOnboardingDraftStorage(prefs: prefs);
      await draftStorage.flush(const OnboardingState(currentStep: 4));

      final containerB = ProviderContainer(
        overrides: [
          onboardingDraftStorageProvider.overrideWithValue(draftStorage),
        ],
      );
      addTearDown(containerB.dispose);

      final routeWithDraft = await containerB.read(appStartupProvider.future);
      expect(routeWithDraft, equals('/onboarding/setup/step-4'));
    });

    test(
      '4. signed in user opening onboarding or login is redirected to Path; signed out user opening Path is redirected to welcome',
      () {
        expect(appRouterRedirect(location: '/welcome', isSignedIn: true), equals('/path'));
        expect(appRouterRedirect(location: '/onboarding/setup/step-1', isSignedIn: true), equals('/path'));
        expect(appRouterRedirect(location: '/login', isSignedIn: true), equals('/path'));
        expect(appRouterRedirect(location: '/register', isSignedIn: true), equals('/path'));
        expect(appRouterRedirect(location: '/verify-otp', isSignedIn: true), equals('/path'));
        expect(appRouterRedirect(location: '/forgot-password', isSignedIn: true), equals('/path'));
        expect(appRouterRedirect(location: '/path', isSignedIn: true), isNull);

        expect(appRouterRedirect(location: '/path', isSignedIn: false), equals('/welcome'));
        expect(appRouterRedirect(location: '/missions', isSignedIn: false), equals('/welcome'));
        expect(appRouterRedirect(location: '/review', isSignedIn: false), equals('/welcome'));
        expect(appRouterRedirect(location: '/rewards', isSignedIn: false), equals('/welcome'));
        expect(appRouterRedirect(location: '/settings', isSignedIn: false), equals('/welcome'));
        expect(appRouterRedirect(location: '/welcome', isSignedIn: false), isNull);
        expect(appRouterRedirect(location: '/login', isSignedIn: false), isNull);
        expect(appRouterRedirect(location: '/onboarding/setup/step-2', isSignedIn: false), isNull);
      },
    );

    test(
      '5. a network error or a server error never signs the user out; a 401 keeps local data and asks to sign in again',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          'active_user_id': 'user_1',
          'token_user_1': 'jwt_user_1',
        });
        final tokenStorage = TokenStorage();
        await tokenStorage.getActiveSession();
        expect(tokenStorage.isSignedIn, isTrue);

        const cachedProfile = UserProfile(
          userId: 'user_1',
          ageBand: AgeBand.adult,
          explanationLanguageCode: 'en',
          targetLanguageCode: 'es',
          reasonIds: {'travel'},
          dailyGoalId: 'regular',
          reminderTime: ReminderTime(hour: 19, minute: 0),
          selectedWeekdayNumbers: {1, 2, 3, 4, 5, 6, 7},
          remindersEnabled: true,
          accentId: 'violet',
          plan: 'free',
          firstName: 'User 1',
        );
        final fakeLocalRepo = FakeProfileRepository(cachedProfile);

        var networkFailureCalled = false;
        String? sessionExpiredUserId;

        final fakeApiClient = FakeApiClient(tokenStorage: tokenStorage);

        final remoteRepo = RemoteProfileRepository(
          apiClient: fakeApiClient,
          localFallback: fakeLocalRepo,
          onNetworkFailure: () => networkFailureCalled = true,
          onSessionExpired: (uid) => sessionExpiredUserId = uid,
        );

        final reqOptions = RequestOptions(path: '/api/me');

        // Case A: Connection Timeout / Network Error
        fakeApiClient.onGet = (_) => throw DioException(
          requestOptions: reqOptions,
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timed out',
        );

        final profileA = await remoteRepo.getCurrentProfile();
        expect(profileA, isNotNull);
        expect(profileA?.userId, equals('user_1'));
        expect(tokenStorage.isSignedIn, isTrue);
        expect(networkFailureCalled, isTrue);
        expect(sessionExpiredUserId, isNull);

        // Reset flags
        networkFailureCalled = false;

        // Case B: 500 Server Error
        fakeApiClient.onGet = (_) => throw DioException(
          requestOptions: reqOptions,
          response: Response(requestOptions: reqOptions, statusCode: 500),
          type: DioExceptionType.badResponse,
          message: 'Internal server error',
        );

        final profileB = await remoteRepo.getCurrentProfile();
        expect(profileB, isNotNull);
        expect(tokenStorage.isSignedIn, isTrue);
        expect(networkFailureCalled, isFalse);
        expect(sessionExpiredUserId, isNull);

        // Case C: 401 Unauthorized / Session expired
        fakeApiClient.onGet = (_) => throw DioException(
          requestOptions: reqOptions,
          response: Response(requestOptions: reqOptions, statusCode: 401),
          type: DioExceptionType.badResponse,
          message: 'Unauthorized',
        );

        final profileC = await remoteRepo.getCurrentProfile();
        expect(profileC, isNotNull);
        expect(sessionExpiredUserId, equals('user_1'));
        expect(fakeLocalRepo.profile, isNotNull);
      },
    );

    test(
      '6. token without user id (and the reverse), and an unreadable secure storage, behave as signed out without crashing',
      () async {
        // Case A: Token exists but active user ID missing
        FlutterSecureStorage.setMockInitialValues({'token_ghost': 'orphan_jwt'});
        final storageA = TokenStorage();
        final sessionA = await storageA.getActiveSession();
        expect(sessionA, isNull);
        expect(storageA.isSignedIn, isFalse);

        // Case B: Active user ID exists but token is missing
        FlutterSecureStorage.setMockInitialValues({'active_user_id': 'orphan_user'});
        final storageB = TokenStorage();
        final sessionB = await storageB.getActiveSession();
        expect(sessionB, isNull);
        expect(storageB.isSignedIn, isFalse);

        // Case C: Unreadable secure storage (throws Exception)
        final storageC = TokenStorage(secureStorage: const ThrowingSecureStorage());
        final sessionC = await storageC.getActiveSession();
        expect(sessionC, isNull);
        expect(storageC.isSignedIn, isFalse);
      },
    );

    test('7. fresh install with leftover secure storage is cleared (first-run flag missing)', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({
        'active_user_id': 'leftover_user',
        'token_leftover_user': 'leftover_jwt',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final targetRoute = await container.read(appStartupProvider.future);
      expect(targetRoute, equals('/welcome'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('first_run_done'), isTrue);

      final tokenStorage = container.read(tokenStorageProvider);
      final session = await tokenStorage.getActiveSession();
      expect(session, isNull);
      expect(tokenStorage.isSignedIn, isFalse);
    });
  });
}

class _NoticeBannerConsumer {
  static Widget build(BuildContext context, WidgetRef ref, Widget? child) {
    final isOffline = ref.watch(isOfflineProvider);
    if (isOffline) {
      return const OfflineNoticeBanner();
    }
    return const SizedBox.shrink();
  }
}
