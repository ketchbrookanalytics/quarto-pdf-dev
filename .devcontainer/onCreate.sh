#!/usr/bin/env bash
set -e

# This runs as `onCreateCommand`, which VS Code waits for before connecting
# and activating extensions (the default `waitFor` is `updateContentCommand`,
# which runs after it). The Air VS Code extension looks up `air` on PATH once at
# startup (see `air.executableStrategy` in devcontainer.json); if it were
# installed in `postCreateCommand` instead, the extension could start first and
# silently fall back to its bundled binary.

# jq is used by the Claude Code hook in .claude/hooks/air-format.sh
echo "==> Installing system dependencies for arf, Air, and Claude Code hooks..."
apt-get update -qq
apt-get install -y -qq curl xz-utils jq

# Install into /usr/local/bin so `air` is on PATH for every shell, including
# the non-login shells that Claude Code runs commands and hooks in. The Air VS
# Code extension uses this same binary, so the editor, the terminal, and Claude
# Code's format hook all format R code identically.
echo "==> Installing Air CLI..."
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/posit-dev/air/releases/latest/download/air-installer.sh \
  | AIR_INSTALL_DIR=/usr/local/bin AIR_NO_MODIFY_PATH=1 sh

echo "==> ✅ onCreateCommand complete."
