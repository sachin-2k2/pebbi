import 'package:flutter/foundation.dart';

/// Mapping for accent colors.
///
/// Follows API-UPDATES.md §1 & §5:
/// - Confirmed allowed values are string IDs: `violet`, `green`, `orange`, `blue`, `pink`, `slate`.
/// - Hex string codes are NOT sent.
abstract final class AccentMapper {
  static const String defaultAccent = 'violet';

  static const Set<String> validAccents = {
    'violet',
    'green',
    'orange',
    'blue',
    'pink',
    'slate',
  };

  /// Validates and normalizes accent ID for API payload.
  static String toApi(String? accentId) {
    if (accentId == null || !validAccents.contains(accentId.toLowerCase())) {
      if (kDebugMode && accentId != null) {
        debugPrint(
          '[AccentMapper] Unknown accent ID: "$accentId". Using default.',
        );
      }
      return defaultAccent;
    }
    return accentId.toLowerCase();
  }

  /// Normalizes incoming accent string from backend API.
  static String fromApi(String? apiValue) {
    if (apiValue == null) return defaultAccent;
    final lower = apiValue.toLowerCase().trim();
    if (validAccents.contains(lower)) return lower;
    return defaultAccent;
  }
}
