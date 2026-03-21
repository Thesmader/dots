---
description: Iterate on a technical plan with codebase investigation, then optionally sync to a GitHub issue
---

# Plan

Collaborate on a technical plan through iterative refinement. Investigate the codebase to validate assumptions, update the plan based on findings and feedback, and optionally sync to a GitHub issue for review.

## Inputs

- **Topic/context**: what the plan is about (feature, design URL, existing spec, etc.)
- **Plan file path**: where to read/write the plan (defaults to `docs/tech-specs/<topic>.md`)

Use $ARGUMENTS to parse these if provided (e.g., `/plan action-center`).

## Workflow

### Phase 1: Understand

1. If a Figma URL or design reference is provided, fetch the screenshot to understand the UI
2. If a plan file already exists, read it as the starting point
3. If neither exists, ask the user what they want to plan

### Phase 2: Iterate

This is a conversational loop — repeat until the user is satisfied:

1. **Draft/update the plan** in the target markdown file based on user input
2. **Investigate the codebase** when the plan makes assumptions about existing code:
   - Use the Explore agent to search for relevant code paths, schemas, services
   - Verify feasibility (e.g., "can we reliably get this timestamp?", "will this cause N+1 queries?")
   - Report findings to the user with specific file:line references
3. **Update the plan** based on investigation findings
4. **Present changes** concisely — what was added/removed/changed and why
5. **Wait for user feedback** before the next iteration

### Key investigation patterns

- **Data availability**: check if required fields exist in DB schemas and are populated on all code paths
- **Query efficiency**: trace data flow to ensure no redundant fetches or N+1 queries
- **Timestamp reliability**: audit all update paths for a column to find gaps
- **Integration points**: check what existing services already fetch to avoid duplication

### Phase 3: Approve

When the user indicates the plan is ready, ask them explicitly:

> Do you want to sync this plan to a GitHub issue?

Present these options:
- **Create new issue** — create a new GitHub issue with the plan as the body
- **Update existing issue** — update an existing issue (ask for issue number)
- **No sync** — plan stays in the markdown file only

If syncing:

1. Read the final plan file
2. Create or update the GitHub issue:
   ```bash
   # Create
   gh issue create --title "<title>" --body "$(cat <plan-file>)"
   # Update
   gh issue edit <number> --body "$(cat <plan-file>)"
   ```
3. Optionally update the issue title if user requests
4. Return the issue URL

## Guidelines

- Keep the plan file as the single source of truth — all changes go there
- Be concise in updates — summarize what changed, don't repeat the whole plan
- When investigating code, be exhaustive — one missed code path can invalidate the plan
- Don't make code changes — this is planning only
- Ask clarifying questions when requirements are ambiguous instead of assuming