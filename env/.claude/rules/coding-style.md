# Coding Style

## Comments

- **Do not add obvious or redundant comments**
- **Only comment complex or non-obvious code**
- Prefer self-explanatory code with clear names for variables and functions
- When a comment is needed, write it in **English** (keeps tooling, reviews, and AI context consistent)
- Avoid comments that merely restate what the code does

### When comments are appropriate

```javascript
// ✅ GOOD: Explains non-obvious logic
// Bitwise check: true iff n is a power of two
if ((n & (n - 1)) === 0) { ... }

// ✅ GOOD: Explains a non-obvious decision
// Clone to avoid mutating cached objects shared across requests
const copy = JSON.parse(JSON.stringify(obj));

// ❌ BAD: Obvious noise
// Increment the counter
counter++;
```

## JavaScript / TypeScript

### Modules and imports

- Use ES modules (`import` / `export`)
- Group imports: built-in → external → internal
- Blank line between groups

```typescript
// Standard library / runtime (language-specific)
import { readFile } from "fs/promises";
import path from "path";

// Third-party (registry, vendor, or internal package repo)
import { createApp } from "application-framework";
import { defineSchema } from "validation-library";

// This project
import { UserService } from "./services/user";
import { logger } from "./utils/logger";
```

### Naming

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

- Prefer arrow functions for short callbacks; use `function` for top-level exported APIs when hoisting or `this` binding matters
- Keep functions small and single-purpose

```typescript
// ✅ GOOD
function getActiveUserIds(users: User[]) {
  return users.filter((user) => user.status === "active").map((user) => user.id);
}

// ❌ BAD: One huge function doing many unrelated things
function doEverything() {
  // hundreds of lines...
}
```

### Async / await

- Prefer `async`/`await` over long `.then()` chains
- Handle errors explicitly (`try`/`catch` or `.catch()` at boundaries)

```typescript
// ✅ GOOD
async function getUser(id: string) {
  try {
    const user = await db.users.findById(id);
    return user;
  } catch (error) {
    logger.error("Error fetching user:", error);
    throw error;
  }
}

// ❌ BAD
function getUser(id: string) {
  return db.users
    .findById(id)
    .then((user) => user)
    .catch((err) => console.log(err));
}
```

### TypeScript

- Use explicit types on public function parameters and return types where they help inference
- Avoid `any`; use `unknown` and narrow, or proper generics
- Prefer `interface` for object shapes; `type` for unions, intersections, and aliases

```typescript
// ✅ GOOD
interface User {
  id: string;
  email: string;
}

type Status = "active" | "inactive" | "pending";

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

- Do not copy-paste logic; extract shared helpers
- Avoid premature abstraction—repeat until a pattern is clear

### Composition over inheritance

- Prefer composing small functions or objects
- Use inheritance only when it matches the domain model

### Readability

- Self-explanatory code beats comments
- Descriptive names beat short cryptic names
- Simplicity beats cleverness

```typescript
// ✅ GOOD
const activeUsers = users.filter((user) => user.status === "active");

// ❌ BAD
const u = users.filter((x) => x.s === "a"); // needs a comment to be understood
```

## Testing

- Test non-trivial logic and regressions
- Use descriptions that document expected behavior
- Prefer small, focused unit tests

```typescript
// ✅ GOOD
describe("UserService", () => {
  it("returns user when a valid id is provided", async () => {
    const user = await userService.getById("123");
    expect(user).toBeDefined();
    expect(user.id).toBe("123");
  });
});
```

## Error handling

- Handle errors at appropriate boundaries; do not swallow failures
- Use custom error classes when they improve handling upstream
- Never use empty `catch` blocks

```typescript
// ✅ GOOD
class UserNotFoundError extends Error {
  constructor(userId: string) {
    super(`User not found: ${userId}`);
    this.name = "UserNotFoundError";
  }
}

// ❌ BAD
try {
  // ...
} catch {
  // silent failure
}
```
