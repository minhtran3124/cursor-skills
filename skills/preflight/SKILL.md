---
name: preflight
description: >
  Research-first feature discovery check. Before any implementation, answer five critical
  questions: What is this repo? What exists locally? What does the ecosystem support?
  What do official docs recommend? What is the lightest credible path? Use this skill
  when the user asks to add a feature, build something new, or wants to know the best
  approach — trigger with /preflight or when someone says "how should I build X", "what's the
  best way to implement Y", or "I need to add Z to this project".
relationships:
  - target: incremental-implementation
    type: leads-to
    label: "implement after research"
  - target: review-diff
    type: leads-to
    label: "review what was built"
  - target: compound
    type: leads-to
    label: "save research learnings"
---

# Preflight — Research-First Feature Discovery

Preflight is an anti-reinvention check. Its job is to answer five critical questions before
building: What is this repo? What exists locally? What does the ecosystem support? What
do official docs recommend? What is the lightest credible path?

**HARD-GATE:** Do not write code or edit files until the research brief is complete.
The only exception is an explicit user waiver.

---

## Step 0: Check for Research Waiver

Before anything else, check if the user explicitly waived research:

- Waiver phrases: "skip research", "just build it", "I know the stack", "--waive"
- If waived: acknowledge it, note the accepted risk, skip to implementation
- If not waived: continue to Step 1

---

## Step 1: Read Repo Contracts

Read these files if they exist — they define intent, constraints, and conventions:

- `AGENTS.md`, `CLAUDE.md`, `.cursorrules`
- `README.md`, `CONTRIBUTING.md`
- Any `docs/` or `.docs/` directory

Extract: project purpose, tech constraints, forbidden patterns, contribution rules.

---

## Step 2: Map the Stack from Artifacts

Detect the stack from real files — never guess from folder names alone:

| Artifact | What it tells you |
|---|---|
| `package.json`, `yarn.lock`, `pnpm-lock.yaml` | JS/TS stack, exact dependency versions |
| `Cargo.toml`, `Cargo.lock` | Rust crates and versions |
| `pyproject.toml`, `requirements.txt`, `Pipfile` | Python stack and versions |
| `go.mod` | Go modules and versions |
| `Dockerfile`, `docker-compose.yml` | Runtime environment |
| `.nvmrc`, `.python-version`, `.tool-versions` | Exact runtime versions |

Record: primary language, frameworks, relevant packages, detectable versions.

---

## Step 3: Search Locally Before Inventing

Before proposing anything new, prove it does not already exist:

1. Search for related functions, hooks, utilities, services, middleware
2. Search for related tests — they often reveal hidden seams
3. Search for related config, constants, or type definitions
4. Check existing abstractions and extension points

**Rule:** Never claim something is missing without checking local surfaces first.

---

## Step 4: Check Upstream Patterns

Only after the local picture is clear, look at upstream:

- Search public GitHub repos for how others solved this in similar stacks
- Look for established patterns that fit the detected versions
- Note gaps or mismatches between upstream patterns and this repo

**Rule:** Do not cargo-cult external patterns when local ones exist.

---

## Step 5: Verify Official Docs at Detected Versions

Check official documentation matched to the versions detected in Step 2:

- Prefer version-specific docs over "latest stable" when versions are known
- Identify built-in capabilities that already support the feature
- Note deprecations, migration guides, or breaking changes relevant to this version
- Never cite blog posts when official docs exist

**Rule:** State uncertainty explicitly when exact versions are unknown.

---

## Step 6: Produce the Research Brief

Fill out `references/research-brief-template.md` before any implementation.

### Recommendation Hierarchy

Choose the lightest credible path:

1. **Reuse** existing local functionality
2. **Use** built-in framework or library capability matching repo version
3. **Adapt** an upstream pattern that fits
4. **Build from scratch** only when options 1–3 are insufficient

When recommending option 3 or 4, explicitly state why the higher options were rejected.

### Source Attribution

Every finding must be labeled — never blur types together in narrative:

- `Local` — from this repository
- `Upstream` — from public GitHub repositories
- `Docs` — from official documentation
- `Inference` — conclusions drawn from evidence

---

## Depth Modes

Choose based on risk and scope:

| Mode | When to use | Scope |
|---|---|---|
| **Quick** | Low-risk, obvious local seam, familiar area | Steps 1–3 + brief |
| **Standard** | Default for most features | All steps |
| **Deep** | Cross-cutting, version-sensitive, high-risk changes | All steps + risk analysis + wider repo coverage |

---

## Critical Guardrails

- Never guess stack from folder names alone
- Never claim something missing without checking local surfaces
- Never start coding before brief unless explicitly waived
- Never treat tool unavailability as reason to skip a research step
- Never cite blogs when official docs exist
- Never blur `Local`, `Upstream`, `Docs`, `Inference` together in narratives
- Never force official docs onto a repo when local behavior conflicts — call the mismatch out explicitly

---

## Pressure Scenarios

See `references/pressure-scenarios.md` for scenarios that test whether Xia holds its
guardrails under deadline pressure, familiarity bias, and implementation-first framing.
