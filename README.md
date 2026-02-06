# projectuner

A [copier](https://copier.readthedocs.io/) template that scaffolds git projects using the
**bare repo + worktree** pattern described in
[Git Worktrees Done Right](https://gabri.me/blog/git-worktrees-done-right).

Instead of switching branches with `git checkout`, you keep multiple branches checked out
simultaneously as separate directories (worktrees). A bare clone holds all git data, and
each worktree is a full working copy of a branch.

## Prerequisites

- git
- [copier](https://copier.readthedocs.io/) (invoked via `uvx`)

## Usage

```bash
uvx copier copy gh:dpoblador/projectuner ~/dev/my-project
```

You'll be prompted for:

| Question | Default | Description |
|----------|---------|-------------|
| `project_name` | directory name | Name of the project |
| `git_remote_url` | (required) | Remote URL to bare-clone |
| `default_branch` | `main` | Primary branch name |
| `include_scratchpad` | yes | Create `_/` for scripts and notes |
| `include_claude_config` | yes | Create `.claude/` for agent settings |

After answering, copier runs `setup.sh` which clones the bare repo, creates worktrees, and
configures everything.

## What you get

```
my-project/
├── .bare/           # Bare git clone
├── .git             # Pointer file to .bare
├── main/            # Worktree for the default branch
├── bin/
│   ├── wt-add       # Create a new worktree
│   ├── wt-rm        # Remove a worktree
│   └── wt-ls        # List all worktrees
├── _/               # Scratchpad (optional)
├── .claude/         # Agent config (optional)
├── AGENTS.md        # Instructions for AI agents
├── CLAUDE.md        # Symlink to AGENTS.md
├── setup.sh         # The setup script (kept for reference)
└── .copier-answers.yml
```

## Worktree workflow

```bash
# Start a new feature
bin/wt-add my-feature

# Work in it
cd my-feature/

# List all worktrees
bin/wt-ls

# Clean up when done
bin/wt-rm my-feature
```

The `main/` worktree stays pristine as a clean reference for diffing. Never edit files in it
directly.

## AI agent support

The generated `AGENTS.md` (with `CLAUDE.md` symlinked to it) teaches AI coding agents how
the worktree structure works: where to run commands, how to create branches, and what lives
outside version control.

## Credit

Based on the workflow from [Git Worktrees Done Right](https://gabri.me/blog/git-worktrees-done-right)
by Gabriel Gonzalez.
