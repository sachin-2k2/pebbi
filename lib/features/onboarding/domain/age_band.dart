/// Age bands for privacy and child-safety compliance.
///
/// Follows AGENTS.md §5 and §6: pure Dart domain model with zero Flutter imports.
/// The raw year of birth is NEVER stored in models, state, or database.
enum AgeBand {
  /// Under 13 years old. Requires strict child-safe settings (COPPA).
  /// TODO(question): Confirm legal age cutoffs (e.g. 13 vs 16 for GDPR-K) with client/legal.
  child,

  /// 13 to 17 years old.
  /// TODO(question): Confirm teen privacy policies and parental consent rules.
  teen,

  /// 18 years old and above.
  adult;

  /// Human-readable privacy message data-driven by the age band.
  String get privacyNote {
    switch (this) {
      case AgeBand.child:
        return 'Pebbi is for ages 13 and up. Ask a grown-up to set this up with you — we store only your age band, nothing else.';
      case AgeBand.teen:
        return 'All set. We store only the age band, never your birthday.';
      case AgeBand.adult:
        return 'All set. We store only the age band, never your birthday.';
    }
  }

  /// Whether this age band displays the protective shield alert icon.
  bool get hasShieldIcon => this == AgeBand.child;

  /// Calculates the [AgeBand] from a given birth year.
  ///
  /// [currentYear] defaults to `DateTime.now().year` if not provided.
  static AgeBand fromBirthYear(int birthYear, {int? currentYear}) {
    final nowYear = currentYear ?? DateTime.now().year;
    final age = nowYear - birthYear;

    if (age < 13) {
      return AgeBand.child;
    } else if (age < 18) {
      return AgeBand.teen;
    } else {
      return AgeBand.adult;
    }
  }
}
