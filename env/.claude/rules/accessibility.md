# Accessibility (A11y) Rules

These rules follow [WCAG 2.2](https://www.w3.org/TR/WCAG22/) principles. Default target: **Level AA** for text contrast and common UI patterns unless the product explicitly requires AAA.

## Core principles (WCAG)

### 1. Perceivable

Users must be able to perceive the information

### 2. Operable

Users must be able to use the interface

### 3. Understandable

Information must be clear

### 4. Robust

Must work across different technologies (screen readers, etc.)

---

## Semantic HTML

### Use correct elements

```html
<!-- ✅ GOOD - Semantic -->
<header>
  <nav>
    <ul>
      <li><a href="/">Home</a></li>
    </ul>
  </nav>
</header>

<main>
  <article>
    <h1>Title</h1>
    <p>Content</p>
  </article>
</main>

<footer>
  <p>© Company</p>
</footer>

<!-- ❌ BAD - All divs -->
<div class="header">
  <div class="nav">
    <div class="link">Home</div>
  </div>
</div>
```

### Semantic elements to use

- `<header>` - Page/section header
- `<nav>` - Navigation
- `<main>` - Main content (only one per page)
- `<article>` - Independent content
- `<section>` - Thematic grouping
- `<aside>` - Sidebar/related content
- `<footer>` - Page/section footer
- `<button>` - Interactive buttons
- `<a>` - Links (navigation)

---

## Heading hierarchy

### Correct structure

```html
<!-- ✅ GOOD - Logical hierarchy -->
<h1>Page Title</h1>
<h2>Section 1</h2>
<h3>Subsection 1.1</h3>
<h3>Subsection 1.2</h3>
<h2>Section 2</h2>
<h3>Subsection 2.1</h3>

<!-- ❌ BAD - Skipping levels -->
<h1>Page Title</h1>
<h3>Section 1</h3>
<!-- Skipped h2 -->
<h2>Section 2</h2>
```

### Rules:

- Only one `<h1>` per page
- Don't skip heading levels
- Don't use headings for styling (use CSS)
- Headings should describe content

---

## Forms

### Always use labels

```html
<!-- ✅ GOOD - Explicit label -->
<label for="email">Email:</label>
<input type="email" id="email" name="email" required />

<!-- ✅ GOOD - Implicit label -->
<label>
  Email:
  <input type="email" name="email" required />
</label>

<!-- ❌ BAD - No label -->
<input type="email" placeholder="Email" />
```

### Form validation

```html
<!-- ✅ GOOD - Accessible error messages -->
<label for="password">Password:</label>
<input
  type="password"
  id="password"
  aria-describedby="password-error"
  aria-invalid="true"
/>
<span id="password-error" role="alert">
  Password must be at least 8 characters
</span>
```

### Required fields

```html
<!-- ✅ GOOD - Multiple indicators -->
<label for="name"> Name <span aria-label="required">*</span> </label>
<input type="text" id="name" required aria-required="true" />
```

---

## Images

### Alt text

```html
<!-- ✅ GOOD - Descriptive alt -->
<img src="dog.jpg" alt="Golden retriever playing in the park" />

<!-- ✅ GOOD - Decorative image -->
<img src="decoration.svg" alt="" role="presentation" />

<!-- ❌ BAD - No alt -->
<img src="dog.jpg" />

<!-- ❌ BAD - Useless alt -->
<img src="dog.jpg" alt="image" />
```

### Complex images

```html
<!-- ✅ GOOD - Detailed description -->
<figure>
  <img src="chart.png" alt="Sales chart" aria-describedby="chart-desc" />
  <figcaption id="chart-desc">
    Bar chart showing sales increased 25% from Q1 to Q2
  </figcaption>
</figure>
```

---

## ARIA (Use sparingly)

### When to use ARIA

- Only when semantic HTML isn't enough
- For dynamic content
- For custom widgets

### Common ARIA attributes

```html
<!-- Roles -->
<div role="button" tabindex="0">Click me</div>
<div role="alert">Error message</div>
<div role="navigation">...</div>

<!-- States -->
<button aria-pressed="true">Toggle</button>
<div aria-expanded="false">Collapsed content</div>
<input aria-invalid="true" />

<!-- Properties -->
<button aria-label="Close dialog">×</button>
<input aria-describedby="help-text" />
<div aria-live="polite">Status updates</div>
```

### ARIA best practices

```html
<!-- ✅ GOOD - Semantic HTML first -->
<button>Click me</button>

<!-- ❌ BAD - Unnecessary ARIA -->
<div role="button" tabindex="0">Click me</div>

<!-- ✅ GOOD - ARIA when needed -->
<button aria-label="Close" aria-pressed="false">
  <svg>...</svg>
</button>
```

---

## Keyboard navigation

### All interactive elements must be keyboard accessible

```html
<!-- ✅ GOOD - Native button (keyboard accessible) -->
<button onclick="doSomething()">Click</button>

<!-- ❌ BAD - Div not keyboard accessible -->
<div onclick="doSomething()">Click</div>

<!-- ✅ GOOD - Div made keyboard accessible -->
<div
  role="button"
  tabindex="0"
  onclick="doSomething()"
  onkeypress="handleKeyPress(event)"
>
  Click
</div>
```

### Tab order

```html
<!-- ✅ GOOD - Natural tab order -->
<input type="text" />
<input type="email" />
<button>Submit</button>

<!-- ❌ BAD - Custom tab order (avoid) -->
<input type="text" tabindex="3" />
<input type="email" tabindex="1" />
<button tabindex="2">Submit</button>
```

### Skip links

```html
<!-- ✅ GOOD - Skip to main content -->
<a href="#main-content" class="skip-link"> Skip to main content </a>

<nav>...</nav>

<main id="main-content">...</main>
```

---

## Color and contrast

### WCAG AA requirements

- **Normal text**: 4.5:1 contrast ratio
- **Large text** (18pt+ or 14pt+ bold): 3:1 contrast ratio
- **UI components**: 3:1 contrast ratio

```css
/* ✅ GOOD - Sufficient contrast */
.text {
  color: #333; /* Dark gray */
  background: #fff; /* White */
  /* Contrast ratio: 12.6:1 */
}

/* ❌ BAD - Insufficient contrast */
.text {
  color: #999; /* Light gray */
  background: #fff; /* White */
  /* Contrast ratio: 2.8:1 - FAILS */
}
```

### Don't rely on color alone

```html
<!-- ❌ BAD - Color only -->
<span style="color: red;">Error</span>
<span style="color: green;">Success</span>

<!-- ✅ GOOD - Color + icon/text -->
<span class="error">
  <svg aria-hidden="true">❌</svg>
  Error: Invalid input
</span>
<span class="success">
  <svg aria-hidden="true">✅</svg>
  Success: Saved
</span>
```

---

## Focus indicators

### Visible focus

```css
/* ❌ BAD - Removing focus outline */
button:focus {
  outline: none;
}

/* ✅ GOOD - Custom focus style */
button:focus {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

/* ✅ GOOD - Modern focus-visible */
button:focus-visible {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}
```

---

## Dynamic content

### Live regions

```html
<!-- ✅ GOOD - Announce updates -->
<div aria-live="polite" aria-atomic="true">
  <p>Items in cart: <span id="cart-count">3</span></p>
</div>

<!-- For urgent updates -->
<div role="alert" aria-live="assertive">Error: Payment failed</div>
```

### Loading states

```html
<!-- ✅ GOOD - Accessible loading -->
<button aria-busy="true" aria-label="Loading...">
  <span aria-hidden="true">⏳</span>
  Loading
</button>
```

---

## Modals and dialogs

### Accessible modal

```html
<div
  role="dialog"
  aria-labelledby="dialog-title"
  aria-describedby="dialog-desc"
  aria-modal="true"
>
  <h2 id="dialog-title">Confirm Delete</h2>
  <p id="dialog-desc">Are you sure you want to delete this item?</p>

  <button>Cancel</button>
  <button>Delete</button>
</div>
```

### Focus management

```javascript
// ✅ GOOD - Trap focus in modal
const modal = document.querySelector('[role="dialog"]');
const focusableElements = modal.querySelectorAll(
  'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])',
);
const firstElement = focusableElements[0];
const lastElement = focusableElements[focusableElements.length - 1];

// Focus first element when modal opens
firstElement.focus();

// Trap focus
modal.addEventListener("keydown", (e) => {
  if (e.key === "Tab") {
    if (e.shiftKey && document.activeElement === firstElement) {
      e.preventDefault();
      lastElement.focus();
    } else if (!e.shiftKey && document.activeElement === lastElement) {
      e.preventDefault();
      firstElement.focus();
    }
  }

  // Close on Escape
  if (e.key === "Escape") {
    closeModal();
  }
});
```

---

## Testing tools

### Automated testing

- **Browser audits** — built-in or extension-based accessibility audits (Lighthouse-style scores, axe, WAVE, etc.)
- **CLI / CI** — run the same rules against a **deployed or locally served URL** your pipeline already uses (no fixed port)
- **Libraries** — stack-specific testing helpers (e.g. React Testing Library with a11y queries, Cypress/Playwright plugins)

### Manual testing

- Keyboard only (no pointer)
- Screen reader (platform-native or common third-party tools)
- Browser zoom (e.g. 200%+)
- High contrast / forced-colors where relevant
- Light and dark themes if the product ships both

### Automated testing in CI/CD

Point your CI job at the URL under test (preview, staging, or ephemeral app URL). Use whatever the project already standardizes on (bundled CLI, containerized audit tool, or E2E suite with accessibility assertions)—avoid hardcoding hosts or package-manager invocations in shared rules.
