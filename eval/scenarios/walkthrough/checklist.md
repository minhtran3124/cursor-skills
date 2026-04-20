# walkthrough evaluation checklist

**Run date:** ___
**Skill version:** ___
**Run #:** ___

## Structure

- [ ] Opened with a table of contents / tour plan
- [ ] Covered all changed files (app.py, routes/tasks.py, middleware/auth.py)
- [ ] Presented changes in a logical order (not random file order)
- [ ] Used Before / After / Why structure for each change

## Accuracy

- [ ] Correctly identifies this as an auth/security addition
- [ ] Explains the `require_auth` decorator purpose
- [ ] Notes that only mutation endpoints (POST, PUT) are protected
- [ ] Notes that GET endpoints remain public (read-only access is open)
- [ ] Mentions the `X-API-Key` header mechanism
- [ ] No hallucinated changes or files

## Quality

- [ ] Tone matches senior engineer walking through a PR
- [ ] Includes helpful diagrams or visualizations (ASCII/text)
- [ ] Explains *why* this architecture (decorator pattern) was chosen
- [ ] Mentions the `AUTH_ENABLED` config flag in app.py
- [ ] Appropriate level of detail (not too shallow, not line-by-line)

## Interaction

- [ ] Offers to continue / dive deeper after initial walkthrough
- [ ] Responds well to follow-up questions (if tested)

## Consistency (fill after 3 runs)

| Dimension | Run 1 | Run 2 | Run 3 | Variance |
|-----------|-------|-------|-------|----------|
| Same files covered | | | | |
| Same logical ordering | | | | |
| Before/After/Why used | | | | |
| Diagrams included | | | | |
| Overall quality (1-5) | | | | |
