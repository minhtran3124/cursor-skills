# create-wiki evaluation checklist

**Run date:** ___
**Skill version:** ___
**Run #:** ___

## Structure (automated — run validate.sh)

- [ ] `.docs/index.html` exists
- [ ] File is substantial (> 1KB)
- [ ] Valid HTML with proper structure
- [ ] Has navigation/sidebar
- [ ] Contains CSS styling
- [ ] Has theme toggle

## Content coverage

- [ ] Project overview / description section
- [ ] API endpoints documented (GET, POST, PUT with paths)
- [ ] Task model documented (fields: id, title, description, priority, etc.)
- [ ] Project structure / architecture section
- [ ] Validation rules mentioned
- [ ] Testing setup mentioned
- [ ] No hallucinated features that don't exist in the codebase

## Visual quality (open in browser)

- [ ] Page renders correctly
- [ ] Sidebar navigation works (links scroll to sections)
- [ ] Theme toggle works (light/dark)
- [ ] Responsive layout (resize browser)
- [ ] Text is readable, code blocks are formatted
- [ ] Diagrams / flow visualizations are present and accurate

## Template adherence

- [ ] Uses the bundled template from the skill's references/
- [ ] Hero section with project name
- [ ] Tech badges (Flask, Python, pytest)
- [ ] File tree component used for project structure

## Consistency (fill after 3 runs)

| Dimension | Run 1 | Run 2 | Run 3 | Variance |
|-----------|-------|-------|-------|----------|
| Same sections present | | | | |
| Same endpoints documented | | | | |
| Template components used | | | | |
| Visual quality (1-5) | | | | |
| Overall quality (1-5) | | | | |
