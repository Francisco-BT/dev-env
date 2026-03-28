# Context Optimization Rules

## Goal

Minimize token usage and avoid unnecessary context consumption to reduce costs and improve response times.

**Tool names vary by product** (e.g. file viewers, search, codebase search). Apply the same ideas: prefer **grep/search → small read ranges** over opening entire large files; **parallelize** independent reads; keep heavy paths out of index via `.claude/ignore` (or equivalent).

## 1. Be selective with file reads

### ❌ BAD - Reading entire large files
```
"Show me the view tool implementation"
→ Reads entire 5000-line file when only 50 lines are relevant
```

### ✅ GOOD - Use targeted searches
```
"Show me the view tool implementation"
→ Use view with search_query_regex to find specific function
→ Or use view_range to read only relevant lines
```

## 2. Avoid redundant file reads

### ❌ BAD - Re-reading files already in context
```
1. Read file.ts
2. Make changes
3. Read file.ts again (unnecessary - already in context)
```

### ✅ GOOD - Track what's in context
```
1. Read file.ts
2. Make changes based on existing context
3. Only re-read if file might have changed externally
```

## 3. Use codebase-retrieval efficiently

### ❌ BAD - Vague or overly broad queries
```
"Show me all the code"
"Find everything related to users"
"Get all files in the project"
```

### ✅ GOOD - Specific, targeted queries
```
"Find the UserService class implementation"
"Show authentication middleware functions"
"Locate the database connection configuration"
```

## 4. Limit directory listings

### ❌ BAD - Listing huge directories
```
Dependency trees (install dirs), generated output dirs, or entire monorepo roots without a path filter
```

### ✅ GOOD - Target specific paths
```
Open the smallest subtree that contains the feature (e.g. `src/services/`)
Prefer single files when possible
Use ignore rules (e.g. `.claude/ignore`) for artifacts your stack always regenerates
```

## 5. Exclude unnecessary files

### Maintain an ignore file (e.g. `.claude/ignore`)

Adapt names to your stack. Typical categories:

```
# Build / compile output
dist/
build/
out/
target/
.next/
*.egg-info/

# Installed dependencies
node_modules/
vendor/bundle/
.venv/
__pypackages__/

# Logs, caches, OS noise
*.log
.DS_Store
*.tmp
.cache/

# Coverage output
coverage/

# Secrets (security + less noise)
.env
.env.*

# Large binaries / media (unless the task needs them)
*.mp4
*.zip
*.tar.gz
*.pdf
```

Add lockfiles or manifests here **only** if you rarely need them in context; many teams prefer to keep one lockfile readable for version bumps.

## 6. Use search instead of full reads

### ❌ BAD - Reading to find something
```
Read entire 2000-line file to find one function
```

### ✅ GOOD - Search first, then read
```
Use view with search_query_regex="function myFunction"
Then use view_range to read just that section
```

## 7. Batch related operations

### ❌ BAD - Multiple separate tool calls
```
Read file A, then file B, then file C as three sequential steps when they are independent
```

### ✅ GOOD - Parallel tool calls when possible
```
Read independent files in one parallel batch
```

## 8. Avoid reading generated/compiled code

### Files to avoid:
- Minified or bundled artifacts (`*.min.js`, `*.bundle.js`, etc.)
- Generated declaration or stub files (e.g. `*.d.ts`) unless the task is about types
- Source maps
- Compiled output trees (`dist/`, `build/`, …)
- Lockfiles when the question is not about dependency versions

### When you need type info:
- Read **source** in the authoring language, not generated stubs
- Use semantic search to find interfaces and definitions

## 9. Smart test file handling

### ❌ BAD - Reading all test files
```
Glob every `*test*` file to “learn the codebase”
```

### ✅ GOOD - Read tests only when needed
```
Open tests when:
- Explicitly asked to write/fix tests
- You need expected behavior for a specific module
- Debugging a failing test run
```

## 10. Optimize for common tasks

### For bug fixes:
1. Use codebase-retrieval to find relevant code
2. Read only the specific file/function
3. Check related tests if needed
4. Make targeted changes

### For new features:
1. Use codebase-retrieval to find similar patterns
2. Read 2-3 example files max
3. Create new code based on patterns
4. Don't read entire codebase

### For refactoring:
1. Use codebase-retrieval to find all usages
2. Read files with usages
3. Make changes
4. Don't re-read unless necessary

## Context usage guidelines

### Low usage (<30%): ✅ Optimal
- Continue normal operations
- Can afford to read additional context if needed

### Medium usage (30-60%): ⚠️ Be mindful
- Avoid reading large files
- Use search and view_range
- Clear unnecessary context if possible

### High usage (60-80%): 🔶 Optimize
- Only read essential files
- Use very targeted searches
- Avoid directory listings
- Consider summarizing instead of full reads

### Critical usage (>80%): 🔴 Minimize
- Emergency mode: minimal reads only
- Summarize instead of reading
- Ask user for specific files if needed
- Avoid any non-essential operations

## Best practices summary

✅ DO:
- Use .claude/ignore extensively
- Use search_query_regex for targeted reads
- Use view_range for partial file reads
- Batch parallel operations
- Read source files, not generated ones
- Use codebase-retrieval with specific queries

❌ DON'T:
- Read entire large files unnecessarily
- List huge directories
- Read generated/compiled code
- Re-read files already in context
- Use vague codebase-retrieval queries
- Read all tests unless specifically needed

