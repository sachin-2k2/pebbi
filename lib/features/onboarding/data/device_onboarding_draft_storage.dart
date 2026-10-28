import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/age_band.dart';
import '../domain/language_level.dart';
import '../domain/onboarding_state.dart';
import '../domain/placement_result.dart';
import '../domain/reminder_time.dart';

/// Device-level store for persisting unauthenticated onboarding setup answers.
///
/// Follows AGENTS.md §2 & §6:
/// - Key: `device_onboarding_draft_v1` (no "guest", versioned).
/// - 300 ms debounce, with immediate [flush] on step and lifecycle transitions.
/// - Security Rule: NEVER persists birth year, raw quiz answers, is_correct,
///   emails, passwords, or session tokens.
/// - Migration: Discards legacy drafts containing old strings (`child`, `teen`, `adult`).
class DeviceOnboardingDraftStorage {
  DeviceOnboardingDraftStorage({SharedPreferences? prefs}) : _prefs = prefs;

  static const String storageKey = 'device_onboarding_draft_v1';
  static const int currentSchemaVersion = 1;

  SharedPreferences? _prefs;
  Timer? _debounceTimer;
  OnboardingState? _pendingState;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Saves the active onboarding draft with a 300ms debounce.
  void saveDebounced(OnboardingState state) {
    _pendingState = state;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (_pendingState != null) {
        flush(_pendingState!);
      }
    });
  }

  /// Immediately flushes the [state] to [SharedPreferences] without debounce delay.
  Future<void> flush(OnboardingState state) async {
    _debounceTimer?.cancel();
    _pendingState = null;

    final prefs = await _getPrefs();
    final jsonMap = _toJson(state);
    await prefs.setString(storageKey, jsonEncode(jsonMap));
  }

  /// Loads and deserializes the persisted onboarding draft.
  ///
  /// Discards corrupted or outdated legacy drafts safely.
  Future<OnboardingState?> load() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        await clear();
        return null;
      }

      // Schema version check
      final version = decoded['version'] as int?;
      if (version != currentSchemaVersion) {
        await clear();
        return null;
      }

      // Legacy migration guard: discard old 'child'/'teen'/'adult' drafts
      final rawAge = decoded['age_band']?.toString();
      if (rawAge == 'child' || rawAge == 'teen' || rawAge == 'adult') {
        if (kDebugMode) {
          debugPrint(
            '[DraftStorage] Discarding legacy draft with old age_band: $rawAge',
          );
        }
        await clear();
        return null;
      }

      return _fromJson(decoded);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[DraftStorage] Error decoding draft: $e. Clearing storage.',
        );
      }
      await clear();
      return null;
    }
  }

  /// Clears the draft from device storage.
  Future<void> clear() async {
    _debounceTimer?.cancel();
    _pendingState = null;
    final prefs = await _getPrefs();
    await prefs.remove(storageKey);
  }

  /// Serializes privacy-safe [OnboardingState] fields.
  static Map<String, dynamic> _toJson(OnboardingState state) {
    return {
      'version': currentSchemaVersion,
      'current_step': state.currentStep,
      if (state.ageBand != null) 'age_band': state.ageBand!.apiValue,
      'explanation_language_code': state.explanationLanguageCode,
      'target_language_code': state.targetLanguageCode,
      'selected_reason_ids': state.selectedReasonIds.toList(),
      'selected_goal_id': state.selectedGoalId,
      'reminder_time': state.reminderTime.to24HourString(),
      'selected_weekday_numbers': state.selectedWeekdayNumbers.toList(),
      'reminders_enabled': state.remindersEnabled,
      'accent_id': state.accentId,
      if (state.firstStickerId != null)
        'first_sticker_id': state.firstStickerId,
      if (state.chosenLevel != null) 'chosen_level': state.chosenLevel!.id,
      if (state.suggestedLevel != null)
        'suggested_level': state.suggestedLevel!.id,
      'placement_skipped': state.isPlacementSkipped,
      if (state.placementResult != null) ...{
        'placement_score': state.placementResult!.firstTryCorrect,
        'placement_total': state.placementResult!.totalQuestions,
        'praised_phrases': state.placementResult!.praisePhrases,
      },
    };
  }

  /// Deserializes JSON back into an [OnboardingState].
  static OnboardingState _fromJson(Map<String, dynamic> json) {
    final ageStr = json['age_band']?.toString();
    final ageBand = AgeBand.fromApiValue(ageStr);

    final reasonList =
        (json['selected_reason_ids'] as List?)?.cast<String>() ?? [];
    final weekdayList =
        (json['selected_weekday_numbers'] as List?)?.cast<int>() ??
        [1, 2, 3, 4, 5, 6, 7];

    final chosenLevelStr = json['chosen_level']?.toString();
    final suggestedLevelStr = json['suggested_level']?.toString();
    final chosenLevel = chosenLevelStr != null
        ? LanguageLevel.fromId(chosenLevelStr)
        : null;
    final suggestedLevel = suggestedLevelStr != null
        ? LanguageLevel.fromId(suggestedLevelStr)
        : null;

    final isSkipped = json['placement_skipped'] as bool? ?? false;
    PlacementResult? placementResult;
    final score = json['placement_score'] as int?;
    final total = json['placement_total'] as int?;
    final praised = (json['praised_phrases'] as List?)?.cast<String>() ?? [];

    if (score != null && total != null && chosenLevel != null) {
      placementResult = PlacementResult(
        suggestedLevel: suggestedLevel ?? chosenLevel,
        chosenLevel: chosenLevel,
        firstTryCorrect: score,
        totalQuestions: total,
        praisePhrases: praised,
      );
    }

    return OnboardingState(
      currentStep: json['current_step'] as int? ?? 1,
      ageBand: ageBand,
      explanationLanguageCode:
          json['explanation_language_code'] as String? ?? 'en',
      targetLanguageCode: json['target_language_code'] as String? ?? 'es',
      selectedReasonIds: Set<String>.unmodifiable(reasonList),
      selectedGoalId: json['selected_goal_id'] as String? ?? 'regular',
      reminderTime: json['reminder_time'] != null
          ? ReminderTime.parse(json['reminder_time'].toString())
          : ReminderTime.defaultTime,
      selectedWeekdayNumbers: Set<int>.unmodifiable(weekdayList),
      remindersEnabled: json['reminders_enabled'] as bool? ?? true,
      accentId: json['accent_id'] as String? ?? 'violet',
      firstStickerId: json['first_sticker_id'] as String?,
      chosenLevel: chosenLevel,
      suggestedLevel: suggestedLevel,
      selectedLevel: chosenLevel,
      isPlacementSkipped: isSkipped,
      placementResult: placementResult,
    );
  }
}
