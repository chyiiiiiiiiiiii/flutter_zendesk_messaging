# Claude Command: Commit

This command helps you create well-formatted commits with conventional commit messages and emoji.

## 📋 PRE-COMMIT VALIDATION CHECKLIST

**IMPORTANT**: Before running `/commit`, complete this checklist to ensure your code changes are ready.

- [ ] **README.md**: Is the `README.md` up-to-date with any changes to the public API or setup?
- [ ] **CHANGELOG.md**: Have you added an entry to `CHANGELOG.md` for this change?
- [ ] **API Documentation**: Are all new or modified public APIs documented with `///` comments?
- [ ] **Example App**: Have you tested your changes in the `example/` app to ensure they work correctly?
- [ ] **Code Formatting**: Have you run `dart format .` to ensure consistent code style?
- [ ] **Code Analysis**: Does the project pass `flutter analyze` with no warnings?
- [ ] **Tests**: Do all tests pass when running `flutter test`?

### Code Quality Final Check

Before committing, run these quality commands:

```bash
# Format code
dart format .

# Run analysis
flutter analyze

# Run tests (critical - must pass)
flutter test
```

**All checks must PASS** before proceeding to commit:
- [ ] ✅ Code formatting passed
- [ ] ✅ Linter analysis passed (no warnings)
- [ ] ✅ All unit/widget tests passed

### Final Readiness Check

- [ ] All staged files reviewed
- [ ] `CHANGELOG.md` and `README.md` updated if needed
- [ ] All quality checks passed
- [ ] No sensitive data committed (API keys, tokens, passwords)

---

## Usage

To create a commit after completing the pre-commit checklist above, just type:
```
/commit
```

Or with options:
```
/commit --no-verify
```

## What This Command Does

1. Checks which files are staged with `git status`
2. If 0 files are staged, automatically adds all modified and new files with `git add`
3. Performs a `git diff` to understand what changes are being committed
4. **Analyzes changes for automatic separation** - Detects multiple distinct logical changes across different scopes/purposes
5. **Automatically separates commits** when different concerns are detected (see separation criteria below)
6. For each separated commit group, creates optimized commit messages using emoji conventional commit format
7. Executes multiple commits in logical sequence, ensuring each commit serves a single purpose
8. Shows summary of all commits created with their scope and purpose

## Commit Message Format

Uses conventional commit format with readable emojis:
```
<emoji> <type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

## Core Commit Types

### Primary Types (Most Common)
- ✨ **feat**: A new feature
- 🐛 **fix**: A bug fix
- 📝 **docs**: Documentation changes
- 💄 **style**: Code style changes (formatting, etc)
- ♻️ **refactor**: Code changes that neither fix bugs nor add features
- ⚡️ **perf**: Performance improvements
- 🧪 **test**: Adding or fixing tests
- 🔧 **chore**: Changes to the build process, tools, etc.

### Development & CI/CD
- 🚀 **ci**: CI/CD improvements
- 👷 **ci**: Add or update CI build system
- 💚 **fix**: Fix CI build
- 🏗️ **refactor**: Make architectural changes
- 🧑‍💻 **chore**: Improve developer experience

### Bug Fixes & Security
- 🚑️ **fix**: Critical hotfix
- 🩹 **fix**: Simple fix for a non-critical issue
- 🥅 **fix**: Catch errors
- 🔒️ **fix**: Fix security issues
- 🚨 **fix**: Fix compiler/linter warnings
- 👽️ **fix**: Update code due to external API changes

### Features & Enhancements
- 🚸 **feat**: Improve user experience / usability
- 📱 **feat**: Work on responsive design
- 👔 **feat**: Add or update business logic
- 🌐 **feat**: Internationalization and localization
- 💬 **feat**: Add or update text and literals
- 🏷️ **feat**: Add or update types
- 🔍️ **feat**: Improve SEO
- 🧵 **feat**: Add or update code related to multithreading or concurrency
- 📈 **feat**: Add or update analytics or tracking code
- 🔊 **feat**: Add or update logs
- 🚩 **feat**: Add, update, or remove feature flags
- 💥 **feat**: Introduce breaking changes
- ♿️ **feat**: Improve accessibility
- 🦺 **feat**: Add or update code related to validation
- ✈️ **feat**: Improve offline support
- 🥚 **feat**: Add or update an easter egg

### Code Quality & Structure
- 🎨 **style**: Improve structure/format of the code
- 🔥 **fix**: Remove code or files
- ⚰️ **refactor**: Remove dead code
- 🚚 **refactor**: Move or rename resources

### Dependencies & Packages
- 📦️ **chore**: Add or update compiled files or packages
- ➕ **chore**: Add a dependency
- ➖ **chore**: Remove a dependency
- 📌 **chore**: Pin dependencies to specific versions

### Project Management
- 🎉 **chore**: Begin a project
- 🔖 **chore**: Release/Version tags
- 📄 **chore**: Add or update license
- 👥 **chore**: Add or update contributors
- 🔀 **chore**: Merge branches
- 🙈 **chore**: Add or update .gitignore file

### Testing & Quality Assurance
- ✅ **test**: Tests
- 🤡 **test**: Mock things
- 📸 **test**: Add or update snapshots
- ⚗️ **experiment**: Perform experiments

### Documentation & Comments
- 💡 **docs**: Add or update comments in source code
- ✏️ **fix**: Fix typos

### Database & Data
- 🗃️ **db**: Perform database related changes
- 🌱 **chore**: Add or update seed files

### UI/UX & Assets
- 💫 **ui**: Add or update animations and transitions
- 🍱 **assets**: Add or update assets

### Miscellaneous
- 🗑️ **revert**: Reverting changes
- ⏪️ **revert**: Revert changes
- 🚧 **wip**: Work in progress
- 🔇 **fix**: Remove logs

## Best Practices for Commits

- **Verify before committing**: Ensure code is linted, builds correctly, and documentation is updated
- **Atomic commits**: Each commit should contain related changes that serve a single purpose
- **Split large changes**: If changes touch multiple concerns, split them into separate commits
- **Present tense, imperative mood**: Write commit messages as commands (e.g., "add feature" not "added feature")
- **Concise first line**: Keep the first line under 72 characters
- **Use scopes**: Include scope when relevant (component, module, or area affected)

## Automatic Commit Separation Criteria

The command **automatically separates** commits when detecting multiple concerns. Changes are grouped into separate commits based on:

### Primary Separation Rules (Automatic)

1. **Change Type Separation**
   - Features vs Bug Fixes vs Refactoring vs Documentation
   - Never mix feat/fix/refactor/docs in the same commit
   - Each type gets its own commit with appropriate emoji

2. **Scope Separation**
   - Different parts of the plugin (e.g., `ios`, `android`, `lib`)
   - Core logic vs example app changes

3. **File Pattern Separation**
   - Source code (.dart, .swift, .kt) vs Configuration (.yaml, .gradle, .podspec)
   - Documentation (.md) vs Tests (_test.dart)
   - Build scripts vs Application code

4. **Functional Separation**
   - Native code changes vs Dart code changes
   - API changes vs Model changes
   - New features vs Existing feature modifications

### Secondary Separation Rules (When Detected)

5. **Dependency Separation**
   - `pubspec.yaml` changes vs Code changes
   - Version bumps vs Implementation changes

6. **Security & Performance**
   - Security fixes vs Feature additions
   - Performance optimizations vs New functionality
   - Critical hot fixes vs Regular improvements

7. **Size-Based Separation**
   - Large feature implementations split into logical phases
   - Massive refactoring split by component/module
   - Bulk changes split by affected area

### Force Single Commit When
- All changes serve a single, cohesive purpose
- Changes are tightly coupled and cannot be separated logically
- User explicitly requests single commit with `--single` flag

## Examples

### Good Single Commits
- ✨ feat: add user authentication method
- 🐛 fix: resolve issue with message stream on Android
- 📝 docs: update README with new initialization parameters
- ♻️ refactor: simplify event parsing logic
- 🚨 fix: resolve linter warnings in plugin files
- 🧑‍💻 chore: improve example app UI
- 🩹 fix: address minor styling inconsistency in example app
- 🎨 style: reorganize file structure for better readability
- 🔥 fix: remove deprecated API method
- 💚 fix: resolve failing CI pipeline tests for iOS
- 📈 feat: implement analytics tracking for messaging events
- 🔒️ fix: strengthen data handling in native code
- ♿️ feat: improve accessibility in example app

### Real-World Automatic Separation Examples

#### Example 1: Mixed Feature Development
**Before (Single Large Commit):**
- Modified native iOS code, updated Dart API, added tests, updated docs

**After (Automatic Separation):**
1. `🏗️ refactor(ios): update Swift plugin to new Zendesk SDK`
2. `✨ feat(lib): expose new authentication parameters in Dart`
3. `✅ test(lib): add tests for new authentication flow`
4. `📝 docs(readme): update documentation for new auth method`

#### Example 2: Bug Fix with Dependency Update
**Before (Mixed Concerns):**
- Fixed an issue on Android, updated `build.gradle`, refactored a helper function

**After (Automatic Separation):**
1. `🐛 fix(android): resolve crash on opening messaging view`
2. `📦️ chore(android): update Zendesk SDK dependency`
3. `♻️ refactor(lib): simplify message creation helper`

## Command Options

- `--no-verify`: Skip running the pre-commit checks (format, analyze, test)
- `--single`: Force all changes into a single commit (overrides automatic separation)
- `--preview`: Show what commits would be created without actually committing
- `--interactive`: Review each proposed commit before execution
- `--scope <scope>`: Force a specific scope for all commits (e.g., `--scope android`)

## Important Notes

### Automatic Separation Behavior
- **Default Mode**: Automatically separates commits by scope and purpose without asking
- **Smart Analysis**: Analyzes file patterns, change types, and functional areas
- **Preserves Relationships**: Maintains logical dependencies between related commits
- **Staging Strategy**: Uses selective staging to group related changes per commit

### Workflow Details
- If specific files are already staged, analyzes only staged changes for separation
- If no files are staged, stages all modified/new files and analyzes the complete changeset
- Creates commits in logical order (dependencies first, features second, tests third, docs last)
- Each commit is atomic and can be safely cherry-picked or reverted independently
- Pre-commit hooks run for each individual commit to ensure quality

### Quality Assurance
- Runs syntax fixes (`dart fix --apply`) before any commit operations
- Runs linting and testing after each commit (unless `--no-verify`)
- Validates that each commit is clean before proceeding to the next
- If any commit fails checks, stops the process and allows manual intervention
- Maintains clean git history with meaningful, searchable commit messages

### Override Controls
- Use `--single` to force everything into one commit when separation isn't desired
- Use `--preview` to see the separation plan before execution
- Use `--interactive` to approve each commit individually
- Manual staging still respected - only analyzes what you've staged
