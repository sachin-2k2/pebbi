import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/back_link.dart';
import 'package:peddi/core/design_system/button_3d.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/core/services/wakelock_controller.dart';
import 'package:peddi/features/auth/data/mock_profile_repository.dart';
import 'package:peddi/features/auth/domain/user_profile.dart';
import 'package:peddi/features/auth/presentation/providers/auth_provider.dart';
import 'package:peddi/features/emergency/domain/emergency_repository.dart';
import 'package:peddi/features/emergency/presentation/providers/emergency_provider.dart';
import 'package:peddi/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:peddi/features/emergency/presentation/widgets/emergency_header.dart';
import 'package:peddi/features/emergency/presentation/widgets/emergency_note.dart';
import 'package:peddi/features/emergency/presentation/widgets/emergency_phrase_card.dart';
import 'package:peddi/features/emergency/presentation/widgets/emergency_unavailable_state.dart';
import 'package:peddi/features/emergency/presentation/widgets/show_screen_view.dart';
import 'package:peddi/features/onboarding/domain/age_band.dart';
import 'package:peddi/features/onboarding/domain/reminder_time.dart';
import 'package:peddi/l10n/app_strings.dart';

void main() {
  const spanishUser = UserProfile(
    userId: 'user_es',
    ageBand: AgeBand.adult,
    explanationLanguageCode: 'en',
    targetLanguageCode: 'es',
    reasonIds: {},
    dailyGoalId: 'casual',
    reminderTime: ReminderTime(hour: 9, minute: 0),
    selectedWeekdayNumbers: {1},
    remindersEnabled: false,
    accentId: 'violet',
    plan: 'free',
  );

  const frenchUser = UserProfile(
    userId: 'user_fr',
    ageBand: AgeBand.adult,
    explanationLanguageCode: 'en',
    targetLanguageCode: 'fr',
    reasonIds: {},
    dailyGoalId: 'casual',
    reminderTime: ReminderTime(hour: 9, minute: 0),
    selectedWeekdayNumbers: {1},
    remindersEnabled: false,
    accentId: 'violet',
    plan: 'free',
  );

  Widget buildSubject({
    UserProfile? user = spanishUser,
    EmergencyRepository? customRepo,
  }) {
    final fakeWakelock = FakeWakelockController();
    final fakeSpeech = FakeSpeechService();

    return ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(
          MockProfileRepository(initialProfile: user),
        ),
        wakelockControllerProvider.overrideWithValue(fakeWakelock),
        textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
        if (customRepo != null)
          emergencyRepositoryProvider.overrideWithValue(customRepo),
      ],
      child: const MaterialApp(home: EmergencyScreen()),
    );
  }

  testWidgets(
    'renders all 8 phrases, header, note, and back controls for Spanish',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify BackLink
      expect(find.byType(BackLink), findsOneWidget);
      expect(find.text(AppStrings.missionsLink), findsOneWidget);

      // Verify Header
      expect(find.byType(EmergencyHeader), findsOneWidget);
      expect(find.text(AppStrings.emergencyHeaderTitle), findsOneWidget);
      expect(find.text(AppStrings.emergencyHeaderSubtitle), findsOneWidget);

      // Verify 8 phrase cards
      expect(find.byType(EmergencyPhraseCard), findsNWidgets(8));
      expect(find.text('I need a doctor'), findsOneWidget);
      expect(find.text('Necesito un médico'), findsOneWidget);
      expect(find.text('Call the police'), findsOneWidget);
      expect(find.text('Llame a la policía, por favor'), findsOneWidget);
      expect(find.text("I'm lost"), findsOneWidget);
      expect(find.text('Estoy perdido'), findsOneWidget);
      expect(find.text("I'm allergic to..."), findsOneWidget);
      expect(find.text('Soy alérgico a esto'), findsOneWidget);
      expect(find.text("I don't understand"), findsOneWidget);
      expect(find.text('No entiendo'), findsOneWidget);
      expect(find.text('Where is the hospital?'), findsOneWidget);
      expect(find.text('¿Dónde está el hospital?'), findsOneWidget);
      expect(find.text('Please speak slowly'), findsOneWidget);
      expect(find.text('Hable más despacio, por favor'), findsOneWidget);
      expect(find.text('I lost my passport'), findsOneWidget);
      expect(find.text('Perdí mi pasaporte'), findsOneWidget);

      // Verify EmergencyNote
      expect(find.byType(EmergencyNote), findsOneWidget);
      expect(
        find.text(AppStrings.emergencyNoteMessage('Spanish')),
        findsOneWidget,
      );

      // Verify bottom button
      expect(find.byType(Button3D), findsOneWidget);
      expect(find.text(AppStrings.emergencyBackToMissions), findsOneWidget);
    },
  );

  testWidgets('tapping a phrase card opens ShowScreenView', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    await tester.pumpAndSettle();

    final firstCard = find.byType(EmergencyPhraseCard).first;
    await tester.tap(firstCard);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byType(ShowScreenView), findsOneWidget);
    expect(find.text('Necesito un médico'), findsOneWidget);
  });

  testWidgets(
    'renders EmergencyUnavailableState when active target language is unreviewed',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSubject(user: frenchUser));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(EmergencyUnavailableState), findsOneWidget);
      expect(
        find.text(AppStrings.emergencyPhrasesNotReadyTitle),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.emergencyPhrasesNotReadySubtitle),
        findsOneWidget,
      );
      expect(find.byType(EmergencyPhraseCard), findsNothing);
    },
  );
}
