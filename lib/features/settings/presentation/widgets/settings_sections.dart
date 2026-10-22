import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/audio_feedback_service.dart';
import '../../../onboarding/domain/age_band.dart';
import '../../../onboarding/domain/language_level.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/domain/level_info.dart';
import '../../../onboarding/domain/reminder_time.dart';
import '../providers/app_settings_provider.dart';
import '../providers/version_info_provider.dart';
import '../screens/settings_screen_actions.dart';
import 'accessibility_section.dart';
import 'account_section.dart';
import 'appearance_section.dart';
import 'courses_section.dart';
import 'goal_reminders_section.dart';
import 'more_section.dart';
import 'settings_header.dart';
import 'sound_haptics_section.dart';

/// Bundle of all configured Settings section widgets.
///
/// Encapsulates Riverpod reads and callbacks to keep screens under 100 lines.
class SettingsSections {
  const SettingsSections({
    required this.header,
    required this.courses,
    required this.goalReminders,
    required this.soundHaptics,
    required this.appearance,
    required this.accessibility,
    required this.account,
    required this.more,
    required this.version,
  });

  final SettingsHeader header;
  final Widget courses;
  final Widget goalReminders;
  final Widget soundHaptics;
  final Widget appearance;
  final Widget accessibility;
  final Widget account;
  final Widget more;
  final String version;

  factory SettingsSections.from(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final settings = ref.watch(appSettingsProvider);
    final version = ref.watch(versionInfoProvider).appVersion;

    final targetLang = SettingsScreenActions.resolveTargetLanguage(
      user?.targetLanguageCode ?? 'es',
    );
    final levelInfo = LevelInfo.forLevel(
      user?.selectedLevel ?? LanguageLevel.little,
    );

    return SettingsSections(
      header: SettingsHeader(
        targetLanguage: targetLang,
        levelInfo: levelInfo,
        initialName: user?.firstName ?? settings.firstName,
        onNameSaved: (n) => SettingsScreenActions.handleNameSaved(ref, user, n),
        ageBand: user?.ageBand ?? AgeBand.adult,
      ),
      courses: CoursesSection(
        selectedTargetLanguageCode: user?.targetLanguageCode ?? 'es',
        onTargetLanguageChanged: (c) =>
            SettingsScreenActions.handleTargetLanguage(ref, user, c),
        selectedLevel: user?.selectedLevel ?? LanguageLevel.little,
        onLevelChanged: (l) => SettingsScreenActions.handleLevel(ref, user, l),
        selectedExplanationLanguageCode: user?.explanationLanguageCode ?? 'en',
        onExplanationLanguageChanged: (c) =>
            SettingsScreenActions.handleExplanation(ref, user, c),
        showHelperLine: settings.showHelperLine,
        onShowHelperLineChanged: (v) =>
            ref.read(appSettingsProvider.notifier).setShowHelperLine(v),
      ),
      goalReminders: GoalRemindersSection(
        selectedGoalId: user?.dailyGoalId ?? 'regular',
        onGoalChanged: (g) => SettingsScreenActions.handleGoal(ref, user, g),
        reminderTime:
            user?.reminderTime ?? const ReminderTime(hour: 19, minute: 0),
        onReminderTimeChanged: (t) =>
            SettingsScreenActions.handleReminderTime(ref, user, t),
        selectedWeekdays:
            user?.selectedWeekdayNumbers ?? const {1, 2, 3, 4, 5, 6, 7},
        onToggleWeekday: (d) =>
            SettingsScreenActions.handleWeekdayToggle(ref, user, d),
        remindersEnabled: user?.remindersEnabled ?? true,
        onRemindersEnabledChanged: (e) =>
            SettingsScreenActions.handleRemindersToggle(context, ref, user, e),
      ),
      soundHaptics: SoundHapticsSection(
        soundEnabled: settings.soundEnabled,
        onSoundEnabledChanged: (v) =>
            ref.read(appSettingsProvider.notifier).setSoundEnabled(v),
        hapticsEnabled: settings.hapticsEnabled,
        onHapticsEnabledChanged: (v) =>
            ref.read(appSettingsProvider.notifier).setHapticsEnabled(v),
        autoplayEnabled: settings.autoplay,
        onAutoplayChanged: (v) =>
            ref.read(appSettingsProvider.notifier).setAutoplay(v),
        speakingPracticeEnabled: settings.speakingPracticeEnabled,
        onSpeakingPracticeChanged: (v) => ref
            .read(appSettingsProvider.notifier)
            .setSpeakingPracticeEnabled(v),
        onTestSound: () => ref.read(audioFeedbackServiceProvider).playSuccess(),
      ),
      appearance: AppearanceSection(
        selectedThemeMode: settings.themeMode,
        onThemeModeChanged: (m) =>
            ref.read(appSettingsProvider.notifier).setThemeMode(m),
        selectedAccentId: settings.accentId,
        onAccentChanged: (a) =>
            ref.read(appSettingsProvider.notifier).setAccentId(a),
        textScale: settings.textScale,
        onTextScaleChanged: (s) =>
            ref.read(appSettingsProvider.notifier).setTextScale(s),
      ),
      accessibility: AccessibilitySection(
        reduceMotion: settings.reduceMotion,
        onReduceMotionChanged: (v) =>
            ref.read(appSettingsProvider.notifier).setReduceMotion(v),
        captionsAlwaysOn: settings.captionsAlwaysOn,
        onCaptionsChanged: (v) =>
            ref.read(appSettingsProvider.notifier).setCaptionsAlwaysOn(v),
        isLeftHanded: settings.isLeftHanded,
        onLeftHandedChanged: (v) =>
            ref.read(appSettingsProvider.notifier).setLeftHanded(v),
      ),
      account: AccountSection(
        userProfile: user,
        onSignIn: () => context.push('/login?returnTo=/settings'),
        onSeeOptions: () => context.push('/premium/options'),
        onResetProgress: () =>
            SettingsScreenActions.handleResetProgress(context, ref),
        onLogOut: () => ref.read(currentUserProvider.notifier).logout(),
      ),
      more: MoreSection(
        onPrivacyTap: () => context.push('/settings/privacy'),
        onHelpTap: () => context.push('/settings/help'),
        onAboutTap: () => context.push('/settings/about'),
      ),
      version: version,
    );
  }
}
