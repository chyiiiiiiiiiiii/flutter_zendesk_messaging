# Flutter用Zendesk Messaging

[![pub package](https://img.shields.io/pub/v/zendesk_messaging.svg)](https://pub.dev/packages/zendesk_messaging)
[![CI](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml/badge.svg)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml)
[![coverage](https://img.shields.io/badge/coverage-83%25-brightgreen)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![Zendesk Messaging](https://raw.githubusercontent.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/master/Messaging.png)

[English](README.md) | [繁體中文](README.zh-TW.md) | [简体中文](README.zh-CN.md) | [Español](README.es.md) | [Português (Brasil)](README.pt-BR.md) | 日本語 | [한국어](README.ko.md)

Zendesk Messaging SDKをモバイルアプリケーションに統合するためのFlutterプラグインです。複数会話サポート、リアルタイムイベント、JWT認証を備えたアプリ内カスタマーサポートメッセージングを提供します。

## 機能

- Zendesk Messaging UIの初期化と表示
- JWTユーザー認証
- 複数会話のナビゲーション
- リアルタイムイベントストリーミング（24イベントタイプ）
- 未読メッセージ数の追跡
- 会話タグとカスタムフィールド
- 接続ステータスの監視
- プッシュ通知のサポート（FCM/APNs）

## 要件

| プラットフォーム | 最小バージョン |
|----------------|----------------|
| iOS | 14.0 |
| Android | API 21 (minSdk) |
| Dart | 3.6.0 |
| Flutter | 3.27.0 |

## インストール

`pubspec.yaml`に`zendesk_messaging`を追加します：

```yaml
dependencies:
  zendesk_messaging: <latest_version>
```

### Androidのセットアップ

プロジェクトレベルの`android/build.gradle`にZendesk Mavenリポジトリを追加します：

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://zendesk.jfrog.io/artifactory/repo' }
    }
}
```

### iOSのセットアップ

`ios/Podfile`を更新してiOS 14.0をターゲットにします：

```ruby
platform :ios, '14.0'
```

その後、実行します：

```bash
cd ios && pod install
```

## クイックスタート

### チャンネルキーの取得

SDKを初期化する前に、Zendesk管理センターからAndroidおよびiOSのチャンネルキーを取得する必要があります：

1. **管理センター** > **チャネル** > **メッセージングとソーシャル** > **メッセージング**に移動します
2. 設定したいブランドにカーソルを合わせ、**オプションアイコン**をクリックします
3. **編集**をクリックし、**インストール**セクションに移動します
4. **チャネルID**の下にある**コピー**をクリックしてキーをクリップボードにコピーします
5. このキーをAndroidとiOSの両方の初期化に使用します

> **注意：** 同じチャネルIDが両方のプラットフォームで使用されます。必要に応じて、AndroidとiOS用に別々のチャネルを作成できます。

### 初期化

```dart
import 'package:zendesk_messaging/zendesk_messaging.dart';

// SDKを初期化します（アプリ起動時に一度だけ呼び出します）
await ZendeskMessaging.initialize(
  androidChannelKey: '<YOUR_ANDROID_CHANNEL_KEY>',
  iosChannelKey: '<YOUR_IOS_CHANNEL_KEY>',
);
```

### メッセージングUIの表示

```dart
// デフォルトのメッセージングインターフェースを表示します
await ZendeskMessaging.show();

// 特定の会話を表示します（複数会話が有効になっている必要があります）
await ZendeskMessaging.showConversation('conversation_id');

// 会話リストを表示します
await ZendeskMessaging.showConversationList();

// 新しい会話を開始します
await ZendeskMessaging.startNewConversation();
```

### ユーザー認証

```dart
// JWTでログインします
try {
  final response = await ZendeskMessaging.loginUser(jwt: '<YOUR_JWT_TOKEN>');
  print('ログイン成功: ${response.id}');
} catch (e) {
  print('ログイン失敗: $e');
}

// ログイン状態を確認します
final isLoggedIn = await ZendeskMessaging.isLoggedIn();

// 現在のユーザーを取得します
final user = await ZendeskMessaging.getCurrentUser();
if (user != null) {
  print('ユーザーID: ${user.id}');
  print('外部ID: ${user.externalId}');
  print('認証タイプ: ${user.authenticationType.name}');
}

// ログアウトします
await ZendeskMessaging.logoutUser();
```

## イベント処理

SDKは、すべてのZendeskイベントに対して統一されたイベントストリームを提供します。Dart 3のパターンマッチングを使用して、特定のイベントタイプを処理します：

```dart
ZendeskMessaging.eventStream.listen((event) {
  switch (event) {
    case UnreadMessageCountChanged(:final totalUnreadCount, :final conversationId):
      print('未読: $totalUnreadCount${conversationId != null ? ' (会話: $conversationId)' : ''}');

    case AuthenticationFailed(:final errorMessage, :final isJwtExpired):
      print('認証失敗: $errorMessage (JWT期限切れ: $isJwtExpired)');
      if (isJwtExpired) {
        // JWTトークンを更新
      }

    case ConnectionStatusChanged(:final status):
      print('接続状態: ${status.name}');

    // ... 他のイベントをここで処理 ...
  }
});

// イベントのリスニングを開始します
await ZendeskMessaging.listenUnreadMessages();
```

## プッシュ通知

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

// プッシュトークンを登録します
final token = await FirebaseMessaging.instance.getToken();
if (token != null) {
  await ZendeskMessaging.updatePushNotificationToken(token);
}

// フォアグラウンド通知を処理します
FirebaseMessaging.onMessage.listen((message) async {
  final responsibility = await ZendeskMessaging.shouldBeDisplayed(message.data);
  if (responsibility == ZendeskPushResponsibility.messagingShouldDisplay) {
    await ZendeskMessaging.handleNotification(message.data);
  }
});
```

## APIリファレンス

### ZendeskMessaging

| メソッド | 戻り値 | 説明 |
|---|---|---|
| `initialize(...)` | `Future<void>` | SDKを初期化します |
| `show()` | `Future<void>` | メッセージングUIを表示します |
| `loginUser(jwt)` | `Future<ZendeskLoginResponse>` | JWTでログインします |
| `logoutUser()` | `Future<void>` | ユーザーをログアウトします |
| ... | ... | ... |

## ライセンス

MITライセンス - 詳細は[LICENSE](LICENSE)をご覧ください。
