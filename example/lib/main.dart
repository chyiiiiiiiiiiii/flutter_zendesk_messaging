import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zendesk Messaging Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ZendeskMessagingDemo(),
    );
  }
}

class ZendeskMessagingDemo extends StatefulWidget {
  const ZendeskMessagingDemo({super.key});

  @override
  State<ZendeskMessagingDemo> createState() => _ZendeskMessagingDemoState();
}

class _ZendeskMessagingDemoState extends State<ZendeskMessagingDemo> {
  // Replace with your actual channel keys
  static const String androidChannelKey = '<YOUR_ANDROID_CHANNEL_KEY>';
  static const String iosChannelKey = '<YOUR_IOS_CHANNEL_KEY>';

  final List<String> _logs = [];
  StreamSubscription<ZendeskEvent>? _eventSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  bool _isInitialized = false;
  bool _isLoggedIn = false;
  int _unreadMessageCount = 0;
  ZendeskConnectionStatus _connectionStatus = ZendeskConnectionStatus.unknown;
  ZendeskUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkInitializationStatus();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.dispose();
  }

  void _log(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _logs.insert(0, '[$timestamp] $message');
      if (_logs.length > 100) _logs.removeLast();
    });
  }

  Future<void> _checkInitializationStatus() async {
    final isInitialized = await ZendeskMessaging.isInitialized();
    final isLoggedIn = await ZendeskMessaging.isLoggedIn();
    setState(() {
      _isInitialized = isInitialized;
      _isLoggedIn = isLoggedIn;
    });
    if (isInitialized) {
      _log('SDK already initialized');
      _setupEventListeners();
    }
  }

  // ========== Initialization ==========

  Future<void> _initialize() async {
    _log('Initializing SDK...');
    try {
      await ZendeskMessaging.initialize(
        androidChannelKey: androidChannelKey,
        iosChannelKey: iosChannelKey,
      );
      setState(() => _isInitialized = true);
      _log('SDK initialized successfully');
      _setupEventListeners();
    } catch (e) {
      _log('Initialize failed: $e');
    }
  }

  Future<void> _invalidate() async {
    _log('Invalidating SDK...');
    try {
      await ZendeskMessaging.invalidate();
      _eventSubscription?.cancel();
      _unreadCountSubscription?.cancel();
      setState(() {
        _isInitialized = false;
        _isLoggedIn = false;
        _currentUser = null;
        _unreadMessageCount = 0;
        _connectionStatus = ZendeskConnectionStatus.unknown;
      });
      _log('SDK invalidated');
    } catch (e) {
      _log('Invalidate failed: $e');
    }
  }

  // ========== Event Listeners ==========

  void _setupEventListeners() {
    // Listen to all events via the unified event stream
    _eventSubscription?.cancel();
    _eventSubscription = ZendeskMessaging.eventStream.listen(_handleEvent);
    _log('Event listener setup complete');

    // Also listen to unread count stream for backwards compatibility demo
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription =
        ZendeskMessaging.unreadMessagesCountStream.listen((count) {
      setState(() => _unreadMessageCount = count);
    });

    // Start listening for unread messages
    ZendeskMessaging.listenUnreadMessages();
  }

  void _handleEvent(ZendeskEvent event) {
    // Use Dart 3 pattern matching with sealed classes
    final message = switch (event) {
      UnreadMessageCountChanged(
        :final totalUnreadCount,
        :final conversationId
      ) =>
        'Unread count: $totalUnreadCount${conversationId != null ? ' (conversation: $conversationId)' : ''}',
      AuthenticationFailed(:final errorMessage, :final isJwtExpired) =>
        'Auth failed: $errorMessage (JWT expired: $isJwtExpired)',
      ConnectionStatusChanged(:final status) => () {
          setState(() => _connectionStatus = status);
          return 'Connection: ${status.name}';
        }(),
      ConversationAdded(:final conversationId) =>
        'Conversation added: $conversationId',
      ConversationStarted(:final conversationId) =>
        'Conversation started: $conversationId',
      ConversationOpened(:final conversationId) =>
        'Conversation opened: ${conversationId ?? 'default'}',
      MessagesShown(:final conversationId, :final messages) =>
        'Messages shown: ${messages.length} in $conversationId',
      SendMessageFailed(:final errorMessage) => 'Send failed: $errorMessage',
      FieldValidationFailed(:final errors) =>
        'Field validation failed: ${errors.join(', ')}',
      MessagingOpened() => 'Messaging UI opened',
      MessagingClosed() => 'Messaging UI closed',
      ProactiveMessageDisplayed(:final proactiveMessageId) =>
        'Proactive message displayed: $proactiveMessageId',
      ProactiveMessageClicked(:final proactiveMessageId) =>
        'Proactive message clicked: $proactiveMessageId',
      ConversationWithAgentRequested(:final conversationId) =>
        'Agent requested: $conversationId',
      ConversationWithAgentAssigned(:final conversationId) =>
        'Agent assigned: $conversationId',
      ConversationServedByAgent(:final conversationId, :final agentId) =>
        'Agent serving: $agentId in $conversationId',
      NewConversationButtonClicked() => 'New conversation button clicked',
      PostbackButtonClicked(:final actionName) =>
        'Postback clicked: $actionName',
      ArticleClicked(:final articleUrl) => 'Article clicked: $articleUrl',
      ArticleBrowserClicked(:final articleUrl) =>
        'Article opened in browser: $articleUrl',
      ConversationExtensionOpened(:final extensionUrl) =>
        'Extension opened: $extensionUrl',
      ConversationExtensionDisplayed(:final extensionUrl) =>
        'Extension displayed: $extensionUrl',
      NotificationDisplayed(:final conversationId) =>
        'Notification displayed: $conversationId',
      NotificationOpened(:final conversationId) =>
        'Notification opened: $conversationId',
    };
    _log('EVENT: $message');
  }

  // ========== Authentication ==========

  Future<void> _login() async {
    _log('Logging in...');
    try {
      // Replace with your actual JWT token
      final response =
          await ZendeskMessaging.loginUser(jwt: '<YOUR_JWT_TOKEN>');
      setState(() {
        _isLoggedIn = true;
        _currentUser = ZendeskUser(
          id: response.id,
          externalId: response.externalId,
          authenticationType: ZendeskAuthenticationType.jwt,
        );
      });
      _log('Login success: ${response.id}');
    } catch (e) {
      _log('Login failed: $e');
    }
  }

  Future<void> _logout() async {
    _log('Logging out...');
    try {
      await ZendeskMessaging.logoutUser();
      setState(() {
        _isLoggedIn = false;
        _currentUser = null;
      });
      _log('Logout success');
    } catch (e) {
      _log('Logout failed: $e');
    }
  }

  Future<void> _getCurrentUser() async {
    _log('Getting current user...');
    try {
      final user = await ZendeskMessaging.getCurrentUser();
      setState(() => _currentUser = user);
      if (user case final user?) {
        _log('Current user: ${user.id} (${user.authenticationType.name})');
      } else {
        _log('No user logged in');
      }
    } catch (e) {
      _log('Get current user failed: $e');
    }
  }

  // ========== Messaging UI ==========

  Future<void> _showMessaging() async {
    _log('Opening messaging...');
    try {
      await ZendeskMessaging.show();
      _log('Messaging shown');
    } catch (e) {
      _log('Show messaging failed: $e');
    }
  }

  Future<void> _showConversationList() async {
    _log('Opening conversation list...');
    try {
      await ZendeskMessaging.showConversationList();
      _log('Conversation list shown');
    } catch (e) {
      _log('Show conversation list failed: $e');
    }
  }

  Future<void> _startNewConversation() async {
    _log('Starting new conversation...');
    try {
      await ZendeskMessaging.startNewConversation();
      _log('New conversation started');
    } catch (e) {
      _log('Start new conversation failed: $e');
    }
  }

  // ========== Message Count ==========

  Future<void> _getUnreadCount() async {
    try {
      final count = await ZendeskMessaging.getUnreadMessageCount();
      setState(() => _unreadMessageCount = count);
      _log('Unread count: $count');
    } catch (e) {
      _log('Get unread count failed: $e');
    }
  }

  Future<void> _getConnectionStatus() async {
    try {
      final status = await ZendeskMessaging.getConnectionStatus();
      setState(() => _connectionStatus = status);
      _log('Connection status: ${status.name}');
    } catch (e) {
      _log('Get connection status failed: $e');
    }
  }

  // ========== Conversation Data ==========

  Future<void> _setTags() async {
    try {
      await ZendeskMessaging.setConversationTags(['vip', 'mobile', 'flutter']);
      _log('Tags set: vip, mobile, flutter');
    } catch (e) {
      _log('Set tags failed: $e');
    }
  }

  Future<void> _clearTags() async {
    try {
      await ZendeskMessaging.clearConversationTags();
      _log('Tags cleared');
    } catch (e) {
      _log('Clear tags failed: $e');
    }
  }

  Future<void> _setFields() async {
    try {
      await ZendeskMessaging.setConversationFields({
        'app_version': '3.0.0',
        'platform': 'flutter',
        'user_tier': 'premium',
      });
      _log('Fields set');
    } catch (e) {
      _log('Set fields failed: $e');
    }
  }

  Future<void> _clearFields() async {
    try {
      await ZendeskMessaging.clearConversationFields();
      _log('Fields cleared');
    } catch (e) {
      _log('Clear fields failed: $e');
    }
  }

  // ========== UI ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zendesk Messaging 3.0'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() => _logs.clear()),
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBar(),
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildControls()),
                Expanded(flex: 3, child: _buildLogViewer()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        children: [
          _StatusChip(
            label: 'SDK',
            value: _isInitialized ? 'Ready' : 'Not Init',
            color: _isInitialized ? Colors.green : Colors.grey,
          ),
          _StatusChip(
            label: 'Auth',
            value: _isLoggedIn ? 'Logged In' : 'Anonymous',
            color: _isLoggedIn ? Colors.blue : Colors.grey,
          ),
          _StatusChip(
            label: 'Connection',
            value: _connectionStatus.name,
            color: switch (_connectionStatus) {
              ZendeskConnectionStatus.connected ||
              ZendeskConnectionStatus.connectedRealtime =>
                Colors.green,
              ZendeskConnectionStatus.connectingRealtime => Colors.orange,
              ZendeskConnectionStatus.disconnected => Colors.red,
              ZendeskConnectionStatus.unknown => Colors.grey,
            },
          ),
          if (_unreadMessageCount > 0)
            Chip(
              avatar: const Icon(Icons.mail, size: 16),
              label: Text('$_unreadMessageCount unread'),
              backgroundColor: Colors.red.shade100,
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection('Initialization', [
          _ActionButton(
            label: 'Initialize',
            onPressed: !_isInitialized ? _initialize : null,
            icon: Icons.play_arrow,
          ),
          _ActionButton(
            label: 'Invalidate',
            onPressed: _isInitialized ? _invalidate : null,
            icon: Icons.stop,
            destructive: true,
          ),
        ]),
        _buildSection('Authentication', [
          _ActionButton(
            label: 'Login',
            onPressed: _isInitialized && !_isLoggedIn ? _login : null,
            icon: Icons.login,
          ),
          _ActionButton(
            label: 'Logout',
            onPressed: _isInitialized && _isLoggedIn ? _logout : null,
            icon: Icons.logout,
          ),
          _ActionButton(
            label: 'Get Current User',
            onPressed: _isInitialized ? _getCurrentUser : null,
            icon: Icons.person,
          ),
        ]),
        _buildSection('Messaging UI', [
          _ActionButton(
            label: 'Show Messaging',
            onPressed: _isInitialized ? _showMessaging : null,
            icon: Icons.chat,
          ),
          _ActionButton(
            label: 'Conversation List',
            onPressed: _isInitialized ? _showConversationList : null,
            icon: Icons.list,
          ),
          _ActionButton(
            label: 'Start New Conversation',
            onPressed: _isInitialized ? _startNewConversation : null,
            icon: Icons.add_comment,
          ),
        ]),
        _buildSection('Status & Count', [
          _ActionButton(
            label: 'Get Unread Count',
            onPressed: _isInitialized ? _getUnreadCount : null,
            icon: Icons.mark_email_unread,
          ),
          _ActionButton(
            label: 'Get Connection Status',
            onPressed: _isInitialized ? _getConnectionStatus : null,
            icon: Icons.wifi,
          ),
        ]),
        _buildSection('Conversation Data', [
          _ActionButton(
            label: 'Set Tags',
            onPressed: _isInitialized ? _setTags : null,
            icon: Icons.label,
          ),
          _ActionButton(
            label: 'Clear Tags',
            onPressed: _isInitialized ? _clearTags : null,
            icon: Icons.label_off,
          ),
          _ActionButton(
            label: 'Set Fields',
            onPressed: _isInitialized ? _setFields : null,
            icon: Icons.text_fields,
          ),
          _ActionButton(
            label: 'Clear Fields',
            onPressed: _isInitialized ? _clearFields : null,
            icon: Icons.clear,
          ),
        ]),
        if (_currentUser != null) ...[
          const Divider(),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current User',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('ID: ${_currentUser!.id ?? 'N/A'}'),
                  Text('External ID: ${_currentUser!.externalId ?? 'N/A'}'),
                  Text('Auth: ${_currentUser!.authenticationType.name}'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLogViewer() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Event Log',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final isEvent = log.contains('EVENT:');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    log,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: isEvent ? Colors.cyan : Colors.green.shade300,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool destructive;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: destructive ? Colors.red : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
