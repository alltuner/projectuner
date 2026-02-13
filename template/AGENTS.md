# Agent Instructions

This project uses a **bare repo + worktree** structure. Read this before making changes.

## Project layout

```
<project>/
├── .git/            # Bare git repo (all git object data lives here)
├── main/            # Worktree for the main branch (keep pristine)
├── <feature>/       # Worktree for a feature branch
├── SPECS.md         # Project specifications (editable via web)
├── task_*.md        # Pending task files (created by bot/web)
├── completed/       # Completed tasks (moved here by agents)
├── justfile         # Worktree management recipes (run via just)
├── .claude/         # Agent configuration (outside version control)
└── AGENTS.md        # This file
```

## Key rules

1. **Never work directly in `main/`**. It is a clean reference. Use it for diffing and
   basing new branches, not for edits.
2. **Each worktree is a full checkout** of a branch. You `cd` into a worktree directory to work on
   that branch. There is no `git checkout` or `git switch` needed.
3. **The project root is a container, not a working directory**. The `.git` directory is the bare
   repo itself. Running `git status` at the root will say "must be run in a work tree", which
   is correct. Always `cd` into a worktree to do git operations on that branch.
4. **Files at the project root** (outside worktrees) are not tracked by git. The `justfile`,
   `AGENTS.md`, `SPECS.md`, `task_*.md`, `completed/`, and config directories live here intentionally.
5. **Before editing ANY file**, verify you are in a feature worktree directory, not `main/`.
   If no feature worktree exists for your current task, create one with `just wt-add <name>`
   before making any changes.

## Developing with worktrees

All recipes are run from the project root. If just is not installed,
use `uv run --from just-bin just` instead of `just`.

Start a feature by creating a worktree:

```bash
just wt-add my-feature     # creates branch from main
cd my-feature/             # full working copy, ready to go
```

Work normally (edit, commit, push) inside `my-feature/`. Meanwhile `main/` stays
pristine, so you can diff against it anytime:

```bash
git diff main...my-feature
```

You can have multiple worktrees active at once (one per branch):

```bash
just wt-add bugfix         # another branch, another directory
just wt-ls                 # see all active worktrees
```

When a branch is merged, clean up:

```bash
just wt-rm my-feature      # removes worktree + local branch
just wt-destroy bugfix     # also deletes the remote branch
```

To pull the latest changes into your local main:

```bash
just wt-update             # fetches all remotes, fast-forwards main
```

## Repository management

Clone an existing GitHub repo into this project:

```bash
just repo-clone owner/repo-name
```

Initialize a fresh bare repo (no remote):

```bash
just repo-init
```

Create a GitHub repo and push main:

```bash
just repo-create owner/repo-name           # private by default
just repo-create owner/repo-name public    # or public
```

Change repo visibility:

```bash
just repo-public
just repo-private
```

## Updating template files

This project was scaffolded from a copier template. To pull in template updates:

```bash
just template-update
```

Extra arguments are passed through to `copier update`:

```bash
just template-update --vcs-ref v0.2.0   # pin to a specific template version
just template-update --defaults          # accept all defaults without prompting
```

The task copies template-managed files to a temporary git repo (since copier doesn't
work in bare repo roots), runs the update there, and syncs results back.

## When running commands

- Always `cd` into the appropriate worktree directory before running build, test, lint, or git commands.
- To compare branches from a worktree: `git diff main...<branch>`.
- To fetch updates: `git fetch --all` from any worktree.

## Task management

### SPECS.md

`SPECS.md` at the project root describes what the project is about — its purpose, goals, and
key decisions. This file is created and maintained through the project manager (bot or web
interface). Agents should read it for context before starting work.

### Task files

Tasks are individual markdown files at the project root, named `task_N.md` where N is a
random 4-digit ID (e.g. `task_4821.md`). Each file contains a plain text description of
the task.

Tasks are created by the project manager (bot or web interface). To complete a task:

```bash
mkdir -p completed && mv task_N.md completed/
```

Completed tasks live in `completed/` for reference.

## PR title conventions

This project uses **conventional commit format** for PR titles. PR titles become commit
messages after squash-merge, so they drive changelog generation and semantic versioning.

### Format

```text
<type>[optional scope]: <description>
```

### Types

- `feat:` New features (MINOR version bump)
- `fix:` Bug fixes (PATCH version bump)
- `docs:` Documentation changes
- `chore:` Maintenance, dependencies
- `refactor:` Code refactoring
- `test:` Test changes
- `perf:` Performance improvements
- `ci:` CI/CD changes
- `build:` Build system changes
- `style:` Formatting, linting

### Breaking changes

Add `!` after the type to signal a breaking change (MAJOR version bump):

```text
feat!: remove deprecated API
fix!: change database schema
```

### Examples

```text
feat: add OAuth authentication support
fix: resolve Docker build failure
docs: update installation guide
chore: bump FastAPI dependency
```

## Local excludes

Each worktree has its own `.gitignore`. Use `.git/info/exclude` for patterns that should
apply across all worktrees.

## Improving these instructions

If anything in this document is unclear, incomplete, or caused you to make a mistake,
file an issue at https://github.com/alltuner/projectuner so we can fix it.
