import '../domain/learning_reason.dart';
import '../domain/learning_reason_repository.dart';

/// Mock repository implementation returning the 9 learning reasons for Step 5.
///
/// Follows AGENTS.md §1 & §2: realistic mock data matching the design specification.
class MockLearningReasonRepository implements LearningReasonRepository {
  const MockLearningReasonRepository();

  static const List<LearningReason> _reasons = [
    LearningReason(id: 'travel', label: 'Travel', iconEmoji: '🧳'),
    LearningReason(id: 'work', label: 'Work and career', iconEmoji: '💼'),
    LearningReason(id: 'interview', label: 'Job interview', iconEmoji: '🤝'),
    LearningReason(id: 'study_abroad', label: 'Study abroad', iconEmoji: '🎓'),
    LearningReason(
      id: 'move_abroad',
      label: 'Move abroad and settle in',
      iconEmoji: '🏠',
    ),
    LearningReason(
      id: 'family',
      label: 'Family and friends',
      iconEmoji: '👨‍👩‍👧',
    ),
    LearningReason(id: 'exams', label: 'Exams', iconEmoji: '📝'),
    LearningReason(id: 'culture', label: 'Culture and fun', iconEmoji: '🎉'),
    LearningReason(
      id: 'just_learning',
      label: 'Just learning',
      iconEmoji: '🌱',
    ),
  ];

  @override
  List<LearningReason> getReasons() => _reasons;
}
