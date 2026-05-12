#!/usr/bin/env bash
# Intercept run_in_terminal calls that attempt to stage FITS files, data
# product directories, or other git-excluded file types via `git add`.

input=$(cat)
tool=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('toolName',''))" 2>/dev/null)
cmd=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); inp=d.get('toolInput',{}); print(inp.get('command', inp.get('cmd','')))" 2>/dev/null)

# Only inspect terminal/shell tool invocations
if [[ "$tool" != "run_in_terminal" && "$tool" != "execute_command" ]]; then
    exit 0
fi

# Match `git add` commands that include forbidden file patterns
if echo "$cmd" | grep -qE 'git\s+add'; then
    if echo "$cmd" | grep -qE '\.(fits|fits\.gz|ecsv|reg)(\.gz)?([[:space:]]|$)' \
       || echo "$cmd" | grep -qE 'mastDownload'; then
        echo '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Attempting to stage a FITS image, catalog output (.ecsv/.reg), or mastDownload directory. Per project policy these files must never be committed. Check the .gitignore and remove these paths from the git add command."
  }
}'
        exit 0
    fi
fi

exit 0
