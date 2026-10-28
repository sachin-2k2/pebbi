import 'language_level.dart';

/// Single emoji option presented to the learner in placement quiz questions.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class PlacementOption {
  const PlacementOption({
    required this.emoji,
    required this.label,
    required this.isCorrect,
    this.pebbiCorrect = '',
    this.pebbiWrong = '',
    this.funFact,
  });

  /// The emoji character rendered in the 2x2 grid tile.
  final String emoji;

  /// Accessibility semantic label (e.g. "Here you are!").
  final String label;

  /// Checked locally upon tap; NEVER displayed or logged.
  final bool isCorrect;

  /// Mascot praise message when chosen.
  final String pebbiCorrect;

  /// Mascot gentle correction when chosen.
  final String pebbiWrong;

  /// Optional explanation unfolded on "Why?".
  final String? funFact;
}

/// A placement quiz question item.
class PlacementQuestion {
  const PlacementQuestion({
    required this.id,
    required this.sortOrder,
    this.difficulty,
    String? prompt,
    String? questionText,
    required this.targetPhrase,
    required this.options,
    this.funFact,
    this.pebbiCorrect,
    this.pebbiWrong,
    this.pebbiWarning,
  }) : prompt = prompt ?? questionText ?? '',
       _questionText = questionText ?? prompt;

  final String id;
  final int sortOrder;
  final String? difficulty;
  final String prompt;
  final String? _questionText;
  String get questionText => _questionText ?? prompt;
  final String targetPhrase;
  final List<PlacementOption> options;
  final String? funFact;
  final String? pebbiCorrect;
  final String? pebbiWrong;
  final String? pebbiWarning;

  /// Checks whether this question has duplicate option emojis.
  bool get hasDuplicateEmojis {
    final seen = <String>{};
    for (final opt in options) {
      if (!seen.add(opt.emoji.trim())) return true;
    }
    return false;
  }

  /// Whether options count satisfies defensive bounds (2 to 6 options).
  bool get isValidOptionCount => options.length >= 2 && options.length <= 6;

  /// Whether this question is valid for display in the placement quiz.
  bool get isValid => isValidOptionCount && !hasDuplicateEmojis;
}

/// Complete placement question set payload including availability flag.
class PlacementQuestionSet {
  const PlacementQuestionSet({
    required this.isAvailable,
    required this.total,
    required this.questions,
    this.unavailableMessage,
    this.defaultLevel = LanguageLevel.little,
  });

  final bool isAvailable;
  final int total;
  final List<PlacementQuestion> questions;
  final String? unavailableMessage;
  final LanguageLevel defaultLevel;

  /// Returns valid questions sorted strictly by [sortOrder].
  List<PlacementQuestion> get sortedValidQuestions {
    final valid = questions.where((q) => q.isValid).toList();
    valid.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return List.unmodifiable(valid);
  }
}
