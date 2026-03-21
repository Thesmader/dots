---
name: create-pull-request
description: Create a pull request for the current branch using GitHub CLI, with support for PR templates, reviewers, and assignees
---

# Create Pull Request

Create a pull request for the current branch using the GitHub CLI.

## Instructions

1. **Check for PR template**: Look for `.github/pull_request_template.md` in the repository. If it exists, follow its structure when creating the PR body.

2. **Gather branch information**:
   - Run `git status` to check for uncommitted changes
   - Run `git branch --show-current` to get the current branch name
   - Run `git log origin/main..HEAD --oneline` (or appropriate base branch) to see commits to be included
   - Run `git diff origin/main...HEAD` to understand the full scope of changes

3. **Ask for reviewer and assignee**: Before creating the PR, ask the user:
   - Who should review this PR? (GitHub username)
   - Who should be assigned to this PR? (GitHub username, can be the same as reviewer)

4. **Create the PR**: Use the GitHub CLI (`gh`) to create the pull request.

## GitHub CLI Commands

### Basic PR creation:

```bash
gh pr create --title "Your PR title" --body "Your PR description"
```

### With reviewer and assignee:

```bash
gh pr create --title "Your PR title" --body "Your PR description" --reviewer username --assignee username
```

### With multiple reviewers:

```bash
gh pr create --title "Your PR title" --body "Your PR description" --reviewer user1,user2 --assignee username
```

### Specifying base branch:

```bash
gh pr create --title "Your PR title" --body "Your PR description" --base main --reviewer username --assignee username
```

### Using a HEREDOC for multi-line body:

```bash
gh pr create --title "Your PR title" --body "$(cat <<'EOF'
## Summary
Description of changes...

## Changes
- Change 1
- Change 2

## Testing
How this was tested...
EOF
)" --reviewer username --assignee username
```

### Draft PR:

```bash
gh pr create --title "Your PR title" --body "Your PR description" --draft --reviewer username --assignee username
```

## Important Notes

- Do NOT include any attribution lines such as:
  - "Generated with Claude" or similar
  - "Co-Authored-By: Claude" or similar
  - Any other AI attribution markers
- Push the branch to remote before creating the PR if not already pushed: `git push -u origin <branch-name>`
- If the PR template exists, respect its sections and fill them out appropriately based on the changes
- **Base branch**: Default to `main` unless the user explicitly requests a different base branch
- Return the PR URL to the user when complete
