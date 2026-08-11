---
name: harness-commit
disable-model-invocation: true
description: Create atomic git commits for harness repo changes (docs, rules, skills, CI, Makefile). Scans changes, groups them logically, generates conventional commit messages, runs pre-commit security scan, updates CHANGELOG.md, and presents for human approval. Not for projects/ submodule commits — use /mon:implement for that. Use when the user says /harness:commit or asks to commit harness changes.
---

# Harness Commit

Create atomic, conventional commits for **harness repository changes only** (docs, rules, skills, CI, Makefile, component references). This skill is **not for committing code in `projects/` submodules** — use `/mon:implement` for that, which follows CMO commit conventions and push safety gates.

## Input

```
/harness:commit [--no-changelog] [--auto]
```

- No arguments — commit pending changes and update `CHANGELOG.md`, with human approval at each step
- `--no-changelog` — skip the changelog update
- `--auto` — skip per-commit approval prompts if the pre-commit scan passes cleanly (no secrets, no unintended files). The commit plan (step 2) still requires approval — only the individual commit executions (step 5) are auto-approved

## Steps

### 1. Scan changes

Run these commands to understand the working tree:

```bash
git status --short -- ':!projects/'
git diff --stat -- ':!projects/'
git diff --cached --stat
```

If there are no changes (excluding `projects/`), tell the user and stop.

### 2. Group changes into atomic commits

Analyze the changed files and group them into logical, atomic commits. Each commit should be self-contained and pass lint independently. Common groupings:

- **By type**: docs changes, CI changes, chore/tooling changes, fixes
- **By scope**: component docs, skills, rules, workflows, Makefile
- **By dependency**: if commit B depends on commit A, order them correctly

Unless `--no-changelog`, include a `CHANGELOG.md` update **in each commit** — add the changelog entry for that commit's change and stage `CHANGELOG.md` alongside the other files. This avoids a noisy standalone "docs: update changelog" commit.

Present the proposed commit plan as a numbered list:

```
Proposed commits:

1. docs: slim .cursor/rules/02-development-workflow.mdc
   Files: .cursor/rules/02-development-workflow.mdc, CHANGELOG.md

2. ci: add checks workflow
   Files: .github/workflows/checks.yaml, CHANGELOG.md
```

**Wait for user approval before proceeding.** The user may reorder, merge, split, or rename commits.

### 3. Commit type reference

Use conventional commit types:

| Type       | When to use                                          |
|------------|------------------------------------------------------|
| `feat`     | New feature, rule, or component reference            |
| `fix`      | Bug fix or correction                                |
| `docs`     | Documentation-only changes                           |
| `chore`    | Maintenance (gitignore, Makefile, submodule updates) |
| `refactor` | Restructuring without changing behavior              |
| `test`     | Adding or updating tests                             |
| `ci`       | CI/CD configuration changes                          |

Scope is optional: `feat(rules): add security rule`.

### 4. Pre-commit scan

Before committing, check for **unintended files** in the staging area:

```bash
git diff --cached --name-only
```

**Hard block — `projects/` submodule changes:**

If any `projects/*` paths are staged, **automatically unstage them** before proceeding:

```bash
git reset HEAD -- projects/
```

Submodule updates are handled by the automated `bump-submodules` CI workflow. Never commit submodule pointer changes manually — they create noisy diffs and conflict with the automated workflow.

**Flag and stop** if any of these are staged:

*Secrets and credentials:*
- `.env`, `.env.*` (except `.env.example`)
- `*.pem`, `*.key`, `*.crt`, `*kubeconfig*`
- `.cursor/mcp.json`, `credentials.json`, `*token*`
- Files containing: `BEGIN PRIVATE KEY`, `BEGIN RSA PRIVATE KEY`, `BEGIN CERTIFICATE`
- Hardcoded API keys, tokens, passwords, bearer/auth headers, connection strings

*Unintended files:*
- OS files: `.DS_Store`, `Thumbs.db`
- Editor files: `*.swp`, `*.swo`, `*~`
- Build artifacts: `bin/`, `*.exe`, `*.o`

Also scan `git diff --cached` content for secrets — report as **Severity | `path:line` | type** without printing the secret value.

If anything is found, **stop and report** — never commit secrets or unintended files.

### 5. Execute commits

For each approved commit, in order:

1. Unless `--no-changelog`, update `CHANGELOG.md` for this commit's change:
   - Read `CHANGELOG.md`
   - Add a concise entry at the top of the list (below the header)
   - Follow the existing style — one bullet per logical change, newest first

2. Stage the relevant files (including `CHANGELOG.md` if updated):

```bash
git add <files>
```

3. Run the pre-commit scan (step 4) on the staged files.

4. Present the staged diff and proposed message:

```bash
git diff --cached --stat
```

```
Proposed commit message: docs: slim .cursor/rules/02-development-workflow.mdc
```

5. **If `--auto` and the pre-commit scan passed cleanly:** proceed directly to commit.
   **Otherwise:** wait for user approval before committing.

6. Commit with DCO sign-off and GPG signature:

```bash
git commit -s -S -m "<message>"
```

If `--auto` and the pre-commit scan found issues for any commit, **stop the entire auto flow** and fall back to manual approval for that commit and all remaining commits.

### 6. Verify

After all commits, show the final state:

```bash
git log --oneline -<N>   # N = number of commits created
git status --short -- ':!projects/'
```

Confirm the working tree is clean (excluding `projects/`).

## Constraints

- **Harness changes only** — this skill commits to the harness repo itself (docs, rules, skills, CI, Makefile). For code changes in `projects/` submodules, use `/mon:implement` which has its own commit conventions, push safety, and PR workflow
- **Never commit autonomously** — commit plan always requires user approval; individual commits require approval unless `--auto` is passed and pre-commit scan is clean
- **Always use `-s -S`** — DCO sign-off and GPG signature on every commit
- **Never commit secrets** — scan diffs before staging
- **Never include `projects/` changes** — auto-unstage them; submodule bumps are handled by CI
- **Never push** — this skill only commits locally; pushing is the user's decision
