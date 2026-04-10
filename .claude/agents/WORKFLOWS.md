# Agent Team Workflows

Example prompts to start agent teams using the builder, reviewer, and documenter agents.

## Build + Review + Document (full pipeline)

```
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

## Build + Review (no docs)

```
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

## Review + Document (existing code)

```
Create an agent team to review recent changes and update docs.

Team:
- Spawn "reviewer" using the reviewer agent type to review changes on this branch
- Spawn "documenter" using the documenter agent type

Workflow:
1. Reviewer generates .review/review.md for current branch changes
2. After review, documenter generates .docs/index.html
3. Give me a walkthrough of the review findings
```

## Full-Stack Build (frontend + backend + QA)

```
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

## Backend Build + Review + QA

```
Create an agent team to build a backend service with review and testing.

Plan: [paste plan or path to plan.md]

Team:
- Spawn "backend" using the backend agent type. Require plan approval.
- Spawn "reviewer" using the reviewer agent type.
- Spawn "qa" using the qa agent type.

Workflow:
1. Backend proposes service breakdown — I'll approve
2. Backend implements, logs to progress.md
3. Reviewer reviews and sends feedback to backend
4. Backend fixes, reviewer re-reviews until clean
5. QA designs test plan, writes tests, reports bugs to backend
6. QA generates .qa/report.md when all critical bugs are resolved
7. Give me a walkthrough summary when done
```

## Frontend Build + Review

```
Create an agent team to build frontend components with review.

Plan: [paste plan or path to plan.md]

Team:
- Spawn "frontend" using the frontend agent type. Require plan approval.
- Spawn "reviewer" using the reviewer agent type.

Workflow:
1. Frontend proposes component breakdown — I'll approve
2. Frontend implements, logs to progress.md
3. Reviewer reviews and sends feedback to frontend
4. Frontend fixes, reviewer re-reviews until clean
5. Give me a walkthrough summary when done
```

## Parallel Review (competing perspectives)

```
Create an agent team to review PR #[number] from multiple angles.

Team:
- Spawn "security-reviewer" using the reviewer agent type with prompt:
  "Focus exclusively on security: auth, input validation, injection, secrets"
- Spawn "design-reviewer" using the reviewer agent type with prompt:
  "Focus on code design: abstractions, naming, separation of concerns"
- Spawn "test-reviewer" using the reviewer agent type with prompt:
  "Focus on test coverage: missing tests, edge cases, test quality"

Have them each review independently, then synthesize their findings.
```
