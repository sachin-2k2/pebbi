import '../../domain/suggestion.dart';

/// Parses raw backend `options` or `initial_options` arrays into domain [Suggestion]s.
///
/// Follows AGENTS.md §2.1 & §3.1 (< 50 lines, pure Dart).
List<Suggestion> parseMissionOptions(dynamic raw) {
  if (raw is! List) return const [];
  final suggestions = <Suggestion>[];
  for (int i = 0; i < raw.length; i++) {
    final item = raw[i];
    if (item is Map) {
      final text = (item['text'] ?? item['option'] ?? item['phrase'] ?? '')
          .toString()
          .trim();
      final translation = (item['translation'] ?? item['translated_text'])
          ?.toString()
          .trim();
      final id = (item['id'] ?? 'sug_$i').toString();
      if (text.isNotEmpty) {
        suggestions.add(
          Suggestion(
            id: id,
            text: text,
            translation: translation?.isNotEmpty == true ? translation : null,
          ),
        );
      }
    } else if (item is String && item.trim().isNotEmpty) {
      suggestions.add(Suggestion(id: 'sug_$i', text: item.trim()));
    }
  }
  return suggestions;
}

