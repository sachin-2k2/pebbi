import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../settings/domain/lesson_settings.dart';

/// Riverpod provider for active [LessonSettings].
///
/// Follows AGENTS.md §2.3: clean state management accessible by exercise widgets.
final lessonSettingsProvider = StateProvider<LessonSettings>((ref) {
  return const LessonSettings();
});
