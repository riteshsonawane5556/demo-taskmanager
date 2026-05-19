#!/usr/bin/env bash
set -euo pipefail

MR_IID="${1:?Usage: mr_review.sh <MR_IID> <PROJECT_ID>}"
PROJECT_ID="${2:?Usage: mr_review.sh <MR_IID> <PROJECT_ID>}"

: "${GITLAB_TOKEN:?GITLAB_TOKEN env variable is required}"
: "${GITLAB_API_URL:?GITLAB_API_URL env variable is required}"
: "${CLAUDE_CODE_OAUTH_TOKEN:?CLAUDE_CODE_OAUTH_TOKEN env variable is required}"

echo "Fetching diff for MR !${MR_IID} in project ${PROJECT_ID}..."

export RAW_DIFF=$(curl -s --fail \
  --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
  "${GITLAB_API_URL}/projects/${PROJECT_ID}/merge_requests/${MR_IID}/diffs")

# Debug: verify we got something
if [[ -z "$RAW_DIFF" ]]; then
  echo "ERROR: Empty response from GitLab API. Check GITLAB_TOKEN permissions and GITLAB_API_URL." >&2
  exit 1
fi

DIFF_TEXT=$(python3 - <<'PYEOF'
import sys, json, os

raw = os.environ.get("RAW_DIFF", "")
try:
    diffs = json.loads(raw)
except json.JSONDecodeError as e:
    print(f"Failed to parse diff JSON: {e}", file=sys.stderr)
    sys.exit(1)

output = []
for entry in diffs:
    fname = entry.get("new_path") or entry.get("old_path", "unknown")
    diff  = entry.get("diff", "")
    output.append(f"### File: {fname}\n```diff\n{diff}\n```")

print("\n\n".join(output))
PYEOF
)

if [[ -z "$DIFF_TEXT" ]]; then
  echo "No diff content found — nothing to review."
  exit 0
fi

REVIEW_PROMPT="You are a senior code reviewer. Review this MR diff carefully and provide:
1. SUMMARY: One paragraph overview of what this MR does
2. ISSUES: List any bugs, logic errors, security vulnerabilities, or missing error handling. Use 🔴 Critical, 🟡 Warning, 🟢 Suggestion labels.
3. POSITIVES: What is done well
4. VERDICT: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
Be specific, reference file names and line numbers where possible.

${DIFF_TEXT}"

export ANTHROPIC_API_KEY="${CLAUDE_CODE_OAUTH_TOKEN}"

echo "Claude version: $(claude --version 2>&1)"
echo "Auth check: $(claude -p 'say hi' --output-format text 2>&1 | head -5)"

echo "Sending diff to Claude for review..."
REVIEW=$(echo "$REVIEW_PROMPT" | claude -p --output-format text 2>&1) || {
  echo "ERROR: Claude exited with code $?. Output: $REVIEW" >&2
  exit 1
}

echo "Posting review comment to MR !${MR_IID}..."

COMMENT_BODY="## 🤖 Claude Code Review

${REVIEW}"

curl -s --fail \
  --request POST \
  --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
  --header "Content-Type: application/json" \
  --data "$(python3 -c "import json,sys; print(json.dumps({'body': sys.argv[1]}))" "$COMMENT_BODY")" \
  "${GITLAB_API_URL}/projects/${PROJECT_ID}/merge_requests/${MR_IID}/notes" \
  > /dev/null

echo "Review posted successfully to MR !${MR_IID}."