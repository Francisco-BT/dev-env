# Commit Message Rules

## Format (Conventional Commits)

**ALWAYS use this format:**

```
<type>: <short description>
```

### Allowed types:

- `feat` - New feature
- `fix` - Bug fix
- `chore` - Maintenance tasks (deps, config, etc.)
- `refactor` - Code refactoring (no functionality change)
- `docs` - Documentation changes
- `test` - Add or modify tests
- `perf` - Performance improvements
- `style` - Code formatting (no logic changes)
- `ci` - CI/CD changes
- `build` - Build system changes
- `revert` - Reverts a previous commit (reference the hash in the body when helpful)

### Strict rules:

1. **Maximum 80 characters** in the message
2. **Lowercase** description
3. **No period** at the end
4. **Imperative mood** - "add feature" not "added feature"
5. **Descriptive but concise**

### Good examples ✅

```bash
feat: add user authentication with JWT
fix: resolve memory leak in websocket connection
chore: update dependencies to latest versions
refactor: simplify error handling logic
test: add unit tests for payment service
perf: optimize database queries with indexes
ci: add pipeline job for automated tests
```

### Bad examples ❌

```bash
feat: Added a new feature for users to login and authenticate themselves  # Too long
Fix bug  # Not descriptive
updated stuff  # No type, vague
feat: Add feature.  # Period at end
FEAT: ADD FEATURE  # Uppercase
```

## Commits with scope (optional)

For larger projects, use scope:

```
<type>(<scope>): <description>
```

Examples:

```bash
feat(auth): add password reset functionality
fix(api): handle null response in user endpoint
chore(deps): upgrade react to v18
test(payments): add integration tests for stripe
```

## When to commit

- **Small, frequent commits** > large commits
- One commit = one logical unit of change
- If you use "and" in the message, you probably need 2 commits
- Commit working code, not broken code

## Optional body and footer

For non-trivial changes, add a blank line after the subject and a short body explaining **what** and **why** (not how every line changed). Use footers for issue references (`Fixes #123`) and breaking-change details.

## Breaking changes

Use `!` after the type/scope or a `BREAKING CHANGE:` footer:

```bash
feat!: remove deprecated API endpoints

feat(api): update user schema

BREAKING CHANGE: user.name is now user.fullName
```
