/// Delivery state of a chat message.
enum MessageDeliveryState {
  sending,
  sent,
  failed,
}

/// The author of a chat message in the role-play session.
enum MessageAuthor {
  character,
  user,
  system,
}

/// Domain representation of a single chat message in a mission role-play session.
///
/// Follows AGENTS.md §2.2: Pure Dart, zero Flutter imports.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.targetText,
    this.clientTurnId,
    this.translationText,
    this.audioLocale,
    this.correction,
    this.deliveryState = MessageDeliveryState.sent,
    required this.timestamp,
  });

  final String id;
  final String? clientTurnId;
  final MessageAuthor author;
  final String targetText;
  final String? translationText;
  final String? audioLocale;
  final String? correction;
  final MessageDeliveryState deliveryState;
  final DateTime timestamp;

  bool get isFromCharacter => author == MessageAuthor.character;
  bool get isFromUser => author == MessageAuthor.user;
  bool get isSystem => author == MessageAuthor.system;

  ChatMessage copyWith({
    String? id,
    String? clientTurnId,
    MessageAuthor? author,
    String? targetText,
    String? translationText,
    String? audioLocale,
    String? correction,
    MessageDeliveryState? deliveryState,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      clientTurnId: clientTurnId ?? this.clientTurnId,
      author: author ?? this.author,
      targetText: targetText ?? this.targetText,
      translationText: translationText ?? this.translationText,
      audioLocale: audioLocale ?? this.audioLocale,
      correction: correction ?? this.correction,
      deliveryState: deliveryState ?? this.deliveryState,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clientTurnId == other.clientTurnId &&
          author == other.author &&
          targetText == other.targetText &&
          translationText == other.translationText &&
          audioLocale == other.audioLocale &&
          correction == other.correction &&
          deliveryState == other.deliveryState;

  @override
  int get hashCode => Object.hash(
        id,
        clientTurnId,
        author,
        targetText,
        translationText,
        audioLocale,
        correction,
        deliveryState,
      );
}
