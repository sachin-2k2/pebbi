import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/core/design_system/notice_banner.dart';
import 'package:peddi/core/network/api_client.dart';
import 'package:peddi/core/network/api_config.dart';
import 'package:peddi/core/services/text_to_speech_service.dart';
import 'package:peddi/features/onboarding/data/remote_language_repository.dart';
import 'package:peddi/features/onboarding/presentation/providers/onboarding_flow_provider.dart';
import 'package:peddi/features/onboarding/presentation/screens/language_step_screen.dart';
import 'package:peddi/features/onboarding/presentation/screens/learn_language_step_screen.dart';
import 'package:peddi/features/onboarding/presentation/widgets/step_footer_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../test/core/network/fake_http_adapter.dart';

const String _sampleNativeJson = '''[
  {
    "code": "ml",
    "name": "മലയാളം",
    "english_name": "Malayalam",
    "script_glyph": "മ",
    "translations_reviewed": false
  },
  {
    "code": "hi",
    "name": "हिन्दी",
    "english_name": "Hindi",
    "script_glyph": "अ",
    "translations_reviewed": false
  },
  {
    "code": "ta",
    "name": "தமிழ்",
    "english_name": "Tamil",
    "script_glyph": "த",
    "translations_reviewed": false
  },
  {
    "code": "te",
    "name": "తెలుగు",
    "english_name": "Telugu",
    "script_glyph": "తె",
    "translations_reviewed": false
  },
  {
    "code": "kn",
    "name": "ಕನ್ನಡ",
    "english_name": "Kannada",
    "script_glyph": "ಕ",
    "translations_reviewed": false
  },
  {
    "code": "es",
    "name": "Español",
    "english_name": "Spanish",
    "script_glyph": "Ñ",
    "translations_reviewed": false
  },
  {
    "code": "ar",
    "name": "العربية",
    "english_name": "Arabic",
    "script_glyph": "ع",
    "translations_reviewed": false
  },
  {
    "code": "fr",
    "name": "Français",
    "english_name": "French",
    "script_glyph": "Ç",
    "translations_reviewed": false
  },
  {
    "code": "de",
    "name": "Deutsch",
    "english_name": "German",
    "script_glyph": "Ä",
    "translations_reviewed": false
  },
  {
    "code": "en",
    "name": "English",
    "english_name": "English",
    "script_glyph": "A",
    "translations_reviewed": true
  }
]''';

const String _sampleLearnJson = '''[
  {
    "code": "en",
    "name": "English",
    "english_name": "English",
    "script_glyph": "A",
    "difficulty": 1,
    "learners_count": 52000000,
    "status": "available",
    "has_lessons": true,
    "has_placement": true,
    "hello_text": "Hello",
    "tts_locale": "en-US"
  },
  {
    "code": "es",
    "name": "Español",
    "english_name": "Spanish",
    "script_glyph": "Ñ",
    "difficulty": 1,
    "learners_count": 42000000,
    "status": "available",
    "has_lessons": false,
    "has_placement": true,
    "hello_text": "Hola",
    "tts_locale": "es-ES"
  },
  {
    "code": "fr",
    "name": "Français",
    "english_name": "French",
    "script_glyph": "Ç",
    "difficulty": 2,
    "learners_count": 28000000,
    "status": "coming_soon",
    "has_lessons": false,
    "has_placement": false,
    "hello_text": "Bonjour",
    "tts_locale": "fr-FR"
  },
  {
    "code": "de",
    "name": "Deutsch",
    "english_name": "German",
    "script_glyph": "Ä",
    "difficulty": 2,
    "learners_count": 16000000,
    "status": "coming_soon",
    "has_lessons": false,
    "has_placement": false,
    "hello_text": "Hallo",
    "tts_locale": "de-DE"
  },
  {
    "code": "ar",
    "name": "العربية",
    "english_name": "Arabic",
    "script_glyph": "ع",
    "difficulty": 3,
    "learners_count": 19000000,
    "status": "coming_soon",
    "has_lessons": false,
    "has_placement": false,
    "hello_text": "مرحبا",
    "tts_locale": "ar-SA"
  }
]''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeHttpClientAdapter adapter;
  late ApiClient apiClient;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    adapter = FakeHttpClientAdapter();
    apiClient = ApiClient(
      config: ApiConfig(baseUrl: 'https://test.api'),
      adapter: adapter,
    );
  });

  // TEST 1
  test('1. native list parses (incl. two-character glyph) and English is present', () async {
    adapter.onJson('/api/languages/native', _sampleNativeJson);
    final repo = RemoteLanguageRepository(apiClient: apiClient);

    final languages = await repo.getNativeLanguages();
    expect(languages.length, equals(10));

    final telugu = languages.firstWhere((l) => l.code == 'te');
    expect(telugu.badgeGlyph, equals('తె'));
    expect(telugu.nativeName, equals('తెలుగు'));

    final english = languages.firstWhere((l) => l.code == 'en');
    expect(english.englishName, equals('English'));
    expect(english.translationsReviewed, isTrue);
  });

  // TEST 2
  testWidgets('2. notice appears for a translations_reviewed:false language and not for English', (tester) async {
    adapter.onJson('/api/languages/native', _sampleNativeJson);
    final repo = RemoteLanguageRepository(apiClient: apiClient);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          home: Scaffold(body: LanguageStepScreen(initialCode: 'en')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // English selected: no yellow notice
    expect(find.byType(NoticeBanner), findsNothing);

    // Select Malayalam (translations_reviewed == false)
    await tester.tap(find.text('മലയാളം'));
    await tester.pumpAndSettle();

    expect(find.byType(NoticeBanner), findsOneWidget);
    expect(
      find.textContaining('Lessons are translated by AI for now'),
      findsOneWidget,
    );
  });

  // TEST 3
  testWidgets('3. learn list: English selectable; Spanish (has_lessons false), French, German, Arabic greyed and not selectable', (tester) async {
    adapter.onJson('/api/languages/learn', _sampleLearnJson);
    final repo = RemoteLanguageRepository(apiClient: apiClient);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          home: Scaffold(body: LearnLanguageStepScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // English has status: available and has_lessons: true -> selectable (and since exactly 1 selectable, auto-preselected)
    expect(find.text('English'), findsNWidgets(2));
    expect(find.text('52M learners'), findsOneWidget);

    // Spanish: has_lessons == false -> coming soon badge, not selectable
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('More coming soon'), findsWidgets);

    // Tap Spanish: should NOT change selection away from English
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    // Continue button remains enabled for English
    final footer = tester.widget<StepFooterButton>(find.byType(StepFooterButton));
    expect(footer.isEnabled, isTrue);
  });

  // TEST 4
  testWidgets('4. no selectable language shows the no-courses state', (tester) async {
    // Return only coming_soon languages
    const emptyCoursesJson = '''[
      {
        "code": "fr",
        "name": "Français",
        "english_name": "French",
        "script_glyph": "Ç",
        "status": "coming_soon",
        "has_lessons": false,
        "has_placement": false,
        "hello_text": "Bonjour",
        "tts_locale": "fr-FR"
      }
    ]''';
    adapter.onJson('/api/languages/learn', emptyCoursesJson);
    final repo = RemoteLanguageRepository(apiClient: apiClient);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          home: Scaffold(body: LearnLanguageStepScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No courses for your language yet'), findsOneWidget);
    expect(find.text('Change spoken language'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });

  // TEST 5
  test('5. changing the spoken language clears an invalid learn choice', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(onboardingFlowProvider.notifier);

    // Initially speaking 'ml' and learning 'en'
    notifier.setExplanationLanguageCode('ml');
    notifier.setTargetLanguageCode('en');

    var state = container.read(onboardingFlowProvider);
    expect(state.explanationLanguageCode, equals('ml'));
    expect(state.targetLanguageCode, equals('en'));

    // User goes back and changes spoken language to 'hi'
    notifier.setExplanationLanguageCode('hi');

    state = container.read(onboardingFlowProvider);
    expect(state.explanationLanguageCode, equals('hi'));
    expect(state.targetLanguageCode, isEmpty);
  });

  // TEST 6
  testWidgets('6. offline with cache uses the cache; offline without cache shows the fallback (step 3) / offline state (step 4)', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    // Step 3 with cache: returns cached
    await prefs.setString(
      'cached_native_languages_v1',
      jsonEncode([
        {
          "code": "cached_lang",
          "name": "Cached",
          "english_name": "Cached",
          "script_glyph": "C",
          "translations_reviewed": true
        }
      ]),
    );

    adapter.on('/api/languages/native', (opts) => ResponseBody.fromBytes(
      utf8.encode('{"detail": "offline"}'),
      500,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    ));

    final repo = RemoteLanguageRepository(apiClient: apiClient, prefs: prefs);
    final cachedResult = await repo.getNativeLanguages();
    expect(cachedResult.first.code, equals('cached_lang'));

    // Step 3 without cache: returns bundled fallback (10 languages)
    await prefs.remove('cached_native_languages_v1');
    final fallbackResult = await repo.getNativeLanguages();
    expect(fallbackResult.length, equals(10));

    // Step 4 with cache: returns cached
    await prefs.setString(
      'cached_learn_languages_ml',
      jsonEncode([
        {
          "code": "cached_learn",
          "name": "Cached Learn",
          "english_name": "Cached Learn",
          "script_glyph": "L",
          "difficulty": 1,
          "learners_count": 1000,
          "status": "available",
          "has_lessons": true,
          "has_placement": true,
          "hello_text": "Hi",
          "tts_locale": "en-US"
        }
      ]),
    );
    final cachedLearn = await repo.getLearnLanguages('ml');
    expect(cachedLearn.first.code, equals('cached_learn'));

    // Step 4 without cache: offline state rendered in UI
    await prefs.remove('cached_learn_languages_ml');
    adapter.on('/api/languages/learn', (opts) => ResponseBody.fromBytes(
      utf8.encode('{"detail": "offline"}'),
      500,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          home: Scaffold(body: LearnLanguageStepScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text("You're offline"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  // TEST 7
  testWidgets('7. tapping a selectable card plays its hello_text once, and nothing plays on open', (tester) async {
    adapter.onJson('/api/languages/learn', _sampleLearnJson);
    final repo = RemoteLanguageRepository(apiClient: apiClient);
    final fakeSpeech = FakeSpeechService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          languageRepositoryProvider.overrideWithValue(repo),
          textToSpeechServiceProvider.overrideWithValue(fakeSpeech),
        ],
        child: const MaterialApp(
          home: Scaffold(body: LearnLanguageStepScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify nothing played on open
    expect(fakeSpeech.speakCallCount, equals(0));

    // Tap English card (first occurrence)
    await tester.tap(find.text('English').first);
    await tester.pump();

    // Plays hello_text once with correct locale
    expect(fakeSpeech.speakCallCount, equals(1));
    expect(fakeSpeech.lastSpokenText, equals('Hello'));
    expect(fakeSpeech.lastLocale, equals('en-US'));
  });
}
