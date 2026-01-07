# Zendesk Messaging for Flutter

[![pub package](https://img.shields.io/pub/v/zendesk_messaging.svg)](https://pub.dev/packages/zendesk_messaging)
[![CI](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml/badge.svg)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml)
[![coverage](https://img.shields.io/badge/coverage-83%25-brightgreen)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![Zendesk Messaging](https://raw.githubusercontent.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/master/Messaging.png)

[English](README.md) | [繁體中文](README.zh-TW.md) | 简体中文 | [Español](README.es.md) | [Português (Brasil)](README.pt-BR.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

Flutter 插件，用于将 Zendesk Messaging SDK 集成到您的移动应用程序中。提供应用内客服消息功能，支持多会话、实时事件和 JWT 身份验证。

## 功能特性

- 初始化并显示 Zendesk Messaging UI
- JWT 用户身份验证
- 多会话导航
- 实时事件流（24 种事件类型）
- 未读消息数量跟踪
- 会话标签和自定义字段
- 连接状态监控
- 推送通知支持（FCM/APNs）

## 系统要求

| 平台 | 最低版本 |
|------|----------|
| iOS | 14.0 |
| Android | API 21 (minSdk) |
| Dart | 3.6.0 |
| Flutter | 3.27.0 |

## 安装

在 `pubspec.yaml` 中添加 `zendesk_messaging`：

```yaml
dependencies:
  zendesk_messaging: <latest_version>
```

### Android 配置

在项目级 `android/build.gradle` 中添加 Zendesk Maven 仓库：

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://zendesk.jfrog.io/artifactory/repo' }
    }
}
```

### iOS 配置

更新 `ios/Podfile` 以指定 iOS 14.0：

```ruby
platform :ios, '14.0'
```

然后运行：

```bash
cd ios && pod install
```

## 快速开始

### 获取 Channel Keys

在初始化 SDK 之前，您需要从 Zendesk Admin Center 获取 Android 和 iOS 的 channel keys：

1. 前往 **Admin Center** > **Channels** > **Messaging and social** > **Messaging**
2. 将鼠标悬停在要配置的品牌上，点击**选项图标**
3. 点击 **Edit** 并导航到 **Installation** 部分
4. 在 **Channel ID** 下方，点击 **Copy** 将密钥复制到剪贴板
5. 使用此密钥进行 Android 和 iOS 初始化

> **注意：** 两个平台使用相同的 Channel ID。如有需要，您可以为 Android 和 iOS 创建单独的频道。

### 初始化

```dart
import 'package:zendesk_messaging/zendesk_messaging.dart';

// 初始化 SDK（在应用启动时调用一次）
await ZendeskMessaging.initialize(
  androidChannelKey: '<YOUR_ANDROID_CHANNEL_KEY>',
  iosChannelKey: '<YOUR_IOS_CHANNEL_KEY>',
);
```

### 显示消息 UI

```dart
// 显示默认消息界面
await ZendeskMessaging.show();

// 显示特定会话（需启用多会话功能）
await ZendeskMessaging.showConversation('conversation_id');

// 显示会话列表
await ZendeskMessaging.showConversationList();

// 开始新会话
await ZendeskMessaging.startNewConversation();
```

### 用户身份验证

```dart
// 使用 JWT 登录
try {
  final response = await ZendeskMessaging.loginUser(jwt: '<YOUR_JWT_TOKEN>');
  print('已登录：${response.id}');
} catch (e) {
  print('登录失败：$e');
}

// 检查登录状态
final isLoggedIn = await ZendeskMessaging.isLoggedIn();

// 获取当前用户
final user = await ZendeskMessaging.getCurrentUser();
if (user != null) {
  print('用户 ID：${user.id}');
  print('外部 ID：${user.externalId}');
  print('验证类型：${user.authenticationType.name}');
}

// 登出
await ZendeskMessaging.logoutUser();
```

## 事件处理

SDK 提供统一的事件流，涵盖所有 Zendesk 事件。使用 Dart 3 模式匹配来处理特定事件类型：

```dart
ZendeskMessaging.eventStream.listen((event) {
  switch (event) {
    case UnreadMessageCountChanged(:final totalUnreadCount, :final conversationId):
      print('未读：$totalUnreadCount${conversationId != null ? '（会话：$conversationId）' : ''}');

    case AuthenticationFailed(:final errorMessage, :final isJwtExpired):
      print('验证失败：$errorMessage（JWT 已过期：$isJwtExpired）');
      if (isJwtExpired) {
        // 刷新 JWT token
      }

    case ConnectionStatusChanged(:final status):
      print('连接状态：${status.name}');

    case ConversationAdded(:final conversationId):
      print('会话已添加：$conversationId');

    case ConversationStarted(:final conversationId):
      print('会话已开始：$conversationId');

    case ConversationOpened(:final conversationId):
      print('会话已打开：${conversationId ?? '默认'}');

    case MessagesShown(:final conversationId, :final messages):
      print('消息已显示：${messages.length} 条于 $conversationId');

    case SendMessageFailed(:final errorMessage):
      print('发送失败：$errorMessage');

    case FieldValidationFailed(:final errors):
      print('字段验证失败：${errors.join(', ')}');

    case MessagingOpened():
      print('消息 UI 已打开');

    case MessagingClosed():
      print('消息 UI 已关闭');

    case ProactiveMessageDisplayed(:final proactiveMessageId):
      print('主动消息已显示：$proactiveMessageId');

    case ProactiveMessageClicked(:final proactiveMessageId):
      print('主动消息已点击：$proactiveMessageId');

    case ConversationWithAgentRequested(:final conversationId):
      print('已请求客服：$conversationId');

    case ConversationWithAgentAssigned(:final conversationId):
      print('已分配客服：$conversationId');

    case ConversationServedByAgent(:final conversationId, :final agentId):
      print('客服服务中：$agentId 于 $conversationId');

    case NewConversationButtonClicked():
      print('已点击新会话按钮');

    case PostbackButtonClicked(:final actionName):
      print('已点击 Postback：$actionName');

    case ArticleClicked(:final articleUrl):
      print('已点击文章：$articleUrl');

    case ArticleBrowserClicked(:final articleUrl):
      print('已在浏览器中打开文章：$articleUrl');

    case ConversationExtensionOpened(:final extensionUrl):
      print('扩展功能已打开：$extensionUrl');

    case ConversationExtensionDisplayed(:final extensionUrl):
      print('扩展功能已显示：$extensionUrl');

    case NotificationDisplayed(:final conversationId):
      print('通知已显示：$conversationId');

    case NotificationOpened(:final conversationId):
      print('通知已打开：$conversationId');
  }
});

// 开始监听事件
await ZendeskMessaging.listenUnreadMessages();
```

### 可用事件

| 事件 | 说明 |
|------|------|
| `UnreadMessageCountChanged` | 未读消息数量变更 |
| `AuthenticationFailed` | 身份验证失败 |
| `ConnectionStatusChanged` | 连接状态变更 |
| `ConversationAdded` | 新会话已创建 |
| `ConversationStarted` | 会话已开始 |
| `ConversationOpened` | 会话已打开 |
| `MessagesShown` | 消息已渲染 |
| `SendMessageFailed` | 消息发送失败 |
| `FieldValidationFailed` | 字段验证失败 |
| `MessagingOpened` | 消息 UI 已打开 |
| `MessagingClosed` | 消息 UI 已关闭 |
| `ProactiveMessageDisplayed` | 主动消息已显示 |
| `ProactiveMessageClicked` | 主动消息已点击 |
| `ConversationWithAgentRequested` | 用户请求客服 |
| `ConversationWithAgentAssigned` | 客服已分配 |
| `ConversationServedByAgent` | 客服服务中 |
| `NewConversationButtonClicked` | 已点击新会话 |
| `PostbackButtonClicked` | 已点击 Postback 按钮 |
| `ArticleClicked` | 已点击文章 |
| `ArticleBrowserClicked` | 已在浏览器中打开文章 |
| `ConversationExtensionOpened` | 扩展功能已打开 |
| `ConversationExtensionDisplayed` | 扩展功能已显示 |
| `NotificationDisplayed` | 推送通知已显示 |
| `NotificationOpened` | 推送通知已打开 |

## 未读消息数量

```dart
// 获取当前数量
final count = await ZendeskMessaging.getUnreadMessageCount();

// 获取特定会话的数量
final convCount = await ZendeskMessaging.getUnreadMessageCountForConversation('conv_id');

// 监听数量变更（旧版 API）
ZendeskMessaging.unreadMessagesCountStream.listen((count) {
  print('未读：$count');
});
```

## 会话标签和字段

```dart
// 设置标签（用户发送消息时应用）
await ZendeskMessaging.setConversationTags(['vip', 'mobile', 'flutter']);

// 清除标签
await ZendeskMessaging.clearConversationTags();

// 设置自定义字段
await ZendeskMessaging.setConversationFields({
  'app_version': '3.0.0',
  'platform': 'flutter',
  'user_tier': 'premium',
});

// 清除字段
await ZendeskMessaging.clearConversationFields();
```

## 连接状态

```dart
final status = await ZendeskMessaging.getConnectionStatus();

// 处理不同的连接状态
final color = switch (status) {
  ZendeskConnectionStatus.connected ||
  ZendeskConnectionStatus.connectedRealtime => Colors.green,
  ZendeskConnectionStatus.connectingRealtime => Colors.orange,
  ZendeskConnectionStatus.disconnected => Colors.red,
  ZendeskConnectionStatus.unknown => Colors.grey,
};
```

## 推送通知

启用推送通知，在应用程序处于后台或已关闭时通知用户有新消息。

### 要求

| 平台 | 要求 |
|------|------|
| Android | Firebase Cloud Messaging (FCM) 配置 |
| iOS | APNs 证书已上传至 Zendesk Admin Center |
| 两者均需 | 真实设备（模拟器不支持推送） |

### 配置

#### Android

1. 将 Firebase 添加到您的 Android 应用（[Firebase 配置指南](https://firebase.google.com/docs/android/setup)）
2. 在 `pubspec.yaml` 中添加 `firebase_messaging`：
   ```yaml
   dependencies:
     firebase_messaging: ^15.0.0
   ```
3. 从 Firebase Console 获取 FCM Server Key
4. 将密钥上传至 Zendesk Admin Center > Channels > Messaging > Android > Notifications

#### iOS

1. 在 Apple Developer Portal 创建 APNs 证书
2. 从 Keychain Access 导出为 `.p12` 文件
3. 上传至 Zendesk Admin Center > Channels > Messaging > iOS > Notifications
4. 在 Xcode 中添加 Push Notifications capability

### 使用方法

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

Future<void> setupPushNotifications() async {
  final messaging = FirebaseMessaging.instance;

  // 请求权限
  await messaging.requestPermission();

  // 获取并注册 token
  final token = await messaging.getToken();
  if (token != null) {
    await ZendeskMessaging.updatePushNotificationToken(token);
  }

  // 监听 token 刷新
  messaging.onTokenRefresh.listen((token) {
    ZendeskMessaging.updatePushNotificationToken(token);
  });

  // 处理前台通知
  FirebaseMessaging.onMessage.listen((message) async {
    final responsibility = await ZendeskMessaging.shouldBeDisplayed(message.data);
    switch (responsibility) {
      case ZendeskPushResponsibility.messagingShouldDisplay:
        await ZendeskMessaging.handleNotification(message.data);
      case ZendeskPushResponsibility.notFromMessaging:
        // 处理您自己的通知
        break;
      default:
        break;
    }
  });

  // 处理通知点击（应用在后台）
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    await ZendeskMessaging.handleNotificationTap(message.data);
  });
}
```

### 推送通知 API

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `updatePushNotificationToken(token)` | `Future<void>` | 向 Zendesk 注册 FCM/APNs token |
| `shouldBeDisplayed(data)` | `Future<ZendeskPushResponsibility>` | 检查通知是否来自 Zendesk |
| `handleNotification(data)` | `Future<bool>` | 显示通知 |
| `handleNotificationTap(data)` | `Future<void>` | 处理通知点击 |

### ZendeskPushResponsibility

| 值 | 说明 |
|----|------|
| `messagingShouldDisplay` | Zendesk 通知，SDK 可显示 |
| `messagingShouldNotDisplay` | Zendesk 通知，但不应显示（例如用户正在查看该会话） |
| `notFromMessaging` | 非 Zendesk 通知，请自行处理 |
| `unknown` | 无法判断 |

## SDK 生命周期

```dart
// 检查 SDK 是否已初始化
final isInit = await ZendeskMessaging.isInitialized();

// 使 SDK 实例失效（清理）
await ZendeskMessaging.invalidate();
// 失效后，您必须再次调用 initialize() 才能使用 SDK
```

## API 参考

### ZendeskMessaging

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `initialize(androidChannelKey, iosChannelKey)` | `Future<void>` | 初始化 SDK |
| `isInitialized()` | `Future<bool>` | 检查 SDK 是否已初始化 |
| `invalidate()` | `Future<void>` | 使 SDK 实例失效 |
| `show()` | `Future<void>` | 显示消息 UI |
| `showConversation(id)` | `Future<void>` | 显示特定会话 |
| `showConversationList()` | `Future<void>` | 显示会话列表 |
| `startNewConversation()` | `Future<void>` | 开始新会话 |
| `loginUser(jwt)` | `Future<ZendeskLoginResponse>` | 使用 JWT 登录 |
| `logoutUser()` | `Future<void>` | 登出当前用户 |
| `isLoggedIn()` | `Future<bool>` | 检查登录状态 |
| `getCurrentUser()` | `Future<ZendeskUser?>` | 获取当前用户信息 |
| `getUnreadMessageCount()` | `Future<int>` | 获取总未读数量 |
| `getUnreadMessageCountForConversation(id)` | `Future<int>` | 获取会话的未读数量 |
| `listenUnreadMessages()` | `Future<void>` | 开始监听事件 |
| `setConversationTags(tags)` | `Future<void>` | 设置会话标签 |
| `clearConversationTags()` | `Future<void>` | 清除会话标签 |
| `setConversationFields(fields)` | `Future<void>` | 设置自定义字段 |
| `clearConversationFields()` | `Future<void>` | 清除自定义字段 |
| `getConnectionStatus()` | `Future<ZendeskConnectionStatus>` | 获取连接状态 |
| `updatePushNotificationToken(token)` | `Future<void>` | 注册推送 token |
| `shouldBeDisplayed(data)` | `Future<ZendeskPushResponsibility>` | 检查通知来源 |
| `handleNotification(data)` | `Future<bool>` | 处理推送通知 |
| `handleNotificationTap(data)` | `Future<void>` | 处理通知点击 |

### Streams

| Stream | 类型 | 说明 |
|--------|------|------|
| `eventStream` | `Stream<ZendeskEvent>` | 所有 Zendesk 事件 |
| `unreadMessagesCountStream` | `Stream<int>` | 未读数量变更（旧版） |

### Models

**ZendeskUser**
```dart
class ZendeskUser {
  String? id;
  String? externalId;
  ZendeskAuthenticationType authenticationType;
}
```

**ZendeskLoginResponse**
```dart
class ZendeskLoginResponse {
  String? id;
  String? externalId;
}
```

**ZendeskMessage**
```dart
class ZendeskMessage {
  String id;
  String conversationId;
  String? authorId;
  String? content;
  DateTime? timestamp;
}
```

### Enums

**ZendeskAuthenticationType**
- `anonymous`
- `jwt`

**ZendeskConnectionStatus**
- `connected`
- `connectedRealtime`
- `connectingRealtime`
- `disconnected`
- `unknown`

**ZendeskPushResponsibility**
- `messagingShouldDisplay`
- `messagingShouldNotDisplay`
- `notFromMessaging`
- `unknown`

## 从 2.x 迁移

### 3.0.0 重大变更

1. **iOS 最低版本 14.0** - 目标为 iOS 12/13 的应用必须升级
2. **需要 Dart 3.6+** - 更新您的 SDK 约束
3. **需要 Flutter 3.24+** - 更新您的 Flutter SDK
4. **新事件 API** - 使用 sealed class 模式进行类型安全的事件处理

### 迁移步骤

1. 更新 `pubspec.yaml`：
```yaml
environment:
  sdk: ^3.6.0
  flutter: ">=3.27.0"
```

2. 更新 iOS Podfile：
```ruby
platform :ios, '14.0'
```

3. 更新事件处理（可选但推荐）：
```dart
// 旧方式（仍可使用）
ZendeskMessaging.unreadMessagesCountStream.listen((count) {
  print('未读：$count');
});

// 新方式（推荐）
ZendeskMessaging.eventStream.listen((event) {
  if (event is UnreadMessageCountChanged) {
    print('未读：${event.totalUnreadCount}');
  }
});
```

## 故障排除

### iOS 构建失败

确保您的 Podfile 有正确的平台版本：
```ruby
platform :ios, '14.0'
```

然后运行：
```bash
cd ios && pod install --repo-update
```

### Android 构建失败

确保已添加 Zendesk Maven 仓库：
```gradle
maven { url 'https://zendesk.jfrog.io/artifactory/repo' }
```

### 未收到事件

确保在初始化后调用 `listenUnreadMessages()`：
```dart
await ZendeskMessaging.initialize(...);
await ZendeskMessaging.listenUnreadMessages();
```

## SDK 版本

| 插件 | Android SDK | iOS SDK |
|------|-------------|---------|
| 3.1.0 | 2.36.1 | 2.36.0 |
| 3.0.0 | 2.36.1 | 2.36.0 |
| 2.9.x | 2.26.0 | 2.24.0 |

## 许可证

MIT License - 详见 [LICENSE](LICENSE)。

## 贡献

欢迎贡献！提交 pull request 前请先阅读贡献指南。

## 链接

- [GitHub Repository](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging)
- [Zendesk Android SDK 文档](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/getting_started/)
- [Zendesk iOS SDK 文档](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/ios/getting_started/)
- [移动渠道的 Messaging 使用说明](https://support.zendesk.com/hc/en-us/articles/4408834810394-Working-with-messaging-for-your-mobile-channel)
