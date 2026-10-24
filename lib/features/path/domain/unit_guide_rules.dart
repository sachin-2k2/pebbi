import 'unit.dart';

/// Pure domain rules governing unit guidebook accessibility.
///
/// Follows AGENTS.md §2 (pure domain rules, zero Flutter imports).
abstract final class UnitGuideRules {
  /// Determines if a user can open and view the guidebook for [unit].
  ///
  /// TODO(question): Can a free tier user open the guide of a premium-locked unit to preview content?
  /// For now, returns true unconditionally per design specification.
  static bool canOpenUnitGuide({required dynamic user, required Unit unit}) {
    // Unconditional access for now until product team specifies locking behavior.
    return true;
  }
}
