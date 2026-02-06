# projectuner

A [copier](https://copier.readthedocs.io/) template that scaffolds git projects using the
**bare repo + worktree** pattern described in
[Git Worktrees Done Right](https://gabri.me/blog/git-worktrees-done-right) and its followup
[git-wt: Worktrees Simplified](https://gabri.me/blog/git-wt) by Ahmed el Gabri.

Instead of switching branches with `git checkout`, you keep multiple branches checked out
simultaneously as separate directories (worktrees). A bare clone holds all git data, and
each worktree is a full working copy of a branch.

## Prerequisites

- git
- [gh](https://cli.github.com/) (GitHub CLI, for repo creation tasks)
- [mise](https://mise.jdx.dev/) (task runner for worktree management)

## Usage

```bash
uvx copier copy --trust gh:alltuner/projectuner ~/dev/my-project
```

The `--trust` flag is required because this template runs post-copy tasks (bare clone setup
via mise). Without it, copier will refuse to execute them.

You'll be prompted for:

| Question | Default | Description |
|----------|---------|-------------|
| `git_remote_url` | (empty) | Remote URL to bare-clone. Leave empty to start a fresh repo. |

If you provide a remote URL, the template clones it as a bare repo. If you leave it empty,
it initializes a fresh bare repo with an empty initial commit. You can connect it to GitHub
afterwards (see [Setting up a remote](#setting-up-a-remote)).

## What you get

```
my-project/
├── .bare/           # Bare git clone
├── .git             # Pointer file to .bare
├── main/            # Worktree for the main branch
├── .mise/
│   └── tasks/       # Project tasks
│       ├── wt-add       # Create a new worktree
│       ├── wt-rm        # Remove a worktree
│       ├── wt-destroy   # Remove worktree + local + remote branch
│       ├── wt-ls        # List all worktrees
│       ├── wt-update    # Fetch remotes and fast-forward main
│       ├── repo-public  # Create a public GitHub repo
│       ├── repo-private # Create a private GitHub repo
│       └── remote-add   # Add a remote to an existing repo
├── .mise.toml       # Mise configuration
├── _/               # Scratchpad for scripts and notes
├── .claude/         # Agent configuration
├── AGENTS.md        # Instructions for AI coding agents
├── CLAUDE.md        # Symlink to AGENTS.md
└── .copier-answers.yml
```

## Worktree workflow

All worktree operations are mise tasks, run from the project root:

```bash
# Start a new feature
mise run wt-add my-feature

# Work in it
cd my-feature/

# List all worktrees
mise run wt-ls

# Fetch latest and fast-forward main
mise run wt-update

# Clean up when done (keeps remote branch)
mise run wt-rm my-feature

# Or nuke everything: worktree + local + remote branch
mise run wt-destroy my-feature
```

The `main/` worktree stays pristine as a clean reference for diffing. Never edit files in it
directly.

## Setting up a remote

If you started with a fresh repo (no remote URL), connect it to GitHub:

```bash
# Create a new GitHub repo and push (pick one)
mise run repo-private myorg/my-project
mise run repo-public myorg/my-project

# Or add an existing remote
mise run remote-add myorg/my-project
```

`repo-public` and `repo-private` use `gh repo create` under the hood, so they'll fail if
the repo already exists (which is what you want).

## Updating a scaffolded project

When the projectuner template gets new features or fixes, pull them into your project:

```bash
cd ~/dev/my-project
uvx copier update --trust
```

Copier reads `.copier-answers.yml` to know which template version you're on, computes a diff
against the latest version, and applies changes. It will prompt you to resolve conflicts if
any of your local changes overlap with template updates.

To update to a specific version:

```bash
uvx copier update --trust --vcs-ref=v0.2.0
```

> **Note**: `copier update` requires `.copier-answers.yml`, which is created automatically
> when scaffolding with copier or converting with `uvx` available. If you converted manually
> (without `uvx`), re-run the conversion script to pick up template changes.

## Converting an existing clone

Already have a regular `git clone` and want to switch to the worktree structure? The
conversion script restructures it in place:

```bash
# Run directly from a local copy of this repo
./scripts/convert-to-worktree ~/dev/my-project

# Or pipe it from GitHub (no local clone needed)
bash <(curl -fsSL https://raw.githubusercontent.com/alltuner/projectuner/main/scripts/convert-to-worktree) ~/dev/my-project
```

When `uvx` is available, the script uses copier under the hood. This gives you
`.copier-answers.yml`, so future `copier update --trust` works. When `uvx` is not available,
it falls back to a manual conversion (no `.copier-answers.yml`).

The script will:

1. Validate the directory is a regular git clone with a clean working tree
2. Scaffold the worktree structure via copier (or manually as fallback)
3. Preserve all branches, tags, and remote configuration

Requirements: the working tree must be clean (no uncommitted or untracked changes). Commit
or stash everything first.

## Why bare repo + worktrees?

The traditional git workflow (checkout, stash, switch) has a hidden cost: every branch switch
tears down your working state and rebuilds it. With worktrees:

- **No context switching tax**. Each branch is its own directory. Your editor, terminal, and
  build cache stay intact.
- **Parallel work**. Run tests on one branch while coding on another.
- **AI agent isolation**. Spawn a worktree per agent. They can't interfere with each other or
  your active work.
- **Clean diffing**. Keep `main/` pristine and diff any branch against it without stashing.

## AI agent support

The generated `AGENTS.md` (with `CLAUDE.md` symlinked to it) teaches AI coding agents how
the worktree structure works: where to run commands, how to create branches, and what lives
outside version control.

## Mise tasks reference

| Task | Usage | Description |
|------|-------|-------------|
| `wt-add` | `mise run wt-add <branch> [base]` | Create a new worktree. Fetches remotes first, defaults to branching from `main`. |
| `wt-rm` | `mise run wt-rm <branch>` | Remove a worktree and its local branch. |
| `wt-destroy` | `mise run wt-destroy <branch>` | Remove a worktree and delete both local and remote branches. |
| `wt-ls` | `mise run wt-ls` | List all active worktrees. |
| `wt-update` | `mise run wt-update` | Fetch all remotes and fast-forward `main`. |
| `repo-public` | `mise run repo-public <owner/repo>` | Create a public GitHub repo, set up remote, and push `main`. |
| `repo-private` | `mise run repo-private <owner/repo>` | Create a private GitHub repo, set up remote, and push `main`. |
| `remote-add` | `mise run remote-add <owner/repo> [name]` | Add an existing GitHub repo as remote and push `main`. Defaults remote name to `origin`. |

## Local excludes

Files at the project root are outside version control. They're excluded via
`.bare/info/exclude` (not `.gitignore`). The `setup` task pre-populates common patterns.
To add your own, edit `.bare/info/exclude` directly.

## Credit

Based on the workflow from Ahmed el Gabri:

- [Git Worktrees Done Right](https://gabri.me/blog/git-worktrees-done-right) -- the bare repo
  + worktree pattern that this template scaffolds.
- [git-wt: Worktrees Simplified](https://gabri.me/blog/git-wt) -- a standalone CLI tool that
  wraps the same pattern. Several of our mise tasks (`wt-update`, `wt-destroy`, fetch-before-add)
  are inspired by `git-wt`'s approach. If you prefer a single CLI over mise tasks, check out
  [git-wt](https://github.com/ahmedelgabri/git-wt).
