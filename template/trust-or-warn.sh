#!/bin/bash
if command -v mise &>/dev/null; then
  mise trust
else
  echo ""
  echo "WARNING: mise is not installed."
  echo "  Install it from https://mise.jdx.dev/ to use worktree tasks (wt-add, wt-rm, wt-ls, etc)."
fi
