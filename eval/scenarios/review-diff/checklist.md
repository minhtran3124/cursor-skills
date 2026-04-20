# review-diff evaluation checklist

**Run date:** ___
**Skill version:** ___
**Run #:** ___

## Structure (automated — run validate.sh)

- [ ] `.review/review.md` exists
- [ ] Has system architecture section
- [ ] Has component detail section
- [ ] Has code walkthrough section
- [ ] Contains >= 2 Mermaid diagrams
- [ ] References all 3 changed files

## Accuracy

- [ ] C4 diagram correctly shows Flask app, routes, models, and data flow
- [ ] DELETE endpoint addition is identified as new functionality
- [ ] Description validation change is identified as an improvement
- [ ] `TaskStore.delete()` method is mentioned in the model changes
- [ ] No hallucinated files or functions that don't exist

## Diagram quality

- [ ] Mermaid diagrams render without syntax errors (paste into mermaid.live)
- [ ] Dark theme color specs followed (if specified in skill)
- [ ] Node labels are short and readable (under 25 chars)
- [ ] Diagram accurately represents the code architecture

## Narrative quality

- [ ] Walkthrough explains *why* changes were made, not just *what*
- [ ] Changes are grouped logically (not file-by-file dump)
- [ ] Technical details are accurate (correct function names, routes, etc.)

## Consistency (fill after 3 runs)

| Dimension | Run 1 | Run 2 | Run 3 | Variance |
|-----------|-------|-------|-------|----------|
| Same sections present | | | | |
| Same files covered | | | | |
| Diagram structure similar | | | | |
| Overall quality (1-5) | | | | |
