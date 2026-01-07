# Flutter용 Zendesk 메시징

[![pub package](https://img.shields.io/pub/v/zendesk_messaging.svg)](https://pub.dev/packages/zendesk_messaging)
[![CI](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml/badge.svg)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml)
[![coverage](https://img.shields.io/badge/coverage-83%25-brightgreen)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![Zendesk Messaging](https://raw.githubusercontent.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/master/Messaging.png)

[English](README.md) | [繁體中文](README.zh-TW.md) | [简体中文](README.zh-CN.md) | [Español](README.es.md) | [Português (Brasil)](README.pt-BR.md) | [日本語](README.ja.md) | 한국어

Zendesk 메시징 SDK를 모바일 애플리케이션에 통합하기 위한 Flutter 플러그인입니다. 다중 대화 지원, 실시간 이벤트 및 JWT 인증을 통한 인앱 고객 지원 메시징을 제공합니다.

## 기능

- Zendesk 메시징 UI 초기화 및 표시
- JWT 사용자 인증
- 다중 대화 탐색
- 실시간 이벤트 스트리밍 (24개 이벤트 유형)
- 읽지 않은 메시지 수 추적
- 대화 태그 및 사용자 정의 필드
- 연결 상태 모니터링
- 푸시 알림 지원 (FCM/APNs)

## 요구 사항

| 플랫폼 | 최소 버전 |
|---|---|
| iOS | 14.0 |
| Android | API 21 (minSdk) |
| Dart | 3.6.0 |
| Flutter | 3.27.0 |

## 설치

`pubspec.yaml`에 `zendesk_messaging`을 추가합니다:

```yaml
dependencies:
  zendesk_messaging: <latest_version>
```

### Android 설정

프로젝트 수준의 `android/build.gradle`에 Zendesk Maven 저장소를 추가합니다:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://zendesk.jfrog.io/artifactory/repo' }
    }
}
```

### iOS 설정

`ios/Podfile`을 업데이트하여 iOS 14.0을 타겟으로 합니다:

```ruby
platform :ios, '14.0'
```

그런 다음 실행합니다:

```bash
cd ios && pod install
```

## 빠른 시작

### 채널 키 얻기

SDK를 초기화하기 전에 Zendesk 관리 센터에서 Android 및 iOS 채널 키를 얻어야 합니다:

1. **관리 센터** > **채널** > **메시징 및 소셜** > **메시징**으로 이동합니다.
2. 구성하려는 브랜 위로 마우스를 가져가 **옵션 아이콘**을 클릭합니다.
3. **편집**을 클릭하고 **설치** 섹션으로 이동합니다.
4. **채널 ID** 아래에서 **복사**를 클릭하여 키를 클립보드에 복사합니다.
5. 이 키를 Android 및 iOS 초기화 모두에 사용합니다.

> **참고:** 동일한 채널 ID가 두 플랫폼 모두에 사용됩니다. 필요한 경우 Android와 iOS에 대해 별도의 채널을 만들 수 있습니다.

### 초기화

```dart
import 'package:zendesk_messaging/zendesk_messaging.dart';

// SDK 초기화 (앱 시작 시 한 번 호출)
await ZendeskMessaging.initialize(
  androidChannelKey: '<YOUR_ANDROID_CHANNEL_KEY>',
  iosChannelKey: '<YOUR_IOS_CHANNEL_KEY>',
);
```

### 메시징 UI 표시

```dart
// 기본 메시징 인터페이스 표시
await ZendeskMessaging.show();

// 특정 대화 표시 (다중 대화가 활성화되어 있어야 함)
await ZendeskMessaging.showConversation('conversation_id');

// 대화 목록 표시
await ZendeskMessaging.showConversationList();

// 새 대화 시작
await ZendeskMessaging.startNewConversation();
```

### 사용자 인증

```dart
// JWT로 로그인
try {
  final response = await ZendeskMessaging.loginUser(jwt: '<YOUR_JWT_TOKEN>');
  print('로그인 성공: ${response.id}');
} catch (e) {
  print('로그인 실패: $e');
}

// 로그인 상태 확인
final isLoggedIn = await ZendeskMessaging.isLoggedIn();

// 현재 사용자 가져오기
final user = await ZendeskMessaging.getCurrentUser();
if (user != null) {
  print('사용자 ID: ${user.id}');
  print('외부 ID: ${user.externalId}');
  print('인증 유형: ${user.authenticationType.name}');
}

// 로그아웃
await ZendeskMessaging.logoutUser();
```

## 이벤트 처리

SDK는 모든 Zendesk 이벤트에 대해 통합된 이벤트 스트림을 제공합니다. Dart 3의 패턴 매칭을 사용하여 특정 이벤트 유형을 처리합니다:

```dart
ZendeskMessaging.eventStream.listen((event) {
  switch (event) {
    case UnreadMessageCountChanged(:final totalUnreadCount, :final conversationId):
      print('읽지 않음: $totalUnreadCount${conversationId != null ? ' (대화: $conversationId)' : ''}');

    case AuthenticationFailed(:final errorMessage, :final isJwtExpired):
      print('인증 실패: $errorMessage (JWT 만료됨: $isJwtExpired)');
      if (isJwtExpired) {
        // JWT 토큰 새로고침
      }

    case ConnectionStatusChanged(:final status):
      print('연결 상태: ${status.name}');

    // ... 다른 이벤트를 여기서 처리 ...
  }
});

// 이벤트 수신 시작
await ZendeskMessaging.listenUnreadMessages();
```

## 푸시 알림

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

// 푸시 토큰 등록
final token = await FirebaseMessaging.instance.getToken();
if (token != null) {
  await ZendeskMessaging.updatePushNotificationToken(token);
}

// 포그라운드 알림 처리
FirebaseMessaging.onMessage.listen((message) async {
  final responsibility = await ZendeskMessaging.shouldBeDisplayed(message.data);
  if (responsibility == ZendeskPushResponsibility.messagingShouldDisplay) {
    await ZendeskMessaging.handleNotification(message.data);
  }
});
```

## API 참조

### ZendeskMessaging

| 메소드 | 반환값 | 설명 |
|---|---|---|
| `initialize(...)` | `Future<void>` | SDK를 초기화합니다 |
| `show()` | `Future<void>` | 메시징 UI를 표시합니다 |
| `loginUser(jwt)` | `Future<ZendeskLoginResponse>` | JWT로 로그인합니다 |
| `logoutUser()` | `Future<void>` | 사용자를 로그아웃합니다 |
| ... | ... | ... |

## 라이선스

MIT 라이선스 - 자세한 내용은 [LICENSE](LICENSE)를 참조하십시오.
