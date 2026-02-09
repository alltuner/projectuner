# Agent Instructions

This project uses a **bare repo + worktree** structure. Read this before making changes.

## Project layout

```
<project>/
├── .git/            # Bare git repo (all git object data lives here)
├── main/            # Worktree for the main branch (keep pristine)
├── <feature>/       # Worktree for a feature branch
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
   `AGENTS.md`, and config directories live here intentionally.

## Working with worktrees

All worktree operations use just recipes from the project root. If just is not installed,
use `uv run --from just-bin just` instead of `just`.

Create a new worktree for a feature branch:

```bash
just wt-add my-feature          # branches from main
just wt-add my-feature develop  # branches from develop
```

List active worktrees:

```bash
just wt-ls
```

Fetch latest from all remotes and fast-forward main:

```bash
just wt-update
```

Remove a worktree when done:

```bash
just wt-rm my-feature

# Or remove worktree + local + remote branch in one shot
just wt-destroy my-feature
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
