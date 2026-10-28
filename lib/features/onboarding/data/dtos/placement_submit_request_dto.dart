import '../../domain/placement_answer.dart';

/// DTO representing the request payload for `POST /api/placement/submit`.
class PlacementSubmitRequestDto {
  const PlacementSubmitRequestDto({
    required this.nativeLanguage,
    required this.answers,
  });

  final String nativeLanguage;
  final List<PlacementAnswer> answers;

  Map<String, dynamic> toJson() => {
    'native_language': nativeLanguage,
    'answers': answers.map((a) => a.toJson()).toList(),
  };
}
