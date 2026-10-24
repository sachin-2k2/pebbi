import '../domain/guide_note.dart';
import '../domain/guide_phrase.dart';
import '../domain/unit_guide.dart';
import '../domain/unit_guide_repository.dart';

/// Mock implementation of [UnitGuideRepository] supplying realistic guide data.
///
/// Follows AGENTS.md §1 & §2: provides rich mock data matching the prototype design
/// and multiple testing configurations (French 16+3, Spanish, 40-phrase, RTL, etc.).
class MockUnitGuideRepository implements UnitGuideRepository {
  MockUnitGuideRepository({
    this.simulatedDelay = Duration.zero,
    this.cachedUnitIds = const {'unit_everyday_1', '1', 'unit_french_1'},
  });

  final Duration simulatedDelay;
  final Set<String> cachedUnitIds;

  @override
  bool isGuideCached(String unitId) => cachedUnitIds.contains(unitId);

  @override
  Future<UnitGuide?> getUnitGuide(
    String unitId, {
    required String languageCode,
    required String explanationLanguageCode,
    bool isOnline = true,
  }) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    if (!isOnline && !isGuideCached(unitId)) {
      return null;
    }

    if (unitId == 'unit_unavailable') {
      return null;
    }

    if (unitId == 'unit_arabic_1' || languageCode == 'ar') {
      return _buildArabicGuide(unitId, isCached: isGuideCached(unitId));
    }

    if (unitId == 'unit_long') {
      return _buildLongGuide(unitId, isCached: isGuideCached(unitId));
    }

    if (unitId == 'unit_no_notes') {
      return _buildNoNotesGuide(unitId, isCached: isGuideCached(unitId));
    }

    if (unitId == 'unit_no_phrases') {
      return _buildNoPhrasesGuide(unitId, isCached: isGuideCached(unitId));
    }

    if (unitId == 'unit_es_1' || languageCode == 'es') {
      return _buildSpanishGuide(unitId, isCached: isGuideCached(unitId));
    }

    // Default French guidebook matching the 3 design screenshots exactly
    return _buildFrenchGuide(unitId, isCached: isGuideCached(unitId));
  }

  UnitGuide _buildFrenchGuide(String unitId, {required bool isCached}) {
    const phrases = [
      GuidePhrase(
        id: 'fr_1',
        targetText: 'Bonjour',
        meaning: 'Hello, good day',
        helperLine: 'bohn-zhoor',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_2',
        targetText: 'Bonsoir',
        meaning: 'Good evening',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_3',
        targetText: 'Salut !',
        meaning: 'Hi!',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_4',
        targetText: 'Comment ça va ?',
        meaning: 'How are you?',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_5',
        targetText: 'Ça va bien, merci',
        meaning: "I'm well, thank you",
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_6',
        targetText: "S'il vous plaît",
        meaning: 'Please',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_7',
        targetText: 'Excusez-moi',
        meaning: 'Excuse me',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_8',
        targetText: "Je m'appelle Léa",
        meaning: 'My name is Léa',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_9',
        targetText: 'Enchanté',
        meaning: 'Nice to meet you',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_10',
        targetText: 'Au revoir',
        meaning: 'Goodbye',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_11',
        targetText: "Un café, s'il vous plaît",
        meaning: 'A coffee, please',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_12',
        targetText: 'Je voudrais un croissant',
        meaning: 'I would like a croissant',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_13',
        targetText: 'Combien ça coûte ?',
        meaning: 'How much is it?',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_14',
        targetText: "L'addition, s'il vous plaît",
        meaning: 'The bill, please',
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_15',
        targetText: "C'est délicieux",
        meaning: "It's delicious",
        audioLocale: 'fr-FR',
      ),
      GuidePhrase(
        id: 'fr_16',
        targetText: 'Tout de suite',
        meaning: 'Right away',
        audioLocale: 'fr-FR',
      ),
    ];

    const notes = [
      GuideNote(
        id: 'note_fr_1',
        emoji: '🧩',
        title: 'tu or vous?',
        body:
            'Use vous with strangers and at work. Save tu for friends and family.',
        tag: 'grammar',
      ),
      GuideNote(
        id: 'note_fr_2',
        emoji: '🔗',
        title: 'Liaison',
        body:
            'Words join together: les amis sounds like "lay-zamee". Listening for it makes fast French clearer.',
        tag: 'grammar',
      ),
      GuideNote(
        id: 'note_fr_3',
        emoji: '🥐',
        title: 'Bonjour first',
        body:
            'Greet before you ask for anything. Walking into a shop without a bonjour reads as rude.',
        tag: 'culture',
      ),
    ];

    return UnitGuide(
      unitId: unitId,
      title: 'First conversations',
      subtitleKey: 'unitGuideSubtitle',
      keyPhrases: phrases,
      notes: notes,
      languageCode: 'fr',
      explanationLanguageCode: 'en',
      isCached: isCached,
    );
  }

  UnitGuide _buildSpanishGuide(String unitId, {required bool isCached}) {
    const phrases = [
      GuidePhrase(
        id: 'es_1',
        targetText: '¡Hola!',
        meaning: 'Hello!',
        audioLocale: 'es-ES',
      ),
      GuidePhrase(
        id: 'es_2',
        targetText: 'Buenos días',
        meaning: 'Good morning',
        audioLocale: 'es-ES',
      ),
      GuidePhrase(
        id: 'es_3',
        targetText: 'Por favor',
        meaning: 'Please',
        audioLocale: 'es-ES',
      ),
      GuidePhrase(
        id: 'es_4',
        targetText: 'Gracias',
        meaning: 'Thank you',
        audioLocale: 'es-ES',
      ),
      GuidePhrase(
        id: 'es_5',
        targetText: 'De nada',
        meaning: "You're welcome",
        audioLocale: 'es-ES',
      ),
      GuidePhrase(
        id: 'es_6',
        targetText: 'Adiós',
        meaning: 'Goodbye',
        audioLocale: 'es-ES',
      ),
    ];

    const notes = [
      GuideNote(
        id: 'note_es_1',
        emoji: '🗣️',
        title: 'Tú vs Usted',
        body:
            'Use tú with friends, family, and peers. Use usted in polite or formal interactions.',
        tag: 'grammar',
      ),
    ];

    return UnitGuide(
      unitId: unitId,
      title: 'First conversations',
      subtitleKey: 'unitGuideSubtitle',
      keyPhrases: phrases,
      notes: notes,
      languageCode: 'es',
      explanationLanguageCode: 'en',
      isCached: isCached,
    );
  }

  UnitGuide _buildLongGuide(String unitId, {required bool isCached}) {
    final phrases = List.generate(
      40,
      (i) => GuidePhrase(
        id: 'long_$i',
        targetText: 'Phrase number ${i + 1}',
        meaning: 'Meaning for phrase ${i + 1}',
        audioLocale: 'fr-FR',
      ),
    );

    return UnitGuide(
      unitId: unitId,
      title: 'Long Unit Guide',
      subtitleKey: 'unitGuideSubtitle',
      keyPhrases: phrases,
      notes: const [],
      languageCode: 'fr',
      explanationLanguageCode: 'en',
      isCached: isCached,
    );
  }

  UnitGuide _buildNoNotesGuide(String unitId, {required bool isCached}) {
    return UnitGuide(
      unitId: unitId,
      title: 'First conversations',
      subtitleKey: 'unitGuideSubtitle',
      keyPhrases: const [
        GuidePhrase(
          id: 'nn_1',
          targetText: 'Bonjour',
          meaning: 'Hello',
          audioLocale: 'fr-FR',
        ),
      ],
      notes: const [],
      languageCode: 'fr',
      explanationLanguageCode: 'en',
      isCached: isCached,
    );
  }

  UnitGuide _buildNoPhrasesGuide(String unitId, {required bool isCached}) {
    return UnitGuide(
      unitId: unitId,
      title: 'Culture Overview',
      subtitleKey: 'unitGuideSubtitle',
      keyPhrases: const [],
      notes: const [
        GuideNote(
          id: 'np_note_1',
          emoji: '🥐',
          title: 'Bonjour first',
          body: 'Greet before you ask for anything.',
          tag: 'culture',
        ),
      ],
      languageCode: 'fr',
      explanationLanguageCode: 'en',
      isCached: isCached,
    );
  }

  UnitGuide _buildArabicGuide(String unitId, {required bool isCached}) {
    const phrases = [
      GuidePhrase(
        id: 'ar_1',
        targetText: 'مرحباً',
        meaning: 'Hello',
        helperLine: 'Marhaban',
        audioLocale: 'ar-SA',
        isRtl: true,
      ),
      GuidePhrase(
        id: 'ar_2',
        targetText: 'شكراً',
        meaning: 'Thank you',
        helperLine: 'Shukran',
        audioLocale: 'ar-SA',
        isRtl: true,
      ),
    ];

    const notes = [
      GuideNote(
        id: 'ar_note_1',
        emoji: '📖',
        title: 'Greeting in Arabic',
        body: 'Greetings are fundamental in Arab culture.',
        tag: 'culture',
        isRtl: true,
      ),
    ];

    return UnitGuide(
      unitId: unitId,
      title: 'المحادثات الأولى',
      subtitleKey: 'unitGuideSubtitle',
      keyPhrases: phrases,
      notes: notes,
      languageCode: 'ar',
      explanationLanguageCode: 'en',
      isCached: isCached,
    );
  }
}
