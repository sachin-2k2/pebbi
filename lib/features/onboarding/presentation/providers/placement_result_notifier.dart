import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/language_level.dart';
import '../../domain/placement_result.dart';
import 'onboarding_flow_provider.dart';
import 'placement_result_state.dart';

/// Default mock placement result matching the primary design specifications.
const PlacementResult kDefaultPlacementResult = PlacementResult(
  suggestedLevel: LanguageLevel.expert,
  chosenLevel: LanguageLevel.expert,
  firstTryCorrect: 8,
  totalQuestions: 8,
  praisePhrases: ['Un café, por favor', 'Buenas tardes', 'Soy de México'],
  streakDay: 1,
);

/// State notifier managing placement result presentation and level selection.
///
/// Follows AGENTS.md §2.3: clean StateNotifier with autoDispose.
class PlacementResultNotifier extends StateNotifier<PlacementResultState> {
  PlacementResultNotifier({PlacementResult? initialResult})
    : super(
        PlacementResultState(
          result: initialResult ?? kDefaultPlacementResult,
          chosenLevel: (initialResult ?? kDefaultPlacementResult).chosenLevel,
          isPickerOpen: false,
        ),
      );

  /// Selects a new [level], updates state, and collapses the picker.
  ///
  /// TODO(question): Confirm whether picking a level should auto-collapse the picker
  /// or stay open until the learner taps "Start from here".
  void selectLevel(LanguageLevel level) {
    state = state.copyWith(
      chosenLevel: level,
      result: state.result.copyWith(chosenLevel: level),
      isPickerOpen: false,
    );
  }

  /// Toggles the inline level picker open / closed.
  void togglePicker() {
    state = state.copyWith(isPickerOpen: !state.isPickerOpen);
  }

  /// Expands the inline level picker.
  void openPicker() {
    if (!state.isPickerOpen) {
      state = state.copyWith(isPickerOpen: true);
    }
  }

  /// Collapses the inline level picker.
  void closePicker() {
    if (state.isPickerOpen) {
      state = state.copyWith(isPickerOpen: false);
    }
  }

  /// Updates the underlying evaluated result.
  void setResult(PlacementResult result) {
    state = state.copyWith(
      result: result,
      chosenLevel: result.chosenLevel,
      isPickerOpen: false,
    );
  }
}

/// Provider managing placement results presentation state.
final placementResultProvider =
    StateNotifierProvider.autoDispose<
      PlacementResultNotifier,
      PlacementResultState
    >((ref) {
      final onboardingState = ref.watch(onboardingFlowProvider);
      return PlacementResultNotifier(
        initialResult: onboardingState.placementResult,
      );
    });
