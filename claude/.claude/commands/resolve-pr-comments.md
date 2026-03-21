---
description: Analyze PR review comments, fix valid issues with user approval, commit, push, and reply
---

# Resolve PR Review Comments

Systematically resolve all open PR review comments for the current branch.

## Workflow

### Phase 1: Analyze

1. Get current branch and find associated PR:

   ```bash
   gh pr list --head $(git branch --show-current) --json number,title,url
   ```

2. Fetch all review comments (inline + body):

   ```bash
   gh pr view <number> --json body,comments,reviews
   gh api repos/<owner>/<repo>/pulls/<number>/comments
   ```

3. For each comment:
   - Read the referenced code and surrounding context
   - Analyze against codebase patterns and logic
   - Determine validity (valid concern vs false positive)
   - For valid: outline solution approach
   - For invalid: draft reply explaining why

4. **Report findings to user** in a table:

   | #   | File:Line  | Comment Summary    | Valid? | Proposed Action                 |
   | --- | ---------- | ------------------ | ------ | ------------------------------- |
   | 1   | file.ts:42 | Missing null check | Yes    | Add guard clause                |
   | 2   | svc.ts:100 | Duplicate call     | No     | Reply: mutually exclusive paths |

5. **Wait for user approval** before proceeding:
   - User can adjust the plan (skip items, change approach)
   - User can mark items as "won't fix" with reason
   - Only proceed when user explicitly approves

### Phase 2: Fix

For each approved fix:

1. Implement the change
2. Run relevant tests to verify fix works
3. Mark as complete

### Phase 3: Commit & Push

1. Stage all changed files:

   ```bash
   git add <files>
   ```

2. Create commit with descriptive message referencing the PR:

   ```bash
   git commit -m "<type>(<scope>): address PR review comments

   - <summary of fix 1>
   - <summary of fix 2>"
   ```

3. Push to remote:
   ```bash
   git push
   ```

### Phase 4: Reply

For each comment:

1. Construct appropriate reply:
   - For fixes: reference commit hash, explain what was done
   - For won't fix: explain reasoning clearly
   - For invalid concerns: explain why with evidence (code paths, logic flow)

2. Post reply via GitHub API:

   ```bash
   gh api repos/<owner>/<repo>/pulls/<pr>/comments/<id>/replies -f body='<reply>'
   ```

3. Report posted replies to user

## Usage

```
/resolve-pr-comments
```

## Prerequisites

- Must be in a git repo with an open PR for current branch
- GitHub CLI (`gh`) installed and authenticated
- Write access to the repository
