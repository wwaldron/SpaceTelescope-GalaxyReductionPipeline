#!/usr/bin/env bash
# Intercept execute/run_in_terminal tool calls and require approval before
# any invocation of the ./configure script.

input=$(cat)
tool=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('toolName',''))" 2>/dev/null)
cmd=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); inp=d.get('toolInput',{}); print(inp.get('command', inp.get('cmd','')))" 2>/dev/null)

# Only intercept if the command invokes ./configure or python configure.py
if [[ "$cmd" =~ (^|[[:space:]])(\.\/configure|python[[:space:]]+configure\.py) ]]; then
    echo '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "Running ./configure will overwrite placeholder strings in all notebooks. Please confirm the galaxy name, author, and institution are correct before proceeding."
  }
}'
    exit 0
fi

exit 0
