# Agent output quality

Rules for code and edits produced during assistance. These are **requirements**, not a checklist to paste into replies.

## Scope and diff hygiene

- Implement **only** what the user asked for. Do not refactor unrelated files, rename symbols across the codebase, or add features “while you’re here.”
- Keep the diff **small and reviewable**. If a change touches more than a few files, there should be a direct reason tied to the request.
- Preserve existing behavior unless the user asked to change it. When fixing a bug, avoid drive-by style or formatting churn in untouched code.

## Fit the codebase

- **Read surrounding code first** and mirror naming, patterns, error handling, imports, and test style already in the repo.
- Do not introduce a new library, pattern, or config convention if the project already has an established equivalent.
- Reuse existing helpers and types instead of duplicating logic or adding parallel abstractions.

## Correctness and robustness

- Handle errors at **appropriate boundaries** (I/O, parsing, external APIs). Do not swallow exceptions or return ambiguous failures without the user asking for that behavior.
- Validate external or untrusted input at the edge; use the project’s validation approach when one exists.
- Avoid **placeholder** implementations passed off as complete (`TODO`, `FIXME`, `return null`, fake IDs) unless the user explicitly wants a stub or skeleton.

## Types and APIs (when the stack uses static types)

- Do not use `any` to silence the compiler. Prefer `unknown`, generics, or narrowing.
- Public functions and exported APIs should have clear, honest types matching real runtime values.

## Comments and documentation

- Do not add comments that restate the code, or long explanatory blocks unless the user asked for documentation.
- Do not leave **AI-style noise**: obvious JSDoc on every function, redundant section headers in small files, or “As an AI…” style prose in code or commits.

## Tests

- When behavior changes or bugs are fixed, update or add tests **if the repo already tests that area**. Follow the project’s runner and patterns; do not invent a second testing style.

## Security and hygiene

- Never commit secrets, tokens, or real credentials. Use env vars or existing config mechanisms.
- Remove temporary debug logging before finishing unless the user wants it.
- For non-trivial changes, run the project’s usual **verify** step (build, lint, tests) when you have shell access; fix what you broke.

## When uncertain

- Prefer **asking a short clarifying question** over guessing requirements or inventing product behavior.
- If the repo’s conventions are unclear from context, state the assumption briefly and proceed consistently.
