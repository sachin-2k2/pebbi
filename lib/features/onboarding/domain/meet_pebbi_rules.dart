import 'accent_option.dart';
import 'sticker_option.dart';

/// Pure selection rules governing Step 9: Meet Pebbi (Accent Colour & First Sticker).
///
/// Follows AGENTS.md §2.2: Pure Dart business rules with zero Flutter imports.
abstract final class MeetPebbiRules {
  /// Default preselected accent colour ID.
  static const String defaultAccentId = AccentOption.defaultAccentId;

  /// Checks if an accent ID is a recognized valid option.
  static bool isValidAccent(String id) {
    return AccentOption.options.any((opt) => opt.id == id);
  }

  /// Toggles sticker selection: tapping the currently selected sticker deselects it,
  /// otherwise selects the tapped sticker.
  static String? toggleSticker({
    required String? currentSelectedId,
    required String tappedId,
  }) {
    if (currentSelectedId == tappedId) {
      return null;
    }
    return StickerOption.findById(tappedId)?.id;
  }

  /// Whether the user can continue past Step 9.
  ///
  /// Always returns true because selecting a sticker is optional, and an accent
  /// colour is preselected by default.
  static bool canContinue({
    required String accentId,
    required String? stickerId,
  }) {
    return isValidAccent(accentId);
  }
}
