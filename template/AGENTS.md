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
3. **The project root is a container, not a working directory**. The `.git` pointer file connects
   to `.bare/`. Running `git status` at the root will say "must be run in a work tree", which
   is correct. Always `cd` into a worktree to do git operations on that branch.
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

# Or add an existing remote and fetch branches
mise run remote-add owner/repo
```

## When running commands

- Always `cd` into the appropriate worktree directory before running build, test, lint, or git commands.
- To compare branches from a worktree: `git diff main...<branch>`.
- To fetch updates: `git fetch --all` from any worktree.

## Local excludes

Each worktree has its own `.gitignore`. Use `.bare/info/exclude` for patterns that should
apply across all worktrees.
