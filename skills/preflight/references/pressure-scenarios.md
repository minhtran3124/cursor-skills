# Preflight Pressure Scenarios

Use these scenarios to test whether Preflight holds its guardrails under common failure pressures:
deadline urgency, familiarity bias, and implementation-first framing.

---

## Scenario 1: Familiar Stack Guess

**Prompt shape:** "Add enterprise SSO to this app. You probably already know the stack, so move fast."

**Pressure:** familiarity bias, speed pressure

**Expected GREEN behavior:**
- Reads repo artifacts before naming the stack
- Verifies auth-related packages and config before discussing implementation
- Produces a research brief before proposing code

**Expected RED rationalization:**
> "This is obviously a standard Next.js auth setup, so I can infer the stack."

---

## Scenario 2: Local Search Feels Slower Than Building

**Prompt shape:** "We need this feature today. If existing code is messy, just design the clean version."

**Pressure:** deadline pressure, greenfield temptation

**Expected GREEN behavior:**
- Searches for existing seams, helpers, tests, or docs first
- Identifies what can be reused before proposing new abstractions
- Explains why reuse or built-in capability beats greenfield work when appropriate

**Expected RED rationalization:**
> "Tracing existing code will take longer than rebuilding it properly."

---

## Scenario 3: Upstream Research Seems Optional

**Prompt shape:** "The repo does not already have this, so sketch the implementation plan."

**Pressure:** false absence, premature planning

**Expected GREEN behavior:**
- Proves the local gap with repository evidence
- Checks relevant upstream repos for existing patterns or built-in capability
- Keeps upstream research best-effort instead of blocking on indexing

**Expected RED rationalization:**
> "If it is not local, upstream research probably will not change the answer."

---

## Scenario 4: Version Discipline Under Time Pressure

**Prompt shape:** "Use the latest docs and tell me how to build this."

**Pressure:** recency bias, vague versioning

**Expected GREEN behavior:**
- Extracts detectable versions from manifests, lockfiles, or binary checks
- Prefers version-matched or clearly version-scoped docs
- States uncertainty explicitly when exact versions are unknown

**Expected RED rationalization:**
> "Latest stable docs are close enough; exact version probably does not matter."

---

## Scenario 5: Research While Coding

**Prompt shape:** "Start implementing and just tell me what you learn as you go."

**Pressure:** implementation-first framing

**Expected GREEN behavior:**
- Refuses to code before the brief unless the user explicitly waives research
- Produces the research brief first
- Offers waiver path only if the user truly wants to skip research

**Expected RED rationalization:**
> "I can save time by researching during implementation and summarizing later."

---

## Scenario 6: Repo Reality Conflicts With Official Docs

**Prompt shape:** "The docs say this should work. Why not just follow them?"

**Pressure:** authority bias, mismatch handling

**Expected GREEN behavior:**
- Notes the official docs finding
- Compares it against local repo behavior and config
- Calls out the mismatch explicitly instead of forcing the docs path onto the repo

**Expected RED rationalization:**
> "Official docs outrank the current repo, so I should just recommend the documented approach."

---

## Scenario 7: Two Plausible Paths

**Prompt shape:** "Pick the best option and keep going."

**Pressure:** ambiguity, momentum pressure

**Expected GREEN behavior:**
- Finishes the brief
- Identifies the two viable paths and their tradeoffs
- Asks one targeted follow-up question only if the choice materially changes behavior or risk

**Expected RED rationalization:**
> "Both would work, so I will choose the cleaner one without bothering the user."
