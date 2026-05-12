#!/usr/bin/env bash
# Gate destructive git operations that are hard to reverse:
#   git push --force / --force-with-lease
#   git reset --hard
#   git rebase (rewrites history)
#   git commit --amend (rewrites published commits)

input=$(cat)
tool=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('toolName',''))" 2>/dev/null)
cmd=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); inp=d.get('toolInput',{}); print(inp.get('command', inp.get('cmd','')))" 2>/dev/null)

if [[ "$tool" != "run_in_terminal" && "$tool" != "execute_command" ]]; then
    exit 0
fi

reason=""

if echo "$cmd" | grep -qE 'git\s+push\s+.*--(force|force-with-lease)' \
   || echo "$cmd" | grep -qE 'git\s+push\s+-f(\s|$)'; then
    reason="git push --force rewrites remote history and can break collaborators' clones. Confirm this is intentional and that no one else is working on this branch."
fi

if echo "$cmd" | grep -qE 'git\s+reset\s+--hard'; then
    reason="git reset --hard discards all uncommitted changes and cannot be undone. Confirm there is no in-progress work that should be saved first."
fi

if echo "$cmd" | grep -qE 'git\s+rebase(\s|$)'; then
    reason="git rebase rewrites commit history. This project targets a linear history on main via standard merges. Confirm this rebase is necessary and the branch has not been pushed."
fi

if echo "$cmd" | grep -qE 'git\s+commit\s+.*--amend'; then
    reason="git commit --amend rewrites the most recent commit. If this commit has already been pushed, it will require a force-push. Confirm the commit has not been published."
fi

if [[ -n "$reason" ]]; then
    escaped=$(echo "$reason" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))")
    echo "{
  \"hookSpecificOutput\": {
    \"hookEventName\": \"PreToolUse\",
    \"permissionDecision\": \"ask\",
    \"permissionDecisionReason\": $escaped
  }
}"
    exit 0
fi

exit 0
