# Zendesk Messaging para Flutter

[![pub package](https://img.shields.io/pub/v/zendesk_messaging.svg)](https://pub.dev/packages/zendesk_messaging)
[![CI](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml/badge.svg)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml)
[![coverage](https://img.shields.io/badge/coverage-83%25-brightgreen)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![Zendesk Messaging](https://raw.githubusercontent.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/master/Messaging.png)

[English](README.md) | [繁體中文](README.zh-TW.md) | [简体中文](README.zh-CN.md) | [Español](README.es.md) | Português (Brasil) | [日本語](README.ja.md) | [한국어](README.ko.md)

Um plugin Flutter para integrar o SDK de Mensagens da Zendesk em seus aplicativos móveis. Fornece mensagens de suporte ao cliente no aplicativo com suporte a várias conversas, eventos em tempo real e autenticação JWT.

## Funcionalidades

- Inicializar e exibir a interface de usuário do Zendesk Messaging
- Autenticação de usuário com JWT
- Navegação em múltiplas conversas
- Streaming de eventos em tempo real (24 tipos de eventos)
- Rastreamento da contagem de mensagens não lidas
- Tags de conversa e campos personalizados
- Monitoramento do status da conexão
- Substituição do idioma da interface de mensagens
- Suporte a notificações push (FCM/APNs)

## Requisitos

| Plataforma | Versão Mínima   |
|------------|-----------------|
| iOS        | 14.0            |
| Android    | API 21 (minSdk) |
| Dart       | 3.6.0           |
| Flutter    | 3.27.0          |

## Instalação

Adicione `zendesk_messaging` ao seu `pubspec.yaml`:

```yaml
dependencies:
  zendesk_messaging: <latest_version>
```

### Configuração do Android

Adicione o repositório Maven da Zendesk ao seu arquivo `android/build.gradle` no nível do projeto:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://zendesk.jfrog.io/artifactory/repo' }
    }
}
```

### Configuração do iOS

Atualize seu `ios/Podfile` para o iOS 14.0:

```ruby
platform :ios, '14.0'
```

Em seguida, execute:

```bash
cd ios && pod install
```

## Guia Rápido

### Obtendo as Chaves do Canal

Antes de inicializar o SDK, você precisa obter suas chaves de canal do Android e iOS no Centro de Administração da Zendesk:

1. Vá para **Centro de Administração** > **Canais** > **Mensagens e redes sociais** > **Mensagens**
2. Passe o mouse sobre a marca que deseja configurar e clique no **ícone de opções**
3. Clique em **Editar** e navegue até a seção **Instalação**
4. Em **ID do canal**, clique em **Copiar** para copiar a chave para a área de transferência
5. Use esta chave para a inicialização do Android e do iOS

> **Nota:** O mesmo ID de Canal é usado para ambas as plataformas. Você pode criar canais separados para Android e iOS, se necessário.

### Inicializar

```dart
import 'package:zendesk_messaging/zendesk_messaging.dart';

// Inicialize o SDK (chame uma vez na inicialização do aplicativo)
await ZendeskMessaging.initialize(
  androidChannelKey: '<SUA_CHAVE_DE_CANAL_ANDROID>',
  iosChannelKey: '<SUA_CHAVE_DE_CANAL_IOS>',
);
```

### Exibir a Interface de Mensagens

```dart
// Exibe a interface de mensagens padrão
await ZendeskMessaging.show();

// Exibe uma conversa específica (requer multi-conversa ativada)
await ZendeskMessaging.showConversation('id_da_conversa');

// Exibe a lista de conversas
await ZendeskMessaging.showConversationList();

// Inicia uma nova conversa
await ZendeskMessaging.startNewConversation();
```

### Autenticação de Usuário

```dart
// Fazer login com JWT
try {
  final response = await ZendeskMessaging.loginUser(jwt: '<SEU_TOKEN_JWT>');
  print('Login realizado: ${response.id}');
} catch (e) {
  print('Falha no login: $e');
}

// Verificar status do login
final isLoggedIn = await ZendeskMessaging.isLoggedIn();

// Obter usuário atual
final user = await ZendeskMessaging.getCurrentUser();
if (user != null) {
  print('ID do usuário: ${user.id}');
  print('ID externo: ${user.externalId}');
  print('Tipo de autenticação: ${user.authenticationType.name}');
}

// Fazer logout
await ZendeskMessaging.logoutUser();
```

## Manipulação de Eventos

O SDK fornece um fluxo de eventos unificado para todos os eventos da Zendesk. Use o pattern matching do Dart 3 para lidar com tipos de eventos específicos:

```dart
ZendeskMessaging.eventStream.listen((event) {
  switch (event) {
    case UnreadMessageCountChanged(:final totalUnreadCount, :final conversationId):
      print('Não lidas: $totalUnreadCount${conversationId != null ? ' (conversa: $conversationId)' : ''}');

    case AuthenticationFailed(:final errorMessage, :final isJwtExpired):
      print('Falha na autenticação: $errorMessage (JWT expirado: $isJwtExpired)');
      if (isJwtExpired) {
        // Atualizar token JWT
      }

    case ConnectionStatusChanged(:final status):
      print('Conexão: ${status.name}');

    // ... manipule outros eventos aqui
  }
});

// Comece a ouvir os eventos
await ZendeskMessaging.listenUnreadMessages();
```

### Eventos Disponíveis

| Evento | Descrição |
|--------|-------------|
| `UnreadMessageCountChanged` | Contagem de mensagens não lidas alterada |
| `AuthenticationFailed` | Falha na autenticação |
| `ConnectionStatusChanged` | Status da conexão alterado |
| ... | ... |

## Contagem de Mensagens Não Lidas

```dart
// Obter contagem atual
final count = await ZendeskMessaging.getUnreadMessageCount();

// Ouvir alterações na contagem (API legada)
ZendeskMessaging.unreadMessagesCountStream.listen((count) {
  print('Não lidas: $count');
});
```

## Tags e Campos de Conversa

```dart
// Definir tags (aplicadas quando o usuário envia uma mensagem)
await ZendeskMessaging.setConversationTags(['vip', 'mobile', 'flutter']);

// Limpar tags
await ZendeskMessaging.clearConversationTags();

// Definir campos personalizados
await ZendeskMessaging.setConversationFields({
  'app_version': '3.0.0',
  'platform': 'flutter',
});

// Limpar campos
await ZendeskMessaging.clearConversationFields();
```

## Idioma

Substitui o idioma do sistema do dispositivo para que a interface do Zendesk Messaging corresponda ao idioma do seu aplicativo. O SDK do Zendesk inclui [33 idiomas](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/localization/).

```dart
// Melhor opção: defina o idioma antes de inicializar
await ZendeskMessaging.setLocale('es');
await ZendeskMessaging.initialize(
  androidChannelKey: '<YOUR_ANDROID_CHANNEL_KEY>',
  iosChannelKey: '<YOUR_IOS_CHANNEL_KEY>',
);

// Android: também é possível trocar em tempo de execução antes de show()
await ZendeskMessaging.setLocale('ja');
await ZendeskMessaging.show();

// iOS: aplicado na próxima abertura do app
await ZendeskMessaging.setLocale('fr');
// No iOS, invalidate() + initialize() não recarrega o idioma.
```

**Detalhes por plataforma:**
- **Android**: Define `Locale.setDefault()` e atualiza a configuração de recursos do aplicativo/atividade. O SDK resolve os textos da interface pelo sistema de recursos do Android, portanto surte efeito quando o SDK abre a atividade de mensagens. Pode ser alterado em tempo de execução.
- **iOS**: Define a preferência de usuário `AppleLanguages`, que controla qual pacote de localização o SDK carrega. O iOS só lê esse valor quando o app é aberto, então o novo idioma é aplicado na **próxima abertura do app**. Chamar `invalidate()` e depois `initialize()` não o troca em tempo de execução ([#105](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/issues/105)). O valor fica salvo no dispositivo e também define o idioma que o iOS usa para os recursos localizados do seu próprio app.

## Notificações Push

```dart
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

// Registra o token de push correto de acordo com a plataforma
// - Android: token FCM via getToken()
// - iOS: token de dispositivo APNs via getAPNSToken()
//   (o SDK iOS do Zendesk exige o token APNs, NÃO o token FCM)
final messaging = FirebaseMessaging.instance;
final token = Platform.isIOS
    ? await messaging.getAPNSToken()
    : await messaging.getToken();
if (token != null) {
  await ZendeskMessaging.updatePushNotificationToken(token);
}

// Lidar com notificações em primeiro plano
FirebaseMessaging.onMessage.listen((message) async {
  final responsibility = await ZendeskMessaging.shouldBeDisplayed(message.data);
  if (responsibility == ZendeskPushResponsibility.messagingShouldDisplay) {
    await ZendeskMessaging.handleNotification(message.data);
  }
});
```

> **Importante (iOS):** O SDK iOS do Zendesk usa APNs diretamente para notificações push, não FCM. Você deve passar o token de dispositivo APNs via `getAPNSToken()`, não o token de registro FCM de `getToken()`. Usar o tipo de token errado fará as notificações falharem silenciosamente.

## Referência da API

### ZendeskMessaging

| Método | Retorna | Descrição |
|--------|---------|-------------|
| `initialize(...)` | `Future<void>` | Inicializa o SDK |
| `show()` | `Future<void>` | Exibe a interface de mensagens |
| `loginUser(jwt)` | `Future<ZendeskLoginResponse>` | Faz login com JWT |
| `logoutUser()` | `Future<void>` | Faz logout do usuário |
| `setLocale(locale)` | `Future<void>` | Define o idioma da interface de mensagens |
| ... | ... | ... |

## Licença

Licença MIT - veja [LICENSE](LICENSE) para detalhes.
