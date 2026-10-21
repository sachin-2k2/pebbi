import '../domain/phrase.dart';
import '../domain/phrase_repository.dart';
import '../domain/review_summary.dart';

/// In-memory mock implementation of [PhraseRepository].
///
/// Follows AGENTS.md §1 & §6: Implements per-user and per-language phrase persistence in memory.
class MockPhraseRepository implements PhraseRepository {
  MockPhraseRepository({
    Map<String, Map<String, List<Phrase>>>? initialData,
    List<Phrase>? samplePhrases,
    this.shouldFail = false,
  }) : _storage = initialData ?? {} {
    if (samplePhrases != null) {
      _storage['guest_default'] = {'es': List.of(samplePhrases)};
      _storage['user_test'] = {'es': List.of(samplePhrases)};
    }
  }

  final bool shouldFail;

  /// Internal store: `userId -> languageCode -> List<Phrase>`
  final Map<String, Map<String, List<Phrase>>> _storage;

  /// Static getter returning default 5 sample phrases.
  static List<Phrase> get defaultSamplePhrases =>
      MockPhraseRepository.withSamplePhrases()._storage['user_test']?['es'] ??
      const [];

  /// Helper generating large lists of phrases for performance tests.
  static List<Phrase> generateLargePhraseList(
    int count, {
    String languageCode = 'es',
  }) {
    return List.generate(
      count,
      (i) => Phrase(
        id: 'phrase_perf_$i',
        languageCode: languageCode,
        targetText: 'Frase de prueba número $i',
        meaning: 'Test phrase number $i',
        status: i % 5 == 0
            ? PhraseStatus.tricky
            : (i % 3 == 0 ? PhraseStatus.newPhrase : PhraseStatus.none),
        isSaved: i % 4 == 0,
        seenCount: i + 1,
        wrongCount: i % 5 == 0 ? 3 : 0,
      ),
    );
  }

  /// Factory creating a mock pre-seeded with 5 sample phrases in Spanish.
  factory MockPhraseRepository.withSamplePhrases({
    String userId = 'user_test',
    String languageCode = 'es',
  }) {
    final repo = MockPhraseRepository();
    repo._storage[userId] = {
      languageCode: [
        const Phrase(
          id: 'phrase_1',
          languageCode: 'es',
          targetText: '¿Dónde está el baño?',
          meaning: 'Where is the bathroom?',
          helperLine: 'don-de es-ta el ba-nyo',
          status: PhraseStatus.tricky,
          isSaved: true,
          seenCount: 5,
          wrongCount: 3,
        ),
        const Phrase(
          id: 'phrase_2',
          languageCode: 'es',
          targetText: 'Un café con leche, por favor',
          meaning: 'A coffee with milk, please',
          helperLine: 'un ka-fe kon le-che por fa-vor',
          status: PhraseStatus.none,
          isSaved: false,
          seenCount: 8,
          wrongCount: 0,
        ),
        const Phrase(
          id: 'phrase_3',
          languageCode: 'es',
          targetText: 'Mucho gusto en conocerte',
          meaning: 'Nice to meet you',
          helperLine: 'mu-cho gus-to en ko-no-ser-te',
          status: PhraseStatus.newPhrase,
          isSaved: false,
          seenCount: 1,
          wrongCount: 0,
        ),
        const Phrase(
          id: 'phrase_4',
          languageCode: 'es',
          targetText: 'La cuenta, por favor',
          meaning: 'The bill, please',
          helperLine: 'la kwen-ta por fa-vor',
          status: PhraseStatus.tricky,
          isSaved: false,
          seenCount: 4,
          wrongCount: 2,
        ),
        const Phrase(
          id: 'phrase_5',
          languageCode: 'es',
          targetText: 'No entiendo',
          meaning: 'I do not understand',
          helperLine: 'no en-tyen-do',
          status: PhraseStatus.none,
          isSaved: true,
          seenCount: 6,
          wrongCount: 1,
        ),
      ],
      'ar': [
        const Phrase(
          id: 'phrase_ar_1',
          languageCode: 'ar',
          targetText: 'أين الحمام؟',
          meaning: 'Where is the bathroom?',
          helperLine: 'Ayna al-hammam?',
          status: PhraseStatus.tricky,
          isSaved: true,
          seenCount: 3,
          wrongCount: 2,
        ),
      ],
    };
    return repo;
  }

  /// Factory creating a mock with 300 generated phrases for sliver list performance tests.
  factory MockPhraseRepository.with300Phrases({
    String userId = 'user_perf',
    String languageCode = 'es',
  }) {
    final repo = MockPhraseRepository();
    final phrases = List.generate(
      300,
      (i) => Phrase(
        id: 'phrase_perf_$i',
        languageCode: languageCode,
        targetText: 'Frase de prueba número $i',
        meaning: 'Test phrase number $i',
        status: i % 5 == 0
            ? PhraseStatus.tricky
            : (i % 3 == 0 ? PhraseStatus.newPhrase : PhraseStatus.none),
        isSaved: i % 4 == 0,
        seenCount: i + 1,
        wrongCount: i % 5 == 0 ? 3 : 0,
      ),
    );
    repo._storage[userId] = {languageCode: phrases};
    return repo;
  }

  @override
  Future<List<Phrase>> getPhrases({
    required String userId,
    required String languageCode,
  }) async {
    if (shouldFail) {
      throw StateError('Unable to load phrases from repository.');
    }
    return _storage[userId]?[languageCode] ?? const [];
  }

  @override
  Future<void> toggleBookmark({
    required String userId,
    required String phraseId,
    required bool isSaved,
  }) async {
    if (shouldFail) {
      throw StateError('Unable to update bookmark status.');
    }
    final userMap = _storage[userId];
    if (userMap != null) {
      for (final entry in userMap.entries) {
        final list = entry.value;
        final idx = list.indexWhere((p) => p.id == phraseId);
        if (idx != -1) {
          final current = list[idx].isSaved;
          list[idx] = list[idx].copyWith(isSaved: !current);
          return;
        }
      }
    }

    for (final map in _storage.values) {
      for (final list in map.values) {
        final idx = list.indexWhere((p) => p.id == phraseId);
        if (idx != -1) {
          final current = list[idx].isSaved;
          list[idx] = list[idx].copyWith(isSaved: !current);
          return;
        }
      }
    }
  }

  @override
  Future<void> addPhrase({
    required String userId,
    required Phrase phrase,
  }) async {
    if (shouldFail) {
      throw StateError('Unable to save phrase to repository.');
    }
    final userMap = _storage.putIfAbsent(userId, () => {});
    final langList = userMap.putIfAbsent(phrase.languageCode, () => []);
    langList.insert(0, phrase);
  }

  @override
  Future<void> savePhrase(Phrase phrase, {String userId = 'guest_default'}) =>
      addPhrase(userId: userId, phrase: phrase);

  @override
  Future<void> toggleSaved(
    String phraseId, {
    String userId = 'guest_default',
    bool? isSaved,
  }) => toggleBookmark(
    userId: userId,
    phraseId: phraseId,
    isSaved: isSaved ?? true,
  );

  @override
  Future<ReviewSummary> getSummary({
    required String userId,
    required String languageCode,
  }) async {
    final phrases = await getPhrases(
      userId: userId,
      languageCode: languageCode,
    );
    return ReviewSummary.fromPhrases(phrases);
  }
}
