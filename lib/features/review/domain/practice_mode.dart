/// The modes available for targeted review practice.
enum PracticeMode {
  mix2min('mix2min'),
  flashcards('flashcards'),
  tricky('tricky');

  const PracticeMode(this.paramValue);

  final String paramValue;

  static PracticeMode fromString(String? val) {
    if (val == null) return PracticeMode.mix2min;
    return PracticeMode.values.firstWhere(
      (m) => m.paramValue == val,
      orElse: () => PracticeMode.mix2min,
    );
  }
}
