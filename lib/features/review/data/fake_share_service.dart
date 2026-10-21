import '../domain/share_service.dart';

/// Test and placeholder implementation of [ShareService] avoiding external dependencies.
///
/// Follows AGENTS.md §2.4: Records share calls for assertions without adding unauthorized packages.
class FakeShareService implements ShareService {
  final List<Map<String, String?>> shareCalls = [];

  int get shareCount => shareCalls.length;
  String? get lastSharedLink =>
      shareCalls.isNotEmpty ? shareCalls.last['linkUrl'] : null;

  @override
  Future<void> share({
    required String text,
    String? subject,
    String? linkUrl,
  }) async {
    shareCalls.add({'text': text, 'subject': subject, 'linkUrl': linkUrl});
  }

  void reset() => shareCalls.clear();
}
