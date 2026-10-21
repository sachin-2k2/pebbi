import '../domain/grammar_note.dart';
import '../domain/grammar_note_summary.dart';
import '../domain/notes_repository.dart';

/// Fake repository supplying mock grammar and culture notes with offline caching simulation.
///
/// Follows AGENTS.md §1 (fake repo with realistic data) and §6 (user-isolated read state).
class MockNotesRepository implements NotesRepository {
  MockNotesRepository({
    List<GrammarNote>? initialNotes,
    this.userId = 'guest',
  }) {
    if (initialNotes != null) {
      _notes = List.of(initialNotes);
    } else {
      _notes = List.of(defaultNotes);
    }
  }

  final String userId;
  late final List<GrammarNote> _notes;

  // Shared across users on this device: cached note bodies
  static final Set<String> _sharedCachedNoteIds = {};

  // User-isolated: which notes this user has read
  static final Map<String, Set<String>> _userReadNoteIds = {};

  // Telemetry event tracking for unit testing
  final List<String> reportedOpenedEvents = [];

  bool isOnline = true;

  static const List<GrammarNote> defaultNotes = [
    GrammarNote(
      summary: GrammarNoteSummary(
        id: 'ser_vs_estar',
        emoji: '🧩',
        title: 'ser vs estar',
        excerpt:
            'Both mean "to be". Ser is for who you are, estar for how you are. Learn when to reach for each one with our quick rule of thumb.',
        languageCode: 'es',
        levelId: 'A1',
        dots: 3,
      ),
      body:
          'In Spanish, both "ser" and "estar" translate to the English verb "to be", but they serve completely different purposes.\n\n'
          'Use "ser" for essential qualities, identity, nationality, profession, and characteristics that define who or what something is permanently.\n\n'
          'Use "estar" for temporary states, locations, health, and current emotional or physical conditions.\n\n'
          'Example:\n'
          '• "Soy profesor" (I am a teacher - identity)\n'
          '• "Estoy cansado" (I am tired - state of being)',
    ),
    GrammarNote(
      summary: GrammarNoteSummary(
        id: 'el_cafe_la_cuenta',
        emoji: '🔤',
        title: 'el café, la cuenta',
        excerpt:
            'Every noun has a gender. Learn the word together with its el or la so you never have to guess when ordering at a counter.',
        languageCode: 'es',
        levelId: 'A1',
        dots: 3,
      ),
      body:
          'In Spanish, every single noun is either masculine or feminine.\n\n'
          'Masculine nouns usually take "el" (singular) and "los" (plural), often ending in -o (el café, el libro).\n\n'
          'Feminine nouns usually take "la" (singular) and "las" (plural), often ending in -a, -ción, or -dad (la cuenta, la ciudad).\n\n'
          'Golden rule: Always memorize words with their article (el or la) together!',
    ),
    GrammarNote(
      summary: GrammarNoteSummary(
        id: 'greetings_culture',
        emoji: '🌍',
        title: 'Greetings',
        excerpt:
            'Two cheek kisses in Spain, one in much of Latin America, a handshake in formal settings. How to say hello naturally wherever you travel.',
        languageCode: 'es',
        levelId: 'A1',
        dots: 3,
      ),
      body:
          'Greeting etiquette in the Spanish-speaking world is warm and relational.\n\n'
          'In Spain, greeting friends and acquaintances typically involves two cheek kisses (starting right to left). In most of Latin America, one cheek kiss or a warm embrace is common.\n\n'
          'In business or when meeting elders, a firm handshake with direct eye contact is standard.\n\n'
          'Common greetings:\n'
          '• "¡Hola! ¿Cómo estás?" (Informal)\n'
          '• "Buenos días / Buenas tardes" (Polite)',
    ),
  ];

  static List<GrammarNote> generate40Notes() {
    return List.generate(40, (index) {
      return GrammarNote(
        summary: GrammarNoteSummary(
          id: 'note_$index',
          emoji: index % 2 == 0 ? '📚' : '💡',
          title: 'Grammar Note #$index: Spanish Patterns',
          excerpt:
              'Excerpt for lesson rule $index explaining regular verb conjugations and cultural nuance.',
          languageCode: 'es',
          levelId: 'A1',
          dots: index % 4,
        ),
        body: 'Full guide text for note #$index with detailed examples.',
      );
    });
  }

  static List<GrammarNote> generateRtlNotes() {
    return const [
      GrammarNote(
        summary: GrammarNoteSummary(
          id: 'arabic_greetings',
          emoji: '🌙',
          title: 'التحيات في اللغة العربية',
          excerpt:
              'السلام عليكم هي التحية الأكثر شيوعاً في العالم العربي، وتستخدم في كل الأوقات والمناسبات.',
          languageCode: 'ar',
          levelId: 'A1',
          dots: 3,
        ),
        body: 'تفاصيل التحيات باللغة العربية مع نطقها الصحيح واستخداماتها.',
      ),
    ];
  }

  @override
  Future<List<GrammarNoteSummary>> getNotes({
    required String languageCode,
    required String levelId,
    String? explanationLanguage,
  }) async {
    final userReads = _userReadNoteIds[userId] ?? {};

    return _notes
        .where(
          (n) =>
              n.summary.languageCode == languageCode &&
              n.summary.levelId == levelId,
        )
        .map((n) {
          final isCached = _sharedCachedNoteIds.contains(n.id);
          final isRead = userReads.contains(n.id);
          return n.summary.copyWith(isCached: isCached, isRead: isRead);
        })
        .toList();
  }

  @override
  Future<GrammarNote?> openNote(String id, {bool isOnline = true}) async {
    final note = _notes.cast<GrammarNote?>().firstWhere(
      (n) => n?.id == id,
      orElse: () => null,
    );
    if (note == null) return null;

    final isCached = _sharedCachedNoteIds.contains(id);

    if (isOnline) {
      // Offline once opened: cache the body on the device
      _sharedCachedNoteIds.add(id);
      await markNoteRead(id);
      return note;
    } else {
      // Offline: only return if already cached
      if (isCached) {
        await markNoteRead(id);
        return note;
      }
      return null;
    }
  }

  @override
  Future<void> markNoteRead(String id) async {
    final userReads = _userReadNoteIds.putIfAbsent(userId, () => {});
    userReads.add(id);
    if (!reportedOpenedEvents.contains(id)) {
      reportedOpenedEvents.add(id);
    }
  }

  @override
  bool isNoteCached(String id) => _sharedCachedNoteIds.contains(id);

  static void resetSharedCache() {
    _sharedCachedNoteIds.clear();
    _userReadNoteIds.clear();
  }
}
