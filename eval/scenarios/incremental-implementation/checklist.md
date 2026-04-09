# incremental-implementation evaluation checklist

**Run date:** ___
**Skill version:** ___
**Run #:** ___

## Structure (automated — run validate.sh)

- [ ] `progress.md` exists with chunk tracking
- [ ] Source files modified (routes, models)
- [ ] Search/filter code implemented
- [ ] New tests added
- [ ] TaskStore has search/filter methods

## Process quality

- [ ] Proposed chunk breakdown before implementing (asked for confirmation)
- [ ] Chunks were right-sized (1-4 files each, single abstraction layer)
- [ ] Each chunk produced observable output
- [ ] Used AskUserQuestion for feedback at checkpoints
- [ ] Before/After diagrams provided for each chunk

## Implementation accuracy

- [ ] `q` parameter searches title (case-insensitive)
- [ ] `priority` parameter filters by exact priority
- [ ] `completed` parameter filters by completion status
- [ ] Parameters can be combined
- [ ] GET /api/tasks with no params still returns all tasks (backward compat)
- [ ] No regressions — existing tests still pass

## Progress log quality

- [ ] progress.md tracks each chunk with clear status
- [ ] Includes what was done in each chunk
- [ ] Includes verification results per chunk
- [ ] Final summary / wrap-up section

## Consistency (fill after 3 runs)

| Dimension | Run 1 | Run 2 | Run 3 | Variance |
|-----------|-------|-------|-------|----------|
| Number of chunks | | | | |
| Same chunk breakdown | | | | |
| All features implemented | | | | |
| Tests pass | | | | |
| Overall quality (1-5) | | | | |
