import '../../domain/exercise.dart';
import '../../domain/picture_option.dart';
import '../../domain/text_option.dart';
import '../../domain/word_tile_item.dart';
import '../dtos/exercise_dto.dart';
import '../dtos/picture_option_dto.dart';
import '../dtos/text_option_dto.dart';
import '../dtos/word_tile_dto.dart';

/// Pure mapper converting DTO representations into clean domain entities.
///
/// Follows AGENTS.md §2.1: isolates widgets and providers from API DTO shapes.
abstract final class ExerciseMapper {
  static PictureOption toPictureOption(PictureOptionDto dto) {
    return PictureOption(
      id: dto.id,
      imageRef: dto.imageRef,
      spokenLabel: dto.spokenLabel,
    );
  }

  static TextOption toTextOption(TextOptionDto dto) {
    return TextOption(id: dto.id, text: dto.text);
  }

  static WordTileItem toWordTileItem(WordTileDto dto) {
    return WordTileItem(id: dto.id, text: dto.text);
  }

  static Exercise toExercise(ExerciseDto dto) {
    switch (dto.type) {
      case 'pick_picture':
        return PickPictureExercise(
          id: dto.id,
          prompt: dto.prompt,
          audioText: dto.audioText,
          audioLocale: dto.audioLocale,
          explanationText: dto.explanationText,
          correctAnswerText: dto.correctAnswerText,
          feedbackSuccessText: dto.feedbackSuccessText,
          praisePhrase: dto.praisePhrase,
          options: dto.options.map(toPictureOption).toList(),
          correctOptionId: dto.correctOptionId ?? '',
        );
      case 'choose_meaning':
        return ChooseMeaningExercise(
          id: dto.id,
          prompt: dto.prompt,
          audioText: dto.audioText,
          audioLocale: dto.audioLocale,
          explanationText: dto.explanationText,
          correctAnswerText: dto.correctAnswerText,
          feedbackSuccessText: dto.feedbackSuccessText,
          praisePhrase: dto.praisePhrase,
          phrase: dto.phrase ?? dto.audioText,
          helperLine: dto.helperLine,
          options: dto.textOptions.map(toTextOption).toList(),
          correctOptionId: dto.correctOptionId ?? '',
        );
      case 'build_sentence':
        return BuildSentenceExercise(
          id: dto.id,
          prompt: dto.prompt,
          audioText: dto.audioText,
          audioLocale: dto.audioLocale,
          explanationText: dto.explanationText,
          correctAnswerText: dto.correctAnswerText,
          feedbackSuccessText: dto.feedbackSuccessText,
          praisePhrase: dto.praisePhrase,
          tiles: dto.tiles.map(toWordTileItem).toList(),
          acceptedAnswers: dto.acceptedAnswers,
          distractorTileIds: dto.distractorTileIds,
        );
      default:
        // Fallback for unknown exercise types
        return PickPictureExercise(
          id: dto.id,
          prompt: dto.prompt,
          audioText: dto.audioText,
          audioLocale: dto.audioLocale,
          explanationText: dto.explanationText,
          correctAnswerText: dto.correctAnswerText,
          feedbackSuccessText: dto.feedbackSuccessText,
          praisePhrase: dto.praisePhrase,
          options: dto.options.map(toPictureOption).toList(),
          correctOptionId: dto.correctOptionId ?? '',
        );
    }
  }
}
