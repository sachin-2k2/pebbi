import 'grammar_note_summary.dart';

/// Full grammar and culture note with plain-text body.
///
/// Follows AGENTS.md §2 (pure domain rules, zero Flutter imports).
class GrammarNote {
  const GrammarNote({required this.summary, required this.body});

  final GrammarNoteSummary summary;
  final String body;

  String get id => summary.id;
  String get title => summary.title;
  String get emoji => summary.emoji;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrammarNote &&
          runtimeType == other.runtimeType &&
          summary == other.summary &&
          body == other.body;

  @override
  int get hashCode => summary.hashCode ^ body.hashCode;
}
