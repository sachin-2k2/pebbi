/// Data Transfer Object representing a text choice option.
class TextOptionDto {
  const TextOptionDto({required this.id, required this.text});

  final String id;
  final String text;

  factory TextOptionDto.fromJson(Map<String, dynamic> json) {
    return TextOptionDto(
      id: json['id'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}
