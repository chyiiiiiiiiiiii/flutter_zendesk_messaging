/// Message data from Zendesk SDK events.
///
/// Represents a single message in a conversation.
class ZendeskMessage {
  /// Creates a new [ZendeskMessage] instance.
  const ZendeskMessage({
    required this.id,
    required this.conversationId,
    this.authorId,
    this.content,
    this.timestamp,
  });

  /// The unique message ID.
  final String id;

  /// The ID of the conversation this message belongs to.
  final String conversationId;

  /// The ID of the message author (user or agent).
  final String? authorId;

  /// The text content of the message.
  final String? content;

  /// The timestamp when the message was received.
  final DateTime? timestamp;

  /// Creates a [ZendeskMessage] from a map.
  ///
  /// Used for deserializing data from the native platform.
  factory ZendeskMessage.fromMap(Map<String, dynamic> map) {
    return ZendeskMessage(
      id: map['id'] as String? ?? '',
      conversationId: map['conversationId'] as String? ?? '',
      authorId: map['authorId'] as String?,
      content: map['content'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : null,
    );
  }

  @override
  String toString() {
    return 'ZendeskMessage(id: $id, conversationId: $conversationId, '
        'authorId: $authorId, content: $content, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZendeskMessage &&
        other.id == id &&
        other.conversationId == conversationId &&
        other.authorId == authorId &&
        other.content == content &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode =>
      Object.hash(id, conversationId, authorId, content, timestamp);
}
