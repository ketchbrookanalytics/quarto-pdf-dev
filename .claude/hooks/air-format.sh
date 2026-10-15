#!/usr/bin/env bash
# Formats an R file with Air after Claude Code edits or writes it.
#
# Claude Code writes files directly to disk, so VS Code's format-on-save never
# runs on its edits. This PostToolUse hook (registered in .claude/settings.json)
# fills that gap. Claude Code passes the tool call as JSON on stdin.
#
# Outside the devcontainer, `air` or `jq` may be missing, so the hook exits
# quietly instead of failing every edit.

command -v air >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

file=$(jq -r '.tool_input.file_path // empty')

case "$file" in
  *.R | *.r)
    # Exit code 2 sends Air's error (e.g. a syntax error) back to Claude.
    air format "$file" || exit 2
    ;;
esac

exit 0
