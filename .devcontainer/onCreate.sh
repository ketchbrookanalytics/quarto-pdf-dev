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

# Leave R formatting to Air. On save, the Quarto extension formats each R chunk
# of a .qmd file by asking VS Code for "the" R formatter, which ignores
# `editor.defaultFormatter` and can pick the R language server instead. That
# formats with {styler} at roughly a second per chunk, so saving a .qmd file
# with many chunks stalls for several seconds and doesn't match Air's style.
# This turns off the language server's formatting so Air is the only R
# formatter. It goes in Rprofile.site, not ~/.Rprofile, because R skips
# ~/.Rprofile whenever a project has its own .Rprofile (as {renv} adds). It has
# to exist before the R extension starts the language server, hence onCreate.
echo "==> Leaving R formatting to Air..."
rprofile_site="$(R RHOME)/etc/Rprofile.site"
if ! grep -q "languageserver.server_capabilities" "$rprofile_site" 2>/dev/null; then
  cat >> "$rprofile_site" <<'EOF'

# Added by .devcontainer/onCreate.sh: leave R formatting to Air.
options(languageserver.server_capabilities = list(
  documentFormattingProvider = FALSE,
  documentRangeFormattingProvider = FALSE,
  documentOnTypeFormattingProvider = FALSE
))
EOF
fi

echo "==> ✅ onCreateCommand complete."
