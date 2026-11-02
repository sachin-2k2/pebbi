import 'package:flutter_test/flutter_test.dart';
import 'package:peddi/features/missions/data/dtos/mission_detail_dto.dart';
import 'package:peddi/features/missions/data/dtos/mission_message_response_dto.dart';
import 'package:peddi/features/missions/data/dtos/mission_status_dto.dart';
import 'package:peddi/features/missions/data/dtos/missions_response_dto.dart';
import 'package:peddi/features/missions/data/dtos/today_mission_dto.dart';
import 'package:peddi/features/missions/domain/mission_summary.dart';

void main() {
  group('TodayMissionDto', () {
    test('parses GET /api/missions/today response correctly', () {
      final json = {
        'mission_id': 'order-a-coffee',
        'title': 'Order a coffee',
        'character_name': 'Lucia',
        'character_role': 'barista',
        'duration_minutes': 5,
        'category': 'Everyday',
        'icon': '☕',
        'description': 'Practice ordering your favorite coffee drink.',
        'status': 'not_started',
      };

      final dto = TodayMissionDto.fromJson(json);
      expect(dto.missionId, 'order-a-coffee');
      expect(dto.title, 'Order a coffee');
      expect(dto.characterName, 'Lucia');
      expect(dto.characterRole, 'barista');
      expect(dto.durationMinutes, 5);
      expect(dto.category, 'Everyday');
      expect(dto.icon, '☕');
      expect(dto.description, 'Practice ordering your favorite coffee drink.');
      expect(dto.status, 'not_started');

      final domain = dto.toTodayMission();
      expect(domain.mission.id, 'order-a-coffee');
      expect(domain.mission.title, 'Order a coffee');
      expect(domain.mission.characterName, 'Lucia');
      expect(domain.mission.characterRole, 'barista');
      expect(domain.mission.categoryIds, ['everyday']);
      expect(domain.mission.status, MissionStatus.newMission);
      expect(domain.isCompleted, isFalse);
      expect(domain.reason, 'Practice ordering your favorite coffee drink.');
    });

    test('maps completed status to done and isCompleted=true', () {
      final json = {
        'mission_id': 'order-a-coffee',
        'title': 'Order a coffee',
        'character_name': 'Lucia',
        'character_role': 'barista',
        'duration_minutes': 5,
        'category': 'Everyday',
        'icon': '☕',
        'status': 'complete',
      };

      final dto = TodayMissionDto.fromJson(json);
      final domain = dto.toTodayMission();
      expect(domain.mission.status, MissionStatus.done);
      expect(domain.isCompleted, isTrue);
    });

    test('tryParse handles wrapped null {"today_mission": null}', () {
      final json = {'today_mission': null};
      final dto = TodayMissionDto.tryParse(json);
      expect(dto, isNull);
    });

    test('tryParse parses wrapped {"today_mission": {...}}', () {
      final json = {
        'today_mission': {
          'mission_id': 'order-a-coffee',
          'title': 'Order a coffee',
          'character_name': 'Lucia',
          'character_role': 'barista',
        },
      };
      final dto = TodayMissionDto.tryParse(json);
      expect(dto, isNotNull);
      expect(dto!.missionId, 'order-a-coffee');
      expect(dto.title, 'Order a coffee');
    });

    test('tryParse returns null on empty map or missing essential fields', () {
      expect(TodayMissionDto.tryParse({}), isNull);
      expect(TodayMissionDto.tryParse({'other': 123}), isNull);
    });
  });

  group('MissionsResponseDto', () {
    test('parses GET /api/missions categories and missions list', () {
      final json = {
        'categories': ['All', 'Everyday', 'Travel', 'Health', 'Money', 'Social'],
        'missions': [
          {
            'mission_id': 'order-a-coffee',
            'title': 'Order a coffee',
            'character_name': 'Lucia',
            'character_role': 'barista',
            'duration_minutes': 5,
            'category': 'Everyday',
            'icon': '☕',
            'status': 'not_started',
          },
          {
            'mission_id': 'ask-for-directions',
            'title': 'Ask for directions',
            'character_name': 'Karim',
            'character_role': 'a passer-by',
            'duration_minutes': 5,
            'category': 'Everyday',
            'icon': '🗺️',
            'status': 'in_progress',
          },
        ],
      };

      final dto = MissionsResponseDto.fromJson(json);
      expect(dto.categories.length, 6);
      expect(dto.missions.length, 2);

      final categories = dto.toCategories();
      expect(categories.first.id, 'all');
      expect(categories.first.title, 'All');
      expect(categories[1].id, 'everyday');
      expect(categories[1].title, 'Everyday');

      final missions = dto.toMissionSummaries();
      expect(missions.length, 2);
      expect(missions[0].id, 'order-a-coffee');
      expect(missions[0].status, MissionStatus.newMission);
      expect(missions[1].id, 'ask-for-directions');
      expect(missions[1].status, MissionStatus.inProgress);
    });
  });

  group('MissionStatusDto', () {
    test('parses start and complete response', () {
      final startJson = {
        'mission_id': 'order-a-coffee',
        'status': 'in_progress',
      };
      final startDto = MissionStatusDto.fromJson(startJson);
      expect(startDto.missionId, 'order-a-coffee');
      expect(startDto.status, 'in_progress');

      final completeJson = {
        'mission_id': 'order-a-coffee',
        'status': 'complete',
      };
      final completeDto = MissionStatusDto.fromJson(completeJson);
      expect(completeDto.missionId, 'order-a-coffee');
      expect(completeDto.status, 'complete');
    });
  });

  group('MissionDetailDto', () {
    test('parses GET /api/missions/{mission_id} correctly', () {
      final json = {
        'mission_id': 'order-a-coffee',
        'title': 'Order a coffee',
        'character_name': 'Lucía',
        'character_role': 'barista',
        'duration_minutes': 5,
        'category': 'Everyday',
        'icon': '☕',
        'description': 'Practice ordering your favorite coffee drink.',
        'scene': 'A busy café, morning rush',
        'goals': [
          {
            'id': 1,
            'goal': 'Order a drink',
            'translated_goal': 'Order a drink',
            'completed': false,
          },
          {
            'id': 2,
            'goal': 'Ask the price',
            'translated_goal': 'Ask the price',
            'completed': false,
          },
        ],
        'initial_message': {
          'character_text': '¡Hola! Buenos días. ¿Qué desea tomar?',
          'translation': 'Hello! Good morning. What would you like to have?',
        },
        'status': 'not_started',
      };

      final dto = MissionDetailDto.fromJson(json);
      expect(dto.missionId, 'order-a-coffee');
      expect(dto.title, 'Order a coffee');
      expect(dto.characterName, 'Lucía');
      expect(dto.characterRole, 'barista');
      expect(dto.scene, 'A busy café, morning rush');
      expect(dto.goals.length, 2);
      expect(dto.goals[0].id, '1');
      expect(dto.goals[0].goal, 'Order a drink');
      expect(dto.initialCharacterText, '¡Hola! Buenos días. ¿Qué desea tomar?');
      expect(dto.initialTranslation, 'Hello! Good morning. What would you like to have?');

      final brief = dto.toMissionBrief(targetLanguageCode: 'es');
      expect(brief.missionId, 'order-a-coffee');
      expect(brief.title, 'Order a coffee');
      expect(brief.sceneLine, 'A busy café, morning rush');
      expect(brief.goals.length, 2);
      expect(brief.goals[0].id, '1');
      expect(brief.goals[0].text, 'Order a drink');
    });
  });

  group('MissionMessageResponseDto', () {
    test('parses POST /api/missions/{mission_id}/message response correctly', () {
      final json = {
        'character_text': '¡Hola! Un café, perfecto. ¿Algo más?',
        'translation': 'Hello! A coffee, perfect. Anything else?',
        'completed_goals': ['Order a drink'],
        'is_finished': false,
        'options': [
          {'text': 'Eso es todo, gracias.', 'translation': "That's all, thank you."},
          {'text': '¿Cuánto cuesta?', 'translation': 'How much is it?'},
        ],
      };

      final dto = MissionMessageResponseDto.fromJson(json);
      expect(dto.characterText, '¡Hola! Un café, perfecto. ¿Algo más?');
      expect(dto.translation, 'Hello! A coffee, perfect. Anything else?');
      expect(dto.completedGoals, ['Order a drink']);
      expect(dto.isFinished, isFalse);
      expect(dto.options.length, 2);
      expect(dto.options[0].text, 'Eso es todo, gracias.');
      expect(dto.options[0].translation, "That's all, thank you.");
      expect(dto.options[1].text, '¿Cuánto cuesta?');
      expect(dto.options[1].translation, 'How much is it?');
    });

    test('parses initial_options fallback and string array options', () {
      final json = {
        'character_text': '¡Hola!',
        'initial_options': ['Un café, por favor.', 'Un té, por favor.'],
      };

      final dto = MissionMessageResponseDto.fromJson(json);
      expect(dto.options.length, 2);
      expect(dto.options[0].text, 'Un café, por favor.');
      expect(dto.options[1].text, 'Un té, por favor.');
    });
  });
}

