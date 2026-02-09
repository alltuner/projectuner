# projectuner

A [copier](https://copier.readthedocs.io/) template that drops skeleton files into a git
project using the **bare repo + worktree** pattern described in
[Git Worktrees Done Right](https://gabri.me/blog/git-worktrees-done-right) and its followup
[git-wt: Worktrees Simplified](https://gabri.me/blog/git-wt) by Ahmed el Gabri.

Instead of switching branches with `git checkout`, you keep multiple branches checked out
simultaneously as separate directories (worktrees). A bare clone holds all git data, and
each worktree is a full working copy of a branch.

## Prerequisites

- git
- [uv](https://docs.astral.sh/uv/) (Python package manager, used to run just and copier)

## Usage

Set up the bare repo and main worktree yourself, then run copier to drop skeleton files:

```bash
mkdir ~/repos/my-project && cd ~/repos/my-project
gh repo clone owner/my-project .git -- --bare
git worktree add main main
uvx copier copy gh:dpoblador/projectuner .
```

For a brand-new repo with no remote:

```bash
mkdir ~/repos/my-project && cd ~/repos/my-project
git init --bare .git
git -C .git commit --allow-empty -m "Initial commit"
git worktree add main main
uvx copier copy gh:dpoblador/projectuner .
```

## What you get

```
my-project/
├── .git/            # Bare git repo
├── main/            # Worktree for the main branch
├── justfile         # Worktree management recipes
├── .claude/         # Agent configuration
├── AGENTS.md        # Instructions for AI coding agents
├── CLAUDE.md        # Symlink to AGENTS.md
└── .copier-answers.yml
```

## Worktree workflow

All worktree operations are just recipes, run from the project root. If you have
[just](https://github.com/casey/just) installed, you can use `just <recipe>` directly
instead of the `uv run --from just-bin` prefix.

```bash
# Start a new feature
uv run --from just-bin just wt-add my-feature

# Work in it
cd my-feature/

# List all worktrees
uv run --from just-bin just wt-ls

# Fetch latest and fast-forward main
uv run --from just-bin just wt-update

# Clean up when done (keeps remote branch)
uv run --from just-bin just wt-rm my-feature

# Or nuke everything: worktree + local + remote branch
uv run --from just-bin just wt-destroy my-feature
```

The `main/` worktree stays pristine as a clean reference for diffing. Never edit files in it
directly.

## Updating a scaffolded project

When the projectuner template gets new features or fixes, pull them into your project:

```bash
cd ~/repos/my-project
uv run --from just-bin just template-update
```

The recipe copies template-managed files to a temporary git repo (since copier doesn't work
in bare repo roots), runs `copier update` there, and syncs results back.

To update to a specific version:

```bash
uv run --from just-bin just template-update --vcs-ref=v0.2.0
```

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

## Recipe reference

| Recipe | Usage | Description |
|--------|-------|-------------|
| `wt-add` | `just wt-add <branch> [base]` | Create a new worktree. Fetches remotes first, defaults to branching from `main`. |
| `wt-rm` | `just wt-rm <branch>` | Remove a worktree and its local branch. |
| `wt-destroy` | `just wt-destroy <branch>` | Remove a worktree and delete both local and remote branches. |
| `wt-ls` | `just wt-ls` | List all active worktrees. |
| `wt-update` | `just wt-update` | Fetch all remotes and fast-forward `main`. |
| `template-update` | `just template-update [args]` | Update template files via copier. |

## Local excludes

Files at the project root are outside version control. They're excluded via
`.git/info/exclude` (not `.gitignore`). To add your own patterns, edit
`.git/info/exclude` directly.

## Known issues

### Starship shows branch name at the project root

[Starship](https://starship.rs/)'s `git_branch` module reads `.git/HEAD` and displays the
branch name even at the bare repo root. The `ignore_bare_repo` option doesn't help because
Starship uses [gitoxide](https://github.com/GitoxideLabs/gitoxide) which
[has a bug detecting bare repos](https://github.com/GitoxideLabs/gitoxide/issues/2402).

The fix has been merged in gitoxide and is expected in the gitoxide release on 2026-02-22,
after which Starship needs to bump its gitoxide dependency.

## Credit

Based on the workflow from Ahmed el Gabri:

- [Git Worktrees Done Right](https://gabri.me/blog/git-worktrees-done-right) -- the bare repo
  + worktree pattern that this template scaffolds.
- [git-wt: Worktrees Simplified](https://gabri.me/blog/git-wt) -- a standalone CLI tool that
  wraps the same pattern. Several of our just recipes (`wt-update`, `wt-destroy`, fetch-before-add)
  are inspired by `git-wt`'s approach. If you prefer a single CLI over just recipes, check out
  [git-wt](https://github.com/ahmedelgabri/git-wt).
