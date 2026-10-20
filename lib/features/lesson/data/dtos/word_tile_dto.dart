/// Data Transfer Object representing a word tile in a sentence building exercise.
class WordTileDto {
  const WordTileDto({required this.id, required this.text});

  final String id;
  final String text;

  factory WordTileDto.fromJson(Map<String, dynamic> json) {
    return WordTileDto(id: json['id'] as String, text: json['text'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}
