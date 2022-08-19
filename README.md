# Zendesk Messaging

![](Messaging.png)

**Messaging** is a "user-based" chat

**Live Chat** is a "session-based" chat
 
- **Better UI (Native)**
- **Chat history**
- **Answer Bot**

-------------------

## Setup
### 1. Enable agent work-space
![](screenshot/screenshot_1.png)
### 2. Enable Messaging
![](screenshot/screenshot_2.png)
### 
![](screenshot/screenshot_3.png)
### 3. Add channel and get key
![](screenshot/screenshot_4.png)
### 
![](screenshot/screenshot_5.png)

## How to use?
### Initialize
``` dart
 final String androidChannelKey = '';
 final String iosChannelKey = '';

  @override
  void initState() {
    super.initState();
    ZendeskMessaging.initialize(
      androidChannelKey: androidChannelKey,
      iosChannelKey: iosChannelKey,
    );
  }
```
> just use initialize() one time

### Show
```dart
ZendeskMessaging.show();
```
> You can use in onTap()

### Authenticate (optional)

The SDK needs to be initialized before using authentication methods !

```dart
// Method 1
final ZendeskLoginResponse result = await ZendeskMessaging.loginUser(jwt: "YOUR_JWT");
await ZendeskMessaging.logoutUser();

// Method 2 if you need callbacks
await ZendeskMessaging.loginUserCallbacks(jwt: "YOUR_JWT", onSuccess: (id, externalId) => ..., onFailure: () => ...;
await ZendeskMessaging.logoutUserCallbacks(onSuccess: () => ..., onFailure: () => ...);
```

### Global observer (optional)

If you need to catch all events you can attach a global observer to the ZendeskMessaging.

```dart
ZendeskMessaging.setMessageHandler((type, args){
    print("$type => $args");
});
```

## Weak
- **Tag**：`Currently does not support.` There is no way to help users with additional information like Chat.
- **Attachment file**：`Currently does not support.` The official said it will be launched in the future.
- **Chat room closed**：An agent can not reply to a customer at any time.
if the customer is not active in the foreground, the room will be closed automatically. It is inconvenient to track chat history.


## Future Function

- Push Notifications


## Link
- [Zendesk messaging Help](https://support.zendesk.com/hc/en-us/sections/360011686513-Zendesk-messaging)
- [Agent Workspace for messaging](https://support.zendesk.com/hc/en-us/articles/360055902354-Agent-Workspace-for-messaging)
- [Working with messaging in your Android and iOS SDKs](https://support.zendesk.com/hc/en-us/articles/1260801714930-Working-with-messaging-in-your-Android-and-iOS-SDKs)

## Contribute
- You can star and share with other developers if you feel good and learn something from this repository.
- If you have some ideas, please discuss them with us or commit PR.
