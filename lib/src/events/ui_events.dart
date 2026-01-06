part of 'zendesk_event.dart';

/// Triggered when the messaging UI is opened.
final class MessagingOpened extends ZendeskEvent {
  /// Creates a new [MessagingOpened] event.
  const MessagingOpened({required super.timestamp});
}

/// Triggered when the messaging UI is closed.
final class MessagingClosed extends ZendeskEvent {
  /// Creates a new [MessagingClosed] event.
  const MessagingClosed({required super.timestamp});
}

/// Triggered when the new conversation button is clicked.
final class NewConversationButtonClicked extends ZendeskEvent {
  /// Creates a new [NewConversationButtonClicked] event.
  const NewConversationButtonClicked({required super.timestamp});
}

/// Triggered when a postback button is clicked.
///
/// Postback buttons are interactive elements in rich messages.
final class PostbackButtonClicked extends ZendeskEvent {
  /// Creates a new [PostbackButtonClicked] event.
  const PostbackButtonClicked({
    required super.timestamp,
    required this.conversationId,
    required this.actionName,
  });

  /// The ID of the conversation containing the button.
  final String conversationId;

  /// The action name associated with the button.
  final String actionName;
}

/// Triggered when a proactive message is displayed.
///
/// Proactive messages are automated messages sent to users.
final class ProactiveMessageDisplayed extends ZendeskEvent {
  /// Creates a new [ProactiveMessageDisplayed] event.
  const ProactiveMessageDisplayed({
    required super.timestamp,
    required this.proactiveMessageId,
    this.campaignId,
  });

  /// The ID of the proactive message.
  final String proactiveMessageId;

  /// The ID of the campaign (if applicable).
  final String? campaignId;
}

/// Triggered when a proactive message is clicked.
final class ProactiveMessageClicked extends ZendeskEvent {
  /// Creates a new [ProactiveMessageClicked] event.
  const ProactiveMessageClicked({
    required super.timestamp,
    required this.proactiveMessageId,
    this.campaignId,
  });

  /// The ID of the proactive message.
  final String proactiveMessageId;

  /// The ID of the campaign (if applicable).
  final String? campaignId;
}

/// Triggered when an article is clicked in the article viewer.
final class ArticleClicked extends ZendeskEvent {
  /// Creates a new [ArticleClicked] event.
  const ArticleClicked({
    required super.timestamp,
    required this.articleUrl,
    this.conversationId,
  });

  /// The URL of the article.
  final String articleUrl;

  /// The ID of the conversation (if in conversation context).
  final String? conversationId;
}

/// Triggered when an article is opened in the browser.
final class ArticleBrowserClicked extends ZendeskEvent {
  /// Creates a new [ArticleBrowserClicked] event.
  const ArticleBrowserClicked({
    required super.timestamp,
    required this.articleUrl,
  });

  /// The URL of the article opened in browser.
  final String articleUrl;
}

/// Triggered when a conversation extension is opened.
final class ConversationExtensionOpened extends ZendeskEvent {
  /// Creates a new [ConversationExtensionOpened] event.
  const ConversationExtensionOpened({
    required super.timestamp,
    required this.conversationId,
    required this.extensionUrl,
  });

  /// The ID of the conversation.
  final String conversationId;

  /// The URL of the extension.
  final String extensionUrl;
}

/// Triggered when a conversation extension is displayed.
final class ConversationExtensionDisplayed extends ZendeskEvent {
  /// Creates a new [ConversationExtensionDisplayed] event.
  const ConversationExtensionDisplayed({
    required super.timestamp,
    required this.conversationId,
    required this.extensionUrl,
  });

  /// The ID of the conversation.
  final String conversationId;

  /// The URL of the extension.
  final String extensionUrl;
}
