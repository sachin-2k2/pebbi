import '../domain/language_level.dart';
import '../domain/placement_answer.dart';
import '../domain/placement_intro.dart';
import '../domain/placement_question.dart';
import '../domain/placement_repository.dart';
import '../domain/placement_submission_result.dart';

/// Mock implementation of [PlacementRepository] providing realistic offline placement data.
///
/// Follows AGENTS.md §1 & §2: Used in mock mode and tests.
class MockPlacementRepository implements PlacementRepository {
  const MockPlacementRepository({
    this.shouldFail = false,
    this.isAvailable = true,
    this.delay = Duration.zero,
  });

  final bool shouldFail;
  final bool isAvailable;
  final Duration delay;

  @override
  Future<PlacementIntro> getIntro({
    required String nativeLanguage,
    required String targetLanguage,
  }) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Mock placement intro error');

    final target = targetLanguage.toLowerCase().trim();
    final greeting = target == 'ml'
        ? 'നമസ്കാരം, friend! 🙏'
        : (target == 'es' ? '¡Hola, friend! 👋' : 'Hello, friend! 👋');

    return PlacementIntro(
      pebbiSays:
          "$greeting Let's see how much you know. No pressure — just have fun! 😎",
      subtitle: '8 quick ones · About 2 minutes · Ends in a win',
    );
  }

  @override
  Future<PlacementQuestionSet> getQuestions({
    required String nativeLanguage,
    required String targetLanguage,
  }) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Mock placement questions error');

    if (!isAvailable) {
      return const PlacementQuestionSet(
        isAvailable: false,
        total: 0,
        questions: [],
        unavailableMessage: 'Coming soon! Starting at Little level 🌱',
        defaultLevel: LanguageLevel.little,
      );
    }

    final target = targetLanguage.toLowerCase().trim();
    final native = nativeLanguage.toLowerCase().trim();

    List<PlacementQuestion> questions;
    if (target == 'ml') {
      questions = _kMalayalamQuestions;
    } else if (target == 'en' || native == 'ml') {
      questions = _kEnglishQuestions(isNativeMalayalam: native == 'ml');
    } else {
      questions = _kSpanishQuestions;
    }

    return PlacementQuestionSet(
      isAvailable: true,
      total: questions.length,
      questions: questions,
    );
  }

  @override
  Future<PlacementSubmissionResult> submitAnswers({
    required String nativeLanguage,
    required List<PlacementAnswer> answers,
  }) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Mock placement submit error');

    final score = answers.length >= 6 ? 6 : answers.length;
    final total = answers.isNotEmpty ? answers.length : 8;
    final pct = ((score / total) * 100).round();

    LanguageLevel level;
    if (pct >= 75) {
      level = LanguageLevel.expert;
    } else if (pct >= 50) {
      level = LanguageLevel.knowABit;
    } else {
      level = LanguageLevel.little;
    }

    return PlacementSubmissionResult(
      score: score,
      total: total,
      scorePct: pct,
      level: level,
      estimatedNote: 'Estimated starting point based on this short quiz',
      identity: 'Explorer ⚡',
      emoji: '⚡',
      message: 'Great job! Starting your journey.',
    );
  }
}

// ---------------------------------------------------------------------------
// English Questions (for Malayalam or general speakers learning English)
// ---------------------------------------------------------------------------
List<PlacementQuestion> _kEnglishQuestions({required bool isNativeMalayalam}) => [
  PlacementQuestion(
    id: 'q001',
    sortOrder: 1,
    difficulty: 'A1',
    questionText: isNativeMalayalam
        ? "'ഇതാ നിങ്ങൾക്ക്' എന്ന് പറയാൻ ഏതാണ് ഉപയോഗിക്കുന്നത്? 🎁"
        : "Which one means 'Here you are!'? 🎁",
    targetPhrase: 'Here you are',
    options: const [
      PlacementOption(
        emoji: '🤝',
        label: 'Here you are!',
        isCorrect: true,
        pebbiCorrect: "Spot on! 🔥 You're off to a flying start!",
        pebbiWrong: "Oops! 'Here you are' means handing something over.",
        funFact: "Used whenever you hand something to someone politely.",
      ),
      PlacementOption(
        emoji: '👋',
        label: 'Goodbye!',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Goodbye' means waving farewell! 👋",
      ),
      PlacementOption(
        emoji: '🙅',
        label: 'No way!',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'No way' expresses strong disagreement.",
      ),
      PlacementOption(
        emoji: '🤷',
        label: "I don't know",
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'I don't know' means you lack the answer.",
      ),
    ],
    funFact: "You'll hear 'Here you are' every day in shops and restaurants!",
    pebbiCorrect: "Spot on! 🔥 You're off to a flying start!",
    pebbiWrong: "Oopsie! 'Here you are' is what waiters say when they serve you! 🍽️",
  ),
  PlacementQuestion(
    id: 'q002',
    sortOrder: 2,
    difficulty: 'A1',
    questionText: isNativeMalayalam
        ? "'വളരെ നന്ദി' എന്ന് പറയാൻ ഏതാണ് ഉപയോഗിക്കുന്നത്? 🙏"
        : "Which one means 'Thank you very much!'? 🙏",
    targetPhrase: 'Thank you very much',
    options: const [
      PlacementOption(
        emoji: '🙏',
        label: 'Thank you very much!',
        isCorrect: true,
        pebbiCorrect: 'Spot on! ⭐',
        pebbiWrong: 'No worries! Folded hands indicates gratitude.',
        funFact: 'Politeness opens every door in English.',
      ),
      PlacementOption(
        emoji: '🚪',
        label: 'Excuse me',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Excuse me' is used to get attention or apologize.",
      ),
      PlacementOption(
        emoji: '⏰',
        label: 'See you later',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'See you later' is a parting phrase.",
      ),
      PlacementOption(
        emoji: '☕',
        label: 'A coffee please',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'A coffee please is for ordering a drink!',
      ),
    ],
    funFact: 'Essential anywhere in the English-speaking world.',
    pebbiCorrect: 'Spot on! ⭐',
    pebbiWrong: 'No worries! Thank you very much means expressing gratitude.',
  ),
  PlacementQuestion(
    id: 'q003',
    sortOrder: 3,
    difficulty: 'A1',
    questionText: isNativeMalayalam
        ? "'സുപ്രഭാതം' എന്ന് പറയാൻ ഏതാണ് ഉപയോഗിക്കുന്നത്? 🌅"
        : "Which one means 'Good morning!'? 🌅",
    targetPhrase: 'Good morning',
    options: const [
      PlacementOption(
        emoji: '🌅',
        label: 'Good morning!',
        isCorrect: true,
        pebbiCorrect: 'Bright and early! ☀️',
        pebbiWrong: 'Almost! The rising sun represents morning.',
        funFact: "Used from dawn until noon.",
      ),
      PlacementOption(
        emoji: '🌙',
        label: 'Good night!',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Good night' is only used before going to bed.",
      ),
      PlacementOption(
        emoji: '🍽️',
        label: 'Enjoy your meal!',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Enjoy your meal' is said before eating.",
      ),
      PlacementOption(
        emoji: '🏃',
        label: 'Hurry up!',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Hurry up' means go faster!",
      ),
    ],
    funFact: 'Good morning is the standard greeting before 12:00 PM.',
    pebbiCorrect: 'Bright and early! ☀️',
    pebbiWrong: 'Almost! Good morning is used in the morning.',
  ),
  PlacementQuestion(
    id: 'q004',
    sortOrder: 4,
    difficulty: 'A2',
    questionText: isNativeMalayalam
        ? "'ഇതിന് എത്ര വിലയാകും' എന്ന് ചോദിക്കാൻ ഏതാണ് ഉപയോഗിക്കുന്നത്? 💶"
        : "Which one means 'How much does it cost?'? 💶",
    targetPhrase: 'How much is it?',
    options: const [
      PlacementOption(
        emoji: '💶',
        label: 'How much is it?',
        isCorrect: true,
        pebbiCorrect: 'Great job! 💳',
        pebbiWrong: 'Currency symbols ask for the price.',
        funFact: "Essential phrase when shopping.",
      ),
      PlacementOption(
        emoji: '📍',
        label: 'Where is it?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Where is it?' asks for location.",
      ),
      PlacementOption(
        emoji: '🕐',
        label: 'What time is it?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'What time is it?' asks for the clock.",
      ),
      PlacementOption(
        emoji: '❓',
        label: 'Who is it?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Who is it?' asks for identity.",
      ),
    ],
    funFact: 'A vital phrase when shopping in local stores.',
    pebbiCorrect: 'Great job! 💳',
    pebbiWrong: 'Not quite! How much asks for the price.',
  ),
  PlacementQuestion(
    id: 'q005',
    sortOrder: 5,
    difficulty: 'A2',
    questionText: isNativeMalayalam
        ? "'ബാത്ത്റൂം എവിടെയാണ്' എന്ന് ചോദിക്കാൻ ഏതാണ് ഉപയോഗിക്കുന്നത്? 🚻"
        : "Which one means 'Where is the bathroom?'? 🚻",
    targetPhrase: 'Where is the bathroom?',
    options: const [
      PlacementOption(
        emoji: '🚻',
        label: 'Where is the bathroom?',
        isCorrect: true,
        pebbiCorrect: 'You got it! 🎯',
        pebbiWrong: 'Restroom symbols point to the bathroom.',
        funFact: 'In the UK, people also say "Where is the toilet?".',
      ),
      PlacementOption(
        emoji: '🏨',
        label: 'Where is the hotel?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'The hotel symbol represents accommodation.',
      ),
      PlacementOption(
        emoji: '🚕',
        label: 'Where is the taxi?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'The taxi symbol is for transport.',
      ),
      PlacementOption(
        emoji: '🍽️',
        label: 'Where is the restaurant?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Fork and knife mean restaurant.',
      ),
    ],
    funFact: 'One of the most useful travel survival phrases.',
    pebbiCorrect: 'You got it! 🎯',
    pebbiWrong: 'No worries! Restroom emoji means bathroom.',
  ),
  PlacementQuestion(
    id: 'q006',
    sortOrder: 6,
    difficulty: 'B1',
    questionText: isNativeMalayalam
        ? "'സഹായിക്കാമോ' എന്ന് പറയാൻ ഏതാണ് ഉപയോഗിക്കുന്നത്? 🆘"
        : "Which one means 'Could you help me?'? 🆘",
    targetPhrase: 'Could you help me please?',
    options: const [
      PlacementOption(
        emoji: '🆘',
        label: 'Could you help me?',
        isCorrect: true,
        pebbiCorrect: 'Incredible! You nailed a tough one! 🔥',
        pebbiWrong: 'SOS emoji represents asking for assistance.',
        funFact: "'Could you' is more polite than 'Can you'.",
      ),
      PlacementOption(
        emoji: '🏃',
        label: "I'm running late!",
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Running emoji means being in a hurry.',
      ),
      PlacementOption(
        emoji: '⏳',
        label: 'Just a minute please',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Hourglass means asking someone to wait.',
      ),
      PlacementOption(
        emoji: '😴',
        label: 'I fell asleep',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Sleeping emoji means being tired.',
      ),
    ],
    pebbiWarning: "Heads up — this one's trickier! You've got this 💪",
    funFact: "'Could you' is the standard polite phrasing.",
    pebbiCorrect: 'Incredible! You nailed a tough one! 🔥',
    pebbiWrong: 'Nice try! SOS means asking for help.',
  ),
  PlacementQuestion(
    id: 'q007',
    sortOrder: 7,
    difficulty: 'B1',
    questionText: isNativeMalayalam
        ? "'കുറച്ച് വെള്ളം തരാമോ' എന്ന് ചോദിക്കാൻ ഏതാണ് ഉപയോഗിക്കുന്നത്? 💧"
        : "Which one means 'Could I have some water, please?'? 💧",
    targetPhrase: 'Could I have some water?',
    options: const [
      PlacementOption(
        emoji: '💧',
        label: 'Water please',
        isCorrect: true,
        pebbiCorrect: 'Polite and natural! 🌟',
        pebbiWrong: 'Water droplet represents drinking water.',
        funFact: 'Very polite way to ask in any café or restaurant.',
      ),
      PlacementOption(
        emoji: '🧾',
        label: 'Could I have the bill?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Receipt emoji means asking for the bill.',
      ),
      PlacementOption(
        emoji: '🍷',
        label: 'Could I see the drink menu?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Wine glass means looking at drinks.',
      ),
      PlacementOption(
        emoji: '🧂',
        label: 'Could you pass the salt?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Salt shaker is for seasoning.',
      ),
    ],
    funFact: 'Clear and universally understood phrasing.',
    pebbiCorrect: 'Polite and natural! 🌟',
    pebbiWrong: 'Nice try! Water droplet means asking for water.',
  ),
  PlacementQuestion(
    id: 'q008',
    sortOrder: 8,
    difficulty: 'B1',
    questionText: isNativeMalayalam
        ? "'എനിക്ക് ഒരു ടേബിൾ ബുക്ക് ചെയ്യണം' എന്ന് പറയാൻ ഏതാണ് ഉപയോഗിക്കുന്നത്? 📅"
        : "Which one means 'I would like to make a reservation'? 📅",
    targetPhrase: 'I would like to make a reservation',
    options: const [
      PlacementOption(
        emoji: '📅',
        label: 'Make a reservation',
        isCorrect: true,
        pebbiCorrect: 'Flawless English! 🎉',
        pebbiWrong: 'Calendar emoji represents bookings.',
        funFact: "'Would like' is the polite form of 'want'.",
      ),
      PlacementOption(
        emoji: '✈️',
        label: 'Cancel my flight',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Airplane emoji is about flight bookings.',
      ),
      PlacementOption(
        emoji: '🧳',
        label: 'I lost my luggage',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Luggage emoji is for baggage claims.',
      ),
      PlacementOption(
        emoji: '📞',
        label: 'Could you call me later?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Phone emoji is for telephone calls.',
      ),
    ],
    funFact: 'Reservation is used for restaurants, hotels, and travel.',
    pebbiCorrect: 'Flawless English! 🎉',
    pebbiWrong: 'Good guess! Calendar icon represents booking.',
  ),
];

// ---------------------------------------------------------------------------
// Malayalam Questions (for English or other speakers learning Malayalam)
// ---------------------------------------------------------------------------
const List<PlacementQuestion> _kMalayalamQuestions = [
  PlacementQuestion(
    id: 'q001_ml',
    sortOrder: 1,
    difficulty: 'A1',
    questionText: "Which one means 'Hello / Greetings'? 🙏",
    targetPhrase: 'നമസ്കാരം (Namaskaram)',
    options: [
      PlacementOption(
        emoji: '🙏',
        label: 'നമസ്കാരം (Namaskaram)',
        isCorrect: true,
        pebbiCorrect: 'അടിപൊളി! 🔥 Spot on greeting!',
        pebbiWrong: "'Namaskaram' is the classic Malayalam greeting.",
        funFact: "'Namaskaram' is the respectful greeting used all across Kerala.",
      ),
      PlacementOption(
        emoji: '👋',
        label: 'പോയി വരാം (Poi varam)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Poi varam' means 'I will go and return' (farewell).",
      ),
      PlacementOption(
        emoji: '🙅',
        label: 'ഇല്ല (Illa)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Illa' means 'No / Not'.",
      ),
      PlacementOption(
        emoji: '🤷',
        label: 'അറിയില്ല (Ariyilla)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Ariyilla' means 'I do not know'.",
      ),
    ],
    funFact: "'Namaskaram' is the most traditional greeting in Kerala.",
    pebbiCorrect: 'അടിപൊളി! 🔥 Outstanding start!',
    pebbiWrong: "Namaskaram is the primary greeting with folded hands.",
  ),
  PlacementQuestion(
    id: 'q002_ml',
    sortOrder: 2,
    difficulty: 'A1',
    questionText: "Which one means 'Thank you'? 🤝",
    targetPhrase: 'നന്ദി (Nandi)',
    options: [
      PlacementOption(
        emoji: '🤝',
        label: 'നന്ദി (Nandi)',
        isCorrect: true,
        pebbiCorrect: 'വളരെ നല്ലത്! ⭐ Great job!',
        pebbiWrong: "'Nandi' expresses thankfulness.",
        funFact: "'Nandi' is the Malayalam word for thanks.",
      ),
      PlacementOption(
        emoji: '🚪',
        label: 'ക്ഷമിക്കണം (Kshamikkaṇam)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Kshamikkaṇam' means 'Excuse me / Sorry'.",
      ),
      PlacementOption(
        emoji: '⏰',
        label: 'പിന്നെ കാണാം (Pinne kaanaam)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Pinne kaanaam' means 'See you later'.",
      ),
      PlacementOption(
        emoji: '☕',
        label: 'ചായ വേണം (Chaaya venam)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Chaaya venam' means 'I want tea'.",
      ),
    ],
    funFact: "Heartfelt gratitude in Kerala.",
    pebbiCorrect: 'വളരെ നല്ലത്! ⭐',
    pebbiWrong: "'Nandi' means thank you.",
  ),
  PlacementQuestion(
    id: 'q003_ml',
    sortOrder: 3,
    difficulty: 'A1',
    questionText: "Which one means 'Good morning'? 🌅",
    targetPhrase: 'സുപ്രഭാതം (Suprabhatham)',
    options: [
      PlacementOption(
        emoji: '🌅',
        label: 'സുപ്രഭാതം (Suprabhatham)',
        isCorrect: true,
        pebbiCorrect: 'ഗംഭീരം! ☀️ Morning greeting!',
        pebbiWrong: "'Suprabhatham' is the morning greeting.",
        funFact: "'Suprabhatham' means auspicious morning.",
      ),
      PlacementOption(
        emoji: '🌙',
        label: 'ശുഭരാത്രി (Shubharathri)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Shubharathri' means 'Good night'.",
      ),
      PlacementOption(
        emoji: '🍽️',
        label: 'ഭക്ഷണം കഴിക്കാം (Bhakshanam kazhikkaam)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "That means 'Let us eat food'.",
      ),
      PlacementOption(
        emoji: '🏃',
        label: 'വേഗം വരൂ (Vegam varoo)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Vegam varoo' means 'Come quickly'.",
      ),
    ],
    funFact: "Used in formal and friendly settings in the morning.",
    pebbiCorrect: 'ഗംഭീരം! ☀️',
    pebbiWrong: "'Suprabhatham' is good morning.",
  ),
  PlacementQuestion(
    id: 'q004_ml',
    sortOrder: 4,
    difficulty: 'A2',
    questionText: "Which one means 'How much is it'? 💶",
    targetPhrase: 'എത്രയാണ്? (Ethrayannu?)',
    options: [
      PlacementOption(
        emoji: '💶',
        label: 'എത്രയാണ്? (Ethrayannu?)',
        isCorrect: true,
        pebbiCorrect: 'മിടുക്കൻ/മിടുക്കി! 💳 Perfect!',
        pebbiWrong: "'Ethrayannu?' asks 'How much?'.",
        funFact: "Essential phrase when buying bananas or coconuts in Kerala!",
      ),
      PlacementOption(
        emoji: '📍',
        label: 'എവിടെയാണ്? (Evideyannu?)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Evideyannu?' asks 'Where is it?'.",
      ),
      PlacementOption(
        emoji: '🕐',
        label: 'സമയം എത്ര? (Samayam ethra?)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Samayam ethra?' asks for the time.",
      ),
      PlacementOption(
        emoji: '❓',
        label: 'ആരാണ്? (Aaraannu?)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Aaraannu?' asks 'Who is it?'.",
      ),
    ],
    funFact: "You'll use this every day at local bakeries.",
    pebbiCorrect: 'മിടുക്കൻ/മിടുക്കി! 💳 Perfect!',
    pebbiWrong: "'Ethrayannu' means how much.",
  ),
  PlacementQuestion(
    id: 'q005_ml',
    sortOrder: 5,
    difficulty: 'A2',
    questionText: "Which one means 'Where is it'? 📍",
    targetPhrase: 'എവിടെയാണ്? (Evideyannu?)',
    options: [
      PlacementOption(
        emoji: '📍',
        label: 'എവിടെയാണ്? (Evideyannu?)',
        isCorrect: true,
        pebbiCorrect: 'ശരിയുത്തരം! 🎯 Excellent!',
        pebbiWrong: "'Evideyannu?' is asking where something is located.",
        funFact: "Append a place name in front: 'Hotel evideyannu?'.",
      ),
      PlacementOption(
        emoji: '🏨',
        label: 'ഹോട്ടൽ (Hotel)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "Hotel is just the noun.",
      ),
      PlacementOption(
        emoji: '🚕',
        label: 'ഓട്ടോറിക്ഷ (Autorickshaw)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "That is the vehicle name.",
      ),
      PlacementOption(
        emoji: '🍽️',
        label: 'ചായക്കട (Chaayakkada)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Chaayakkada' means tea stall.",
      ),
    ],
    funFact: "'Evideyannu' is the key direction word in Malayalam.",
    pebbiCorrect: 'ശരിയുത്തരം! 🎯',
    pebbiWrong: "'Evideyannu' asks for location.",
  ),
  PlacementQuestion(
    id: 'q006_ml',
    sortOrder: 6,
    difficulty: 'B1',
    questionText: "Which one means 'I need water'? 💧",
    targetPhrase: 'വെള്ളം വേണം (Vellam venam)',
    options: [
      PlacementOption(
        emoji: '💧',
        label: 'വെള്ളം വേണം (Vellam venam)',
        isCorrect: true,
        pebbiCorrect: 'നന്നായി! 💧 Pure Malayalam!',
        pebbiWrong: "'Vellam' means water, 'venam' means want/need.",
        funFact: "'Venam' is one of the most common helper words in Kerala.",
      ),
      PlacementOption(
        emoji: '🏃',
        label: 'വൈകിപ്പോയി (Vaikkippoyi)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "That means 'I am late'.",
      ),
      PlacementOption(
        emoji: '⏳',
        label: 'ഒരു നിമിഷം (Oru nimisham)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "That means 'Just a moment'.",
      ),
      PlacementOption(
        emoji: '😴',
        label: 'ഉറക്കം വരുന്നു (Urakkam varunnu)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "That means 'I feel sleepy'.",
      ),
    ],
    funFact: "Life-saver on a hot tropical day!",
    pebbiCorrect: 'നന്നായി! 💧',
    pebbiWrong: "'Vellam venam' means water needed.",
  ),
  PlacementQuestion(
    id: 'q007_ml',
    sortOrder: 7,
    difficulty: 'B1',
    questionText: "Which one means 'Could you help me'? 🆘",
    targetPhrase: 'സഹായിക്കാമോ? (Sahayikkamo?)',
    options: [
      PlacementOption(
        emoji: '🆘',
        label: 'സഹായിക്കാമോ? (Sahayikkamo?)',
        isCorrect: true,
        pebbiCorrect: 'അസ്സലായി! 🌟 Polite and friendly!',
        pebbiWrong: "'Sahayikkamo' is a polite request for help.",
        funFact: "Malayalam speakers are famously hospitable when asked nicely.",
      ),
      PlacementOption(
        emoji: '🧾',
        label: 'ബിൽ തരൂ (Bill tharoo)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "That means 'Give the bill'.",
      ),
      PlacementOption(
        emoji: '🍷',
        label: 'കഴിക്കാൻ തരൂ (Kazhikkan tharoo)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "That means 'Give something to eat'.",
      ),
      PlacementOption(
        emoji: '🧂',
        label: 'ഉപ്പ് വേണം (Uppu venam)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "That means 'I need salt'.",
      ),
    ],
    funFact: "Very gentle, natural phrasing.",
    pebbiCorrect: 'അസ്സലായി! 🌟',
    pebbiWrong: "'Sahayikkamo' asks for assistance.",
  ),
  PlacementQuestion(
    id: 'q008_ml',
    sortOrder: 8,
    difficulty: 'B1',
    questionText: "Which one means 'I will go and come back' (Goodbye)? 👋",
    targetPhrase: 'പോയി വരാം (Poi varam)',
    options: [
      PlacementOption(
        emoji: '👋',
        label: 'പോയി വരാം (Poi varam)',
        isCorrect: true,
        pebbiCorrect: 'വിജയം! 🎉 Authentic Kerala farewell!',
        pebbiWrong: "In Kerala, people never say a final goodbye; they say 'Poi varam'!",
        funFact: "Culturally, Malayalis say 'Poi varam' meaning 'I'll go and return' rather than a permanent goodbye.",
      ),
      PlacementOption(
        emoji: '✈️',
        label: 'യാത്ര പോകുന്നു (Yaathra pokunnu)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "That means 'Going on a trip'.",
      ),
      PlacementOption(
        emoji: '🧳',
        label: 'ബാഗ് എവിടെ (Bag evide)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "That means 'Where is the bag'.",
      ),
      PlacementOption(
        emoji: '📞',
        label: 'വിളിക്കാം (Vilikkaam)',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "That means 'I will call you'.",
      ),
    ],
    funFact: "A unique cultural touchstone of the Malayalam language.",
    pebbiCorrect: 'വിജയം! 🎉',
    pebbiWrong: "'Poi varam' is the traditional farewell.",
  ),
];

// ---------------------------------------------------------------------------
// Spanish Questions (for English or other speakers learning Spanish)
// ---------------------------------------------------------------------------
const List<PlacementQuestion> _kSpanishQuestions = [
  PlacementQuestion(
    id: 'q001',
    sortOrder: 1,
    difficulty: 'A1',
    questionText: 'Here you are! 🎁',
    targetPhrase: 'Aquí tiene',
    options: [
      PlacementOption(
        emoji: '🤝',
        label: 'Here you are!',
        isCorrect: true,
        pebbiCorrect: "¡Muy bien! 🔥 You're off to a flying start!",
        pebbiWrong: "Oops! 'Aquí tiene' is what waiters say when they serve you! 🍽️",
        funFact: "You'll hear this every day in Spain!",
      ),
      PlacementOption(
        emoji: '👋',
        label: 'Goodbye!',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Adiós' means goodbye! 👋",
      ),
      PlacementOption(
        emoji: '🙅',
        label: 'No way!',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'De ninguna manera' means no way!",
      ),
      PlacementOption(
        emoji: '🤷',
        label: "I don't know",
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'No sé' means I don't know.",
      ),
    ],
    funFact: "You'll hear this every day in Spain!",
    pebbiCorrect: "¡Muy bien! 🔥 You're off to a flying start!",
    pebbiWrong: "Oopsie! 'Aquí tiene' is what waiters say when they serve you! 🍽️",
  ),
  PlacementQuestion(
    id: 'q002',
    sortOrder: 2,
    difficulty: 'A1',
    questionText: 'Thank you very much! 🙏',
    targetPhrase: 'Muchas gracias',
    options: [
      PlacementOption(
        emoji: '🙏',
        label: 'Thank you very much!',
        isCorrect: true,
        pebbiCorrect: 'Spot on! ⭐',
        pebbiWrong: 'Muchas gracias expresses gratitude.',
        funFact: 'Essential anywhere in the Spanish-speaking world.',
      ),
      PlacementOption(
        emoji: '🚪',
        label: 'Excuse me',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Perdón' means excuse me.",
      ),
      PlacementOption(
        emoji: '⏰',
        label: 'See you later',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Hasta luego' means see you later.",
      ),
      PlacementOption(
        emoji: '☕',
        label: 'A coffee please',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Un café por favor' is for ordering coffee.",
      ),
    ],
    funFact: 'Essential anywhere in the Spanish-speaking world.',
    pebbiCorrect: 'Spot on! ⭐',
    pebbiWrong: 'No worries! Muchas gracias means thank you very much.',
  ),
  PlacementQuestion(
    id: 'q003',
    sortOrder: 3,
    difficulty: 'A1',
    questionText: 'Good morning! 🌅',
    targetPhrase: 'Buenos días',
    options: [
      PlacementOption(
        emoji: '🌅',
        label: 'Good morning!',
        isCorrect: true,
        pebbiCorrect: 'Bright and early! ☀️',
        pebbiWrong: 'Buenos días is morning greeting.',
        funFact: 'Used until early afternoon in many Spanish cultures.',
      ),
      PlacementOption(
        emoji: '🌙',
        label: 'Good night!',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'Buenas noches' means good night.",
      ),
      PlacementOption(
        emoji: '🍽️',
        label: 'Enjoy your meal!',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'¡Buen provecho!' means enjoy your meal.",
      ),
      PlacementOption(
        emoji: '🏃',
        label: 'Hurry up!',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'¡Rápido!' means hurry up.",
      ),
    ],
    funFact: 'Used until early afternoon in many Spanish cultures.',
    pebbiCorrect: 'Bright and early! ☀️',
    pebbiWrong: 'Almost! Buenos días is used in the morning.',
  ),
  PlacementQuestion(
    id: 'q004',
    sortOrder: 4,
    difficulty: 'A2',
    questionText: 'How much does it cost? 💶',
    targetPhrase: '¿Cuánto cuesta?',
    options: [
      PlacementOption(
        emoji: '💶',
        label: 'How much does it cost?',
        isCorrect: true,
        pebbiCorrect: 'Great job! 💳',
        pebbiWrong: '¿Cuánto cuesta? asks for price.',
        funFact: 'A vital phrase when shopping in local markets.',
      ),
      PlacementOption(
        emoji: '📍',
        label: 'Where is it?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'¿Dónde está?' means where is it.",
      ),
      PlacementOption(
        emoji: '🕐',
        label: 'What time is it?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'¿Qué hora es?' asks for time.",
      ),
      PlacementOption(
        emoji: '❓',
        label: 'Who is it?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: "'¿Quién es?' asks who is it.",
      ),
    ],
    funFact: 'A vital phrase when shopping in local markets.',
    pebbiCorrect: 'Great job! 💳',
    pebbiWrong: 'Not quite! ¿Cuánto cuesta? asks for the price.',
  ),
  PlacementQuestion(
    id: 'q005',
    sortOrder: 5,
    difficulty: 'A2',
    questionText: 'Where is the bathroom? 🚻',
    targetPhrase: '¿Dónde está el baño?',
    options: [
      PlacementOption(
        emoji: '🚻',
        label: 'Where is the bathroom?',
        isCorrect: true,
        pebbiCorrect: 'You got it! 🎯',
        pebbiWrong: 'El baño is the bathroom.',
        funFact: 'One of the most useful travel survival phrases.',
      ),
      PlacementOption(
        emoji: '🏨',
        label: 'Where is the hotel?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'El hotel is the hotel.',
      ),
      PlacementOption(
        emoji: '🚕',
        label: 'Where is the taxi?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'El taxi is the taxi.',
      ),
      PlacementOption(
        emoji: '🍽️',
        label: 'Where is the restaurant?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'El restaurante is the restaurant.',
      ),
    ],
    funFact: 'One of the most useful travel survival phrases.',
    pebbiCorrect: 'You got it! 🎯',
    pebbiWrong: 'No worries! El baño is the bathroom.',
  ),
  PlacementQuestion(
    id: 'q006',
    sortOrder: 6,
    difficulty: 'B1',
    questionText: "I've been waiting an hour! ⏰",
    targetPhrase: 'Llevo una hora esperando',
    options: [
      PlacementOption(
        emoji: '⏰',
        label: "I've been waiting an hour!",
        isCorrect: true,
        pebbiCorrect: 'Incredible! You nailed a tough one! 🔥',
        pebbiWrong: 'Llevar + time means to have been doing something.',
        funFact: 'Llevar + gerund is the natural way to describe ongoing duration.',
      ),
      PlacementOption(
        emoji: '🏃',
        label: "I'm running late!",
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Llegar tarde means arriving late.',
      ),
      PlacementOption(
        emoji: '⏳',
        label: 'Just a minute please',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Un momento por favor means just a moment.',
      ),
      PlacementOption(
        emoji: '😴',
        label: 'I fell asleep',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Me quedé dormido means I fell asleep.',
      ),
    ],
    pebbiWarning: "Heads up — this one's trickier! You've got this 💪",
    funFact: 'Llevar + gerund is the natural way to describe ongoing duration.',
    pebbiCorrect: 'Incredible! You nailed a tough one! 🔥',
    pebbiWrong: 'Tricky structure! Llevar + time means to have been doing something.',
  ),
  PlacementQuestion(
    id: 'q007',
    sortOrder: 7,
    difficulty: 'B1',
    questionText: 'Could you recommend a good dish? 🍲',
    targetPhrase: '¿Me recomienda un buen plato?',
    options: [
      PlacementOption(
        emoji: '🍲',
        label: 'Could you recommend a dish?',
        isCorrect: true,
        pebbiCorrect: 'Polite and natural! 🌟',
        pebbiWrong: 'Recomendar means to recommend.',
        funFact: 'Waiters love recommending the chef special when you ask this!',
      ),
      PlacementOption(
        emoji: '🧾',
        label: 'Could I have the bill?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'La cuenta is the bill.',
      ),
      PlacementOption(
        emoji: '🍷',
        label: 'Could I see the wine list?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'La carta de vinos is the wine list.',
      ),
      PlacementOption(
        emoji: '🧂',
        label: 'Could you pass the salt?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'La sal is the salt.',
      ),
    ],
    funFact: 'Waiters love recommending the chef special when you ask this!',
    pebbiCorrect: 'Polite and natural! 🌟',
    pebbiWrong: 'Nice try! Recomendar means to recommend.',
  ),
  PlacementQuestion(
    id: 'q008',
    sortOrder: 8,
    difficulty: 'B1',
    questionText: 'I would like to make a reservation 📅',
    targetPhrase: 'Quisiera hacer una reserva',
    options: [
      PlacementOption(
        emoji: '📅',
        label: 'I would like to make a reservation',
        isCorrect: true,
        pebbiCorrect: 'Flawless Spanish! 🎉',
        pebbiWrong: 'Quisiera hacer una reserva is for booking.',
        funFact: 'Quisiera is the polite conditional form of querer (to want).',
      ),
      PlacementOption(
        emoji: '✈️',
        label: 'I would like to cancel my flight',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Cancelar mi vuelo means cancel my flight.',
      ),
      PlacementOption(
        emoji: '🧳',
        label: 'I lost my luggage',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: 'Perdí mi equipaje means I lost my luggage.',
      ),
      PlacementOption(
        emoji: '📞',
        label: 'Could you call me later?',
        isCorrect: false,
        pebbiCorrect: 'Spot on!',
        pebbiWrong: '¿Podría llamarme más tarde? means call later.',
      ),
    ],
    funFact: 'Quisiera is the polite conditional form of querer (to want).',
    pebbiCorrect: 'Flawless Spanish! 🎉',
    pebbiWrong: 'Good guess! Quisiera hacer una reserva is for booking.',
  ),
];
