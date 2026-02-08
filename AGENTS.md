# Agent Instructions

Copier template that scaffolds git projects using the bare repo + worktree pattern.

## Repository structure

```
copier.yml           Copier template configuration
template/            Template files copied to new projects
  setup.sh.jinja     Post-copy scaffolding script
  justfile           Just recipes for worktree management
  AGENTS.md          Agent instructions for scaffolded projects
scripts/
  convert-to-worktree  Converts an existing git clone to worktree structure
```

## PR title conventions

This project uses **Release Please** for automated versioning and changelog generation.
PR titles must follow **conventional commit format** because they become the commit message
after squash-merge.

### Format

```text
<type>[optional scope]: <description>
```

### Types

| Type | Changelog section | Version bump |
|------|-------------------|--------------|
| `feat:` | Features | MINOR |
| `fix:` | Bug Fixes | PATCH |
| `docs:` | Documentation Updates | PATCH |
| `chore:` | Miscellaneous Chores | PATCH |
| `refactor:` | Code Refactoring | PATCH |
| `test:` | Tests | PATCH |
| `perf:` | Performance Improvements | PATCH |
| `ci:` | CI/CD Changes | PATCH |
| `build:` | Build System | PATCH |
| `style:` | Styling Changes | PATCH |

### Breaking changes

Add `!` after the type to signal a breaking change (MAJOR version bump):

```text
feat!: remove deprecated API
```

### Release workflow

1. Merge a PR with a conventional title
2. Release Please creates/updates a release PR with version bump and changelog
3. Merge the release PR when ready to publish
4. Release Please creates a GitHub release with a git tag
