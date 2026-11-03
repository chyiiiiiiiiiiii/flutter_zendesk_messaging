// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "zendesk_messaging",
  platforms: [
    .iOS("14.0")
  ],
  products: [
    .library(name: "zendesk-messaging", targets: ["zendesk_messaging"])
  ],
  dependencies: [
    // Flutter is provided as a Swift package by the Flutter tool (Flutter 3.44+).
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
    // Pinned to match the CocoaPods podspec (ZendeskSDKMessaging 2.39.0) so
    // both dependency managers resolve to the same native SDK version.
    .package(url: "https://github.com/zendesk/sdk_messaging_ios", exact: "2.39.0"),
    // 2.39.0 requires these with open "from:" ranges, and their newer releases
    // need iOS 16, which fails the build. Keep them at the podspec's resolved versions.
    .package(url: "https://github.com/zendesk/sdk_analytics_kit_ios", exact: "0.4.0"),
    .package(url: "https://github.com/zendesk/sdk_conversation_kit_ios", exact: "14.1.0"),
    .package(url: "https://github.com/zendesk/sdk_core_utilities_ios", exact: "8.1.0"),
    .package(url: "https://github.com/zendesk/sdk_faye_client_ios", exact: "1.16.0"),
    .package(url: "https://github.com/zendesk/sdk_guide_kit_ios", exact: "2.10.0"),
    .package(url: "https://github.com/zendesk/sdk_http_client_ios", exact: "0.21.0"),
    .package(url: "https://github.com/zendesk/sdk_logger_ios", exact: "0.11.0"),
    .package(url: "https://github.com/zendesk/sdk_socket_client_ios", exact: "1.14.0"),
    .package(url: "https://github.com/zendesk/sdk_storage_ios", exact: "1.6.0"),
    .package(url: "https://github.com/zendesk/sdk_ui_components_ios", exact: "14.4.0"),
    .package(url: "https://github.com/zendesk/sdk_zendesk_ios", exact: "3.17.0")
  ],
  targets: [
    .target(
      name: "zendesk_messaging",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework"),
        .product(name: "ZendeskSDKMessaging", package: "sdk_messaging_ios"),
        // SwiftPM ignores a dependency's pin unless a target uses its product.
        .product(name: "ZendeskSDKAnalyticsKit", package: "sdk_analytics_kit_ios"),
        .product(name: "ZendeskSDKConversationKit", package: "sdk_conversation_kit_ios"),
        .product(name: "ZendeskSDKCoreUtilities", package: "sdk_core_utilities_ios"),
        .product(name: "ZendeskSDKFayeClient", package: "sdk_faye_client_ios"),
        .product(name: "ZendeskSDKGuideKit", package: "sdk_guide_kit_ios"),
        .product(name: "ZendeskSDKHTTPClient", package: "sdk_http_client_ios"),
        .product(name: "ZendeskSDKLogger", package: "sdk_logger_ios"),
        .product(name: "ZendeskSDKSocketClient", package: "sdk_socket_client_ios"),
        .product(name: "ZendeskSDKStorage", package: "sdk_storage_ios"),
        .product(name: "ZendeskSDKUIComponents", package: "sdk_ui_components_ios"),
        .product(name: "ZendeskSDK", package: "sdk_zendesk_ios")
      ]
    )
  ]
)
