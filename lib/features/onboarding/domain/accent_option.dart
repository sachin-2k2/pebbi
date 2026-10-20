/// Pure Dart domain model representing a selectable accent colour option.
///
/// Follows AGENTS.md §2.2: Zero Flutter imports so it can be unit tested in any Dart environment.
class AccentOption {
  const AccentOption({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  /// Stable unique identifier ('violet', 'green', 'orange', 'blue', 'pink', 'slate').
  final String id;

  /// English display name ('Violet', 'Green', etc.).
  final String name;

  /// 32-bit ARGB colour value.
  final int colorValue;

  static const String defaultAccentId = 'violet';

  static const List<AccentOption> options = [
    AccentOption(id: 'violet', name: 'Violet', colorValue: 0xFF6C4DF6),
    AccentOption(id: 'green', name: 'Green', colorValue: 0xFF2DD4A4),
    AccentOption(id: 'orange', name: 'Orange', colorValue: 0xFFFF7A00),
    AccentOption(id: 'blue', name: 'Blue', colorValue: 0xFF0EA5E9),
    AccentOption(id: 'pink', name: 'Pink', colorValue: 0xFFF43F5E),
    AccentOption(id: 'slate', name: 'Dark slate', colorValue: 0xFF475569),
  ];

  static AccentOption findById(String id) {
    return options.firstWhere(
      (opt) => opt.id == id,
      orElse: () => options.first,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccentOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          colorValue == other.colorValue;

  @override
  int get hashCode => Object.hash(id, name, colorValue);
}
