import '../../domain/language_level.dart';
import '../../domain/level_info.dart';
import '../../domain/placement_result.dart';

/// Immutable state for the Placement Result screen.
///
/// Follows AGENTS.md §2.3: clean state model with derived getters.
class PlacementResultState {
  const PlacementResultState({
    required this.result,
    required this.chosenLevel,
    this.isPickerOpen = false,
  });

  /// Evaluated result from placement quiz or mock fallback.
  final PlacementResult result;

  /// Currently chosen proficiency level.
  final LanguageLevel chosenLevel;

  /// Whether the inline level picker is expanded.
  final bool isPickerOpen;

  LevelInfo get currentLevelInfo => LevelInfo.forLevel(chosenLevel);

  PlacementResultState copyWith({
    PlacementResult? result,
    LanguageLevel? chosenLevel,
    bool? isPickerOpen,
  }) {
    return PlacementResultState(
      result: result ?? this.result,
      chosenLevel: chosenLevel ?? this.chosenLevel,
      isPickerOpen: isPickerOpen ?? this.isPickerOpen,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlacementResultState &&
          runtimeType == other.runtimeType &&
          result == other.result &&
          chosenLevel == other.chosenLevel &&
          isPickerOpen == other.isPickerOpen;

  @override
  int get hashCode => Object.hash(result, chosenLevel, isPickerOpen);
}
