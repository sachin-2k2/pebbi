import '../../domain/exercise.dart';
import '../../domain/lesson_set.dart';
import '../../domain/phrase_token.dart';
import '../../domain/text_option.dart';
import 'lesson_assessment_config_dto.dart';
import 'lesson_phrase_dto.dart';
import 'lesson_question_dto.dart';
import 'lesson_user_progress_dto.dart';

/// Full lesson content DTO returned by `GET /api/lessons/{lesson_id}`.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class LessonDetailDto {
  const LessonDetailDto({
    required this.lessonId,
    required this.track,
    required this.level,
    required this.lessonNumber,
    this.levelOrder,
    required this.title,
    this.goal,
    this.pebbiIntro,
    this.dialoguePrompt,
    this.dialogueCorrect,
    this.icon,
    this.xpReward = 10,
    this.totalPhrases = 0,
    this.phrases = const [],
    this.assessmentConfig = const LessonAssessmentConfigDto(),
    this.questions = const [],
    this.userProgress,
  });

  final String lessonId;
  final String track;
  final String level;
  final int lessonNumber;
  final int? levelOrder;
  final String title;
  final String? goal;
  final String? pebbiIntro;
  final String? dialoguePrompt;
  final String? dialogueCorrect;
  final String? icon;
  final int xpReward;
  final int totalPhrases;
  final List<LessonPhraseDto> phrases;
  final LessonAssessmentConfigDto assessmentConfig;
  final List<LessonQuestionDto> questions;
  final LessonUserProgressDto? userProgress;

  factory LessonDetailDto.fromJson(Map<String, dynamic> json) {
    return LessonDetailDto(
      lessonId: json['lesson_id']?.toString() ?? '',
      track: json['track']?.toString() ?? 'daily',
      level: json['level']?.toString() ?? 'starter',
      lessonNumber: (json['lesson_number'] as num?)?.toInt() ?? 1,
      levelOrder: (json['level_order'] as num?)?.toInt(),
      title: json['title']?.toString() ?? 'Lesson',
      goal: json['goal']?.toString(),
      pebbiIntro: json['pebbi_intro']?.toString(),
      dialoguePrompt: json['dialogue_prompt']?.toString(),
      dialogueCorrect: json['dialogue_correct']?.toString(),
      icon: json['icon']?.toString(),
      xpReward: (json['xp_reward'] as num?)?.toInt() ?? 10,
      totalPhrases: (json['total_phrases'] as num?)?.toInt() ?? 0,
      phrases: (json['phrases'] as List?)
              ?.whereType<Map>()
              .map((p) => LessonPhraseDto.fromJson(Map<String, dynamic>.from(p)))
              .toList(growable: false) ??
          const [],
      assessmentConfig: json['assessment_config'] is Map
          ? LessonAssessmentConfigDto.fromJson(
              Map<String, dynamic>.from(json['assessment_config'] as Map))
          : const LessonAssessmentConfigDto(),
      questions: (json['questions'] as List?)
              ?.whereType<Map>()
              .map((q) => LessonQuestionDto.fromJson(Map<String, dynamic>.from(q)))
              .toList(growable: false) ??
          const [],
      userProgress: json['user_progress'] is Map
          ? LessonUserProgressDto.fromJson(
              Map<String, dynamic>.from(json['user_progress'] as Map))
          : null,
    );
  }

  /// Converts this DTO into domain [LessonSet] suitable for [ExerciseSessionNotifier].
  LessonSet toLessonSet({
    String learningLanguage = 'en',
    String nativeLanguage = 'en',
  }) {
    final items = <Exercise>[];
    final locale = _resolveLocale(learningLanguage);
    final phraseMap = {for (final p in phrases) p.phraseId: p};

    // 1. Teach cards for each phrase
    for (final p in phrases) {
      items.add(
        NewPhraseCardExercise(
          id: p.phraseId,
          phrase: p.targetText,
          tokens: [
            PhraseToken(
              id: 'tok_${p.phraseId}',
              text: p.targetText,
              meaning: p.translation,
            ),
          ],
          meaning: p.translation,
          picture: p.imageEmoji ?? icon ?? '👋',
          registerTag: p.tags.isNotEmpty ? p.tags.first : 'casual',
          phraseKindTag: 'New phrase',
          tipText: pebbiIntro ?? "Learn it before you're tested on it — take your time.",
          audioText: p.targetText,
          audioLocale: locale,
          correctAnswerText: p.targetText,
        ),
      );
    }

    // 2. Assessment questions
    for (final q in questions) {
      final phrase = q.phraseId != null ? phraseMap[q.phraseId] : null;
      final targetPrompt = phrase?.targetText.isNotEmpty == true
          ? phrase!.targetText
          : (goal ?? 'What does this mean?');

      // Determine correct answer
      String correctOption = phrase?.translation ?? '';
      if (!q.answerChoices.contains(correctOption)) {
        if (q.answerChoices.isNotEmpty) {
          correctOption = q.answerChoices.first;
        }
      }

      items.add(
        ChooseMeaningExercise(
          id: q.questionId,
          prompt: 'What does this mean?',
          phrase: targetPrompt,
          helperLine: null,
          audioText: phrase?.targetText ?? targetPrompt,
          audioLocale: locale,
          explanationText: q.hint ?? (goal ?? ''),
          correctAnswerText: correctOption,
          feedbackSuccessText: 'Great job!',
          correctOptionId: correctOption,
          options: q.answerChoices
              .map((c) => TextOption(id: c, text: c))
              .toList(growable: false),
        ),
      );
    }

    // 3. Optional dialogue / speaking attempt
    if (dialoguePrompt != null && dialogueCorrect != null) {
      items.add(
        SpeakExercise(
          id: '${lessonId}_dialogue',
          prompt: 'Listen and reply',
          phrase: dialogueCorrect!,
          meaning: dialoguePrompt!,
          audioText: dialogueCorrect!,
          audioLocale: locale,
          sttLocale: locale,
          explanationText: dialoguePrompt!,
          correctAnswerText: dialogueCorrect!,
          feedbackSuccessText: 'Well said! 🎉',
        ),
      );
    }

    return LessonSet(
      id: lessonId,
      stopId: lessonId,
      title: title,
      items: items,
    );
  }

  static String _resolveLocale(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'ml':
        return 'ml-IN';
      case 'hi':
        return 'hi-IN';
      case 'ta':
        return 'ta-IN';
      case 'te':
        return 'te-IN';
      case 'kn':
        return 'kn-IN';
      case 'es':
        return 'es-ES';
      case 'ar':
        return 'ar-SA';
      case 'fr':
        return 'fr-FR';
      case 'de':
        return 'de-DE';
      case 'en':
      default:
        return 'en-US';
    }
  }
}
