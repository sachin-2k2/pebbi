import 'phrase.dart';

/// Available filter selections for the learned phrase list.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
enum PhraseFilter {
  all('all'),
  tricky('tricky'),
  newPhrases('new'),
  saved('saved');

  const PhraseFilter(this.id);
  final String id;

  /// Pure filtering method returning phrases matching this filter.
  List<Phrase> apply(List<Phrase> phrases) {
    switch (this) {
      case PhraseFilter.all:
        return phrases;
      case PhraseFilter.tricky:
        return phrases.where((p) => p.status == PhraseStatus.tricky).toList();
      case PhraseFilter.newPhrases:
        return phrases
            .where((p) => p.status == PhraseStatus.newPhrase)
            .toList();
      case PhraseFilter.saved:
        return phrases.where((p) => p.isSaved).toList();
    }
  }
}
