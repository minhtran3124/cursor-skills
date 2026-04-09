# 🎯 Cursor Skills

A collection of custom AI skills for [Cursor IDE](https://cursor.com). These skills teach Cursor's AI agent how to perform specific tasks better.

> 💡 **New to AI skills?** Think of them as "cheat sheets" you give to Cursor's AI — each skill tells it exactly how to do a specific job well.

## 📦 What's Inside

| Skill | What it does |
|-------|-------------|
| 🚶 `walkthrough` | Walks you through git changes file-by-file, like a senior engineer explaining a PR |
| 🔍 `review-diff` | Generates a visual Markdown review of your code changes with architecture diagrams |
| 🧱 `incremental-implementation` | Builds features step-by-step, checking with you before each chunk |
| 📖 `create-wiki` | Generates a single-page HTML wiki documenting your entire project |

## ⚡ Quick Start

### Step 1 — Clone this repo

```bash
git clone <this-repo-url>
```

### Step 2 — Copy skills into your project

```bash
# Example: add the walkthrough skill to your project
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

## 🔄 How It Works

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

## 🌍 Adding a Skill to All Projects

Want a skill available everywhere? Copy it to the global directory:

```bash
mkdir -p ~/.cursor/skills
cp -r skills/walkthrough ~/.cursor/skills/
```

## 📁 Folder Structure

```
skills/
├── 🚶 walkthrough/                  # Git change explainer
│   └── SKILL.md
├── 🔍 review-diff/                  # Visual diff reviewer
│   └── SKILL.md
├── 🧱 incremental-implementation/   # Step-by-step builder
│   └── SKILL.md
└── 📖 create-wiki/                  # Project wiki generator
    ├── SKILL.md
    └── references/
        └── template.html            # HTML template for wiki

eval/                                 # 🧪 Skill evaluation framework
├── run-eval.sh                       # Entry point
├── fixture-app/                      # Test codebase (Flask task API)
└── scenarios/                        # One per skill (setup + validate + checklist)
```

> 📌 Each skill is just a `SKILL.md` file — that's what Cursor reads to know how the skill works. No install, no config, just copy and go!

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

## 🚀 Coming Soon

- 🧪 `test-generator` — Auto-generate unit tests for your code
- 💬 `commit-message` — Write clean commit messages from your diffs
- 🔧 `refactor` — Suggest and apply refactoring patterns
- 🐛 `explain-error` — Break down error messages and suggest fixes
- 📡 `api-docs` — Generate API documentation from route files
- 👀 `code-review` — Review code like a senior engineer with actionable feedback
- 📦 `migration-guide` — Help migrate between framework versions

> ✨ Have an idea for a new skill? Feel free to contribute!
