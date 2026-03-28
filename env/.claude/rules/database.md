# Database Rules

## Naming conventions

### Tables

- **snake_case** in plural
- Descriptive and clear names

```sql
-- ✅ GOOD
users
blog_posts
user_sessions
order_items

-- ❌ BAD
User
blogPost
tbl_users
```

### Columns

- **snake_case** in singular
- Descriptive names

```sql
-- ✅ GOOD
id
email
created_at
updated_at
user_id (foreign key)

-- ❌ BAD
ID
Email
createdAt
userId
```

### Indexes

- Prefix `idx_` + table + columns

```sql
-- ✅ GOOD
idx_users_email
idx_posts_user_id_created_at
idx_orders_status

-- ❌ BAD
index1
users_email_idx
```

### Foreign keys

- Prefix `fk_` + table + referenced_table

```sql
-- ✅ GOOD
fk_posts_users
fk_comments_posts
fk_order_items_orders

-- ❌ BAD
posts_users
fk1
```

---

## Indexes

### When to create indexes

- **Primary keys** - Automatic
- **Foreign keys** - Always index
- **Frequently queried columns** - WHERE, JOIN, ORDER BY
- **Unique constraints** - email, username, etc.

### When NOT to create indexes

- Small tables (<1000 rows)
- Columns with low cardinality (few unique values)
- Columns rarely used in queries
- Write-heavy tables (indexes slow down INSERT/UPDATE)

### Example

```sql
-- ✅ GOOD - Index on frequently queried columns
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_user_id_created_at ON posts(user_id, created_at);
CREATE INDEX idx_orders_status ON orders(status);

-- ❌ BAD - Unnecessary index
CREATE INDEX idx_users_is_active ON users(is_active); -- Low cardinality (true/false)
```

### Composite indexes

```sql
-- ✅ GOOD - Order matters (most selective first)
CREATE INDEX idx_posts_user_id_status_created_at
ON posts(user_id, status, created_at);

-- Query benefits from this index:
SELECT * FROM posts
WHERE user_id = 123
  AND status = 'published'
ORDER BY created_at DESC;
```

---

## Relations

### Foreign keys

```sql
-- ✅ GOOD - Explicit foreign key with ON DELETE/UPDATE
CREATE TABLE posts (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,  -- MySQL
  -- id SERIAL PRIMARY KEY,                -- PostgreSQL
  -- id INTEGER PRIMARY KEY AUTOINCREMENT, -- SQLite
  user_id INTEGER NOT NULL,
  title VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_posts_users
    FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- ❌ BAD - No foreign key constraint
CREATE TABLE posts (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,  -- No constraint
  title VARCHAR(255)
);
```

### Cascade options

- `ON DELETE CASCADE` - Delete related rows
- `ON DELETE SET NULL` - Set foreign key to NULL
- `ON DELETE RESTRICT` - Prevent deletion if related rows exist
- `ON DELETE NO ACTION` - Same as RESTRICT (default)

```sql
-- Example: User has posts
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,

  CONSTRAINT fk_posts_users
    FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE  -- Delete posts when user is deleted
);

-- Example: Post has author (optional)
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  author_id INTEGER,

  CONSTRAINT fk_posts_authors
    FOREIGN KEY (author_id)
    REFERENCES users(id)
    ON DELETE SET NULL  -- Keep post, set author to NULL
);
```

---

## Timestamps

### Always include

```sql
-- ✅ GOOD - created_at and updated_at
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL
);

-- Note: ON UPDATE CURRENT_TIMESTAMP works in MySQL
-- For PostgreSQL/SQLite, use triggers or handle in application code
```

### Soft deletes

```sql
-- ✅ GOOD - Soft delete with deleted_at
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at TIMESTAMP NULL  -- NULL = not deleted
);

-- Query only active users
SELECT * FROM users WHERE deleted_at IS NULL;

-- Create index for soft deletes
CREATE INDEX idx_users_deleted_at ON users(deleted_at);
```

---

## Migrations

### Best practices

- **Reversible** - Always include `up` and `down`
- **Idempotent** - Can run multiple times safely
- **Small** - One logical change per migration
- **Tested** - Test on staging before production

### Example migration

```sql
-- ✅ GOOD - Reversible migration
-- UP
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX idx_products_name ON products(name);

-- DOWN
DROP INDEX IF EXISTS idx_products_name;
DROP TABLE IF EXISTS products;
```

### Adding columns safely

```sql
-- ✅ GOOD - Add column with default (safe for large tables)
ALTER TABLE users
ADD COLUMN phone VARCHAR(20) DEFAULT NULL;

-- ❌ BAD - Add NOT NULL without default (fails if table has data)
ALTER TABLE users
ADD COLUMN phone VARCHAR(20) NOT NULL;

-- ✅ GOOD - Add NOT NULL in steps
-- Step 1: Add column with default
ALTER TABLE users ADD COLUMN phone VARCHAR(20) DEFAULT '';

-- Step 2: Backfill data
UPDATE users SET phone = '' WHERE phone IS NULL;

-- Step 3: Add NOT NULL constraint
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
```

---

## Query optimization

### Detect missing indexes

Use your database's query analyzer to find:

- Tables with frequent sequential scans
- Slow queries that could benefit from indexes
- Unused indexes that waste space

**PostgreSQL:**

```sql
-- Find tables with sequential scans
SELECT schemaname, tablename, seq_scan, idx_scan
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_scan DESC;
```

**MySQL:**

```sql
-- Find tables without indexes
SELECT TABLE_NAME
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'your_database'
  AND TABLE_NAME NOT IN (
    SELECT DISTINCT TABLE_NAME
    FROM information_schema.STATISTICS
  );
```

### Use EXPLAIN to analyze queries

```sql
-- ✅ GOOD - Analyze query performance
-- Works in PostgreSQL, MySQL, SQLite
EXPLAIN
SELECT u.name, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
WHERE u.created_at > '2024-01-01'
GROUP BY u.id, u.name
ORDER BY post_count DESC
LIMIT 10;

-- PostgreSQL: Use EXPLAIN ANALYZE for actual execution
-- MySQL: Use EXPLAIN ANALYZE (MySQL 8.0.18+)
```

### N+1 query problem

```typescript
// ❌ BAD - N+1 queries
const users = await db.users.findMany();
for (const user of users) {
  user.posts = await db.posts.findMany({ where: { userId: user.id } });
}

// ✅ GOOD - Single query with JOIN
const users = await db.users.findMany({
  include: {
    posts: true,
  },
});

// ✅ GOOD - Two queries (better than N+1)
const users = await db.users.findMany();
const userIds = users.map((u) => u.id);
const posts = await db.posts.findMany({
  where: { userId: { in: userIds } },
});
```

---

## Data types

### Choose appropriate types

```sql
-- ✅ GOOD - Appropriate types
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,  -- Limited length
  description TEXT,  -- Unlimited length
  price DECIMAL(10, 2) NOT NULL,  -- Exact decimal (use for money)
  quantity INTEGER NOT NULL,  -- Whole numbers
  is_active BOOLEAN DEFAULT true,  -- True/false (TINYINT in MySQL)
  metadata JSON,  -- JSON data (supported in most modern DBs)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ❌ BAD - Wrong types
CREATE TABLE products (
  id VARCHAR(255),  -- Use INTEGER for IDs
  name TEXT,  -- Use VARCHAR for limited text
  price FLOAT,  -- Use DECIMAL for money (FLOAT has rounding errors)
  quantity VARCHAR(10),  -- Use INTEGER for numbers
  is_active VARCHAR(5),  -- Use BOOLEAN/TINYINT
  created_at VARCHAR(50)  -- Use TIMESTAMP
);
```

### UUID vs SERIAL

```sql
-- AUTO_INCREMENT (sequential IDs)
-- ✅ Pros: Smaller, faster, sequential
-- ❌ Cons: Predictable, not globally unique
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,  -- MySQL
  -- id SERIAL PRIMARY KEY,                -- PostgreSQL
  -- id INTEGER PRIMARY KEY AUTOINCREMENT, -- SQLite
  email VARCHAR(255)
);

-- UUID (universally unique identifiers)
-- ✅ Pros: Globally unique, unpredictable, distributed systems
-- ❌ Cons: Larger (36 chars vs 4-8 bytes), slower, harder to debug
CREATE TABLE users (
  id CHAR(36) PRIMARY KEY,  -- Store as string
  -- id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- PostgreSQL
  email VARCHAR(255)
);
```

---

## Transactions

### Use transactions for multiple operations

```typescript
// ✅ GOOD - Atomic transaction
await db.transaction(async (tx) => {
  const order = await tx.orders.create({
    data: { userId: 1, total: 100 },
  });

  await tx.orderItems.createMany({
    data: [
      { orderId: order.id, productId: 1, quantity: 2 },
      { orderId: order.id, productId: 2, quantity: 1 },
    ],
  });

  await tx.products.updateMany({
    where: { id: { in: [1, 2] } },
    data: { stock: { decrement: 1 } },
  });
});

// ❌ BAD - No transaction (can leave inconsistent state)
const order = await db.orders.create({
  data: { userId: 1, total: 100 },
});

await db.orderItems.createMany({
  data: [
    { orderId: order.id, productId: 1, quantity: 2 },
    { orderId: order.id, productId: 2, quantity: 1 },
  ],
});
// If this fails, order exists but no items!
```

---

## Security

### SQL injection prevention

```typescript
// ❌ BAD - SQL injection vulnerability
const email = req.body.email;
const query = `SELECT * FROM users WHERE email = '${email}'`;
await db.raw(query);

// ✅ GOOD - Parameterized query
const email = req.body.email;
await db.users.findFirst({
  where: { email },
});

// ✅ GOOD - Raw query with parameters
await db.raw("SELECT * FROM users WHERE email = ?", [email]);
```

### Least privilege principle

```sql
-- ✅ GOOD - Separate users for different operations
-- Read-only user for reporting
CREATE USER reporting_user WITH PASSWORD 'secure_password';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reporting_user;

-- Application user with limited permissions
CREATE USER app_user WITH PASSWORD 'secure_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- ❌ BAD - Application using superuser
-- Don't use postgres/root user in application
```

---

## Connection and operations

- Use **connection pooling** in production; avoid opening a new connection per request
- Set **timeouts** and **statement timeouts** where the engine supports them to avoid hung workers
- For Postgres, consider **ROW LEVEL SECURITY** when multi-tenant data lives in one schema
