---
name: analyze-pr
description: Pull request analysis and review for Flutter projects. Use when analyzing PRs, reviewing changes, or preparing PR feedback. Triggers on PR, pull request, merge request, diff, changes.
allowed-tools: Read, Grep, Glob, Bash(git:*), Bash(gh:*)
---

# Pull Request Analysis

## PR Review Process

### 1. Understand the Context
- Read PR title and description
- Check linked issues/tickets
- Understand the goal of the changes

### 2. Review File Changes

```bash
# List changed files
git diff --name-only main...HEAD

# View changes with context
git diff main...HEAD

# Check specific file changes
git diff main...HEAD -- path/to/file.dart
```

### 3. Check Code Quality

**Architecture**
- Clean Architecture layers respected
- No layer violations
- Proper dependency injection

**State Management**
- Riverpod patterns followed
- AsyncValue properly handled
- Provider types appropriate

**Testing**
- Tests added for new code
- Existing tests pass
- Edge cases covered

### 4. Security Review

- [ ] No secrets in code
- [ ] Input validation present
- [ ] No SQL injection risks
- [ ] Proper auth checks

### 5. Performance Review

- [ ] No N+1 queries
- [ ] Proper pagination
- [ ] Image optimization
- [ ] Widget rebuild minimized

## PR Feedback Template

```markdown
## Summary
[Brief summary of the changes reviewed]

## What's Good
- [Positive aspects of the implementation]

## Suggestions
- [ ] [Actionable improvement suggestions]

## Questions
- [Clarifying questions about the implementation]

## Testing
- [ ] Verified locally
- [ ] Tests pass
- [ ] Edge cases considered
```

## Common PR Issues

| Issue | Recommendation |
|-------|----------------|
| Large PR (>500 lines) | Split into smaller PRs |
| Missing tests | Request test coverage |
| No PR description | Ask for context |
| Breaking changes | Ensure migration path |
| Missing i18n | Add translations to all ARB files |

## Git Commands for Review

```bash
# View commit history
git log main...HEAD --oneline

# Check for merge conflicts
git merge-base main HEAD

# View stats
git diff --stat main...HEAD

# Interactive review with gh
gh pr view --web
gh pr diff
```

## Approval Criteria

### Must Have
- [ ] All tests pass
- [ ] No analyzer warnings
- [ ] Code follows project patterns
- [ ] Changes match PR description

### Nice to Have
- [ ] Documentation updated
- [ ] Performance considered
- [ ] Edge cases handled
