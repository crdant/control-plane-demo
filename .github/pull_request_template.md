<!-- 
PULL REQUEST TEMPLATE

This template follows a conversational, practitioner-focused style that combines technical 
precision with approachable explanations. Write as an experienced developer sharing knowledge 
with colleagues—direct and no-nonsense, but not dry or overly formal.

TITLE REQUIREMENTS (ALL must pass):
- Start with verb ending in 's' (Adds, Fixes, Updates, Implements, Creates, Removes)
- ≤ 40 characters total
- Present tense only (no "Added", "Will add", etc.)
- No first person ("I", "We", "My")
- Example: "Adds user authentication system"

BODY REQUIREMENTS:
- Use exact markdown headers below (case sensitive, correct dash count)
- TL;DR: 1-2 sentences maximum, start with DIFFERENT verb than title
- Details: Explain WHY the change was needed, not just WHAT changed
- No forbidden phrases: "this PR", "this change", "this commit", "this update"
- Present tense throughout
- Technical precision: include exact versions, commands, file paths in `backticks`

BEFORE SUBMITTING:
- [ ] Title ≤ 40 characters with verb ending in 's'
- [ ] TL;DR starts with different verb than title
- [ ] No banned phrases in body
- [ ] Headers formatted exactly as shown below
- [ ] Tests pass: `make test`
- [ ] Linting passes: `make lint`
-->

<!-- Replace this comment with your title following the requirements above -->

TL;DR
-----
<!-- Single sentence explaining the change using a DIFFERENT verb than your title.
     Focus on the impact or benefit, not just what was done.
     Examples:
     - If title uses "Adds", start with "Implements", "Creates", "Enables"
     - If title uses "Fixes", start with "Resolves", "Eliminates", "Prevents"
-->

Details
--------
<!-- Explain WHY this change was needed and its impact. Tell the story behind the change.
     What problem does it solve? What improvement does it enable?
     
     Include technical details that illuminate the purpose:
     - Specific version numbers, commands, file paths in `backticks`
     - Link to relevant documentation or issues
     - Mention any trade-offs or limitations honestly
     
     Use active voice and present tense throughout.
     Group related information with bullet points or numbered lists as appropriate.
-->

<!-- Optional sections you can add if relevant:

## Testing
<!-- Describe how the change was tested, any new test cases added -->

## Breaking Changes
<!-- List any breaking changes and migration steps if applicable -->

## Dependencies
<!-- Note any new dependencies or version updates -->

-->