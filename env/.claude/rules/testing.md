# Testing Rules

## Core principles

### 1. Focus on Green Path first

- Write happy path tests first
- Then add edge cases and error scenarios
- Ensure main flow works before testing edge cases

### 2. Test types

- **Unit tests** - Individual functions/methods (fast, isolated)
- **Integration tests** - Interaction between modules/services
- Prefer unit tests (faster, more specific)
- Integration tests for critical flows only

### 3. AAA Pattern (Arrange-Act-Assert)

```typescript
it("should calculate total price with discount", () => {
  // Arrange - Set up test data
  const items = [{ price: 100 }, { price: 200 }];
  const discount = 0.1;

  // Act - Execute the function
  const total = calculateTotal(items, discount);

  // Assert - Verify the result
  expect(total).toBe(270);
});
```

## Test naming

### Descriptive and clear

```typescript
// ✅ GOOD - Describes what it does and expects
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

// ❌ BAD - Vague, not descriptive
describe("UserService", () => {
  it("test1", () => {});
  it("works", () => {});
  it("should work correctly", () => {});
});
```

## Green Path + Edge Cases

### Complete example

```typescript
describe("divide", () => {
  // GREEN PATH - Happy path first
  it("should divide two positive numbers", () => {
    expect(divide(10, 2)).toBe(5);
    expect(divide(100, 4)).toBe(25);
  });

  // EDGE CASES
  it("should throw error when dividing by zero", () => {
    expect(() => divide(10, 0)).toThrow("Cannot divide by zero");
  });

  it("should handle negative numbers correctly", () => {
    expect(divide(-10, 2)).toBe(-5);
    expect(divide(10, -2)).toBe(-5);
    expect(divide(-10, -2)).toBe(5);
  });

  it("should handle decimal results", () => {
    expect(divide(5, 2)).toBe(2.5);
    expect(divide(1, 3)).toBeCloseTo(0.333, 2);
  });

  it("should handle very large numbers", () => {
    expect(divide(Number.MAX_SAFE_INTEGER, 2)).toBeDefined();
  });

  it("should handle very small numbers", () => {
    expect(divide(0.0001, 0.0002)).toBe(0.5);
  });
});
```

## Mocking

### Mock external dependencies only

```typescript
// Use your testing framework's mock function

describe("UserService", () => {
  it("should fetch user from database", async () => {
    // Mock the database
    const mockDb = {
      findById: mockFunction().mockResolvedValue({
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
      findById: mockFunction().mockRejectedValue(
        new Error("DB connection failed"),
      ),
    };

    const service = new UserService(mockDb);

    await expect(service.getUser("1")).rejects.toThrow("DB connection failed");
  });
});
```

### Don't mock what you're testing

```typescript
// ❌ BAD - Mocking the function under test
it("should calculate total", () => {
  const calculateTotal = mockFunction().mockReturnValue(100);
  expect(calculateTotal()).toBe(100); // Tests nothing
});

// ✅ GOOD - Test the real function
it("should calculate total", () => {
  const total = calculateTotal([10, 20, 30]);
  expect(total).toBe(60);
});
```

## Integration tests

### Test complete flows

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
    // Arrange
    const userData = {
      email: "test@example.com",
      password: "SecurePass123!",
      name: "Test User",
    };

    // Act
    const result = await registerUser(userData, { db, emailService });

    // Assert
    expect(result.user).toBeDefined();
    expect(result.user.email).toBe(userData.email);
    expect(result.user.password).not.toBe(userData.password); // Should be hashed
    expect(result.session).toBeDefined();
    expect(emailService.sendWelcomeEmail).toHaveBeenCalledWith(
      userData.email,
      userData.name,
    );

    // Verify in database
    const dbUser = await db.users.findByEmail(userData.email);
    expect(dbUser).toBeDefined();
    expect(dbUser.email).toBe(userData.email);
  });
});
```

## Code coverage

### Target coverage

- **80%** minimum for critical code
- **100%** for security/validation functions
- Don't obsess over 100% everywhere
- Focus on meaningful tests, not coverage numbers

### Run with coverage

Use your project’s documented command (e.g. test runner CLI with a `--coverage` flag, or the IDE task your team uses). Enable watch mode only when iterating locally.

## Best practices

### 1. Independent tests

```typescript
// ✅ GOOD - Each test is independent
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

// ❌ BAD - Tests depend on each other
let counter: Counter;

it("should start at 0", () => {
  counter = new Counter();
  expect(counter.value).toBe(0);
});

it("should increment", () => {
  counter.increment(); // Depends on previous test
  expect(counter.value).toBe(1);
});
```

### 2. Use beforeEach for common setup

```typescript
describe("UserService", () => {
  let service: UserService;
  let mockDb: MockDatabase;
  let mockEmailService: MockEmailService;

  beforeEach(() => {
    mockDb = createMockDatabase();
    mockEmailService = createMockEmailService();
    service = new UserService(mockDb, mockEmailService);
  });

  it("should create user", async () => {
    await service.createUser({ email: "test@example.com" });
    expect(mockDb.insert).toHaveBeenCalled();
  });

  it("should send email on user creation", async () => {
    await service.createUser({ email: "test@example.com" });
    expect(mockEmailService.send).toHaveBeenCalled();
  });
});
```

### 3. Fast tests

- Unit tests should run in milliseconds
- Use mocks for slow operations (DB, API, filesystem)
- Avoid setTimeout/sleep unless testing timing
- Run tests in parallel when possible

### 4. Clear error messages

```typescript
// ✅ GOOD - Descriptive assertions
expect(user.age).toBe(25);
expect(user.email).toContain("@");
expect(response.status).toBe(200);

// ❌ BAD - Vague assertions
expect(user).toBeTruthy();
expect(response).toBeDefined();
```

### 5. Test behavior, not implementation

```typescript
// ✅ GOOD - Tests behavior
it("should return active users", () => {
  const users = [
    { id: 1, status: "active" },
    { id: 2, status: "inactive" },
  ];
  const result = getActiveUsers(users);
  expect(result).toHaveLength(1);
  expect(result[0].id).toBe(1);
});

// ❌ BAD - Tests implementation details
it("should call filter method", () => {
  const filterSpy = spyOn(Array.prototype, "filter");
  getActiveUsers(users);
  expect(filterSpy).toHaveBeenCalled();
});
```

## Flaky tests

- Avoid real time (`setTimeout`), randomness, and network without control; use fakes or deterministic seeds
- Prefer **waitFor** / async matchers over fixed sleeps
- Isolate shared state (DB, env, global mocks) in `beforeEach` / `afterEach`
- If a test is quarantined with `.skip`, add a comment or ticket reference

## Modern testing patterns

### Snapshot testing (use sparingly)

```typescript
// ✅ GOOD - For complex objects that rarely change
it("should match API response structure", () => {
  const response = formatUserResponse(user);
  expect(response).toMatchSnapshot();
});

// ❌ BAD - For simple values or frequently changing data
it("should return user name", () => {
  expect(user.name).toMatchSnapshot(); // Overkill
});
```

### Parameterized tests

```typescript
// ✅ GOOD - Test multiple cases efficiently
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
