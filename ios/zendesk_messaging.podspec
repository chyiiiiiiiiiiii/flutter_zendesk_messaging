#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint zendesk_messaging.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'zendesk_messaging'
  s.version          = '3.6.0'
  s.summary          = 'Zendesk Messaging SDK Flutter Plugin'
  s.description      = <<-DESC
Flutter plugin for Zendesk Messaging SDK. Enables in-app customer support messaging.
                       DESC
  s.homepage         = 'https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'chyiiiiiiiiiiii' => 'ab20803@gmail.com' }
  s.source           = { :path => '.' }
  # Sources live in the Swift Package layout so CocoaPods and Swift Package
  # Manager reference the same files (dual support).
  s.source_files = 'zendesk_messaging/Sources/zendesk_messaging/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'ZendeskSDKMessaging', '2.39.0'
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.cocoapods_version = '>= 1.10.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
