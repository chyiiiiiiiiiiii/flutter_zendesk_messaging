# Zendesk Messaging para Flutter

[![pub package](https://img.shields.io/pub/v/zendesk_messaging.svg)](https://pub.dev/packages/zendesk_messaging)
[![CI](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml/badge.svg)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml)
[![coverage](https://img.shields.io/badge/coverage-83%25-brightgreen)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![Zendesk Messaging](https://raw.githubusercontent.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/master/Messaging.png)

[English](README.md) | [繁體中文](README.zh-TW.md) | [简体中文](README.zh-CN.md) | Español | [Português (Brasil)](README.pt-BR.md) | [日本語](README.ja.md) | [한국어](README.ko.md)

Un plugin de Flutter para integrar el SDK de Zendesk Messaging en tus aplicaciones móviles. Proporciona mensajería de soporte al cliente en la aplicación con soporte para múltiples conversaciones, eventos en tiempo real y autenticación JWT.

## Características

- Inicializar y mostrar la interfaz de usuario de Zendesk Messaging
- Autenticación de usuario con JWT
- Navegación entre múltiples conversaciones
- Transmisión de eventos en tiempo real (24 tipos de eventos)
- Seguimiento del recuento de mensajes no leídos
- Etiquetas de conversación y campos personalizados
- Monitoreo del estado de la conexión
- Soporte para notificaciones push (FCM/APNs)

## Requisitos

| Plataforma | Versión Mínima |
|------------|-----------------|
| iOS        | 14.0            |
| Android    | API 21 (minSdk) |
| Dart       | 3.6.0           |
| Flutter    | 3.27.0          |

## Instalación

Agrega `zendesk_messaging` a tu `pubspec.yaml`:

```yaml
dependencies:
  zendesk_messaging: ^3.1.0
```

### Configuración de Android

Agrega el repositorio Maven de Zendesk a tu archivo `android/build.gradle` a nivel de proyecto:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://zendesk.jfrog.io/artifactory/repo' }
    }
}
```

### Configuración de iOS

Actualiza tu `ios/Podfile` para apuntar a iOS 14.0:

```ruby
platform :ios, '14.0'
```

Luego ejecuta:

```bash
cd ios && pod install
```

## Inicio Rápido

### Obtener las Claves del Canal

Antes de inicializar el SDK, necesitas obtener tus claves de canal de Android e iOS desde el Centro de Administración de Zendesk:

1. Ve a **Centro de Administración** > **Canales** > **Mensajería y redes sociales** > **Mensajería**
2. Pasa el cursor sobre la marca que deseas configurar y haz clic en el **ícono de opciones**
3. Haz clic en **Editar** y navega a la sección **Instalación**
4. En **ID del canal**, haz clic en **Copiar** para copiar la clave a tu portapapeles
5. Usa esta clave para la inicialización tanto en Android como en iOS

> **Nota:** El mismo ID de canal se usa para ambas plataformas. Puedes crear canales separados para Android e iOS si es necesario.

### Inicializar

```dart
import 'package:zendesk_messaging/zendesk_messaging.dart';

// Inicializa el SDK (llama una vez al iniciar la aplicación)
await ZendeskMessaging.initialize(
  androidChannelKey: '<TU_CLAVE_DE_CANAL_ANDROID>',
  iosChannelKey: '<TU_CLAVE_DE_CANAL_IOS>',
);
```

### Mostrar la Interfaz de Mensajería

```dart
// Muestra la interfaz de mensajería predeterminada
await ZendeskMessaging.show();

// Muestra una conversación específica (requiere tener habilitada la multi-conversación)
await ZendeskMessaging.showConversation('id_de_conversacion');

// Muestra la lista de conversaciones
await ZendeskMessaging.showConversationList();

// Inicia una nueva conversación
await ZendeskMessaging.startNewConversation();
```

### Autenticación de Usuario

```dart
// Iniciar sesión con JWT
try {
  final response = await ZendeskMessaging.loginUser(jwt: '<TU_TOKEN_JWT>');
  print('Sesión iniciada: ${response.id}');
} catch (e) {
  print('Error al iniciar sesión: $e');
}

// Verificar estado de la sesión
final isLoggedIn = await ZendeskMessaging.isLoggedIn();

// Obtener usuario actual
final user = await ZendeskMessaging.getCurrentUser();
if (user != null) {
  print('ID de usuario: ${user.id}');
  print('ID externo: ${user.externalId}');
  print('Tipo de autenticación: ${user.authenticationType.name}');
}

// Cerrar sesión
await ZendeskMessaging.logoutUser();
```

## Manejo de Eventos

El SDK proporciona un flujo de eventos unificado para todos los eventos de Zendesk. Usa el reconocimiento de patrones de Dart 3 para manejar tipos de eventos específicos:

```dart
ZendeskMessaging.eventStream.listen((event) {
  switch (event) {
    case UnreadMessageCountChanged(:final totalUnreadCount, :final conversationId):
      print('No leídos: $totalUnreadCount${conversationId != null ? ' (conversación: $conversationId)' : ''}');

    case AuthenticationFailed(:final errorMessage, :final isJwtExpired):
      print('Fallo de autenticación: $errorMessage (JWT expirado: $isJwtExpired)');
      if (isJwtExpired) {
        // Refrescar token JWT
      }

    case ConnectionStatusChanged(:final status):
      print('Conexión: ${status.name}');

    // ... maneja otros eventos aquí
  }
});

// Comienza a escuchar eventos
await ZendeskMessaging.listenUnreadMessages();
```

### Eventos Disponibles

| Evento | Descripción |
|--------|-------------|
| `UnreadMessageCountChanged` | Cambió el recuento de mensajes no leídos |
| `AuthenticationFailed` | Falló la autenticación |
| `ConnectionStatusChanged` | Cambió el estado de la conexión |
| ... | ... |

## Recuento de Mensajes No Leídos

```dart
// Obtener el recuento actual
final count = await ZendeskMessaging.getUnreadMessageCount();

// Escuchar cambios en el recuento (API heredada)
ZendeskMessaging.unreadMessagesCountStream.listen((count) {
  print('No leídos: $count');
});
```

## Etiquetas y Campos de Conversación

```dart
// Establecer etiquetas (se aplican cuando el usuario envía un mensaje)
await ZendeskMessaging.setConversationTags(['vip', 'mobile', 'flutter']);

// Limpiar etiquetas
await ZendeskMessaging.clearConversationTags();

// Establecer campos personalizados
await ZendeskMessaging.setConversationFields({
  'app_version': '3.0.0',
  'platform': 'flutter',
});

// Limpiar campos
await ZendeskMessaging.clearConversationFields();
```

## Notificaciones Push

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

// Registrar token de push
final token = await FirebaseMessaging.instance.getToken();
if (token != null) {
  await ZendeskMessaging.updatePushNotificationToken(token);
}

// Manejar notificaciones en primer plano
FirebaseMessaging.onMessage.listen((message) async {
  final responsibility = await ZendeskMessaging.shouldBeDisplayed(message.data);
  if (responsibility == ZendeskPushResponsibility.messagingShouldDisplay) {
    await ZendeskMessaging.handleNotification(message.data);
  }
});
```

## Referencia de la API

### ZendeskMessaging

| Método | Devuelve | Descripción |
|--------|----------|-------------|
| `initialize(...)` | `Future<void>` | Inicializa el SDK |
| `show()` | `Future<void>` | Muestra la interfaz de mensajería |
| `loginUser(jwt)` | `Future<ZendeskLoginResponse>` | Inicia sesión con JWT |
| `logoutUser()` | `Future<void>` | Cierra la sesión del usuario |
| ... | ... | ... |

## Licencia

Licencia MIT - consulta [LICENSE](LICENSE) para más detalles.
