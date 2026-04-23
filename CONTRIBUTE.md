# Contributing to Cursor Skills

Thanks for your interest! This project ships AI workflow rules for Cursor IDE, with optional Claude Code skills as conversational on-ramps.

## Author

**Minh Tran** — [@minhtran3124](https://github.com/minhtran3124) · tranhuuminh3124@gmail.com

## Ways to contribute

1. Add a new Cursor rule (`rules/*.mdc`) — the primary product
2. Add a new skill (`skills/<name>/SKILL.md`) — optional on-ramp for Claude Code / Codex / Jules
3. Improve an existing rule or skill (clearer instructions, better output, bug fixes)
4. Add an eval scenario under `eval/scenarios/<name>/`
5. Documentation, typos, or real-world usage feedback

## Adding a Cursor rule

Every rule lives in `rules/<name>.mdc` with this frontmatter:

```yaml
---
description: One-sentence trigger description. Be specific — Cursor's agent matches on this. Mention phrases users might type if relevant.
alwaysApply: false  # true = load every turn; false = agent-decided via description
---
```

**Conventions:**
- Rules write to `specs/<feature>/*.md` so artifacts chain naturally (see [CLAUDE.md](CLAUDE.md) for the full layout)
- If the rule reads upstream artifacts (`context.md`, `prd.md`, `tasks.md`), document it in Step 1 of your process
- Keep the body under ~100 lines; split with headers for phases/steps
- Prefer concrete examples in Markdown code blocks over abstract prose
- If the rule updates `progress.md`, update the Position block too — never just append to Chunks/Log

## Adding a skill

Skills live in `skills/<name>/SKILL.md` with YAML frontmatter:

```yaml
---
name: kebab-case-id
description: >
  When to trigger this skill and what it does.
allowed-tools: Bash(git *), Read, Glob, Grep, Write, Edit
relationships:
  - target: other-skill-id
    type: leads-to | alternative | complements | feeds-from | analyzes
    label: "short phrase"
---
```

See `skills/exploring/` and `skills/walkthrough/` as references. If the skill needs template files (HTML, Markdown), add them to `skills/<name>/references/`.

Update [CLAUDE.md](CLAUDE.md)'s output directories table whenever your rule or skill writes a new artifact path.

## Evaluating

```bash
bash eval/run-eval.sh <skill>          # setup sandbox
# open eval/sandbox/ in Cursor or Claude Code and run the skill
bash eval/run-eval.sh <skill> validate # check output
```

Current coverage: `walkthrough`, `review-diff`, `create-wiki`, `incremental-implementation`. New skills should ship their own `eval/scenarios/<name>/` with `setup.sh`, `validate.sh`, and `checklist.md`.

## Commit style

- Imperative subject under 70 characters (`Add X`, `Fix Y`, not `Added X`)
- Body explains the **why**, not the **what**
- Reference issues with `#N` when relevant

## Pull requests

1. Fork and branch from `v1` (current development branch)
2. Make your changes — keep them focused; one rule/skill per PR when possible
3. Test in a real Cursor project where practical
4. Update [CLAUDE.md](CLAUDE.md) if your change affects output paths, workflow relationships, or the rules/skills table
5. Open a PR with a short summary of what changed and why

## Questions

Open an issue on the project's issue tracker. For larger design discussions, draft a proposal in `specs/<proposal-slug>/context.md` using `/exploring` and reference it in the issue.

---

> Convention note: GitHub auto-links `CONTRIBUTING.md` in the PR flow. This project uses `CONTRIBUTE.md` by preference — `CONTRIBUTING.md` works identically if the convention matters for your fork.
