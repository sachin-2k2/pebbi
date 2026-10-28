import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/onboarding/data/device_onboarding_draft_storage.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/onboarding_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceOnboardingDraftStorage', () {
    late DeviceOnboardingDraftStorage storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = DeviceOnboardingDraftStorage();
    });

    test(
      'flushes immediately on call (e.g. before app backgrounded or step change)',
      () async {
        const state = OnboardingState(
          currentStep: 4,
          ageBand: AgeBand.band18_24,
          explanationLanguageCode: 'ml',
          targetLanguageCode: 'en',
        );

        await storage.flush(state);

        final loaded = await storage.load();
        expect(loaded, isNotNull);
        expect(loaded?.currentStep, equals(4));
        expect(loaded?.ageBand, equals(AgeBand.band18_24));
        expect(loaded?.explanationLanguageCode, equals('ml'));
        expect(loaded?.targetLanguageCode, equals('en'));
      },
    );

    test('debounces saves by 300ms', () async {
      const state1 = OnboardingState(
        currentStep: 2,
        explanationLanguageCode: 'en',
      );
      const state2 = OnboardingState(
        currentStep: 3,
        explanationLanguageCode: 'ml',
      );

      storage.saveDebounced(state1);
      storage.saveDebounced(state2);

      // Before 300ms, storage is still empty
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(DeviceOnboardingDraftStorage.storageKey), isNull);

      // After 350ms, the latest state2 is flushed
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final loaded = await storage.load();
      expect(loaded?.currentStep, equals(3));
      expect(loaded?.explanationLanguageCode, equals('ml'));
    });

    test(
      'discards legacy draft with old age_band values (child, teen, adult)',
      () async {
        final legacyDraft = {
          'version': 1,
          'current_step': 3,
          'age_band': 'child', // OLD legacy value
          'native_language': 'en',
        };

        SharedPreferences.setMockInitialValues({
          DeviceOnboardingDraftStorage.storageKey: jsonEncode(legacyDraft),
        });

        storage = DeviceOnboardingDraftStorage();

        final loaded = await storage.load();
        // Should be discarded, returning null so onboarding restarts at step 1
        expect(loaded, isNull);

        // And stored key cleared
        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getString(DeviceOnboardingDraftStorage.storageKey),
          isNull,
        );
      },
    );

    test('stored JSON NEVER contains raw birth year or answers', () async {
      const state = OnboardingState(currentStep: 2, ageBand: AgeBand.band25_34);

      await storage.flush(state);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(DeviceOnboardingDraftStorage.storageKey)!;

      expect(raw.contains('birth_year'), isFalse);
      expect(raw.contains('year_of_birth'), isFalse);
      expect(raw.contains('password'), isFalse);
    });
  });
}
