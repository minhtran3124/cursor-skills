---
name: wiki-generator
description: Investigate a codebase and generate a single-page HTML project wiki at .docs/index.html. Use when creating project documentation, wikis, or codebase overviews.
---

# Wiki Generator

Generate a comprehensive single-page wiki for any codebase, saved to `.docs/index.html`. The wiki explains the project in narrative prose — not terse reference tables.

## Step 1: Investigate the Codebase

Read broadly before writing anything. Cover these angles:

**Overview & Architecture:**
Read package manifest, README, CLAUDE.md, main entry point. Identify framework, key dependencies, project purpose, high-level architecture.

**Core Business Logic:**
Explore main source directories (services/, models/, lib/, core/, src/). Understand domain logic, key abstractions, data flow patterns.

**API / Routes / CLI:**
Explore API routes, controllers, handlers, middleware, or CLI commands. Map endpoint structure, auth patterns, request flows.

**Data & Infrastructure:**
Investigate database schema, migrations, ORM config, CI/CD pipelines, configuration, environment variables.

**Testing & Integrations:**
Explore test structure, frontend components (if any), third-party integrations, logging, metrics.

Skip areas that don't apply. A CLI tool doesn't need an API routes section.

Also read `progress.md` and `.review/review.md` if they exist — they contain context about recent work.

## Step 2: Plan Sections

**Always include:**
- Overview (what the project is, what it does)
- Architecture (high-level system design)
- Project Structure (annotated file tree)
- Development Commands (how to run, build, test)

**Include if relevant:**
- Tech Stack, Key Flows, API Routes, Database, Services, Configuration, Testing, CI/CD, UI & Pages

Order: architecture before implementation details, core flows before infrastructure.

## Step 3: Generate .docs/index.html

Create `.docs/` directory if needed.

### HTML Structure

Build a self-contained HTML page with:

- `<html>` with dark/light theme support via CSS variables
- `<nav>` sidebar with section links and theme toggle
- `<main>` with hero section and content sections
- Embedded CSS (no external dependencies)
- Theme toggle JavaScript with localStorage persistence

### CSS Variables (light/dark)

```css
:root {
  --bg: #ffffff; --bg-secondary: #f6f8fa; --bg-tertiary: #e8ecf0;
  --text: #1f2328; --text-muted: #656d76; --accent: #0969da;
}
[data-theme="dark"] {
  --bg: #0d1117; --bg-secondary: #161b22; --bg-tertiary: #21262d;
  --text: #e6edf3; --text-muted: #8b949e; --accent: #58a6ff;
}
```

### Layout

- Fixed sidebar: 260px width
- Main content: max-width 900px, centered
- Responsive: sidebar collapses on mobile

### Components Available

**Flow diagrams:**
```html
<div class="flow"><div class="flow-steps">
  <span class="flow-step blue">Step 1</span>
  <span class="flow-arrow">&rarr;</span>
  <span class="flow-step green">Step 2</span>
</div></div>
```

**Callout boxes:**
```html
<div class="callout info"><strong>Note:</strong> message</div>
<div class="callout warn"><strong>Warning:</strong> message</div>
```

**File tree:**
```html
<div class="file-tree">
<span class="dir">project/</span>
├── <span class="dir">src/</span>
│   └── <span class="file">index.ts</span> <span class="comment"># Entry</span>
</div>
```

**Tags:** `<span class="tag tag-green">GET</span>` (green, blue, red, orange, purple)

**Tech badges:** `<span class="tech-badge">Flask</span>`

## Step 4: Content Writing Guidelines

Write like you're explaining to a smart new team member:

- Open each section with a paragraph explaining purpose and context
- Use tables and code blocks as supporting material, not the whole section
- Use callout boxes for warnings, gotchas, non-obvious behavior
- Reference actual file paths, function names, class names
- Explain non-obvious design decisions and tradeoffs
- "Why" before "what" — motivation before mechanics

**Avoid:**
- Sections that are just tables with no explanation
- Bullet-point-only sections
- Generic descriptions that could apply to any project

## Step 5: Refine

After generating, verify:
- Sidebar links match section `id` attributes
- File tree renders correctly
- No sections are terse/listy — rewrite any that are
- Cross-references between sections are accurate
- Footer has project name and generation date
