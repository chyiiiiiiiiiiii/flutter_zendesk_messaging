# Fix Pull Request Command (Flutter/Dart)

Fetch unresolved comments for this branch's PR, then systematically address and fix them with Flutter/Dart best practices.

## What This Command Does

1. **Identifies Current Branch**: Determines the active branch and associated PR
2. **Fetches PR Comments**: Retrieves all unresolved review comments and feedback
3. **Analyzes Feedback**: Categorizes comments by type (bugs, suggestions, questions, etc.)
4. **Prioritizes Issues**: Orders fixes by severity and impact
5. **Implements Solutions**: Makes code changes following Flutter/Dart conventions
6. **Validates Changes**: Runs Flutter-specific checks and tests
7. **Updates PR**: Commits fixes with descriptive messages using conventional commit format
8. **Responds to Comments**: Provides context for changes made

## Flutter/Dart Validation Pipeline

Before implementing fixes, ensure the following pass:
```bash
# Code analysis and formatting
flutter analyze
dart format --set-exit-if-changed .

# Testing
flutter test

# Build validation (on example app)
flutter build apk --debug
flutter build ios --debug --no-codesign
```

## Comment Analysis & Categorization

### 🚨 **Critical Issues** (Fix First)
- **Security vulnerabilities**: Insecure data handling, exposed API keys
- **Performance bottlenecks**: UI jank, memory leaks, inefficient builds
- **Breaking changes**: API changes, widget breaking changes
- **Build failures**: Compilation errors, dependency conflicts
- **Platform-specific crashes**: iOS/Android specific issues

### 🐛 **Bug Fixes** (High Priority)
- **Runtime errors**: Null safety violations, type errors
- **Plugin lifecycle issues**: Dispose not called, memory leaks
- **State management bugs**: Incorrect state updates, race conditions
- **Navigation issues**: Route problems, context usage in example app
- **Platform integration**: Plugin issues, native code problems

### 💡 **Code Quality** (Medium Priority)
- **Dart style violations**: `dart format`, linting rules
- **Widget composition**: Over-nested widgets, missing const in example app
- **Performance optimizations**: Unnecessary rebuilds, const constructors
- **Accessibility**: Missing semantics, poor a11y support in example app
- **Documentation**: Missing dartdoc comments for public APIs

### 🔧 **Suggestions** (Low Priority)
- **Architecture improvements**: Better separation of concerns
- **Code organization**: File structure, barrel exports
- **Best practices**: Flutter conventions, pub.dev guidelines
- **Refactoring opportunities**: Extract methods, simplify logic
- **Modern Dart/Flutter features**: Latest API usage

## Fix Implementation Strategy

### 1. **Single Comment Fixes**
```bash
# For isolated Flutter/Dart issues
✨ feat(plugin): implement reviewer suggestion for a new method
🐛 fix(android): handle null safety violation in native code
📝 docs(api): add dartdoc comments per feedback
♻️ refactor(plugin): extract reusable logic as suggested
🎨 style(example): apply const constructors for performance
```

### 2. **Multi-Comment Fixes**
```bash
# For related issues across multiple comments
🐛 fix(ios): address multiple state management review comments in Swift plugin
♻️ refactor(plugin): implement performance improvements from feedback
🧪 test(plugin): add missing unit test coverage per review
🚨 fix(android): resolve context usage issues in native implementation
```

### 3. **Batch Fixes by Area**
```bash
# Group by plugin component/layer
🔧 chore(linting): resolve all dart analyze warnings
🚨 fix(ios): address native iOS review feedback
⚡ perf(plugin): optimize event stream handling per review
🏗️ refactor(architecture): implement suggested API design pattern
```

## Flutter-Specific Response Templates

### ✅ **Fixed Comments**
```markdown
Fixed in [commit-hash]:
- [Brief description of what was changed]
- [Flutter/Dart specific considerations]
- [Performance/accessibility impact]
- [Testing approach used]
```

### 🤔 **Clarification Needed**
```markdown
Thanks for the feedback! Could you clarify:
- [Specific question about Flutter implementation]
- [Platform-specific considerations (iOS/Android/Web)]
- [API design preference]
- [Testing strategy expectations]
```

### 💭 **Alternative Approach**
```markdown
I considered this approach but went with [current solution] because:
- [Plugin performance implications]
- [Platform compatibility reasons]
- [API consistency]
- [Plugin lifecycle considerations]

Would you like me to implement your suggested pattern instead?
```

## Quality Assurance Checklist

### Before Implementing Fixes
- [ ] **Run Flutter doctor**: Ensure development environment is healthy
- [ ] **Check dependencies**: Verify pubspec.yaml compatibility
- [ ] **Review Flutter version**: Ensure compatibility with project requirements
- [ ] **Backup current state**: Create branch backup for rollback

### During Implementation
- [ ] **Follow Dart style guide**: Use `dart format` and linting rules
- [ ] **Apply const constructors**: Optimize widget performance in example app
- [ ] **Handle null safety**: Ensure sound null safety compliance
- [ ] **Test on multiple platforms**: iOS, Android (if applicable)
- [ ] **Check unit tests**: Ensure plugin tests still pass
- [ ] **Verify in example app**: Ensure changes work with hot reload and restart

### After Implementation
- [ ] **Run full test suite**: `flutter test`
- [ ] **Check code coverage**: Maintain or improve test coverage
- [ ] **Validate performance**: No new performance issues in example app
- [ ] **Test accessibility**: Screen reader and semantic compatibility in example app
- [ ] **Build all targets**: Ensure all platforms build successfully for the example app
- [ ] **Update documentation**: Modify README or API docs if needed

## Commit Message Format

Follow conventional commit format with plugin context:

```
<emoji> <type>(<scope>): <description>

Addresses review comment: <comment-summary>
- <specific-dart-change-1>
- <specific-native-change-2>
- <platform-specific-consideration>

Tested on: [iOS/Android] in example app.
Co-authored-by: <reviewer-name> <reviewer-email>
```

### Examples
```bash
🐛 fix(android): handle null pointer in ZendeskMessagingPlugin

Addresses review comment: Add null checks for activity context.
- Added null check for activity before using context.
- Implemented proper error handling for initialization failures.
- Added unit tests for error states.

Tested on: Android
Co-authored-by: Plugin Reviewer <reviewer@example.com>
```

## Common Flutter Plugin Fix Patterns

### 🛡️ **Null Safety Fixes (Dart)**
```dart
// Before (unsafe)
void show() {
  _channel.invokeMethod('show');
}

// After (safe, with potential for more complex logic)
Future<void> show() async {
  // Potentially add checks here before invoking
  await _channel.invokeMethod('show');
}
```

### ⚡ **Performance Fixes (Event Handling)**
```dart
// Before (inefficient stream creation)
Stream<int> get anEventStream {
  return eventChannel.receiveBroadcastStream().cast<int>();
}

// After (cached stream)
Stream<int>? _eventStream;
Stream<int> get anEventStream {
  _eventStream ??= eventChannel.receiveBroadcastStream().cast<int>();
  return _eventStream!;
}
```

### 🧪 **Testing Improvements**
```dart
// Add missing method channel tests
setUp(() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    // mock implementation
    return '42';
  });
});

tearDown(() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
});

test('getPlatformVersion', () async {
  expect(await ZendeskMessaging.platformVersion, '42');
});
```

## Flutter-Specific Command Options

- `--platform=<target>`: Focus on platform-specific issues (ios, android)
- `--tests-only`: Run and fix test related comments
- `--performance`: Address performance-related feedback only
- `--docs`: Address documentation comments only
- `--null-safety`: Address null safety violations
- `--lint-rules`: Fix specific dart analyze warnings

## Integration with Flutter Tools

### Development Workflow
```bash
# Pre-fix validation
flutter doctor
flutter pub get
flutter analyze
dart format --set-exit-if-changed .

# Post-fix validation
flutter test
# In example/ directory:
flutter build apk --debug
flutter build ios --debug --no-codesign
```

### IDE Integration
- **VS Code**: Flutter extension, Dart analysis
- **Android Studio**: Flutter plugin, code inspections
- **IntelliJ**: Flutter support, refactoring tools

### CI/CD Integration
- Works with GitHub Actions Flutter workflows
- Integrates with Codemagic, Bitrise Flutter pipelines
- Supports Firebase Test Lab integration for the example app
- Compatible with Flutter analyze in CI

## Flutter Project Structure Considerations

This project follows a standard Flutter plugin structure.

```
flutter_zendesk_messaging/
├── android/              # Android native code
├── ios/                  # iOS native code
├── lib/                  # Dart API
│   ├── zendesk_messaging.dart
│   └── src/
│       ├── zendesk_messaging_config.dart
│       ├── zendesk_messaging.dart
│       ├── enums/
│       ├── events/
│       └── models/
├── example/              # Example app to demonstrate plugin usage
│   ├── android/
│   ├── ios/
│   ├── lib/main.dart
│   └── ...
└── test/                 # Plugin tests
    └── zendesk_messaging_test.dart
```

## Best Practices for Flutter Plugin PR Fixes

### 🎯 **Code Quality**
- **Use const constructors**: Improve performance in the example app.
- **Follow naming conventions**: Use descriptive, Dart-style names.
- **Document public APIs**: Use `///` for all public methods, classes, and properties.

### 🔄 **API Design**
- **Choose consistent patterns**: Stick to the project's API design.
- **Handle async operations**: Use `Future` and `Stream` correctly.
- **Implement error states**: Propagate native errors to Dart layer gracefully.

### 📱 **Platform Considerations**
- **Test on both platforms**: iOS and Android behavior can differ.
- **Handle platform-specific logic**: Use method channel arguments or separate methods if needed.
- **Consider web/desktop compatibility**: If the plugin might support them in the future.

### 🧪 **Testing Strategy**
- **Unit tests**: For Dart logic.
- **Method Channel tests**: Mock the method channel to test plugin's Dart side.
- **Manual testing**: Use the example app to test end-to-end functionality on real devices/simulators.

