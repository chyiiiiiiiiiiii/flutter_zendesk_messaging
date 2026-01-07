# Zendesk Messaging for Flutter

[![pub package](https://img.shields.io/pub/v/zendesk_messaging.svg)](https://pub.dev/packages/zendesk_messaging)
[![CI](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml/badge.svg)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml)
[![coverage](https://img.shields.io/badge/coverage-83%25-brightgreen)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![Zendesk Messaging](Messaging.png)

[English](README.md) | 繁體中文

Flutter 套件，用於將 Zendesk Messaging SDK 整合至您的行動應用程式。提供應用程式內客服訊息功能，支援多對話、即時事件與 JWT 身份驗證。

## 功能特色

- 初始化並顯示 Zendesk Messaging UI
- JWT 使用者身份驗證
- 多對話導覽
- 即時事件串流（24 種事件類型）
- 未讀訊息數量追蹤
- 對話標籤與自訂欄位
- 連線狀態監控
- 推播通知支援（FCM/APNs）

## 系統需求

| 平台 | 最低版本 |
|------|----------|
| iOS | 14.0 |
| Android | API 21 (minSdk) |
| Dart | 3.6.0 |
| Flutter | 3.27.0 |

## 安裝

在 `pubspec.yaml` 中加入 `zendesk_messaging`：

```yaml
dependencies:
  zendesk_messaging: ^3.1.0
```

### Android 設定

在專案層級的 `android/build.gradle` 中加入 Zendesk Maven 儲存庫：

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://zendesk.jfrog.io/artifactory/repo' }
    }
}
```

### iOS 設定

更新 `ios/Podfile` 以指定 iOS 14.0：

```ruby
platform :ios, '14.0'
```

然後執行：

```bash
cd ios && pod install
```

## 快速開始

### 取得 Channel Keys

在初始化 SDK 之前，您需要從 Zendesk Admin Center 取得 Android 和 iOS 的 channel keys：

1. 前往 **Admin Center** > **Channels** > **Messaging and social** > **Messaging**
2. 將滑鼠移至要設定的品牌上，點擊**選項圖示**
3. 點擊 **Edit** 並導覽至 **Installation** 區段
4. 在 **Channel ID** 下方，點擊 **Copy** 複製金鑰至剪貼簿
5. 使用此金鑰進行 Android 和 iOS 初始化

> **注意：** 兩個平台使用相同的 Channel ID。如有需要，您可以為 Android 和 iOS 建立個別的頻道。

### 初始化

```dart
import 'package:zendesk_messaging/zendesk_messaging.dart';

// 初始化 SDK（在應用程式啟動時呼叫一次）
await ZendeskMessaging.initialize(
  androidChannelKey: '<YOUR_ANDROID_CHANNEL_KEY>',
  iosChannelKey: '<YOUR_IOS_CHANNEL_KEY>',
);
```

### 顯示訊息 UI

```dart
// 顯示預設訊息介面
await ZendeskMessaging.show();

// 顯示特定對話（需啟用多對話功能）
await ZendeskMessaging.showConversation('conversation_id');

// 顯示對話列表
await ZendeskMessaging.showConversationList();

// 開始新對話
await ZendeskMessaging.startNewConversation();
```

### 使用者身份驗證

```dart
// 使用 JWT 登入
try {
  final response = await ZendeskMessaging.loginUser(jwt: '<YOUR_JWT_TOKEN>');
  print('已登入：${response.id}');
} catch (e) {
  print('登入失敗：$e');
}

// 檢查登入狀態
final isLoggedIn = await ZendeskMessaging.isLoggedIn();

// 取得目前使用者
final user = await ZendeskMessaging.getCurrentUser();
if (user != null) {
  print('使用者 ID：${user.id}');
  print('外部 ID：${user.externalId}');
  print('驗證類型：${user.authenticationType.name}');
}

// 登出
await ZendeskMessaging.logoutUser();
```

## 事件處理

SDK 提供統一的事件串流，涵蓋所有 Zendesk 事件。使用 Dart 3 模式匹配來處理特定事件類型：

```dart
ZendeskMessaging.eventStream.listen((event) {
  switch (event) {
    case UnreadMessageCountChanged(:final totalUnreadCount, :final conversationId):
      print('未讀：$totalUnreadCount${conversationId != null ? '（對話：$conversationId）' : ''}');

    case AuthenticationFailed(:final errorMessage, :final isJwtExpired):
      print('驗證失敗：$errorMessage（JWT 已過期：$isJwtExpired）');
      if (isJwtExpired) {
        // 重新整理 JWT token
      }

    case ConnectionStatusChanged(:final status):
      print('連線狀態：${status.name}');

    case ConversationAdded(:final conversationId):
      print('對話已新增：$conversationId');

    case ConversationStarted(:final conversationId):
      print('對話已開始：$conversationId');

    case ConversationOpened(:final conversationId):
      print('對話已開啟：${conversationId ?? '預設'}');

    case MessagesShown(:final conversationId, :final messages):
      print('訊息已顯示：${messages.length} 則於 $conversationId');

    case SendMessageFailed(:final errorMessage):
      print('傳送失敗：$errorMessage');

    case FieldValidationFailed(:final errors):
      print('欄位驗證失敗：${errors.join(', ')}');

    case MessagingOpened():
      print('訊息 UI 已開啟');

    case MessagingClosed():
      print('訊息 UI 已關閉');

    case ProactiveMessageDisplayed(:final proactiveMessageId):
      print('主動訊息已顯示：$proactiveMessageId');

    case ProactiveMessageClicked(:final proactiveMessageId):
      print('主動訊息已點擊：$proactiveMessageId');

    case ConversationWithAgentRequested(:final conversationId):
      print('已請求客服：$conversationId');

    case ConversationWithAgentAssigned(:final conversationId):
      print('已指派客服：$conversationId');

    case ConversationServedByAgent(:final conversationId, :final agentId):
      print('客服服務中：$agentId 於 $conversationId');

    case NewConversationButtonClicked():
      print('已點擊新對話按鈕');

    case PostbackButtonClicked(:final actionName):
      print('已點擊 Postback：$actionName');

    case ArticleClicked(:final articleUrl):
      print('已點擊文章：$articleUrl');

    case ArticleBrowserClicked(:final articleUrl):
      print('已在瀏覽器中開啟文章：$articleUrl');

    case ConversationExtensionOpened(:final extensionUrl):
      print('擴充功能已開啟：$extensionUrl');

    case ConversationExtensionDisplayed(:final extensionUrl):
      print('擴充功能已顯示：$extensionUrl');

    case NotificationDisplayed(:final conversationId):
      print('通知已顯示：$conversationId');

    case NotificationOpened(:final conversationId):
      print('通知已開啟：$conversationId');
  }
});

// 開始監聽事件
await ZendeskMessaging.listenUnreadMessages();
```

### 可用事件

| 事件 | 說明 |
|------|------|
| `UnreadMessageCountChanged` | 未讀訊息數量變更 |
| `AuthenticationFailed` | 身份驗證失敗 |
| `ConnectionStatusChanged` | 連線狀態變更 |
| `ConversationAdded` | 新對話已建立 |
| `ConversationStarted` | 對話已開始 |
| `ConversationOpened` | 對話已開啟 |
| `MessagesShown` | 訊息已渲染 |
| `SendMessageFailed` | 訊息傳送失敗 |
| `FieldValidationFailed` | 欄位驗證失敗 |
| `MessagingOpened` | 訊息 UI 已開啟 |
| `MessagingClosed` | 訊息 UI 已關閉 |
| `ProactiveMessageDisplayed` | 主動訊息已顯示 |
| `ProactiveMessageClicked` | 主動訊息已點擊 |
| `ConversationWithAgentRequested` | 使用者請求客服 |
| `ConversationWithAgentAssigned` | 客服已指派 |
| `ConversationServedByAgent` | 客服服務中 |
| `NewConversationButtonClicked` | 已點擊新對話 |
| `PostbackButtonClicked` | 已點擊 Postback 按鈕 |
| `ArticleClicked` | 已點擊文章 |
| `ArticleBrowserClicked` | 已在瀏覽器中開啟文章 |
| `ConversationExtensionOpened` | 擴充功能已開啟 |
| `ConversationExtensionDisplayed` | 擴充功能已顯示 |
| `NotificationDisplayed` | 推播通知已顯示 |
| `NotificationOpened` | 推播通知已開啟 |

## 未讀訊息數量

```dart
// 取得目前數量
final count = await ZendeskMessaging.getUnreadMessageCount();

// 取得特定對話的數量
final convCount = await ZendeskMessaging.getUnreadMessageCountForConversation('conv_id');

// 監聽數量變更（舊版 API）
ZendeskMessaging.unreadMessagesCountStream.listen((count) {
  print('未讀：$count');
});
```

## 對話標籤與欄位

```dart
// 設定標籤（使用者傳送訊息時套用）
await ZendeskMessaging.setConversationTags(['vip', 'mobile', 'flutter']);

// 清除標籤
await ZendeskMessaging.clearConversationTags();

// 設定自訂欄位
await ZendeskMessaging.setConversationFields({
  'app_version': '3.0.0',
  'platform': 'flutter',
  'user_tier': 'premium',
});

// 清除欄位
await ZendeskMessaging.clearConversationFields();
```

## 連線狀態

```dart
final status = await ZendeskMessaging.getConnectionStatus();

// 處理不同的連線狀態
final color = switch (status) {
  ZendeskConnectionStatus.connected ||
  ZendeskConnectionStatus.connectedRealtime => Colors.green,
  ZendeskConnectionStatus.connectingRealtime => Colors.orange,
  ZendeskConnectionStatus.disconnected => Colors.red,
  ZendeskConnectionStatus.unknown => Colors.grey,
};
```

## 推播通知

啟用推播通知，在應用程式於背景或已關閉時通知使用者有新訊息。

### 需求

| 平台 | 需求 |
|------|------|
| Android | Firebase Cloud Messaging (FCM) 設定 |
| iOS | APNs 憑證已上傳至 Zendesk Admin Center |
| 兩者皆需 | 實體裝置（模擬器不支援推播） |

### 設定

#### Android

1. 將 Firebase 加入您的 Android 應用程式（[Firebase 設定指南](https://firebase.google.com/docs/android/setup)）
2. 在 `pubspec.yaml` 中加入 `firebase_messaging`：
   ```yaml
   dependencies:
     firebase_messaging: ^15.0.0
   ```
3. 從 Firebase Console 取得 FCM Server Key
4. 將金鑰上傳至 Zendesk Admin Center > Channels > Messaging > Android > Notifications

#### iOS

1. 在 Apple Developer Portal 建立 APNs 憑證
2. 從 Keychain Access 匯出為 `.p12` 檔案
3. 上傳至 Zendesk Admin Center > Channels > Messaging > iOS > Notifications
4. 在 Xcode 中新增 Push Notifications capability

### 使用方式

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

Future<void> setupPushNotifications() async {
  final messaging = FirebaseMessaging.instance;

  // 請求權限
  await messaging.requestPermission();

  // 取得並註冊 token
  final token = await messaging.getToken();
  if (token != null) {
    await ZendeskMessaging.updatePushNotificationToken(token);
  }

  // 監聽 token 重新整理
  messaging.onTokenRefresh.listen((token) {
    ZendeskMessaging.updatePushNotificationToken(token);
  });

  // 處理前景通知
  FirebaseMessaging.onMessage.listen((message) async {
    final responsibility = await ZendeskMessaging.shouldBeDisplayed(message.data);
    switch (responsibility) {
      case ZendeskPushResponsibility.messagingShouldDisplay:
        await ZendeskMessaging.handleNotification(message.data);
      case ZendeskPushResponsibility.notFromMessaging:
        // 處理您自己的通知
        break;
      default:
        break;
    }
  });

  // 處理通知點擊（應用程式在背景）
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    await ZendeskMessaging.handleNotificationTap(message.data);
  });
}
```

### 推播通知 API

| 方法 | 回傳值 | 說明 |
|------|--------|------|
| `updatePushNotificationToken(token)` | `Future<void>` | 向 Zendesk 註冊 FCM/APNs token |
| `shouldBeDisplayed(data)` | `Future<ZendeskPushResponsibility>` | 檢查通知是否來自 Zendesk |
| `handleNotification(data)` | `Future<bool>` | 顯示通知 |
| `handleNotificationTap(data)` | `Future<void>` | 處理通知點擊 |

### ZendeskPushResponsibility

| 值 | 說明 |
|----|------|
| `messagingShouldDisplay` | Zendesk 通知，SDK 可顯示 |
| `messagingShouldNotDisplay` | Zendesk 通知，但不應顯示（例如使用者正在檢視該對話） |
| `notFromMessaging` | 非 Zendesk 通知，請自行處理 |
| `unknown` | 無法判斷 |

## SDK 生命週期

```dart
// 檢查 SDK 是否已初始化
final isInit = await ZendeskMessaging.isInitialized();

// 使 SDK 實例失效（清理）
await ZendeskMessaging.invalidate();
// 失效後，您必須再次呼叫 initialize() 才能使用 SDK
```

## API 參考

### ZendeskMessaging

| 方法 | 回傳值 | 說明 |
|------|--------|------|
| `initialize(androidChannelKey, iosChannelKey)` | `Future<void>` | 初始化 SDK |
| `isInitialized()` | `Future<bool>` | 檢查 SDK 是否已初始化 |
| `invalidate()` | `Future<void>` | 使 SDK 實例失效 |
| `show()` | `Future<void>` | 顯示訊息 UI |
| `showConversation(id)` | `Future<void>` | 顯示特定對話 |
| `showConversationList()` | `Future<void>` | 顯示對話列表 |
| `startNewConversation()` | `Future<void>` | 開始新對話 |
| `loginUser(jwt)` | `Future<ZendeskLoginResponse>` | 使用 JWT 登入 |
| `logoutUser()` | `Future<void>` | 登出目前使用者 |
| `isLoggedIn()` | `Future<bool>` | 檢查登入狀態 |
| `getCurrentUser()` | `Future<ZendeskUser?>` | 取得目前使用者資訊 |
| `getUnreadMessageCount()` | `Future<int>` | 取得總未讀數量 |
| `getUnreadMessageCountForConversation(id)` | `Future<int>` | 取得對話的未讀數量 |
| `listenUnreadMessages()` | `Future<void>` | 開始監聽事件 |
| `setConversationTags(tags)` | `Future<void>` | 設定對話標籤 |
| `clearConversationTags()` | `Future<void>` | 清除對話標籤 |
| `setConversationFields(fields)` | `Future<void>` | 設定自訂欄位 |
| `clearConversationFields()` | `Future<void>` | 清除自訂欄位 |
| `getConnectionStatus()` | `Future<ZendeskConnectionStatus>` | 取得連線狀態 |
| `updatePushNotificationToken(token)` | `Future<void>` | 註冊推播 token |
| `shouldBeDisplayed(data)` | `Future<ZendeskPushResponsibility>` | 檢查通知來源 |
| `handleNotification(data)` | `Future<bool>` | 處理推播通知 |
| `handleNotificationTap(data)` | `Future<void>` | 處理通知點擊 |

### Streams

| Stream | 類型 | 說明 |
|--------|------|------|
| `eventStream` | `Stream<ZendeskEvent>` | 所有 Zendesk 事件 |
| `unreadMessagesCountStream` | `Stream<int>` | 未讀數量變更（舊版） |

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

## 從 2.x 遷移

### 3.0.0 重大變更

1. **iOS 最低版本 14.0** - 目標為 iOS 12/13 的應用程式必須升級
2. **需要 Dart 3.6+** - 更新您的 SDK 約束
3. **需要 Flutter 3.24+** - 更新您的 Flutter SDK
4. **新事件 API** - 使用 sealed class 模式進行型別安全的事件處理

### 遷移步驟

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

3. 更新事件處理（選用但建議）：
```dart
// 舊方式（仍可運作）
ZendeskMessaging.unreadMessagesCountStream.listen((count) {
  print('未讀：$count');
});

// 新方式（建議）
ZendeskMessaging.eventStream.listen((event) {
  if (event is UnreadMessageCountChanged) {
    print('未讀：${event.totalUnreadCount}');
  }
});
```

## 疑難排解

### iOS 建置失敗

確保您的 Podfile 有正確的平台版本：
```ruby
platform :ios, '14.0'
```

然後執行：
```bash
cd ios && pod install --repo-update
```

### Android 建置失敗

確保已加入 Zendesk Maven 儲存庫：
```gradle
maven { url 'https://zendesk.jfrog.io/artifactory/repo' }
```

### 未收到事件

確保在初始化後呼叫 `listenUnreadMessages()`：
```dart
await ZendeskMessaging.initialize(...);
await ZendeskMessaging.listenUnreadMessages();
```

## SDK 版本

| 套件 | Android SDK | iOS SDK |
|------|-------------|---------|
| 3.1.0 | 2.36.1 | 2.36.0 |
| 3.0.0 | 2.36.1 | 2.36.0 |
| 2.9.x | 2.26.0 | 2.24.0 |

## 授權條款

MIT License - 詳見 [LICENSE](LICENSE)。

## 貢獻

歡迎貢獻！提交 pull request 前請先閱讀貢獻指南。

## 連結

- [GitHub Repository](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging)
- [Zendesk Android SDK 文件](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/getting_started/)
- [Zendesk iOS SDK 文件](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/ios/getting_started/)
- [行動裝置頻道的 Messaging 使用說明](https://support.zendesk.com/hc/en-us/articles/4408834810394-Working-with-messaging-for-your-mobile-channel)
