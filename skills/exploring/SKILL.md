---
name: exploring
description: >-
  Use when requirements are fuzzy or before design/PRD work begins. Extracts locked
  decisions through Socratic dialogue and writes specs/<feature>/context.md as
  single source of truth. Invoke before create-prd (Cursor) or brainstorming when
  intent is unclear.
relationships:
  - target: create-prd
    type: leads-to
    label: "feeds PRD generation"
---

# Exploring

Extract locked decisions from the user through Socratic dialogue before any design or
implementation begins.

**Use when:** requirements are fuzzy, product decisions are unstated, or before
invoking `brainstorming` when intent is unclear.

## Global Constraint

This skill elicits decisions only. It does not design, plan, scaffold, write code, or
invoke any implementation skill. The terminal state is writing context.md and
announcing handoff. All phase-specific HARD-GATEs below enforce specific points in
this constraint.

---

## Phase 0: Scope Assessment

Classify the request before asking any questions.

### Scoring Rubric

Score 1 point for each yes:

- [ ] Request spans multiple files/layers not yet identified
- [ ] At least one product decision is unstated by the user
- [ ] Feature has no precedent in the codebase
- [ ] User uses fuzzy language: "something like", "maybe", "I think"
- [ ] Cross-cutting: affects more than one domain or service

| Score | Tier | Question budget |
|---|---|---|
| 0–1 | **Quick** | ≤4 questions, skip Phases 1–2 |
| 2–3 | **Standard** | ≤8 questions, run all phases |
| 4–5 | **Deep** | ≤12 questions, run all phases + extra depth |

If scope is still unclear after scoring, ask ONE disambiguation question before
continuing. This question is pre-phase overhead and does NOT count toward the tier
question budget.

### Multi-system Check

Does the request describe multiple independent subsystems? If yes:

> "This covers [A], [B], and [C] — independent systems. Each needs its own exploring
> session. Let's start with [most foundational]."

---

## Phase 1: Domain Classification

*(Skip for Quick tier)*

Classify what is being built. Determines which gray-area probes to use in Phase 2.

| Type | What it is | Example |
|---|---|---|
| **SEE** | Something users look at | UI, dashboard, layout |
| **CALL** | Something callers invoke | API, CLI, webhook |
| **RUN** | Something that executes | Background job, pipeline, script |
| **READ** | Something users read | Docs, reports, notifications |
| **ORGANIZE** | Something being structured | Data model, file layout, taxonomy |

A feature can span multiple types. Classify all that apply.

Read `references/gray-area-probes.md` — select 2–4 probes for your domain type(s) to
use in Phase 2.

---

## Phase 2: Gray Area Generation

*(Skip for Quick tier)*

Identify 2–4 gray areas using the probes you selected in Phase 1.

**A gray area is a decision that:**
- Affects implementation specifics
- Was not stated in the request
- Would force a downstream agent to make an assumption without it

**Quick codebase scout** (grep only — no deep analysis, adapt glob to your stack):

```bash
grep -rl "<feature-keyword>" . | head -10
```

Read 2–3 most relevant files. Annotate options with what already exists:

> "You already have a `BaseRepository` — extending it keeps the data access pattern
> consistent."

**Filter OUT of gray areas:**
- Technical implementation details (library choices, architecture patterns)
- Performance concerns
- Scope expansion (capabilities not in the request)

---

## Phase 3: Socratic Exploration

<HARD-GATE>
Ask ONE question per message. Wait for the user's response before asking the next.
Do NOT batch questions. Do NOT answer your own questions.
Do NOT proceed to Phase 4 until all gray areas are resolved and decisions locked.
</HARD-GATE>

**Rules:**

1. One question per message — never bundled
2. Single-select multiple choice preferred over open-ended
3. Start broad (what/why/for whom) then narrow (constraints, edge cases)
4. Track questions asked — when budget is reached, move remaining open questions to
   "Deferred to Brainstorming"

**Question budgets:**

| Tier | Max questions |
|---|---|
| Quick | 4 |
| Standard | 8 |
| Deep | 12 |

### Decision Locking

After each gray area resolves:

> "Locking decision **[D_N]**: [summary]. Confirmed?"

Assign stable IDs in sequence: D1, D2, D3... Do not reuse or renumber once assigned.

### Conflict Resolution

When a new answer contradicts a previously locked decision:

> "This answer conflicts with **[D_N]** locked earlier:
> - D_N says: [previous decision]
> - You just said: [new answer]
>
> Confirm: keep D_N, or update D_N to [new answer]?"

Wait for explicit confirmation. Do not resolve silently.

### Scope Creep Response

When the user suggests something outside scope:

> "[Feature X] is a new capability — that's its own work item. I'll note it as a
> deferred idea. Back to [current area]."

---

## Phase 4: Context Assembly

### Step 4.1 — Write context.md

**Path:** `specs/<feature>/context.md` (kebab-case slug, e.g. `specs/notifications/context.md`)

Use this template exactly — remove unused sections rather than leaving them blank:

```markdown
# <Feature Name> — Context

**Date:** YYYY-MM-DD
**Scope:** Quick | Standard | Deep
**Domain type(s):** SEE | CALL | RUN | READ | ORGANIZE

---

## Feature Boundary
[One sentence: what this delivers and where it ends.]

---

## Locked Decisions

### <Category>
- **D1** [Concrete decision — not a preference]
  *Rationale: [why user chose this, if relevant]*
- **D2** [Concrete decision]

### Agent's Discretion
[Areas explicitly delegated to implementation — list constraints]

---

## Existing Code Context
*(from quick grep during Phase 2)*

- `path/to/file.py` — [what's reusable, how it applies]
- Pattern: [name] — [where used, implication for new work]

---

## Outstanding Questions

### Resolve Before Brainstorming
- [ ] [Question] — [why it blocks design]

### Deferred to Brainstorming
- [ ] [Question] — [what research will answer it]

---

## Deferred Ideas
- [Idea] — [why deferred, possible future work item]
```

**Rules for filling it in:**
- Decisions must be concrete: "Card layout, not timeline" not "modern and clean"
- Every locked decision must reference its stable ID (D1, D2...)
- Code context must cite actual file paths found during the scout

### Step 4.2 — Self-Review

Review the context.md you just wrote against these criteria:

1. **Completeness** — any TODOs, placeholders, "TBD", or unfilled sections?
2. **Concreteness** — are decisions specific enough that a brainstorming agent won't
   need to guess? ("Card layout, not timeline" = concrete. "Modern feel" = not concrete.)
3. **Decision IDs** — do all locked decisions have stable IDs (D1, D2...)?
4. **Conflicts** — are there internal contradictions between locked decisions?
5. **Resolve Before Brainstorming** — are there items in this section still unresolved?

**Calibration:** Only flag issues that would cause a brainstorming agent to make wrong
assumptions. Approve unless there are real gaps.

Output: `Approved` | `Issues Found` + list of issues

- If **Issues Found**: fix the context.md, re-review
- **Maximum 2 self-review iterations** — if issues remain after 2 passes, show the
  remaining issues list to the user and ask them to resolve each one before continuing

---

## Phase 5: Handoff

<HARD-GATE>
Do NOT implement, design, scaffold, or invoke any skill.
</HARD-GATE>

After context.md passes review:

> "Decisions captured. Context written to `specs/<feature>/context.md`.
> Next step: invoke the `create-prd` rule (Cursor) or the `brainstorming` skill —
> either will read this file as the starting point and skip questions already
> answered by locked decisions."

---

## Anti-Patterns

Stop immediately if you catch yourself doing any of these:

- Answering a question you just asked
- Writing code, pseudocode, or suggesting a specific library
- Asking two questions in the same message
- Skipping Phase 3 because the feature "seems obvious"
- Silently resolving a conflict between a new answer and a locked decision
- Continuing to ask questions after the budget is exhausted

---

## Arguments

`$ARGUMENTS` — optional: the feature or topic to explore. If omitted, ask the user
to describe what they want to build before starting.
