/// Service interface for invoking system share capabilities without unauthorized packages.
///
/// Follows AGENTS.md §2.1 & §2.2: Pure Dart, zero Flutter imports.
abstract interface class ShareService {
  /// Opens the system share dialog with [text] and optional [subject] and [linkUrl].
  Future<void> share({required String text, String? subject, String? linkUrl});
}
