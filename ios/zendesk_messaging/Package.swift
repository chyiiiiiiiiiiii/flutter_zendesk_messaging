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
    // Pinned to match the CocoaPods podspec (ZendeskSDKMessaging 2.37.0) so
    // both dependency managers resolve to the same native SDK version.
    .package(url: "https://github.com/zendesk/sdk_messaging_ios", exact: "2.37.0")
  ],
  targets: [
    .target(
      name: "zendesk_messaging",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework"),
        .product(name: "ZendeskSDKMessaging", package: "sdk_messaging_ios")
      ]
    )
  ]
)
