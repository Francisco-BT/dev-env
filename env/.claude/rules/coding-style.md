# Code Style

## Language
- All code, comments, variable names, function names, and documentation must be written in **English**
- No exceptions: identifiers, string literals used as keys/enums, error messages, log messages — all in English

## Comments
- **DO NOT add obvious or redundant comments**
- **ONLY comment complex or non-intuitive code**
- Prefer self-documenting code with good variable and function names
- When commenting, explain the **why**, not the **what**
- Avoid comments that simply repeat what the code does

### When to comment:
```javascript
// ✅ GOOD: Explains complex or non-obvious logic
// Bitwise check is faster than modulo for power-of-2 validation
if ((n & (n - 1)) === 0) { ... }

// ✅ GOOD: Explains the "why" behind a non-obvious decision
// Clone to prevent cache mutations from leaking into caller's reference
const copy = JSON.parse(JSON.stringify(obj))

// ❌ BAD: Obvious comment
// Increment counter
counter++
```

## JavaScript/TypeScript

### Modules and Imports
- Use ES6+ modules (import/export)
- Group imports: built-in → external → internal
- Blank line between import groups

```typescript
// Built-in
import { readFile } from 'fs/promises';
import path from 'path';

// External
import express from 'express';
import { z } from 'zod';

// Internal
import { UserService } from './services/user';
import { logger } from './utils/logger';
```

### Naming conventions
- **kebab-case** for file names (e.g. `user-service.ts`)
- **PascalCase** for classes and components (e.g. `UserService`, `Button`)
- **camelCase** for variables and functions (e.g. `getUserById`, `isValid`)
- **UPPER_SNAKE_CASE** for constants (e.g. `MAX_RETRIES`, `API_URL`)

```typescript
// ✅ GOOD
const MAX_RETRIES = 3;
class UserService {}
function getUserById(id: string) {}
const isValid = true;

// ❌ BAD
const max_retries = 3;
class userService {}
function GetUserById(id: string) {}
```

### Functions
- Prefer arrow functions for callbacks
- Use function declarations for top-level functions
- Keep functions small with a single responsibility
- Functions should do one thing and do it well

```typescript
// ✅ GOOD
function processUser(user: User) {
  return users.map(u => u.id);
}

// ❌ BAD - Long function with multiple responsibilities
function doEverything() {
  // 100 lines of code...
}
```

### Async/Await
- Prefer async/await over .then()
- Always handle errors with try/catch
- Never swallow errors silently

```typescript
// ✅ GOOD
async function getUser(id: string) {
  try {
    const user = await db.users.findById(id);
    return user;
  } catch (error) {
    logger.error('Error fetching user:', error);
    throw error;
  }
}

// ❌ BAD
function getUser(id: string) {
  return db.users.findById(id)
    .then(user => user)
    .catch(err => console.log(err));
}
```

### TypeScript specifics
- Use explicit types on function parameters and return values
- Avoid `any` — use `unknown` if the type is truly unknown
- Prefer `interface` for object shapes, `type` for unions and intersections
- Use strict null checks — never assume a value is non-null without verification

```typescript
// ✅ GOOD
interface User {
  id: string;
  email: string;
}

type Status = 'active' | 'inactive' | 'pending';

function processUser(user: User): Status {
  // ...
}

// ❌ BAD
function processUser(user: any): any {
  // ...
}
```

## General principles

### DRY (Don't Repeat Yourself)
- Do not duplicate code
- Extract common logic into functions/utilities
- But don't over-abstract — three similar lines is better than a premature abstraction

### Composition over inheritance
- Prefer function composition
- Use inheritance only when it makes semantic sense

### Readability
- Self-documenting code > comments
- Descriptive names > short names
- Simplicity > cleverness

```typescript
// ✅ GOOD - Self-documenting
const activeUsers = users.filter(user => user.status === 'active');

// ❌ BAD - Needs a comment to explain itself
const u = users.filter(x => x.s === 'a'); // active users
```

### Minimize complexity
- Do not add features, refactors, or "improvements" beyond what was asked
- Do not add error handling for scenarios that cannot happen
- Do not create helpers or abstractions for one-time operations
- Do not design for hypothetical future requirements

## Error handling
- Always handle errors explicitly
- Use custom error classes when appropriate
- Never silence errors with empty catch blocks
- Log errors at the appropriate level (error vs warn vs info)

```typescript
// ✅ GOOD
class UserNotFoundError extends Error {
  constructor(userId: string) {
    super(`User not found: ${userId}`);
    this.name = 'UserNotFoundError';
  }
}

// ❌ BAD
try {
  // ...
} catch (e) {
  // silently ignored
}
```

## Security
- Never introduce command injection, XSS, SQL injection, or other OWASP Top 10 vulnerabilities
- Validate input only at system boundaries (user input, external APIs) — trust internal code
- Never commit secrets, API keys, or credentials
- Sanitize any user-provided data before using it in queries or templates

## Testing
- Write tests for complex logic
- Tests should be descriptive and document expected behavior
- Prefer small, focused unit tests
- Follow the AAA pattern: Arrange → Act → Assert
- Tests must be independent — no shared mutable state between tests

```typescript
// ✅ GOOD
describe('UserService', () => {
  it('should return user when valid id is provided', async () => {
    const user = await userService.getById('123');
    expect(user).toBeDefined();
    expect(user.id).toBe('123');
  });

  it('should throw UserNotFoundError when id does not exist', async () => {
    await expect(userService.getById('nonexistent')).rejects.toThrow(UserNotFoundError);
  });
});
```
