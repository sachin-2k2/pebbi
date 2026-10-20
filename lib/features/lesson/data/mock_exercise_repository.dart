import 'dart:convert';
import '../domain/exercise_mode.dart';
import '../domain/exercise_repository.dart';
import '../domain/exercise_set.dart';
import 'dtos/exercise_dto.dart';
import 'mappers/exercise_mapper.dart';

/// Mock implementation of [ExerciseRepository] providing realistic placement check data.
///
/// Follows AGENTS.md §1 & §2: fake repository hiding data origin until real backend API is ready.
class MockExerciseRepository implements ExerciseRepository {
  const MockExerciseRepository();

  @override
  Future<ExerciseSet> loadPlacementSet(String targetLanguageCode) async {
    // Simulated micro-delay for realistic async behaviour
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final rawList = jsonDecode(_kPlacementQuestionsJson) as List<dynamic>;
    final exercises = rawList
        .map(
          (e) => ExerciseMapper.toExercise(
            ExerciseDto.fromJson(e as Map<String, dynamic>),
          ),
        )
        .toList();

    return ExerciseSet(
      id: 'placement_set_$targetLanguageCode',
      title: 'Placement Quick Check',
      mode: ExerciseMode.placement,
      exercises: exercises,
    );
  }

  @override
  Future<ExerciseSet> loadLessonSet(String lessonId) async {
    return loadPlacementSet('es');
  }
}

const String _kPlacementQuestionsJson = '''
[
  {
    "id": "placement_1",
    "type": "pick_picture",
    "prompt": "A ticket to Madrid, please",
    "audio_text": "Un billete a Madrid, por favor",
    "audio_locale": "es-ES",
    "explanation_text": "“Un billete” is used specifically in Spain for train or plane tickets, while “el boleto” is common in Latin America. “Por favor” adds polite courtesy.",
    "correct_answer_text": "Un billete a Madrid, por favor",
    "feedback_success_text": "“Un billete a Madrid, por favor” means A ticket to Madrid, please",
    "correct_option_id": "opt_ticket",
    "options": [
      {"id": "opt_ticket", "image_ref": "🎫", "spoken_label": "ticket"},
      {"id": "opt_moon", "image_ref": "🌙", "spoken_label": "crescent moon"},
      {"id": "opt_smile", "image_ref": "😊", "spoken_label": "smiling face"},
      {"id": "opt_question", "image_ref": "❓", "spoken_label": "question mark"}
    ]
  },
  {
    "id": "placement_2",
    "type": "pick_picture",
    "prompt": "Good morning",
    "audio_text": "Buenos días",
    "audio_locale": "es-ES",
    "explanation_text": "“Buenos días” is the standard Spanish morning greeting until the afternoon. It is grammatically plural in form.",
    "correct_answer_text": "Buenos días",
    "feedback_success_text": "“Buenos días” means Good morning",
    "correct_option_id": "opt_sun",
    "options": [
      {"id": "opt_sun", "image_ref": "☀️", "spoken_label": "morning sun"},
      {"id": "opt_night", "image_ref": "🌙", "spoken_label": "night moon"},
      {"id": "opt_water", "image_ref": "💧", "spoken_label": "water drop"},
      {"id": "opt_bread", "image_ref": "🍞", "spoken_label": "bread loaf"}
    ]
  },
  {
    "id": "placement_3",
    "type": "pick_picture",
    "prompt": "A coffee with milk",
    "audio_text": "Un café con leche",
    "audio_locale": "es-ES",
    "explanation_text": "“Café con leche” is an everyday staple in Spanish cafés, traditionally equal parts espresso and steamed milk.",
    "correct_answer_text": "Un café con leche",
    "feedback_success_text": "“Un café con leche” means A coffee with milk",
    "correct_option_id": "opt_coffee",
    "praise_phrase": "Buenas tardes",
    "options": [
      {"id": "opt_apple", "image_ref": "🍎", "spoken_label": "apple"},
      {"id": "opt_coffee", "image_ref": "☕", "spoken_label": "hot coffee"},
      {"id": "opt_car", "image_ref": "🚗", "spoken_label": "car"},
      {"id": "opt_cat", "image_ref": "🐱", "spoken_label": "cat"}
    ]
  },
  {
    "id": "placement_4",
    "type": "choose_meaning",
    "prompt": "What does this mean?",
    "phrase": "Soy de México",
    "audio_text": "Soy de México",
    "audio_locale": "es-ES",
    "explanation_text": "“Soy de” is the standard Spanish phrase for saying where you are from (using the verb ser for origin). México uses the preposition “de” for origin.",
    "correct_answer_text": "I'm from Mexico",
    "feedback_success_text": "“Soy de México” means I'm from Mexico",
    "correct_option_id": "q4_opt3",
    "praise_phrase": "Soy de México",
    "text_options": [
      {"id": "q4_opt1", "text": "How much does it cost?"},
      {"id": "q4_opt2", "text": "Sparkling water"},
      {"id": "q4_opt3", "text": "I'm from Mexico"}
    ]
  },
  {
    "id": "placement_5",
    "type": "choose_meaning",
    "prompt": "What does this mean?",
    "phrase": "¿Cuánto cuesta?",
    "audio_text": "¿Cuánto cuesta?",
    "audio_locale": "es-ES",
    "explanation_text": "“¿Cuánto cuesta?” literally asks “how much does it cost?”, using the verb costar (to cost) in third person singular.",
    "correct_answer_text": "How much does it cost?",
    "feedback_success_text": "“¿Cuánto cuesta?” means How much does it cost?",
    "correct_option_id": "q5_opt1",
    "text_options": [
      {"id": "q5_opt1", "text": "How much does it cost?"},
      {"id": "q5_opt2", "text": "Where is the bathroom?"},
      {"id": "q5_opt3", "text": "I'm hungry"}
    ]
  },
  {
    "id": "placement_6",
    "type": "choose_meaning",
    "prompt": "What does this mean?",
    "phrase": "Un café, por favor",
    "audio_text": "Un café, por favor",
    "audio_locale": "es-ES",
    "explanation_text": "“Un café, por favor” is the polite, universal phrase for ordering a coffee at any Spanish café or bar.",
    "correct_answer_text": "A coffee, please",
    "feedback_success_text": "“Un café, por favor” means A coffee, please",
    "correct_option_id": "q6_opt1",
    "praise_phrase": "Un café, por favor",
    "text_options": [
      {"id": "q6_opt1", "text": "A coffee, please"},
      {"id": "q6_opt2", "text": "The bill, please"},
      {"id": "q6_opt3", "text": "Good night"}
    ]
  },
  {
    "id": "placement_7",
    "type": "build_sentence",
    "prompt": "Return ticket",
    "audio_text": "Ida y vuelta",
    "audio_locale": "es-ES",
    "explanation_text": "“Ida y vuelta” literally translates to “departure and return”, the standard phrase for a round-trip or return ticket.",
    "correct_answer_text": "Ida y vuelta",
    "feedback_success_text": "“Ida y vuelta” means Return ticket",
    "tiles": [
      {"id": "q7_tile_a", "text": "A"},
      {"id": "q7_tile_y", "text": "y"},
      {"id": "q7_tile_ida", "text": "Ida"},
      {"id": "q7_tile_vuelta", "text": "vuelta"}
    ],
    "accepted_answers": [
      ["q7_tile_ida", "q7_tile_y", "q7_tile_vuelta"]
    ],
    "distractor_tile_ids": ["q7_tile_a"]
  },
  {
    "id": "placement_8",
    "type": "build_sentence",
    "prompt": "A coffee with milk",
    "audio_text": "Un café con leche",
    "audio_locale": "es-ES",
    "explanation_text": "“Café con leche” is an espresso with hot milk, standard for Spanish breakfast.",
    "correct_answer_text": "Un café con leche",
    "feedback_success_text": "“Un café con leche” means A coffee with milk",
    "tiles": [
      {"id": "q8_tile_un", "text": "Un"},
      {"id": "q8_tile_cafe", "text": "café"},
      {"id": "q8_tile_con", "text": "con"},
      {"id": "q8_tile_leche", "text": "leche"},
      {"id": "q8_tile_el", "text": "el"}
    ],
    "accepted_answers": [
      ["q8_tile_un", "q8_tile_cafe", "q8_tile_con", "q8_tile_leche"]
    ],
    "distractor_tile_ids": ["q8_tile_el"]
  }
]
''';
