---
name: frontend
description: Build frontend features by planning component architecture, building from inside out, styling responsively, and ensuring accessibility. Use when implementing UI components, pages, or interactive features.
---

# Frontend Component Development

Build frontend features methodically — understand the design, plan the component tree, build from the inside out, then polish for accessibility and performance.

## Step 1: Understand the Requirements

Before writing code, read everything available:

- UI mockups, design specs, or descriptions of what to build
- Existing design system or component library (check for shared components, tokens, themes)
- Existing page structure and routing
- API endpoints the UI will consume (read backend routes, OpenAPI specs, or ask backend)

Identify:
- What components need to be created vs. reused
- What data each component needs and where it comes from
- What user interactions exist (clicks, forms, navigation, real-time updates)

## Step 2: Plan Component Architecture

Before writing code, propose the component breakdown:

```
Component tree:

[1] UserDashboard (page)
    ├── [2] StatsBar — summary metrics, calls GET /api/stats
    ├── [3] ActivityFeed — scrollable list, calls GET /api/activity
    │   └── [4] ActivityCard — single activity item, receives props
    └── [5] QuickActions — action buttons, calls POST endpoints

State: StatsBar and ActivityFeed fetch independently.
Shared: user context from auth provider.
New components: 3, 4, 5. Reuse existing: PageLayout, Card, Button.
```

Wait for confirmation before building.

### Component Design Rules

A good component:
- Has a single responsibility — one reason to change
- Receives data via props, manages only its own local state
- Is reusable if it appears in more than one place
- Has a clear boundary — you can describe what it does in one sentence

Split when:
- A component has more than 3 distinct visual sections
- Logic and presentation are tangled (extract a hook or container)
- The same UI pattern appears twice

Don't split when:
- The "component" would just pass all props through
- It's only used in one place and is under 50 lines

## Step 3: Build From Inside Out

Start with the innermost leaf components and work outward to the page:

**3a. Data layer first** — Define types/interfaces for the data each component needs. If consuming an API, define the response shape and any transformations.

**3b. Leaf components** — Build the smallest, most reusable pieces first (cards, badges, buttons). These should be pure: props in, JSX out, no side effects.

**3c. Composite components** — Assemble leaf components into larger units. Add data fetching, state management, and event handlers at this level.

**3d. Page component** — Wire composites together, handle routing params, set up providers or context if needed.

**3e. Connect to APIs** — Integrate with backend endpoints. Handle loading, error, and empty states for every data fetch:

```
For each API call, implement three states:
- Loading: skeleton or spinner (not blank screen)
- Error: meaningful message with retry option
- Empty: helpful message explaining why there's no data
```

## Step 4: Implement Styling

Follow the project's existing CSS methodology. If none exists, use this priority order:

1. **Existing design tokens** — Use the project's color, spacing, and typography variables
2. **Component-scoped styles** — CSS modules, styled-components, or Tailwind classes
3. **Responsive breakpoints** — Mobile-first, with breakpoints for tablet and desktop

### Responsive Design Rules

- Use relative units (rem, %, vh/vw) over fixed pixels for layout
- Test at 3 widths: mobile (375px), tablet (768px), desktop (1280px)
- Stack layouts vertically on mobile, use grid/flex on larger screens
- Touch targets: minimum 44x44px on mobile
- Never use horizontal scroll for primary content

### Styling Checklist

- Colors use design tokens / CSS variables (not hardcoded hex)
- Typography follows the scale (don't invent font sizes)
- Spacing is consistent (use the spacing scale, not arbitrary values)
- Dark mode: if the project supports themes, verify both

## Step 5: Add Interactivity

**Forms** — Validate on blur and on submit. Show inline errors next to the relevant field. Disable submit button while request is in flight. Show success/failure feedback after submission.

**Navigation** — Use the project's router. Preserve scroll position where expected. Handle deep links and browser back/forward.

**Optimistic updates** — For actions where latency matters (likes, toggles, reordering), update the UI immediately and revert on failure.

**Real-time** — If the feature needs live updates (websockets, SSE, polling), encapsulate the connection logic in a hook or service, not in the component itself.

## Step 6: Accessibility and Polish

### Accessibility (WCAG 2.1 AA)

- **Semantic HTML** — Use `<button>`, `<nav>`, `<main>`, `<form>`, `<label>` — not divs with click handlers
- **Keyboard navigation** — Every interactive element reachable via Tab. Escape closes modals/dropdowns. Enter/Space activates buttons
- **Screen readers** — Add `aria-label` for icon-only buttons, `aria-live` for dynamic content, `role` attributes for custom widgets
- **Color contrast** — 4.5:1 minimum for text, 3:1 for large text and UI components
- **Focus indicators** — Visible focus ring on all interactive elements. Never `outline: none` without a replacement

### Performance

- Lazy load routes and heavy components (images, charts, modals)
- Memoize expensive renders only when profiling shows a problem — don't premature-optimize
- Debounce search inputs and resize handlers (300ms default)
- Use `loading="lazy"` for below-the-fold images

## Handling API Contracts

When the backend endpoint you need doesn't exist yet or its shape is unclear:

1. Define the interface you need in a types file
2. Build the component against that interface using mock data
3. Message **backend** with the exact request/response shape you need
4. Replace mocks with real API calls once the endpoint is ready

Never block on a missing endpoint — build the UI against a typed interface and swap in the real call later.

## Log to progress.md

After completing each component or group of related components, append:

```markdown
---

## Frontend: [Component/Feature Name]

**Status:** Complete
**Files changed:** `src/components/UserCard.tsx` (created), `src/pages/Dashboard.tsx` (modified)

### What changed
[2-4 sentences: what was built, what data it displays, how it connects to the rest of the app]
```
