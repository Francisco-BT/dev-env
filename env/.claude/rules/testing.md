# Testing Rules

## Running tests — ask first

**Never run tests automatically.** Always ask before executing any test command.

The user may want to:

- Review the written tests before running them
- Run tests manually and validate the output themselves
- Pass a specific failure back as context rather than flooding the conversation

### ❌ BAD

```
[writes tests]
[immediately runs npm test without asking]
```

### ✅ GOOD

```
[writes tests]
"Tests written. Want me to run them, or will you validate manually?"
```

### When the user shares a test failure

If the user pastes a failing test output, treat that as the context — do not re-run the suite to "confirm" the failure. Work from what was provided.

---

## Handling test output

Test runners produce verbose output. Do not dump it raw into the conversation.

### ❌ BAD

```
Pasting 200 lines of Jest output including all passing tests, timing info, and coverage tables
```

### ✅ GOOD

```
Summarize: "3 tests passed, 1 failed — `should throw UserNotFoundError` in UserService.
Expected UserNotFoundError, received generic Error."
Then show only the relevant failure block.
```

If all tests pass, one line is enough: "All 12 tests passed."

---

## Core principles

### 1. Green path first

- Write happy path tests first
- Then add edge cases and error scenarios
- Ensure main flow works before testing edge cases

### 2. Test types

- **Unit tests** — individual functions/methods (fast, isolated)
- **Integration tests** — interaction between modules/services
- Prefer unit tests (faster, more specific)
- Integration tests for critical flows only
- Consider add e2e test for super critical flows, ask before act

### 3. Default scope when "write tests" is requested

- Write tests for the file currently in context
- Cover: green path + most likely failure modes
- Skip exhaustive edge cases unless explicitly asked
- Do not write tests for files not in scope

### 4. AAA Pattern (Arrange-Act-Assert)

```typescript
it("should calculate total price with discount", () => {
  // Arrange
  const items = [{ price: 100 }, { price: 200 }];
  const discount = 0.1;

  // Act
  const total = calculateTotal(items, discount);

  // Assert
  expect(total).toBe(270);
});
```

---

## Test naming

Descriptive: describe what the unit does and what outcome is expected.

```typescript
// ✅ GOOD
describe("UserService", () => {
  describe("createUser", () => {
    it("should create user with valid data", async () => {});
    it("should throw ValidationError when email is invalid", async () => {});
    it("should hash password before saving to database", async () => {});
    it("should send welcome email after user creation", async () => {});
  });

  describe("deleteUser", () => {
    it("should delete user when user exists", async () => {});
    it("should throw UserNotFoundError when user does not exist", async () => {});
  });
});

// ❌ BAD
describe("UserService", () => {
  it("test1", () => {});
  it("works", () => {});
  it("should work correctly", () => {});
});
```

---

## Green path + edge cases

```typescript
describe("divide", () => {
  // GREEN PATH
  it("should divide two positive numbers", () => {
    expect(divide(10, 2)).toBe(5);
    expect(divide(100, 4)).toBe(25);
  });

  // EDGE CASES
  it("should throw when dividing by zero", () => {
    expect(() => divide(10, 0)).toThrow("Cannot divide by zero");
  });

  it("should handle negative numbers", () => {
    expect(divide(-10, 2)).toBe(-5);
    expect(divide(10, -2)).toBe(-5);
    expect(divide(-10, -2)).toBe(5);
  });

  it("should handle decimal results", () => {
    expect(divide(5, 2)).toBe(2.5);
    expect(divide(1, 3)).toBeCloseTo(0.333, 2);
  });
});
```

---

## Mocking

### Mock external dependencies only

**Avoid over mocking** The less we mock the better

```typescript
describe("UserService", () => {
  it("should fetch user from database", async () => {
    const mockDb = {
      findById: jest.fn().mockResolvedValue({
        id: "1",
        name: "John",
        email: "john@example.com",
      }),
    };

    const service = new UserService(mockDb);
    const user = await service.getUser("1");

    expect(mockDb.findById).toHaveBeenCalledWith("1");
    expect(user.name).toBe("John");
  });

  it("should handle database errors", async () => {
    const mockDb = {
      findById: jest.fn().mockRejectedValue(new Error("DB connection failed")),
    };

    const service = new UserService(mockDb);
    await expect(service.getUser("1")).rejects.toThrow("DB connection failed");
  });
});
```

### Don't mock what you're testing

```typescript
// ❌ BAD - mocking the function under test
it("should calculate total", () => {
  const calculateTotal = jest.fn().mockReturnValue(100);
  expect(calculateTotal()).toBe(100); // tests nothing
});

// ✅ GOOD - test the real function
it("should calculate total", () => {
  const total = calculateTotal([10, 20, 30]);
  expect(total).toBe(60);
});
```

---

## Integration tests

```typescript
describe("User Registration Flow", () => {
  let db: Database;
  let emailService: EmailService;

  beforeEach(async () => {
    db = await setupTestDatabase();
    emailService = createMockEmailService();
  });

  afterEach(async () => {
    await cleanupTestDatabase(db);
  });

  it("should register user, hash password, and send welcome email", async () => {
    const userData = {
      email: "test@example.com",
      password: "SecurePass123!",
      name: "Test User",
    };

    const result = await registerUser(userData, { db, emailService });

    expect(result.user.email).toBe(userData.email);
    expect(result.user.password).not.toBe(userData.password);
    expect(result.session).toBeDefined();
    expect(emailService.sendWelcomeEmail).toHaveBeenCalledWith(
      userData.email,
      userData.name,
    );

    const dbUser = await db.users.findByEmail(userData.email);
    expect(dbUser).toBeDefined();
  });
});
```

---

## Code coverage

- **80%** minimum for critical code
- **100%** for security/validation functions
- Don't chase 100% everywhere — focus on meaningful tests, not numbers

---

## Best practices

### Independent tests — no shared mutable state

```typescript
// ✅ GOOD
describe("Counter", () => {
  it("should increment from 0 to 1", () => {
    const counter = new Counter();
    counter.increment();
    expect(counter.value).toBe(1);
  });

  it("should decrement from 0 to -1", () => {
    const counter = new Counter();
    counter.decrement();
    expect(counter.value).toBe(-1);
  });
});

// ❌ BAD - tests depend on each other
let counter: Counter;
it("should start at 0", () => {
  counter = new Counter();
});
it("should increment", () => {
  counter.increment();
  expect(counter.value).toBe(1);
});
```

### Use `beforeEach` for common setup

```typescript
describe("UserService", () => {
  let service: UserService;
  let mockDb: MockDatabase;

  beforeEach(() => {
    mockDb = createMockDatabase();
    service = new UserService(mockDb);
  });

  it("should create user", async () => {
    await service.createUser({ email: "test@example.com" });
    expect(mockDb.insert).toHaveBeenCalled();
  });
});
```

### Test behavior, not implementation

```typescript
// ✅ GOOD
it("should return active users", () => {
  const users = [
    { id: 1, status: "active" },
    { id: 2, status: "inactive" },
  ];
  const result = getActiveUsers(users);
  expect(result).toHaveLength(1);
  expect(result[0].id).toBe(1);
});

// ❌ BAD
it("should call filter method", () => {
  const filterSpy = spyOn(Array.prototype, "filter");
  getActiveUsers(users);
  expect(filterSpy).toHaveBeenCalled();
});
```

### Specific assertions over vague ones

```typescript
// ✅ GOOD
expect(user.age).toBe(25);
expect(response.status).toBe(200);

// ❌ BAD
expect(user).toBeTruthy();
expect(response).toBeDefined();
```

### Keep unit tests fast

- Unit tests must run in under 100ms
- Mock slow operations: DB, external APIs, filesystem
- Avoid `setTimeout`/`sleep` unless testing timing explicitly

---

## Parameterized tests

```typescript
describe.each([
  { input: 10, divisor: 2, expected: 5 },
  { input: 100, divisor: 4, expected: 25 },
  { input: 7, divisor: 2, expected: 3.5 },
])("divide($input, $divisor)", ({ input, divisor, expected }) => {
  it(`should return ${expected}`, () => {
    expect(divide(input, divisor)).toBe(expected);
  });
});
```

---
