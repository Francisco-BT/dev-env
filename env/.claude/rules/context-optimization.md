# Context Optimization Rules

## Goal
Minimize token usage, avoid unnecessary back-and-forth, and make smart assumptions to reduce costs and improve response times.

---

## 1. Don't ask for clarification when the request is actionable

If the request is explicit enough to act on, act on it. Reserve clarifying questions for genuine ambiguity that would cause wasted work if assumed wrong.

### ❌ BAD - Asking unnecessary questions
```
User: "write unit tests"
→ "Which file? All of them? Only the critical ones? What framework?"
```

### ✅ GOOD - Apply sensible defaults and state your assumption
```
User: "write unit tests"
→ Write tests for the file currently open or most recently discussed.
   Cover happy path + main edge cases. Use the framework already in the project.
   State assumption briefly if non-obvious: "Writing tests for UserService using Jest."
```

### Default assumptions when scope is ambiguous:
| Request | Default behavior |
|---|---|
| "write unit tests" | File in context, critical paths only (green path + main edge cases) |
| "add error handling" | The function/block being discussed, not the entire codebase |
| "fix this" | The selected code or most recently read file |
| "refactor" | Scope limited to what was shown/discussed |
| "add types" | Current file only |
| "clean this up" | Current selection or file, no new features |

---

## 2. Make assumptions explicit, not interrogative

When you must assume something, state it in one line and proceed. Don't ask and wait.

```
// ✅ GOOD
"Assuming you want this for all environments — let me know if only production."
[proceeds with the task]

// ❌ BAD
"Should I do this for all environments or just production?
Also, should I update the tests? And do you want me to update the docs too?"
[waits for answer before doing anything]
```

Only stop and ask when the wrong assumption would cause significant wasted work or irreversible changes.

---

## 3. Don't confirm before reversible actions

Skip "Should I proceed?", "Is that OK?", "Want me to make this change?" for actions that are local and reversible (editing files, writing tests, etc.).

Ask before: destructive operations, force pushes, dropping data, sending external messages.

---

## 4. Don't restate the problem or summarize what you just did

Lead with the action or answer. Skip preamble and trailing summaries.

```
// ❌ BAD
"You asked me to fix the authentication bug. I looked at the code and found
the issue in the token validation. Here's what I changed: [diff]
In summary, I updated the validateToken function to handle expired tokens correctly."

// ✅ GOOD
[makes the change]
"Fixed — `validateToken` was not handling expired tokens, added the expiry check."
```

---

## 5. Be selective with file reads

Read the minimum needed to accomplish the task.

### ❌ BAD
```
Reading entire 5000-line file to find one function
Listing node_modules/ or dist/
Re-reading a file already in context
```

### ✅ GOOD
```
Use Grep to locate the function, then Read only those lines
Use Glob to find relevant files before reading any
Skip re-reading files already in context unless they may have changed
```

---

## 6. Parallel tool calls

When multiple reads/searches are independent, run them in parallel — not sequentially.

```
// ❌ BAD - sequential
Read file1.ts → Read file2.ts → Read file3.ts

// ✅ GOOD - parallel
Read file1.ts + file2.ts + file3.ts in a single message
```

---

## 7. Scope inference for common tasks

| Task | What to read | What to skip |
|---|---|---|
| Bug fix | The specific file/function + direct dependencies | Entire codebase, all tests |
| New feature | 1-2 similar existing features as reference | Unrelated modules |
| Write tests | The file under test | All other test files |
| Refactor | Files with usages (via Grep) | Files without usages |
| Add types | Current file + shared type files | Everything else |

---

## 8. Avoid reading generated/compiled files

Never read unless explicitly asked:
- `*.min.js`, `*.bundle.js`, `*.map`
- `*.d.ts` — read source `.ts` instead
- `dist/`, `build/`, `.next/`
- `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`

---

## 9. Read tests only when relevant

Read test files only when:
- Explicitly asked to write or fix tests
- Debugging a test failure
- Need to understand expected behavior of an undocumented function

Do not read test files to understand general codebase structure.

---

## 10. Maintain `.claude/ignore` per project

Keep build artifacts, dependencies, and media out of context:

```
dist/
build/
out/
.next/
node_modules/
vendor/
*.log
.DS_Store
*.tmp
.cache/
coverage/
.nyc_output/
.env
.env.*
*.mp4
*.mov
*.zip
*.tar.gz
*.pdf
*.png
*.jpg
*.jpeg
*.gif
*.svg
```

---

## Summary

| Principle | Rule |
|---|---|
| Ambiguous scope | Default to the file/selection in context |
| Clarifying questions | Only when wrong assumption = wasted work |
| Confirmations | Only before irreversible/destructive actions |
| File reads | Minimum needed — grep first, read targeted lines |
| Parallel ops | Always batch independent tool calls |
| Summaries | Skip trailing "here's what I did" recaps |
| Generated files | Never read unless explicitly asked |
