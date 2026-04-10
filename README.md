# 🎯 Cursor Skills & Claude Code Agent Teams

A collection of reusable AI skills for [Cursor IDE](https://cursor.com) and [Claude Code](https://claude.com/claude-code), plus an agent team system for coordinated build → review → document workflows.

> 💡 **What are skills?** Think of them as "cheat sheets" you give to an AI — each skill tells it exactly how to do a specific job well. They work in Cursor IDE (as slash commands) and in Claude Code (as reusable methodology that agents reference).

## 📦 What's Inside

### Cursor IDE Skills (`skills/`)

| Skill | What it does |
|-------|-------------|
| 🚶 `walkthrough` | Walks you through git changes file-by-file, like a senior engineer explaining a PR |
| 🔍 `review-diff` | Generates a visual Markdown review of your code changes with architecture diagrams |
| 🧱 `incremental-implementation` | Builds features step-by-step, checking with you before each chunk |
| 📖 `create-wiki` | Generates a single-page HTML wiki documenting your entire project |

### Claude Code Skills (`.claude/skills/`)

Reusable methodology extracted from the skills above — can be used standalone or composed by agents:

| Skill | What it does |
|-------|-------------|
| 🔨 `incremental-build` | Chunk breakdown, progress tracking, implementation methodology |
| 🔍 `code-review` | Review structure, C4 diagrams, Mermaid guidelines, feedback format |
| 📖 `wiki-generator` | Codebase investigation, HTML wiki generation, content writing guidelines |

### Claude Code Agent Team (`.claude/agents/`)

Thin agent wrappers that reference skills and add team coordination:

| Agent | Uses skill | Team role |
|-------|-----------|-----------|
| 🔨 `builder` | `incremental-build` | Implements plan, coordinates with lead for approval, notifies reviewer |
| 🔍 `reviewer` | `code-review` | Reviews changes, sends feedback to builder, re-review loop |
| 📖 `documenter` | `wiki-generator` | Generates wiki after review passes, notifies lead |

## ⚡ Quick Start — Cursor IDE

### Step 1 — Clone this repo

```bash
git clone <this-repo-url>
```

### Step 2 — Copy skills into your project

```bash
mkdir -p your-project/.cursor/skills
cp -r skills/walkthrough your-project/.cursor/skills/
```

### Step 3 — Use in Cursor

Open your project in Cursor, then type a command in the AI chat:

```
/walkthrough          → explain git changes on current branch
/review-diff          → generate a visual review of uncommitted changes
/create-wiki          → generate project documentation
```

For `incremental-implementation`, just describe a plan and ask Cursor to "implement this step by step".

## ⚡ Quick Start — Claude Code Agent Team

### Step 1 — Copy agent config into your project

```bash
cp -r .claude/skills   your-project/.claude/skills
cp -r .claude/agents   your-project/.claude/agents
cp    .claude/settings.json your-project/.claude/settings.json
```

Or install globally:

```bash
cp -r .claude/skills ~/.claude/skills
cp -r .claude/agents ~/.claude/agents
```

### Step 2 — Create a plan

Write a `plan.md` describing what you want to build (see `plan.md` in this repo for an example).

### Step 3 — Start the team in Claude Code

```bash
cd your-project
claude
```

Then paste a workflow prompt from `.claude/agents/WORKFLOWS.md`, for example:

```
Create an agent team to implement and review a feature.
Plan: see plan.md
Spawn "builder" using the builder agent type. Require plan approval.
Spawn "reviewer" using the reviewer agent type.
```

## 🔄 How It Works

### Cursor Skills

```
┌─────────────────────────────────────────────────────────┐
│                    YOUR PROJECT                         │
│                                                         │
│   .cursor/skills/                                       │
│   ├── walkthrough/SKILL.md    ← skill instructions      │
│   ├── review-diff/SKILL.md                              │
│   └── ...                                               │
│                                                         │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                  CURSOR IDE                              │
│                                                         │
│   1. 🧑 You type /walkthrough in AI chat                │
│   2. 🤖 Cursor reads SKILL.md for instructions          │
│   3. ✨ AI follows the skill to do the job              │
│   4. 📄 You get structured, high-quality output         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Claude Code Agent Team

```
┌─────────────────────────────────────────────────────────┐
│                    LEAD (you + Claude Code)              │
│   Creates plan, manages task list, approves chunks      │
└─────┬──────────────┬──────────────┬─────────────────────┘
      │              │              │
      ▼              ▼              ▼
┌──────────┐  ┌──────────┐  ┌──────────────┐
│ BUILDER  │←→│ REVIEWER │  │  DOCUMENTER  │
│          │  │          │  │              │
│ skill:   │  │ skill:   │  │ skill:       │
│ incremen │  │ code-    │  │ wiki-        │
│ tal-build│  │ review   │  │ generator    │
│          │  │          │  │              │
│ output:  │  │ output:  │  │ output:      │
│ progress │  │ .review/ │  │ .docs/       │
│ .md      │  │ review.md│  │ index.html   │
└──────────┘  └──────────┘  └──────────────┘
```

## 📄 Generated Files

These files are **created by skills/agents during execution** — they are not source code you edit by hand:

| File | Created by | Purpose |
|------|-----------|---------|
| `plan.md` | You (the human) | Describes what to build — input for the builder agent/skill |
| `progress.md` | `incremental-build` skill | Implementation log — tracks each chunk's status, files changed, and what was built |
| `.review/review.md` | `code-review` skill | Review document with C4 architecture diagrams, component flowcharts, and code walkthrough |
| `.docs/index.html` | `wiki-generator` skill | Single-page HTML project wiki with dark/light theme, sidebar navigation, and narrative docs |

## 🧪 Example: Using `/walkthrough`

```
You                                    Cursor AI
 │                                         │
 │  1. Make changes or switch branch       │
 │                                         │
 │  2. Type: /walkthrough                  │
 │  ──────────────────────────────────►    │
 │                                         │
 │         3. Lists all changed files      │
 │    ◄────────────────────────────────    │
 │                                         │
 │         4. Explains file #1             │
 │            (before → after + why)       │
 │    ◄────────────────────────────────    │
 │                                         │
 │  5. "next" or ask a question            │
 │  ──────────────────────────────────►    │
 │                                         │
 │         6. Explains file #2 ...         │
 │    ◄────────────────────────────────    │
 │                                         │
 │         7. Summary of all changes       │
 │    ◄────────────────────────────────    │
```

## 📖 Example: Using `/create-wiki`

1. 📂 Open your project in Cursor
2. 💬 Open AI chat and type: `/create-wiki`
3. 🔍 AI explores your codebase automatically
4. 📝 Generates `.docs/index.html`
5. 🌐 Open that file in a browser — done!

## 🌍 Adding Skills to All Projects

Want a skill available everywhere? Copy to the global directory:

```bash
# Cursor IDE
mkdir -p ~/.cursor/skills
cp -r skills/walkthrough ~/.cursor/skills/

# Claude Code
cp -r .claude/skills ~/.claude/skills
cp -r .claude/agents ~/.claude/agents
```

## 🧪 Evaluating Skills

Want to make sure a skill runs correctly and produces consistent output? We have an evaluation framework for that!

```bash
# 1. Set up a test scenario
bash eval/run-eval.sh review-diff

# 2. Open eval/sandbox/ in Cursor and run the skill

# 3. Validate the output
bash eval/run-eval.sh review-diff validate
```

Available scenarios: `review-diff`, `walkthrough`, `create-wiki`, `incremental-implementation`

👉 See [eval/README.md](eval/README.md) for the full step-by-step guide.

## 📁 Folder Structure

```
skills/                                # 🎯 Cursor IDE skills
├── 🚶 walkthrough/SKILL.md
├── 🔍 review-diff/SKILL.md
├── 🧱 incremental-implementation/SKILL.md
└── 📖 create-wiki/
    ├── SKILL.md
    └── references/template.html

.claude/                               # 🤖 Claude Code config (gitignored)
├── skills/                            #   Reusable skill methodology
│   ├── incremental-build.md
│   ├── code-review.md
│   └── wiki-generator.md
├── agents/                            #   Agent team definitions
│   ├── builder.md
│   ├── reviewer.md
│   ├── documenter.md
│   └── WORKFLOWS.md
├── hooks/on-task-complete.sh          #   Quality gate hook
└── settings.json                      #   Agent teams + permissions

eval/                                  # 🧪 Skill evaluation framework
├── run-eval.sh
├── fixture-app/                       #   Test codebase (Flask task API)
└── scenarios/                         #   One per skill (setup + validate + checklist)

plan.md                                # 📝 Example plan (input for builder)
progress.md                            # 📊 Implementation log (generated by builder)
.review/review.md                      # 🔍 Review document (generated by reviewer)
```

> 📌 Cursor skills are `SKILL.md` files — just copy and go. Claude Code skills are in `.claude/skills/` — agents reference them for methodology.

## 🚀 Coming Soon

- 🧪 `test-generator` — Auto-generate unit tests for your code
- 💬 `commit-message` — Write clean commit messages from your diffs
- 🔧 `refactor` — Suggest and apply refactoring patterns
- 🐛 `explain-error` — Break down error messages and suggest fixes
- 📡 `api-docs` — Generate API documentation from route files
- 📦 `migration-guide` — Help migrate between framework versions

> ✨ Have an idea for a new skill? Feel free to contribute!
