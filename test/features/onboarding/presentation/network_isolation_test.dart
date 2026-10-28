import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/language_level.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/fake_http_adapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Part A Network Isolation - Onboarding Flow Zero-API Contract', () {
    late FakeHttpClientAdapter fakeAdapter;
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      fakeAdapter = FakeHttpClientAdapter();
      container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWith((ref) {
            return ApiClient(adapter: fakeAdapter);
          }),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Step 2 (Birth year / Age band) makes ZERO HTTP calls', () {
      final notifier = container.read(onboardingFlowProvider.notifier);
      notifier.setStep(2);
      notifier.setAgeBand(AgeBand.band18_24);

      expect(fakeAdapter.recordedRequests, isEmpty);
    });

    test('Step 3 (I speak) makes ZERO HTTP calls', () {
      final notifier = container.read(onboardingFlowProvider.notifier);
      notifier.setStep(3);
      notifier.setExplanationLanguageCode('ml');

      expect(fakeAdapter.recordedRequests, isEmpty);
    });

    test('Step 4 (I want to learn) makes ZERO HTTP calls', () {
      final notifier = container.read(onboardingFlowProvider.notifier);
      notifier.setStep(4);
      notifier.setTargetLanguageCode('en');

      expect(fakeAdapter.recordedRequests, isEmpty);
    });

    test('Step 5 (Reasons for learning) makes ZERO HTTP calls', () {
      final notifier = container.read(onboardingFlowProvider.notifier);
      notifier.setStep(5);
      notifier.toggleReasonId('travel');
      notifier.toggleReasonId('career');

      expect(fakeAdapter.recordedRequests, isEmpty);
    });

    test(
      'Skipping placement ("I\'m brand new, start at Little") makes ZERO HTTP calls',
      () {
        final notifier = container.read(onboardingFlowProvider.notifier);
        notifier.skipPlacementWithLevel(LanguageLevel.little);
        notifier.setStep(7);

        expect(fakeAdapter.recordedRequests, isEmpty);
      },
    );

    test('Step 7 (Daily goal) makes ZERO HTTP calls', () {
      final notifier = container.read(onboardingFlowProvider.notifier);
      notifier.setStep(7);
      notifier.setDailyGoal('serious');

      expect(fakeAdapter.recordedRequests, isEmpty);
    });

    test('Step 8 (Reminders & Days) makes ZERO HTTP calls', () {
      final notifier = container.read(onboardingFlowProvider.notifier);
      notifier.setStep(8);
      notifier.setReminderTime(const ReminderTime(hour: 20, minute: 0));
      notifier.toggleWeekday(1);

      expect(fakeAdapter.recordedRequests, isEmpty);
    });

    test('Step 9 (Meet Pebbi & Accent) makes ZERO HTTP calls', () {
      final notifier = container.read(onboardingFlowProvider.notifier);
      notifier.setStep(9);
      notifier.setAccent('orange');
      notifier.setFirstSticker('wave');

      expect(fakeAdapter.recordedRequests, isEmpty);
    });
  });
}
