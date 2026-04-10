# Claude Code Agent Teams — Master Reference Guide

> A comprehensive reference for building effective agent teams in Claude Code.
> Sourced from official documentation (code.claude.com/docs/en/agent-teams, /sub-agents, /hooks) and battle-tested patterns from this project.

---

## Table of Contents

1. [Core Concepts](#1-core-concepts)
2. [Enabling Agent Teams](#2-enabling-agent-teams)
3. [Architecture](#3-architecture)
4. [Agent Definitions](#4-agent-definitions)
5. [Frontmatter Reference](#5-frontmatter-reference)
6. [Skills: Reusable Methodology](#6-skills-reusable-methodology)
7. [Team Communication](#7-team-communication)
8. [Task System](#8-task-system)
9. [Hooks & Quality Gates](#9-hooks--quality-gates)
10. [Workflow Patterns](#10-workflow-patterns)
11. [Display Modes](#11-display-modes)
12. [Permissions & Security](#12-permissions--security)
13. [Token Cost Management](#13-token-cost-management)
14. [Troubleshooting](#14-troubleshooting)
15. [Limitations](#15-limitations)
16. [Design Patterns & Best Practices](#16-design-patterns--best-practices)
17. [Quick-Start Templates](#17-quick-start-templates)

---

## 1. Core Concepts

### What are agent teams?

Agent teams coordinate **multiple Claude Code instances** working together. One session acts as the **team lead**, coordinating work, assigning tasks, and synthesizing results. **Teammates** work independently, each in its own context window, and can communicate directly with each other.

### Agent teams vs subagents

| | Subagents | Agent Teams |
|:--|:--|:--|
| **Context** | Own context window; results return to the caller | Own context window; fully independent |
| **Communication** | Report results back to the main agent only | Teammates message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks where only the result matters | Complex work requiring discussion and collaboration |
| **Token cost** | Lower: results summarized back to main context | Higher: each teammate is a separate Claude instance |
| **Nesting** | Cannot spawn other subagents | Cannot spawn nested teams |

**Rule of thumb:** Use subagents when you need quick, focused workers that report back. Use agent teams when teammates need to share findings, challenge each other, and coordinate on their own.

### The two-layer architecture: Skills + Agents

This project uses a deliberate separation:

```
Skills (.claude/skills/)     = reusable methodology (HOW to do things)
Agents (.claude/agents/)     = thin wrappers (WHO does things + team coordination)
```

**Skills** contain domain expertise — how to chunk work, how to review code, how to generate documentation. They can be used standalone or by any agent.

**Agents** reference a skill and add team coordination — who to message, how to handle feedback, when to mark tasks complete.

This means you can:
- Reuse the same skill across different agents
- Change team coordination without touching the methodology
- Test skills independently of team dynamics

---

## 2. Enabling Agent Teams

Agent teams are **experimental and disabled by default**. Enable them in `.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Or set the environment variable directly:

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

**Requirements:** Claude Code v2.1.32 or later. Check with `claude --version`.

---

## 3. Architecture

An agent team consists of four components:

| Component | Role | Storage |
|:--|:--|:--|
| **Team lead** | Main Claude Code session that creates the team, spawns teammates, and coordinates work | — |
| **Teammates** | Separate Claude Code instances that work on assigned tasks | — |
| **Task list** | Shared list of work items that teammates claim and complete | `~/.claude/tasks/{team-name}/` |
| **Mailbox** | Messaging system for communication between agents | — |

### How teams start

Two paths:
1. **You request a team** — describe the task and team structure in natural language
2. **Claude proposes a team** — Claude suggests a team if your task would benefit; you confirm

Claude never creates a team without your approval.

### Runtime storage

- **Team config:** `~/.claude/teams/{team-name}/config.json` — holds runtime state (session IDs, tmux pane IDs). Auto-generated and auto-updated. **Do not edit by hand** — changes are overwritten.
- **Task list:** `~/.claude/tasks/{team-name}/` — shared task state

The team config contains a `members` array with each teammate's name, agent ID, and agent type. Teammates can read this file to discover other team members.

> **Important:** There is no project-level team config. A file like `.claude/teams/teams.json` in your project directory is NOT recognized as configuration.

---

## 4. Agent Definitions

### File format

Agent definitions are Markdown files with YAML frontmatter. The frontmatter configures the agent; the body becomes additional system prompt instructions.

```markdown
---
name: builder
description: Implements a plan by breaking it into small chunks...
tools: [Bash, Read, Write, Edit, Glob, Grep]
model: sonnet
---

# Builder Agent

Read and follow the methodology in `.claude/skills/incremental-build.md`...

## Team Coordination

### Before coding
- Send your proposed chunk breakdown to the **lead** for approval
- Wait for approval before writing any code
...
```

### Scope and priority

Agent definitions are discovered from multiple locations. Higher-priority locations win when names collide:

| Priority | Location | Scope | How to create |
|:--|:--|:--|:--|
| 1 (highest) | Managed settings | Organization-wide | Deployed via managed settings |
| 2 | `--agents` CLI flag | Current session | Pass JSON when launching |
| 3 | `.claude/agents/` | Current project | Interactive or manual |
| 4 | `~/.claude/agents/` | All your projects | Interactive or manual |
| 5 (lowest) | Plugin's `agents/` directory | Where plugin is enabled | Installed with plugins |

**Project agents** (`.claude/agents/`) are ideal for agents specific to a codebase. Check them into version control so your team shares them.

**User agents** (`~/.claude/agents/`) are personal agents available across all your projects.

**CLI-defined agents** exist for a single session only:

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer...",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

### Using agents as teammates

When spawning a teammate, reference an agent definition by name:

```text
Spawn a teammate using the builder agent type. Require plan approval.
```

The teammate honors the definition's `tools` allowlist and `model`. The definition's body is **appended** to the teammate's system prompt as additional instructions (it does not replace the system prompt).

> **Note:** The `skills` and `mcpServers` frontmatter fields are **NOT applied** when an agent runs as a teammate. Teammates load skills and MCP servers from your project and user settings, the same as a regular session.

Team coordination tools (`SendMessage`, `TaskCreate`, `TaskUpdate`, `TaskGet`) are **always available** to a teammate even when `tools` restricts other tools.

---

## 5. Frontmatter Reference

Complete reference for all YAML frontmatter fields. Only `name` and `description` are required.

| Field | Required | Type | Description |
|:--|:--|:--|:--|
| `name` | Yes | `string` | Unique identifier. Lowercase letters and hyphens. |
| `description` | Yes | `string` | When Claude should delegate to this agent. Write clearly — Claude uses this to decide delegation. Include "use proactively" to encourage automatic delegation. |
| `tools` | No | `list` | Tools the agent can use. Inherits all tools if omitted. See [Tools](#tools-field). |
| `disallowedTools` | No | `list` | Tools to deny, removed from inherited or specified list. |
| `model` | No | `string` | Model to use: `sonnet`, `opus`, `haiku`, a full model ID (e.g., `claude-opus-4-6`), or `inherit`. Default: `inherit`. |
| `permissionMode` | No | `string` | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. |
| `maxTurns` | No | `int` | Maximum agentic turns before the agent stops. |
| `skills` | No | `list` | Skills to load into context at startup. Full content is injected, not just made available. Agents don't inherit skills from parent. **Not applied for teammates.** |
| `mcpServers` | No | `list` | MCP servers available to this agent. String references or inline definitions. **Not applied for teammates.** |
| `hooks` | No | `object` | Lifecycle hooks scoped to this agent. |
| `memory` | No | `string` | Persistent memory scope: `user`, `project`, or `local`. |
| `background` | No | `bool` | Always run as background task. Default: `false`. |
| `effort` | No | `string` | Override session effort level: `low`, `medium`, `high`, `max` (Opus only). |
| `isolation` | No | `string` | Set to `worktree` for a temporary git worktree (isolated repo copy). Auto-cleaned if no changes. |
| `color` | No | `string` | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`. |
| `initialPrompt` | No | `string` | Auto-submitted as first user turn when running as main session agent (`--agent`). Commands and skills are processed. |

### Tools field

The `tools` field accepts any of Claude Code's internal tools:

**Common tool sets:**

| Tool set | Tools | Use for |
|:--|:--|:--|
| Read-only | `Read, Glob, Grep` | Reviewers, researchers |
| Read + execute | `Read, Glob, Grep, Bash` | QA, test runners |
| Full implementation | `Bash, Read, Write, Edit, Glob, Grep` | Builders, developers |
| Agent spawning | `Agent(worker, researcher)` | Coordinators (restrict which agents can be spawned) |

Team coordination tools (`SendMessage`, task tools) are **always available** regardless of `tools` restrictions.

### Model selection

Resolution order (highest priority first):
1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter (when Claude spawns the agent)
3. Agent definition's `model` frontmatter
4. Main conversation's model

**Practical guidance:**
- Use `sonnet` for most teammates — good balance of capability and speed
- Use `opus` for the lead or complex reasoning tasks
- Use `haiku` for fast, simple tasks (exploration, simple validation)

### Memory scopes

| Scope | Location | Use when |
|:--|:--|:--|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific and shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific but should not be committed |

When memory is enabled:
- The agent's system prompt includes instructions for reading/writing to the memory directory
- First 200 lines or 25KB of `MEMORY.md` in the memory directory is injected into context
- `Read`, `Write`, and `Edit` tools are automatically enabled

---

## 6. Skills: Reusable Methodology

Skills are Markdown files in `.claude/skills/` that contain reusable methodology. They are the "how" that agents reference.

### Skill file format

```markdown
---
name: incremental-build
description: Break a plan into small chunks and implement them one at a time...
---

# Incremental Build

Implement a plan by breaking it into small, verifiable chunks...

## Step 1: Read the Plan
...
```

### How agents reference skills

In the agent's body (not frontmatter), instruct it to read the skill:

```markdown
Read and follow the methodology in `.claude/skills/incremental-build.md`
for implementation approach, chunking rules, and progress tracking format.
```

This pattern works because:
- The agent reads the skill file at runtime, getting the latest version
- The skill methodology is loaded into the agent's context
- The agent's own body adds team-specific coordination on top

### Skill design principles

1. **Self-contained** — A skill should work standalone without team context
2. **Step-by-step** — Break methodology into clear, numbered steps
3. **Artifact-producing** — Each skill should produce a concrete output (progress.md, review.md, index.html)
4. **Testable** — You should be able to verify the skill worked by checking its artifact

### Relationship between skills and agents

```
┌─────────────────────────────────────────────────────────┐
│  Agent Definition (.claude/agents/builder.md)            │
│                                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Frontmatter: name, tools, model                   │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Body: "Read .claude/skills/incremental-build.md"  │  │
│  │        + Team coordination rules                    │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  References:                                             │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Skill (.claude/skills/incremental-build.md)        │  │
│  │  = Pure methodology, no team awareness              │  │
│  └────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 7. Team Communication

### Message types

| Method | Description | Use when |
|:--|:--|:--|
| **message** | Send to one specific teammate by name | Direct feedback, handoffs, questions |
| **broadcast** | Send to all teammates simultaneously | Announcements, shared context updates |

**Use broadcast sparingly** — costs scale with team size (each teammate processes the message in its own context).

### Communication patterns

#### Lead -> Teammate
The lead assigns tasks, provides context, and sends approvals/rejections.

#### Teammate -> Lead
Teammates report progress, surface surprises, request decisions.

#### Teammate -> Teammate
Direct peer communication for handoffs, feedback loops, and API contract negotiation.

```text
builder -> reviewer: "Code is ready for review"
reviewer -> builder: "MUST FIX: missing validation on line 25"
builder -> reviewer: "Fixed, ready for re-review"
reviewer -> lead:    "Review passes, all clean"
```

```text
frontend -> backend: "I need POST /api/items with {title, description} -> {id, title, description, created_at}"
backend -> frontend: "Endpoint is live at /api/v1/items, same contract"
```

### How messages are delivered

- Messages arrive **automatically** — the lead doesn't need to poll
- When a teammate finishes and stops, it **automatically notifies** the lead
- The shared task list is visible to all agents

### Interacting with teammates directly

**In-process mode:**
- `Shift+Down` — cycle through teammates
- `Enter` — view a teammate's session
- `Escape` — interrupt a teammate's current turn
- `Ctrl+T` — toggle the task list
- Type to send a message to the selected teammate

**Split-pane mode:**
- Click into a teammate's pane to interact directly
- Each teammate has a full view of its own terminal

### Teammate naming

The lead assigns names when spawning teammates. Use predictable names you can reference in later prompts:

```text
Spawn "backend" using the backend agent type.
Spawn "frontend" using the frontend agent type.
```

Any teammate can message any other by name.

---

## 8. Task System

### Task states

Tasks have three states: **pending**, **in progress**, and **completed**.

Tasks can also have **dependencies**: a pending task with unresolved dependencies cannot be claimed until those dependencies are completed.

### Task assignment

Two models:
- **Lead assigns** — tell the lead which task to give to which teammate
- **Self-claim** — after finishing a task, a teammate picks up the next unassigned, unblocked task

Task claiming uses **file locking** to prevent race conditions when multiple teammates try to claim simultaneously.

### Task tools

These tools are always available to teammates regardless of `tools` restrictions:

| Tool | Purpose |
|:--|:--|
| `TaskCreate` | Create a new task with subject, description, and optional dependencies |
| `TaskUpdate` | Update task status (pending -> in_progress -> completed) |
| `TaskGet` | Read task details and current status |
| `TaskList` | List all tasks and their states |
| `SendMessage` | Send a message to another teammate or the lead |

### Task sizing guidance

| Size | Problem | Symptom |
|:--|:--|:--|
| Too small | Coordination overhead exceeds benefit | Agent finishes instantly, spends more time reporting than working |
| Too large | Too long without check-ins | Wasted effort if approach is wrong |
| Just right | Self-contained with clear deliverable | A function, a test file, a review, a service module |

**Target: 5-6 tasks per teammate** keeps everyone productive without excessive context switching.

---

## 9. Hooks & Quality Gates

Hooks enforce rules at key lifecycle events. Configure them in `.claude/settings.json`.

### Team-relevant hook events

| Hook Event | Fires when | Exit code 2 effect |
|:--|:--|:--|
| `TaskCreated` | A task is created via `TaskCreate` | Task is NOT created; stderr fed back as feedback |
| `TaskCompleted` | A task is marked as completed | Task is NOT marked complete; stderr fed back |
| `TeammateIdle` | A teammate is about to go idle | Teammate continues working; stderr fed back |

### Hook configuration

```json
{
  "hooks": {
    "TaskCompleted": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/on-task-complete.sh \"$TASK_NAME\""
          }
        ]
      }
    ],
    "TeammateIdle": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/prevent-idle.sh"
          }
        ]
      }
    ]
  }
}
```

### Exit code behavior

| Exit Code | Meaning | Effect |
|:--|:--|:--|
| **0** | Success | Action proceeds normally |
| **2** | Blocking error | Action is blocked; stderr text is fed back to the model as feedback |
| **Other** | Non-blocking error | Execution continues; stderr shown in transcript |

### Hook input schema

All team hooks receive JSON via stdin:

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/my-project",
  "permission_mode": "default",
  "hook_event_name": "TaskCompleted",
  "task_id": "task-001",
  "task_subject": "Implement user authentication",
  "task_description": "Add login and signup endpoints",
  "teammate_name": "builder",
  "team_name": "my-project"
}
```

### Hook examples

**Validate task completion (run tests before allowing completion):**

```bash
#!/bin/bash
# .claude/hooks/on-task-complete.sh
TASK_NAME="$1"

case "$TASK_NAME" in
  *builder*|*backend*|*frontend*)
    if command -v pytest &>/dev/null; then
      pytest --tb=short -q 2>&1
      if [ $? -ne 0 ]; then
        echo "Tests failed — cannot mark task complete" >&2
        exit 2
      fi
    fi
    ;;
  *reviewer*)
    REVIEW=".review/review.md"
    if [ ! -f "$REVIEW" ] || [ $(wc -l < "$REVIEW") -lt 10 ]; then
      echo "Review document missing or too short" >&2
      exit 2
    fi
    if ! grep -q '```mermaid' "$REVIEW"; then
      echo "Review must include at least one Mermaid diagram" >&2
      exit 2
    fi
    ;;
esac

exit 0
```

**Prevent teammate from going idle:**

```bash
#!/bin/bash
# .claude/hooks/prevent-idle.sh
TEAMMATE=$(jq -r '.teammate_name' < /dev/stdin)
echo "Teammate $TEAMMATE still has work to do — check task list" >&2
exit 2
```

**Stop a teammate entirely (JSON output):**

```bash
#!/bin/bash
jq -n '{"continue": false, "stopReason": "All assigned work complete"}'
```

### Agent-scoped hooks (in frontmatter)

Hooks can also be defined inside the agent definition. These only run while that specific agent is active:

```yaml
---
name: db-reader
description: Execute read-only database queries
tools: Bash
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-readonly-query.sh"
---
```

Supported events in agent frontmatter: `PreToolUse`, `PostToolUse`, `Stop` (converted to `SubagentStop` at runtime).

### Project-level agent lifecycle hooks

Configure in `settings.json` to respond to agent start/stop in the main session:

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "matcher": "db-agent",
        "hooks": [
          { "type": "command", "command": "./scripts/setup-db.sh" }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          { "type": "command", "command": "./scripts/cleanup.sh" }
        ]
      }
    ]
  }
}
```

---

## 10. Workflow Patterns

### Pattern 1: Build + Review (minimum viable team)

```
Lead ─── spawns ──→ Builder ──── implements ──→ code
                        │
                        └── messages ──→ Reviewer ──── reviews ──→ .review/review.md
                                             │
                                             └── feedback ──→ Builder (fix loop)
```

**When to use:** Any feature implementation that benefits from independent code review.

```text
Create an agent team to implement a feature with code review.

Plan: [paste plan or path to plan.md]

Team:
- Spawn "builder" using the builder agent type. Require plan approval.
- Spawn "reviewer" using the reviewer agent type.

Workflow:
1. Builder proposes chunks, I approve, then builder implements
2. Reviewer reviews changes and sends feedback to builder
3. Builder fixes, reviewer re-reviews until clean
4. Give me a walkthrough summary when done
```

### Pattern 2: Full Pipeline (Build + Review + Document)

Adds documentation generation after review passes.

```text
Create an agent team to implement and review a feature.

Plan: [paste plan or path to plan.md]

Team:
- Spawn "builder" using the builder agent type. Require plan approval.
- Spawn "reviewer" using the reviewer agent type.

Workflow:
1. Builder proposes chunk breakdown — I'll approve before coding starts
2. Builder implements each chunk, logs to progress.md
3. After all chunks done, reviewer generates .review/review.md
4. If reviewer finds issues, send feedback directly to builder to fix
5. After review passes, spawn "documenter" using the documenter agent type
6. When everything is done, give me a walkthrough summary of all changes
```

### Pattern 3: Full-Stack (Frontend + Backend + Review + QA)

For features spanning multiple layers with separate ownership.

```text
Create an agent team to build a full-stack feature with testing.

Plan: [paste plan or path to plan.md]

Team:
- Spawn "backend" using the backend agent type. Require plan approval.
- Spawn "frontend" using the frontend agent type. Require plan approval.
- Spawn "reviewer" using the reviewer agent type.
- Spawn "qa" using the qa agent type.

Workflow:
1. Backend proposes service breakdown — I'll approve before coding starts
2. Frontend proposes component breakdown — I'll approve before coding starts
3. Backend and frontend coordinate API contracts directly
4. Both implement in parallel, logging to progress.md
5. When both are done, reviewer generates .review/review.md
6. If reviewer finds issues, send feedback to the responsible dev to fix
7. After review passes, qa designs test plan — I'll approve
8. QA writes and runs tests, reports bugs to frontend or backend
9. Devs fix bugs, qa re-tests until clean
10. QA generates .qa/report.md
11. Give me a walkthrough summary when done
```

### Pattern 4: Parallel Review (competing perspectives)

Multiple reviewers look at the same code through different lenses.

```text
Create an agent team to review PR #142 from multiple angles.

Team:
- Spawn "security-reviewer" using the reviewer agent type with prompt:
  "Focus exclusively on security: auth, input validation, injection, secrets"
- Spawn "design-reviewer" using the reviewer agent type with prompt:
  "Focus on code design: abstractions, naming, separation of concerns"
- Spawn "test-reviewer" using the reviewer agent type with prompt:
  "Focus on test coverage: missing tests, edge cases, test quality"

Have them each review independently, then synthesize their findings.
```

### Pattern 5: Competing Hypotheses (debugging)

Teammates test different theories in parallel and debate.

```text
Users report the app crashes on startup after the last deploy.
Spawn 3 agent teammates to investigate different hypotheses:
- One checks dependency/environment changes
- One checks recent code changes for logic errors
- One checks configuration and infrastructure

Have them talk to each other to challenge each other's theories.
Update findings in a shared doc.
```

### Pattern 6: Research + Implement

Research first, then implement based on findings.

```text
Create an agent team:
- Spawn "researcher" to investigate how other projects handle rate limiting
  with FastAPI. Read docs, find patterns, report options.
- Wait for researcher to finish.
- Then spawn "builder" using the builder agent type to implement
  the approach researcher recommends.
- Spawn "reviewer" using the reviewer agent type.
```

---

## 11. Display Modes

| Mode | Description | Requirements |
|:--|:--|:--|
| **in-process** (default) | All teammates run inside main terminal. Use `Shift+Down` to cycle. | Any terminal |
| **split panes** | Each teammate gets its own pane. See everyone at once. | tmux or iTerm2 |
| **auto** (default) | Split panes if inside tmux, in-process otherwise | — |

### Configure display mode

**Globally** in `~/.claude.json`:

```json
{
  "teammateMode": "in-process"
}
```

**Per session:**

```bash
claude --teammate-mode in-process
```

### Split-pane setup

- **tmux:** Install via package manager. `tmux -CC` in iTerm2 is recommended.
- **iTerm2:** Install `it2` CLI, enable Python API in Settings > General > Magic.

> **Note:** Split panes are NOT supported in VS Code integrated terminal, Windows Terminal, or Ghostty.

---

## 12. Permissions & Security

### Permission inheritance

Teammates start with the **lead's permission settings**. If the lead runs with `--dangerously-skip-permissions`, all teammates do too.

After spawning, you can change individual teammate modes, but you **cannot set per-teammate modes at spawn time**.

### Pre-approving operations

To reduce permission prompt interruptions, pre-approve common operations in `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(python3 *)",
      "Bash(pytest *)",
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep"
    ]
  }
}
```

### Permission modes for agents

| Mode | Behavior |
|:--|:--|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits and common filesystem commands |
| `auto` | Background classifier reviews commands |
| `dontAsk` | Auto-deny permission prompts (allowed tools still work) |
| `bypassPermissions` | Skip permission prompts (use with caution) |
| `plan` | Read-only exploration mode |

If the parent uses `bypassPermissions`, it takes precedence and cannot be overridden. If the parent uses `auto`, the agent inherits auto mode and any `permissionMode` in frontmatter is ignored.

### Requiring plan approval

For risky tasks, require teammates to plan before implementing:

```text
Spawn an architect teammate to refactor the auth module.
Require plan approval before they make any changes.
```

The teammate works in read-only plan mode until the lead approves. If rejected, the teammate revises and resubmits.

To influence the lead's judgment, give it criteria:
```text
Only approve plans that include test coverage.
Reject plans that modify the database schema.
```

---

## 13. Token Cost Management

Agent teams use **significantly more tokens** than a single session. Each teammate has its own context window, and usage scales linearly with team size.

### When extra tokens are worth it

- Research, review, and exploration tasks
- New feature development with independent modules
- Debugging with competing hypotheses
- Cross-layer coordination (frontend + backend)

### When to use a single session instead

- Sequential tasks with many dependencies
- Same-file edits
- Routine, straightforward tasks
- Quick fixes

### Sizing guidance

- **Start with 3-5 teammates** for most workflows
- **5-6 tasks per teammate** keeps everyone productive
- **Three focused teammates often outperform five scattered ones**
- Scale up only when work genuinely benefits from parallel execution

---

## 14. Troubleshooting

### Teammates not appearing

- In in-process mode, teammates may be running but not visible — press `Shift+Down` to cycle
- Check the task was complex enough to warrant a team
- For split panes, verify tmux is installed: `which tmux`
- For iTerm2, verify `it2` CLI is installed and Python API is enabled

### Too many permission prompts

Pre-approve common operations in your permission settings before spawning teammates.

### Teammates stopping on errors

Check their output using `Shift+Down` or click the pane, then either:
- Give them additional instructions directly
- Spawn a replacement teammate

### Lead shuts down before work is done

Tell the lead to wait:
```text
Wait for your teammates to complete their tasks before proceeding.
```

### Lead starts implementing instead of delegating

```text
Don't implement this yourself. Assign it to the builder teammate.
```

### Orphaned tmux sessions

```bash
tmux ls
tmux kill-session -t <session-name>
```

### Task status lag

Teammates sometimes fail to mark tasks completed, blocking dependent tasks. Check if the work is actually done and update manually or tell the lead to nudge.

---

## 15. Limitations

Current limitations of agent teams (experimental):

| Limitation | Details |
|:--|:--|
| **No session resumption** | `/resume` and `/rewind` don't restore in-process teammates. After resuming, spawn new teammates. |
| **Task status can lag** | Teammates may fail to mark tasks complete, blocking dependencies. |
| **Slow shutdown** | Teammates finish their current request before shutting down. |
| **One team per session** | Clean up the current team before starting a new one. |
| **No nested teams** | Teammates cannot spawn their own teams. Only the lead manages the team. |
| **Lead is fixed** | The session that creates the team is the lead for its lifetime. |
| **Permissions set at spawn** | All teammates start with lead's mode. Can change after spawning but not at spawn time. |
| **Split panes** | Require tmux or iTerm2. Not supported in VS Code terminal, Windows Terminal, or Ghostty. |
| **Skills/MCP in teammates** | `skills` and `mcpServers` frontmatter are NOT applied when an agent runs as a teammate. |

---

## 16. Design Patterns & Best Practices

### Agent definition design

**1. Keep agents thin**

Agents should be thin wrappers around skills. The agent adds team coordination; the skill contains the methodology.

```
agent = skill reference + team coordination rules
```

**2. Structure the body consistently**

Every agent body should have:
- A reference to which skill to follow
- A "Team Coordination" section with clear subsections

**3. Use consistent coordination subsections**

Standard subsections that appear across agents:

| Subsection | Purpose | Agents that use it |
|:--|:--|:--|
| Before coding/testing | Plan approval flow | builder, frontend, backend, qa |
| During implementation | Task status updates | all |
| Responding to review | Fix loop protocol | builder, frontend, backend |
| Responding to QA | Bug fix protocol | frontend, backend |
| Handling surprises | Escalation to lead | builder, frontend, backend |
| Sending feedback | Feedback format | reviewer |
| Re-review loop | Max rounds + escalation | reviewer, qa |
| Completion | Final deliverable + notification | documenter, qa |

**4. Explicit message routing**

Always specify WHO receives messages using **bold names**: `message the **lead**`, `message the **reviewer**`.

**5. Escalation limits**

Set maximum retry loops to prevent infinite cycles:
```markdown
Don't re-review more than 3 rounds — if issues persist, escalate to the **lead**
```

### Team composition

**6. Match team size to task complexity**

| Task complexity | Recommended team |
|:--|:--|
| Simple feature | builder + reviewer (2) |
| Feature with docs | builder + reviewer + documenter (3) |
| Full-stack feature | backend + frontend + reviewer + qa (4) |
| Complex system | backend + frontend + reviewer + qa + documenter (5) |

**7. Avoid file conflicts**

Break work so each teammate owns **different files**. Two teammates editing the same file leads to overwrites.

**8. Use plan approval for risky work**

Always require plan approval when:
- The work touches critical infrastructure
- Multiple teammates will work in parallel
- The scope is large or ambiguous

### Communication best practices

**9. Give teammates enough context at spawn**

Teammates don't inherit the lead's conversation history. Include task-specific details:

```text
Spawn a security reviewer teammate with the prompt: "Review the authentication
module at src/auth/ for security vulnerabilities. Focus on token handling,
session management, and input validation. The app uses JWT tokens stored in
httpOnly cookies."
```

**10. Use predictable teammate names**

Name teammates to match their agent type for clarity:

```text
Spawn "builder" using the builder agent type.
Spawn "reviewer" using the reviewer agent type.
```

This makes message routing obvious in coordination rules.

### Progress tracking

**11. Use shared artifacts for coordination**

| Artifact | Purpose | Producer | Consumer |
|:--|:--|:--|:--|
| `progress.md` | Implementation log | builder, frontend, backend | reviewer, documenter, qa |
| `.review/review.md` | Review findings | reviewer | builder, documenter, qa |
| `.qa/report.md` | Quality report | qa | lead |
| `.docs/index.html` | Project wiki | documenter | lead |

### Shutdown and cleanup

**12. Always clean up through the lead**

```text
Shut down all teammates, then clean up the team.
```

Never let teammates run cleanup — their team context may not resolve correctly.

**13. Shut down teammates before cleanup**

The lead checks for active teammates and fails cleanup if any are running.

---

## 17. Quick-Start Templates

### Minimal agent definition

```markdown
---
name: my-agent
description: What this agent does and when to use it
tools: [Read, Write, Edit, Glob, Grep, Bash]
model: sonnet
---

# My Agent

[Instructions for the agent]

## Team Coordination

### Before starting
- Send your plan to the **lead** for approval
- Wait for approval before starting work

### During work
- Mark tasks as `in_progress` when starting, `completed` when done

### Completion
- Message the **lead** with a summary of what was done
- Mark your task as `completed`
```

### Minimal skill definition

```markdown
---
name: my-skill
description: What methodology this skill contains
---

# My Skill

[Methodology description]

## Step 1: [First step]
...

## Step 2: [Second step]
...

## Step N: [Final step]
...
```

### Minimal settings.json for agent teams

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(python3 *)",
      "Bash(pytest *)",
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep"
    ]
  }
}
```

### Minimal workflow prompt

```text
Create an agent team to [describe task].

Plan: [paste plan or path]

Team:
- Spawn "[name]" using the [agent-type] agent type. Require plan approval.
- Spawn "[name]" using the [agent-type] agent type.

Workflow:
1. [First step]
2. [Second step]
...
N. Give me a walkthrough summary when done
```

---

## Appendix: This Project's Agent Inventory

### Agents

| Agent | Skill | Model | Tools | Role |
|:--|:--|:--|:--|:--|
| builder | incremental-build | sonnet | Bash, Read, Write, Edit, Glob, Grep | Implements plans in chunks |
| reviewer | code-review | sonnet | Bash, Read, Glob, Grep, Write, Edit | Reviews code with diagrams |
| documenter | wiki-generator | sonnet | Bash, Read, Write, Edit, Glob, Grep | Generates HTML wiki |
| frontend | frontend | sonnet | Bash, Read, Write, Edit, Glob, Grep | Builds frontend components |
| backend | backend | sonnet | Bash, Read, Write, Edit, Glob, Grep | Builds backend services |
| qa | qa | sonnet | Bash, Read, Write, Edit, Glob, Grep | Tests and quality reports |

### Communication graph

```
              ┌──────────┐
              │   Lead   │
              └────┬─────┘
         ┌─────────┼──────────┐
         v         v          v
    ┌─────────┐ ┌──────┐ ┌──────────┐
    │ Builder │ │  QA  │ │Documenter│
    │Frontend │ │      │ │          │
    │Backend  │ │      │ │          │
    └────┬────┘ └──┬───┘ └──────────┘
         │         │
         v         │
    ┌─────────┐    │
    │Reviewer │<───┘ (reads review for test focus)
    └─────────┘

Arrows show primary message flow:
  Lead -> all agents (spawn, approve plans, final synthesis)
  Devs -> Reviewer (code ready for review)
  Reviewer -> Devs (feedback, must-fix items)
  Devs -> QA (feature ready for testing)
  QA -> Devs (bug reports)
  Reviewer, QA -> Lead (completion, escalation)
  Documenter reads progress.md + review.md (no direct messages needed)
```
