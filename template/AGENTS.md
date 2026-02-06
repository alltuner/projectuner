# Agent Instructions

This project uses a **bare repo + worktree** structure. Read this before making changes.

## Project layout

```
<project>/
├── .bare/           # Bare git clone (all git object data lives here)
├── .git             # Pointer file (contains "gitdir: ./.bare")
├── main/            # Worktree for the main branch (keep pristine)
├── <feature>/       # Worktree for a feature branch
├── .mise/
│   └── tasks/       # Project tasks (run via mise)
│       ├── wt-add      # Create a new worktree
│       ├── wt-rm       # Remove a worktree
│       ├── wt-ls       # List worktrees
│       ├── repo-public  # Create a public GitHub repo
│       ├── repo-private # Create a private GitHub repo
│       └── remote-add  # Add a remote to an existing repo
├── .mise.toml       # Mise configuration
├── _/               # Scratchpad for notes and one-off scripts
├── .claude/         # Agent configuration (outside version control)
└── AGENTS.md        # This file
```

## Key rules

1. **Never work directly in `main/`**. It is a clean reference. Use it for diffing and
   basing new branches, not for edits.
2. **Each worktree is a full checkout** of a branch. You `cd` into a worktree directory to work on
   that branch. There is no `git checkout` or `git switch` needed.
3. **Git commands work from the project root**. The `.git` pointer file connects to `.bare/`.
   The root is on a `_workspace` branch (empty tree) so `git status` returns clean.
4. **Files at the project root** (outside worktrees) are not tracked by git. The `.mise/` tasks,
   `AGENTS.md`, and config directories live here intentionally.

## Working with worktrees

All worktree operations use mise tasks from the project root.

Create a new worktree for a feature branch:

```bash
mise run wt-add my-feature          # branches from main
mise run wt-add my-feature develop  # branches from develop
```

List active worktrees:

```bash
mise run wt-ls
```

Remove a worktree when done:

```bash
mise run wt-rm my-feature
```

## Setting up a remote

If the project was created without a remote URL, use one of these to connect it:

```bash
# Create a new GitHub repo (public or private) and push
mise run repo-public owner/repo-name
mise run repo-private owner/repo-name

# Or add an existing remote
mise run remote-add owner/repo
```

## When running commands

- Always `cd` into the appropriate worktree directory before running build, test, or lint commands.
- To compare branches, use `git diff main...<branch>` from the project root.
- To fetch updates: `git fetch --all` from anywhere in the project.

## Local excludes

The project root has a `.gitignore` containing `*` so all root-level files stay untracked.
This only affects the `_workspace` checkout; linked worktrees have their own `.gitignore`.
Use `.bare/info/exclude` only for patterns that should apply across all worktrees.
