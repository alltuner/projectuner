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
- [gh](https://cli.github.com/) (GitHub CLI, for repo setup recipes)
- [uv](https://docs.astral.sh/uv/) (Python package manager, used to run just and copier)

## Usage

Clone an existing GitHub repo:

```bash
uvx copier copy gh:alltuner/projectuner ~/repos/my-project
cd ~/repos/my-project
just repo-clone owner/my-project
```

Or start a fresh repo with no remote:

```bash
uvx copier copy gh:alltuner/projectuner ~/repos/my-project
cd ~/repos/my-project
just repo-init
```

To publish a fresh repo to GitHub:

```bash
just repo-create owner/my-project         # private by default
just repo-create owner/my-project public  # or public
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

## Developing with worktrees

All recipes are run from the project root. If you have
[just](https://github.com/casey/just) installed, you can use `just` directly
instead of `uv run --from just-bin just`.

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
| `repo-clone` | `just repo-clone <owner/repo>` | Clone a GitHub repo as a bare `.git/` and create the `main` worktree. |
| `repo-init` | `just repo-init` | Initialize a bare `.git/` repo with an empty commit and `main` worktree. |
| `repo-create` | `just repo-create <owner/repo> [visibility]` | Create a GitHub repo (default: private) and push `main`. |
| `repo-public` | `just repo-public` | Change the GitHub repo's visibility to public. |
| `repo-private` | `just repo-private` | Change the GitHub repo's visibility to private. |
| `template-update` | `just template-update [args]` | Update template files via copier. |

## Local excludes

Files at the project root are outside version control. They're excluded via
`.git/info/exclude` (not `.gitignore`). To add your own patterns, edit
`.git/info/exclude` directly.

## Credit

Based on the workflow from Ahmed el Gabri:

- [Git Worktrees Done Right](https://gabri.me/blog/git-worktrees-done-right) -- the bare repo
  + worktree pattern that this template scaffolds.
- [git-wt: Worktrees Simplified](https://gabri.me/blog/git-wt) -- a standalone CLI tool that
  wraps the same pattern. Several of our just recipes (`wt-update`, `wt-destroy`, fetch-before-add)
  are inspired by `git-wt`'s approach. If you prefer a single CLI over just recipes, check out
  [git-wt](https://github.com/ahmedelgabri/git-wt).
