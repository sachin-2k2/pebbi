import 'package:flutter/foundation.dart';

/// Mapping between client starter sticker IDs and backend API sticker values.
///
/// Follows API-UPDATES.md §5:
/// - `wave` -> `first_hello`
/// - `sparkle` -> `little_spark`
/// - `wellsaid` -> `well_said`
/// - Note: `explorer` and `star` are read-only achievement stickers unlocked later.
abstract final class StickerMapper {
  static const String firstHello = 'first_hello';
  static const String littleSpark = 'little_spark';
  static const String wellSaid = 'well_said';

  /// Maps domain sticker identifier (`wave`, `sparkle`, `wellsaid`) to backend string.
  static String? toApi(String? stickerId) {
    if (stickerId == null) return null;
    switch (stickerId) {
      case 'wave':
      case 'first_hello':
        return firstHello;
      case 'sparkle':
      case 'little_spark':
        return littleSpark;
      case 'wellsaid':
      case 'well_said':
        return wellSaid;
      default:
        if (kDebugMode) {
          debugPrint('[StickerMapper] Unrecognized sticker ID: "$stickerId".');
        }
        return null;
    }
  }

  /// Maps backend API sticker string back to domain identifier.
  static String? fromApi(String? apiValue) {
    if (apiValue == null) return null;
    switch (apiValue) {
      case firstHello:
        return 'wave';
      case littleSpark:
        return 'sparkle';
      case wellSaid:
        return 'wellsaid';
      default:
        return null;
    }
  }
}
