/// Data Transfer Object representing an exercise picture option from the backend.
class PictureOptionDto {
  const PictureOptionDto({
    required this.id,
    required this.imageRef,
    required this.spokenLabel,
  });

  final String id;
  final String imageRef;
  final String spokenLabel;

  factory PictureOptionDto.fromJson(Map<String, dynamic> json) {
    return PictureOptionDto(
      id: json['id'] as String,
      imageRef: json['image_ref'] as String,
      spokenLabel: json['spoken_label'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image_ref': imageRef,
    'spoken_label': spokenLabel,
  };
}
