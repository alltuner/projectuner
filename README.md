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
- [gh](https://cli.github.com/) (GitHub CLI, for repo creation recipes)
- [uv](https://docs.astral.sh/uv/) (Python package manager, used to run just and copier)

## Usage

```bash
uvx copier copy --trust gh:alltuner/projectuner ~/dev/my-project
```

The `--trust` flag is required because this template runs post-copy tasks (bare clone setup).
Without it, copier will refuse to execute them.

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
├── justfile         # Worktree management recipes
├── _/               # Scratchpad for scripts and notes
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

## Setting up a remote

If you started with a fresh repo (no remote URL), connect it to GitHub:

```bash
# Create a new GitHub repo and push (pick one)
uv run --from just-bin just repo-private myorg/my-project
uv run --from just-bin just repo-public myorg/my-project

# Or add an existing remote
uv run --from just-bin just remote-add myorg/my-project
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
bash <(gh api repos/alltuner/projectuner/contents/scripts/convert-to-worktree \
  -H "Accept: application/vnd.github.raw+json") ~/dev/my-project
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

## Recipe reference

| Recipe | Usage | Description |
|--------|-------|-------------|
| `wt-add` | `just wt-add <branch> [base]` | Create a new worktree. Fetches remotes first, defaults to branching from `main`. |
| `wt-rm` | `just wt-rm <branch>` | Remove a worktree and its local branch. |
| `wt-destroy` | `just wt-destroy <branch>` | Remove a worktree and delete both local and remote branches. |
| `wt-ls` | `just wt-ls` | List all active worktrees. |
| `wt-update` | `just wt-update` | Fetch all remotes and fast-forward `main`. |
| `repo-public` | `just repo-public <owner/repo>` | Create a public GitHub repo, set up remote, and push `main`. |
| `repo-private` | `just repo-private <owner/repo>` | Create a private GitHub repo, set up remote, and push `main`. |
| `remote-add` | `just remote-add <owner/repo> [name]` | Add an existing GitHub repo as remote and push `main`. Defaults remote name to `origin`. |
| `template-update` | `just template-update [args]` | Update template files via copier. |

## Local excludes

Files at the project root are outside version control. They're excluded via
`.bare/info/exclude` (not `.gitignore`). The `setup` task pre-populates common patterns.
To add your own, edit `.bare/info/exclude` directly.

## Known issues

### Starship shows branch name at the project root

[Starship](https://starship.rs/)'s `git_branch` module has an `ignore_bare_repo` option, but
it doesn't work with the gitdir pointer pattern (`.git` file pointing to `.bare/`). This is
because Starship uses [gitoxide](https://github.com/GitoxideLabs/gitoxide) which
[doesn't follow gitdir indirection when checking `is_bare()`](https://github.com/GitoxideLabs/gitoxide/issues/2402).

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
