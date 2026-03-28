# Security Rules

## 1. NEVER hardcode secrets

### ❌ BAD

```typescript
const API_KEY = "sk_live_abc123xyz";
const DB_PASSWORD = "mypassword123";
const JWT_SECRET = "supersecret";
const STRIPE_KEY = "pk_test_123";
```

### ✅ GOOD

```typescript
const API_KEY = process.env.API_KEY;
const DB_PASSWORD = process.env.DB_PASSWORD;
const JWT_SECRET = process.env.JWT_SECRET;

// Always validate env vars exist
if (!API_KEY || !DB_PASSWORD || !JWT_SECRET) {
  throw new Error("Missing required environment variables");
}

// Use a validation library for complex configs (Zod, Joi, Yup, etc.)
function validateEnv() {
  const required = ["API_KEY", "DB_PASSWORD", "JWT_SECRET"];
  const missing = required.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    throw new Error(`Missing env vars: ${missing.join(", ")}`);
  }
}

validateEnv();
```

## 2. Input validation

### Use Type Guards in TypeScript

```typescript
// Type guard function
function isValidEmail(email: unknown): email is string {
  return typeof email === "string" && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// Type assertion with validation
function processUser(data: unknown) {
  if (!isValidUser(data)) {
    throw new Error("Invalid user data");
  }
  // data is now typed as User
  return data.email;
}

interface User {
  email: string;
  name: string;
  age?: number;
}

function isValidUser(data: unknown): data is User {
  return (
    typeof data === "object" &&
    data !== null &&
    "email" in data &&
    "name" in data &&
    typeof data.email === "string" &&
    typeof data.name === "string" &&
    (!("age" in data) || typeof data.age === "number")
  );
}
```

### Use validation libraries (recommended)

Use schema validation libraries like:

- **Zod** (TypeScript-first)
- **Joi** (Node.js)
- **Yup** (React/JavaScript)
- **Ajv** (JSON Schema)
- **class-validator** (TypeScript decorators)

```typescript
// Example with schema validation
interface User {
  email: string;
  name: string;
  age?: number;
  role: "user" | "admin" | "moderator";
}

function validateUser(data: unknown): User {
  // Use your validation library here
  // This is a simplified example
  if (!isValidUser(data)) {
    throw new Error("Invalid user data");
  }

  // Additional validation
  if (!isValidEmail(data.email)) {
    throw new Error("Invalid email format");
  }

  if (data.name.length < 1 || data.name.length > 100) {
    throw new Error("Name must be 1-100 characters");
  }

  return data;
}
```

## 3. Prevent injection attacks

### SQL Injection - Use prepared statements

```typescript
// ❌ BAD - SQL injection vulnerable
const query = `SELECT * FROM users WHERE email = '${email}'`;
db.query(query);

// ✅ GOOD - Parameterized query
const query = "SELECT * FROM users WHERE email = ?";
db.execute(query, [email]);

// ✅ GOOD - ORM / repository API that parameterizes (no raw interpolated SQL)
const user = await users.findByEmail(email);
```

### XSS - Escape HTML

```typescript
// ❌ BAD - XSS vulnerable
element.innerHTML = userInput;

// ✅ GOOD - Use textContent
element.textContent = userInput;

// ✅ GOOD - Sanitize HTML if you must render rich text (trusted allowlist / sanitizer library)
element.innerHTML = sanitizeHtml(userInput);

// ✅ GOOD - Templated UI frameworks usually escape by default
return <div>{userInput}</div>;
```

### Command Injection

```typescript
// ❌ BAD - Command injection vulnerable
exec(`convert ${userFilename} output.png`);

// ✅ GOOD - Use array syntax
execFile("convert", [userFilename, "output.png"]);

// ✅ GOOD - Validate and sanitize input
const safeFilename = path.basename(userFilename);
if (!/^[a-zA-Z0-9_-]+\.(jpg|png)$/.test(safeFilename)) {
  throw new Error("Invalid filename");
}
```

## 4. Authentication & Authorization

```typescript
// Always verify permissions
async function deleteUser(userId: string, requestingUserId: string) {
  const requestingUser = await getUser(requestingUserId);

  if (userId !== requestingUserId && !requestingUser.isAdmin) {
    throw new UnauthorizedError("Insufficient permissions");
  }

  await users.deleteById(userId);
}

// Enforce the same checks in HTTP handlers, RPC methods, or jobs—not only in the UI
// e.g. route guarded by authentication + admin role before calling deleteUser(...)
```

### Password handling

Use a **slow, adaptive** password hash (bcrypt, Argon2, scrypt—via your language’s recommended API). Store only the hash and parameters; verify with a constant-time compare provided by the library.

```typescript
// ✅ GOOD — illustrative; use your stack’s password API
const hash = await passwordHasher.hash(plainTextPassword);
const isValid = await passwordHasher.verify(plainTextPassword, storedHash);

// ❌ BAD — never persist reversible or plaintext passwords
const user = { password: plainTextPassword };
```

## 5. Rate limiting

- Apply limits per IP, user, or API key on public and expensive endpoints
- Use **tighter** limits on login, password reset, and OTP flows
- Return **429** (and `Retry-After` when appropriate) instead of silent failure
- Implement via API gateway, reverse proxy, framework middleware, or your platform’s built-in throttling—match whatever the stack already uses

## 6. Secure logging

```typescript
// ❌ BAD - Logging sensitive data
console.log("User login:", { email, password, token });

// ✅ GOOD - Don't log secrets
console.log("User login:", { email, userId });

// Sanitize before logging
function sanitizeForLog(obj: Record<string, any>) {
  const { password, token, apiKey, secret, ...safe } = obj;
  return safe;
}

logger.info("Request data:", sanitizeForLog(requestData));
```

## 7. CORS

- **Do not** use a wildcard origin when browsers send **credentials** (cookies, client certs)
- Maintain an **allowlist** of origins from configuration per environment
- Keep preflight caching (`Access-Control-Max-Age`) reasonable; configure at framework or edge layer

## 8. CSRF (cookie-based sessions)

For state-changing requests from browsers that use **cookie** sessions, use **CSRF tokens** or **SameSite** cookies (and prefer modern frameworks that wire this for you). Do not rely on CORS alone to prevent cross-site forged requests.

## 9. Security headers

Set **CSP**, **HSTS** (production), **X-Content-Type-Options**, **Referrer-Policy**, and **Permissions-Policy** (as appropriate) via reverse proxy, CDN, or framework middleware. Tighten CSP over time; avoid copying permissive examples without adapting to real asset hosts.

## 10. Dependency hygiene

Run your ecosystem’s **dependency and vulnerability scanners** regularly (package manager audits, language-specific tools, or external services). Fix or triage findings; pin versions where reproducibility matters.
