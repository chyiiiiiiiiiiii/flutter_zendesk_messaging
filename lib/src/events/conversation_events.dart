part of 'zendesk_event.dart';

/// Triggered when a new conversation is added.
///
/// This occurs when a new conversation is created in the SDK.
final class ConversationAdded extends ZendeskEvent {
  /// Creates a new [ConversationAdded] event.
  const ConversationAdded({
    required super.timestamp,
    required this.conversationId,
  });

  /// The ID of the newly added conversation.
  final String conversationId;
}

/// Triggered when a conversation is started.
///
/// This occurs when the user initiates a new conversation.
final class ConversationStarted extends ZendeskEvent {
  /// Creates a new [ConversationStarted] event.
  const ConversationStarted({
    required super.timestamp,
    required this.conversationId,
  });

  /// The ID of the started conversation.
  final String conversationId;
}

/// Triggered when a conversation is opened.
///
/// This occurs when the user opens an existing conversation.
final class ConversationOpened extends ZendeskEvent {
  /// Creates a new [ConversationOpened] event.
  const ConversationOpened({
    required super.timestamp,
    this.conversationId,
  });

  /// The ID of the opened conversation (may be null for default conversation).
  final String? conversationId;
}

/// Triggered when messages are shown to the user.
///
/// This event provides the list of messages that were displayed.
final class MessagesShown extends ZendeskEvent {
  /// Creates a new [MessagesShown] event.
  const MessagesShown({
    required super.timestamp,
    required this.conversationId,
    required this.messages,
  });

  /// The ID of the conversation containing the messages.
  final String conversationId;

  /// The list of messages that were shown.
  final List<ZendeskMessage> messages;
}

/// Triggered when user requests to speak with an agent.
final class ConversationWithAgentRequested extends ZendeskEvent {
  /// Creates a new [ConversationWithAgentRequested] event.
  const ConversationWithAgentRequested({
    required super.timestamp,
    required this.conversationId,
  });

  /// The ID of the conversation.
  final String conversationId;
}

/// Triggered when an agent is assigned to a conversation.
final class ConversationWithAgentAssigned extends ZendeskEvent {
  /// Creates a new [ConversationWithAgentAssigned] event.
  const ConversationWithAgentAssigned({
    required super.timestamp,
    required this.conversationId,
  });

  /// The ID of the conversation.
  final String conversationId;
}

/// Triggered when an agent sends the first message in a conversation.
final class ConversationServedByAgent extends ZendeskEvent {
  /// Creates a new [ConversationServedByAgent] event.
  const ConversationServedByAgent({
    required super.timestamp,
    required this.conversationId,
    this.agentId,
  });

  /// The ID of the conversation.
  final String conversationId;

  /// The ID of the agent serving the conversation.
  final String? agentId;
}
