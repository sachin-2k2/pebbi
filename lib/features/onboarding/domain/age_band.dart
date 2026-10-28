/// Six canonical age bands aligned with TUTOTOCO backend specification.
///
/// Follows AGENTS.md §5 and §6: pure Dart domain model with zero Flutter imports.
/// - Minimum platform age is 13; under 13 is NOT an age band.
/// - Raw birth year is NEVER stored in models, state, or database.
enum AgeBand {
  band13_17(apiValue: '13-17', displayName: '13–17'),
  band18_24(apiValue: '18-24', displayName: '18–24'),
  band25_34(apiValue: '25-34', displayName: '25–34'),
  band35_44(apiValue: '35-44', displayName: '35–44'),
  band45_54(apiValue: '45-54', displayName: '45–54'),
  band55Plus(apiValue: '55+', displayName: '55+'),

  /// Legacy deprecated value for under-13 child accounts.
  /// Note: Under-13 users are now blocked at the onboarding age gate.
  /// Retained for safety checks in downstream features until refactored.
  @Deprecated('Under-13 users are now blocked at the age gate')
  child(apiValue: 'child', displayName: '<13');

  const AgeBand({required this.apiValue, required this.displayName});

  /// Backward-compatibility alias for adult bands.
  static const AgeBand adult = AgeBand.band25_34;

  /// Backward-compatibility alias for minor bands.
  static const AgeBand teen = AgeBand.band13_17;

  final String apiValue;
  final String displayName;

  /// True ONLY for the 13–17 minor band or legacy child value.
  bool get isMinorBand => this == AgeBand.band13_17 || this == AgeBand.child;

  /// Human-readable privacy message.
  String get privacyNote =>
      'All set. We store only the age band, never your birthday.';

  /// Whether this age band displays the protective shield alert icon.
  bool get hasShieldIcon => isMinorBand;

  /// The 6 canonical backend API bands.
  static const List<AgeBand> apiBands = [
    band13_17,
    band18_24,
    band25_34,
    band35_44,
    band45_54,
    band55Plus,
  ];

  /// Resolves an [AgeBand] from the backend API string (e.g. '13-17', '25-34').
  static AgeBand? fromApiValue(String? value) {
    if (value == null) return null;
    for (final band in apiBands) {
      if (band.apiValue == value) return band;
    }
    return null;
  }
}
