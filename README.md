# Zendesk Messaging

<a href="https://pub.dev/packages/zendesk_messaging"><img src="https://img.shields.io/pub/v/zendesk_messaging.svg" alt="Pub"></a>


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

### Invalidate (optional)
``` dart
@override
  void dispose() {
    ZendeskMessaging.invalidate();
    super.dispose();
  }
///  Invalidates the current instance of ZendeskMessaging.
```
After calling this method you will have to call ZendeskMessaging.initialize again if you would like to use ZendeskMessaging.

This can be useful if you need to initiate a chat with another set of `androidChannelKey` and `iosChannelKey`

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
await ZendeskMessaging.loginUserCallbacks(jwt: "YOUR_JWT", onSuccess: (id, externalId) => ..., onFailure: () => ...);
await ZendeskMessaging.logoutUserCallbacks(onSuccess: () => ..., onFailure: () => ...);
```
### Check authentication state (optional)

This method can be used to check wheter the user is alreday logged in!

```dart
await ZendeskMessaging.loginUser(jwt: "YOUR_JWT");
final bool isLoggedIn = await ZendeskMessaging.isLoggedIn();
// After the user is logged in [isLoggedIn] is true
await ZendeskMessaging.logoutUser();
final bool userStillLoggedIn = await ZendeskMessaging.isLoggedIn();
// After you call the logout method [ZendeskMessaging.isLoggedIn()] will return [false]

```
### Retrieve the unread message count (optional)

There's must be a logged user to allow the recovery of the unread message count!

```dart
// Retrieve the unread message count
final int count = await ZendeskMessaging.getUnreadMessageCount()();

// if there's no user logged in, the message count will always be zero.
```
### Set tags to a support ticket (optional)

Allows custom conversation tags to be set, adding contextual data about the conversation.

```dart
// Add tags to a conversation
 await ZendeskMessaging.setConversationTags(['tag1', 'tag2', 'tag3']);

// Note: Conversation tags are not immediately associated with a conversation when this method is called. 
// It will only be applied to a conversation when end users either start a new conversation or send a new message in an existing conversation.
```
### Clear conversation tags (optional)

Allows custom conversation tags to be set, adding contextual data about the conversation.

```dart
// Allows you to clear conversation tags from native SDK storage when the client side context changes.
// This removes all stored conversation tags from the natice SDK storage.
 await ZendeskMessaging.clearConversationTags();

// Note: This method does not affect conversation tags already applied to the conversation.
```

### Global observer (optional)

If you need to catch all events you can attach a global observer to the ZendeskMessaging.

```dart
ZendeskMessaging.setMessageHandler((type, args){
    print("$type => $args");
});
```

## Known shortcomings
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
