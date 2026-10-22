import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Identifiers for the 7 settings sections.
enum SettingsSectionId {
  courses(title: 'Courses', emoji: '🌍'),
  goalReminders(title: 'Goal and reminders', emoji: '🎯'),
  soundHaptics(title: 'Sound and haptics', emoji: '🔔'),
  appearance(title: 'Appearance', emoji: '🎨'),
  accessibility(title: 'Accessibility', emoji: '♿'),
  account(title: 'Account', emoji: '🔑'),
  more(title: 'More', emoji: '📗');

  const SettingsSectionId({required this.title, required this.emoji});

  final String title;
  final String emoji;
}

/// State provider storing the actively selected section in expanded tablet mode.
final selectedSettingsSectionProvider = StateProvider<SettingsSectionId>((ref) {
  return SettingsSectionId.courses;
});
