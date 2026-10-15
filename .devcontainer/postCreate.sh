#!/usr/bin/env bash
set -e

# Version of the Air CLI to install. The Air VS Code extension uses this same
# binary (see `air.executableStrategy` in devcontainer.json), so the editor,
# the terminal, and Claude Code's format hook all format R code identically.
AIR_VERSION="0.12.0"

# jq is used by the Claude Code hook in .claude/hooks/air-format.sh
echo "==> Installing system dependencies for arf, Air, and Claude Code hooks..."
apt-get update -qq
apt-get install -y -qq curl xz-utils jq

echo "==> Installing arf R terminal..."
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/eitsupi/arf/releases/latest/download/arf-console-installer.sh | sh

# Install into /usr/local/bin so `air` is on PATH for every shell, including
# the non-login shells that Claude Code runs commands and hooks in.
echo "==> Installing Air ${AIR_VERSION} CLI..."
curl --proto '=https' --tlsv1.2 -LsSf "https://github.com/posit-dev/air/releases/download/${AIR_VERSION}/air-installer.sh" \
  | AIR_INSTALL_DIR=/usr/local/bin AIR_NO_MODIFY_PATH=1 sh

if [ "$#" -eq 0 ]; then
  echo "==> No R packages specified, skipping pak install."
else
  echo "==> Installing R packages via pak: $*"
  packages=$(printf "'%s', " "$@")
  packages="${packages%, }"
  R -q -e "pak::pkg_install(c(${packages}))"
fi

echo "==> ✅ postCreateCommand complete."
