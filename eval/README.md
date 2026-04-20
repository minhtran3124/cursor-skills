# 🧪 Skill Evaluation Framework

Test and validate cursor skills to make sure they run correctly and produce consistent output.

## 🤔 What is this?

We have a small test app (a Python task tracker API). Each skill gets its own **scenario** — a setup script that puts the app into the right state for that skill to do its thing. You run the skill in Cursor, then a validation script checks the output.

```
📦 fixture-app       ➜  🔧 setup.sh          ➜  🖥️ run skill        ➜  ✅ validate.sh
(our test app)          (prepares sandbox)       (you do in Cursor)     (checks output)
```

## 📋 Prerequisites

Before you start, make sure you have:

- ✅ **Terminal** — macOS Terminal, iTerm2, or any terminal app
- ✅ **Git** installed (type `git --version` in terminal to check)
- ✅ **Cursor IDE** installed ([download here](https://cursor.com) if needed)
- ✅ The cursor skills copied into your Cursor skills folder (see main README)

> 💡 **No Python or Flask installation needed!** The test app is just source code for the AI to read — you don't need to run it.

## 🚀 Quick Start (your first eval in 5 minutes)

We'll walk through the `review-diff` skill as an example. The steps are the same for every skill!

### Step 1: Open your terminal 💻

Open Terminal and navigate to the project folder:

```bash
cd path/to/cursor-skills
```

### Step 2: Set up the scenario 🔧

Run the setup command for the skill you want to test:

```bash
bash eval/run-eval.sh review-diff
```

You'll see output like this — that means it worked! ✨

```
=== review-diff scenario ready ===
Sandbox: .../eval/sandbox

Changes applied (uncommitted):
 src/models/task.py      |  3 +++
 src/routes/tasks.py     |  8 ++++++++
 ...
```

### Step 3: Open the sandbox in Cursor 🖥️

1. Open **Cursor IDE**
2. Go to **File → Open Folder**
3. Navigate to `eval/sandbox/` inside this project and open it
4. Open the **AI chat panel** (Cmd+L on Mac, Ctrl+L on Windows)

### Step 4: Run the skill ▶️

Type the skill command in Cursor's AI chat:

```
/review-diff
```

Wait for the AI to finish working. This may take a minute or two. ☕

### Step 5: Validate the output ✅

Go back to your terminal and run:

```bash
bash eval/run-eval.sh review-diff validate
```

You'll see a report like this:

```
=== Validating review-diff output ===

--- Artifact ---
  PASS: .review/review.md exists
--- Sections ---
  PASS: Found section matching 'Architecture'
  PASS: Found section matching 'Component'
  PASS: Found section matching 'Walkthrough'
--- Diagrams ---
  PASS: Contains 2 mermaid diagrams (>= 2 expected)

=== Result: 10 passed, 0 failed ===
All structural checks passed. 🎉
```

### Step 6: Manual quality review 📝

Open the checklist file for the skill and go through it:

```
eval/scenarios/review-diff/checklist.md
```

Fill in the date, check each box, and rate the quality. This is the human part — the script checks structure, you check quality!

---

## 📖 Skill-by-Skill Guide

### 1️⃣ review-diff

> Generates a markdown review file with architecture diagrams for uncommitted code changes.

**Setup:**

```bash
bash eval/run-eval.sh review-diff
```

**What the setup does:**
- Creates a fresh copy of the test app
- Applies uncommitted changes: new DELETE endpoint, description validation, and tests

**In Cursor:** type `/review-diff` in the AI chat

**What to expect:** The skill creates a file at `.review/review.md` containing:
- 🏗️ A system architecture diagram (C4 level, Mermaid format)
- 🔀 A component detail flowchart
- 📝 A code walkthrough narrative

**Validate:**

```bash
bash eval/run-eval.sh review-diff validate
```

**What validation checks:**
- `.review/review.md` file exists
- Has all 3 required sections (Architecture, Component, Walkthrough)
- Contains at least 2 Mermaid diagrams
- References all changed files (tasks.py, validators.py, task.py)
- Mentions the DELETE endpoint and validation changes

**Checklist:** `eval/scenarios/review-diff/checklist.md`

---

### 2️⃣ walkthrough

> Walks through code changes step-by-step in a conversational, multi-turn way.

**Setup:**

```bash
bash eval/run-eval.sh walkthrough
```

**What the setup does:**
- Creates a fresh copy of the test app on `main` branch
- Creates a `feature/add-auth` branch with authentication middleware added
- You'll be on the `feature/add-auth` branch when you open Cursor

**In Cursor:** type `/walkthrough` in the AI chat, then tell it:

```
Walk through the changes between main and feature/add-auth
```

**What to expect:** The skill will:
- 📋 Show a table of contents / tour plan
- 🔍 Walk through each changed file with Before / After / Why structure
- 💬 Offer to continue or dive deeper after the initial walkthrough

**Validate:**

```bash
bash eval/run-eval.sh walkthrough validate
```

**What validation checks:**
- The `feature/add-auth` branch exists with the right changes
- At least 3 files are in the diff
- `middleware/auth.py` is present as a new file

> ⚠️ **Note:** Walkthrough output is conversational (it appears in Cursor's chat, not as a file). The validation script checks the scenario setup. Use the **checklist** to evaluate the actual chat output quality!

**Checklist:** `eval/scenarios/walkthrough/checklist.md`

---

### 3️⃣ create-wiki

> Investigates a codebase and generates a single-page project wiki as an HTML file.

**Setup:**

```bash
bash eval/run-eval.sh create-wiki
```

**What the setup does:**
- Creates a fresh copy of the test app with a clean `main` branch
- No changes or branches — the skill reads the codebase as-is

**In Cursor:** type `/create-wiki` in the AI chat

**What to expect:** The skill creates `.docs/index.html` — a full project wiki page with:
- 🎨 Dark/light theme toggle
- 📑 Sidebar navigation
- 🏠 Hero section with project name and tech badges
- 📖 Sections covering endpoints, models, tests, project structure

**Validate:**

```bash
bash eval/run-eval.sh create-wiki validate
```

**What validation checks:**
- `.docs/index.html` file exists and is substantial (> 1KB)
- Valid HTML with proper structure
- Has navigation/sidebar
- References the project (task/tracker/API)
- Covers key topics: endpoints, models, tests, validation
- Contains CSS styling and theme support

> 💡 **Tip:** After validation, open `eval/sandbox/.docs/index.html` in your browser to see the actual wiki! Does it look good? Does navigation work?

**Checklist:** `eval/scenarios/create-wiki/checklist.md`

---

### 4️⃣ incremental-implementation

> Breaks an implementation plan into digestible chunks and builds it step by step with progress tracking.

**Setup:**

```bash
bash eval/run-eval.sh incremental-implementation
```

**What the setup does:**
- Creates a fresh copy of the test app
- Adds a `plan.md` file describing a feature: "Add search and filtering to Task API"

**In Cursor:** type `/incremental-implementation` in the AI chat

When the skill asks for a plan, point it to `plan.md`:

```
Follow the plan in plan.md
```

> ⏳ **This one takes longer!** The skill works in chunks and may ask you questions along the way. Follow its prompts and approve each chunk.

**What to expect:**
- 📊 It proposes a chunk breakdown and asks for confirmation
- 🔨 Implements each chunk one at a time
- 📈 Creates `progress.md` to track what's done
- ✅ Adds search/filter methods and new tests

**Validate:**

```bash
bash eval/run-eval.sh incremental-implementation validate
```

**What validation checks:**
- `progress.md` exists with chunk/step references
- Source files were modified (routes, models)
- Search/filter code is present in `src/`
- Query parameter handling in routes
- New tests were added
- TaskStore has search/filter methods

**Checklist:** `eval/scenarios/incremental-implementation/checklist.md`

---

## 🔁 Running Consistency Checks

AI output can vary between runs. To check if a skill produces **consistent** results, run the same scenario 3 times and compare.

### How to do it:

**Run 1️⃣:**

```bash
bash eval/run-eval.sh review-diff          # setup
# 👉 open sandbox in Cursor, run /review-diff
bash eval/run-eval.sh review-diff validate # check
# 📝 save the validation output and note your quality rating
```

**Run 2️⃣:**

```bash
bash eval/run-eval.sh review-diff          # resets sandbox, start fresh
# 👉 open sandbox in Cursor, run /review-diff again
bash eval/run-eval.sh review-diff validate # check
# 📝 save and compare with Run 1
```

**Run 3️⃣:**

```bash
bash eval/run-eval.sh review-diff          # reset again
# 👉 open sandbox in Cursor, run /review-diff one more time
bash eval/run-eval.sh review-diff validate # check
# 📝 save and compare with Run 1 & 2
```

Then fill in the **consistency table** at the bottom of the skill's `checklist.md`. Look for:

- 🟢 **Low variance** = skill is reliable and consistent
- 🟡 **Medium variance** = some differences but core output is the same
- 🔴 **High variance** = skill is unpredictable, may need prompt improvements

---

## 🗂️ Available Commands

```bash
# See all available scenarios
bash eval/run-eval.sh

# Set up a scenario (pick one)
bash eval/run-eval.sh review-diff
bash eval/run-eval.sh walkthrough
bash eval/run-eval.sh create-wiki
bash eval/run-eval.sh incremental-implementation

# Validate after running the skill
bash eval/run-eval.sh review-diff validate
bash eval/run-eval.sh walkthrough validate
bash eval/run-eval.sh create-wiki validate
bash eval/run-eval.sh incremental-implementation validate
```

---

## 📁 File Structure

```
eval/
├── 🚀 run-eval.sh                          # Entry point script
├── 📦 fixture-app/                          # Base test app (Python/Flask task API)
│   ├── src/
│   │   ├── app.py                           # Flask app factory
│   │   ├── routes/tasks.py                  # API endpoints
│   │   ├── models/task.py                   # Task model + in-memory store
│   │   └── utils/validators.py              # Input validation
│   └── tests/test_tasks.py                  # API tests
├── 🎯 scenarios/
│   ├── review-diff/
│   │   ├── setup.sh                         # Creates sandbox with uncommitted changes
│   │   ├── changes/                         # Modified files to overlay on base
│   │   ├── validate.sh                      # Automated structural checks
│   │   └── checklist.md                     # Manual quality review
│   ├── walkthrough/
│   │   ├── setup.sh                         # Creates sandbox with feature branch
│   │   ├── changes/                         # Auth middleware files
│   │   ├── validate.sh                      # Checks branch setup
│   │   └── checklist.md                     # Chat output quality review
│   ├── create-wiki/
│   │   ├── setup.sh                         # Creates clean sandbox
│   │   ├── validate.sh                      # Checks HTML wiki output
│   │   └── checklist.md                     # Visual + content quality review
│   └── incremental-implementation/
│       ├── setup.sh                         # Creates sandbox + plan.md
│       ├── plan.md                          # Feature plan (search & filtering)
│       ├── validate.sh                      # Checks implementation output
│       └── checklist.md                     # Process + code quality review
└── 🏗️ sandbox/                              # Working directory (recreated each run)
```

---

## ❓ Troubleshooting

### 🔴 "command not found" when running scripts

Make sure you're in the `cursor-skills` project folder:

```bash
cd path/to/cursor-skills
```

### 🔴 Setup says "permission denied"

Make the scripts executable:

```bash
chmod +x eval/run-eval.sh eval/scenarios/*/setup.sh eval/scenarios/*/validate.sh
```

### 🔴 Validation fails immediately with "not found"

The skill didn't create its output file. Check that:
1. You opened `eval/sandbox/` in Cursor (not the main project folder!)
2. The skill actually ran to completion in Cursor
3. The skill you ran matches the scenario you set up

### 🔴 "The sandbox looks empty"

Run the setup command again — it recreates the sandbox from scratch:

```bash
bash eval/run-eval.sh <skill-name>
```

### 🟡 Validation passes but output quality is low

That's exactly what the checklist is for! The validation script only checks **structure** (did the file get created, does it have the right sections). Open the `checklist.md` for that skill and do the **manual quality review**.
