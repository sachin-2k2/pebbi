/// DTO representing a goal in Free Talk.
class FreeTalkGoalDto {
  const FreeTalkGoalDto({
    required this.id,
    required this.goal,
    this.completed = false,
  });

  factory FreeTalkGoalDto.fromJson(Map<String, dynamic> json) {
    return FreeTalkGoalDto(
      id: json['id']?.toString() ?? '',
      goal: json['goal']?.toString() ?? '',
      completed: json['completed'] as bool? ?? false,
    );
  }

  final String id;
  final String goal;
  final bool completed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'goal': goal,
    'completed': completed,
  };
}

/// DTO representing an option or reply pill in Free Talk.
class FreeTalkOptionDto {
  const FreeTalkOptionDto({
    required this.text,
    this.translation,
  });

  factory FreeTalkOptionDto.fromJson(Map<String, dynamic> json) {
    return FreeTalkOptionDto(
      text: json['text']?.toString() ?? '',
      translation: json['translation']?.toString(),
    );
  }

  final String text;
  final String? translation;

  Map<String, dynamic> toJson() => {
    'text': text,
    if (translation != null) 'translation': translation,
  };
}

/// DTO representing a message in Free Talk start response.
class FreeTalkInitialMessageDto {
  const FreeTalkInitialMessageDto({
    required this.characterText,
    required this.translation,
  });

  factory FreeTalkInitialMessageDto.fromJson(Map<String, dynamic> json) {
    return FreeTalkInitialMessageDto(
      characterText: json['character_text']?.toString() ?? '',
      translation: json['translation']?.toString() ?? '',
    );
  }

  final String characterText;
  final String translation;

  Map<String, dynamic> toJson() => {
    'character_text': characterText,
    'translation': translation,
  };
}

/// DTO response from POST /api/missions/freetalk/start.
class FreeTalkStartResponseDto {
  const FreeTalkStartResponseDto({
    required this.sessionId,
    required this.characterName,
    required this.characterRole,
    required this.scene,
    required this.topic,
    required this.correctionStyle,
    required this.goals,
    required this.initialMessage,
    required this.options,
  });

  factory FreeTalkStartResponseDto.fromJson(Map<String, dynamic> json) {
    final rawGoals = json['goals'] as List<dynamic>? ?? const [];
    final rawOptions = json['options'] as List<dynamic>? ?? const [];
    final rawInitMsg = json['initial_message'] as Map<String, dynamic>? ?? const {};

    return FreeTalkStartResponseDto(
      sessionId: json['session_id']?.toString() ?? '',
      characterName: json['character_name']?.toString() ?? 'Tutotoco',
      characterRole: json['character_role']?.toString() ?? 'a friendly conversation partner',
      scene: json['scene']?.toString() ?? 'Anywhere you like',
      topic: json['topic']?.toString() ?? '',
      correctionStyle: json['correction_style']?.toString() ?? 'gentle',
      goals: rawGoals
          .whereType<Map<String, dynamic>>()
          .map(FreeTalkGoalDto.fromJson)
          .toList(),
      initialMessage: FreeTalkInitialMessageDto.fromJson(rawInitMsg),
      options: rawOptions
          .whereType<Map<String, dynamic>>()
          .map(FreeTalkOptionDto.fromJson)
          .toList(),
    );
  }

  final String sessionId;
  final String characterName;
  final String characterRole;
  final String scene;
  final String topic;
  final String correctionStyle;
  final List<FreeTalkGoalDto> goals;
  final FreeTalkInitialMessageDto initialMessage;
  final List<FreeTalkOptionDto> options;
}

/// DTO response from POST /api/missions/freetalk/message.
class FreeTalkMessageResponseDto {
  const FreeTalkMessageResponseDto({
    required this.characterText,
    required this.translation,
    this.liveCorrection,
    required this.completedGoals,
    this.isFinished = false,
    this.options = const [],
  });

  factory FreeTalkMessageResponseDto.fromJson(Map<String, dynamic> json) {
    final rawCg = json['completed_goals'] as List<dynamic>? ?? const [];
    final rawOptions = json['options'] as List<dynamic>? ?? const [];

    return FreeTalkMessageResponseDto(
      characterText: json['character_text']?.toString() ?? '',
      translation: json['translation']?.toString() ?? '',
      liveCorrection: json['live_correction']?.toString(),
      completedGoals: rawCg.map((e) => e.toString()).toList(),
      isFinished: json['is_finished'] as bool? ?? false,
      options: rawOptions
          .whereType<Map<String, dynamic>>()
          .map(FreeTalkOptionDto.fromJson)
          .toList(),
    );
  }

  final String characterText;
  final String translation;
  final String? liveCorrection;
  final List<String> completedGoals;
  final bool isFinished;
  final List<FreeTalkOptionDto> options;
}

/// DTO representing a single correction item in Free Talk debrief.
class FreeTalkCorrectionItemDto {
  const FreeTalkCorrectionItemDto({
    required this.userSaid,
    required this.betterWay,
    required this.explanation,
  });

  factory FreeTalkCorrectionItemDto.fromJson(Map<String, dynamic> json) {
    return FreeTalkCorrectionItemDto(
      userSaid: json['user_said']?.toString() ?? '',
      betterWay: json['better_way']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
    );
  }

  final String userSaid;
  final String betterWay;
  final String explanation;
}

/// DTO inner debrief object in Free Talk debrief response.
class FreeTalkDebriefDetailDto {
  const FreeTalkDebriefDetailDto({
    required this.praise,
    this.corrections = const [],
    this.vocabularyRecap = const [],
  });

  factory FreeTalkDebriefDetailDto.fromJson(Map<String, dynamic> json) {
    final rawCorrections = json['corrections'] as List<dynamic>? ?? const [];
    final rawVocab = json['vocabulary_recap'] as List<dynamic>? ?? const [];

    return FreeTalkDebriefDetailDto(
      praise: json['praise']?.toString() ?? '',
      corrections: rawCorrections
          .whereType<Map<String, dynamic>>()
          .map(FreeTalkCorrectionItemDto.fromJson)
          .toList(),
      vocabularyRecap: rawVocab.map((e) => e.toString()).toList(),
    );
  }

  final String praise;
  final List<FreeTalkCorrectionItemDto> corrections;
  final List<String> vocabularyRecap;
}

/// DTO response from POST /api/missions/freetalk/debrief.
class FreeTalkDebriefResponseDto {
  const FreeTalkDebriefResponseDto({
    required this.topic,
    required this.completedGoals,
    required this.totalMessages,
    this.debrief,
  });

  factory FreeTalkDebriefResponseDto.fromJson(Map<String, dynamic> json) {
    final rawCg = json['completed_goals'] as List<dynamic>? ?? const [];
    final rawDebrief = json['debrief'] as Map<String, dynamic>?;

    return FreeTalkDebriefResponseDto(
      topic: json['topic']?.toString() ?? '',
      completedGoals: rawCg.map((e) => e.toString()).toList(),
      totalMessages: (json['total_messages'] as num?)?.toInt() ?? 0,
      debrief: rawDebrief != null
          ? FreeTalkDebriefDetailDto.fromJson(rawDebrief)
          : null,
    );
  }

  final String topic;
  final List<String> completedGoals;
  final int totalMessages;
  final FreeTalkDebriefDetailDto? debrief;
}

