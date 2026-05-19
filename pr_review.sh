#!/usr/bin/env bash
set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN env variable is required}"
: "${CLAUDE_CODE_OAUTH_TOKEN:?CLAUDE_CODE_OAUTH_TOKEN env variable is required}"
: "${PR_NUMBER:?PR_NUMBER env variable is required}"
: "${REPO:?REPO env variable is required}"

export ANTHROPIC_API_KEY="${CLAUDE_CODE_OAUTH_TOKEN}"

echo "Fetching diff for PR #${PR_NUMBER} in ${REPO}..."

RAW_DIFF=$(curl -s --fail \
  --header "Authorization: Bearer ${GH_TOKEN}" \
  --header "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${REPO}/pulls/${PR_NUMBER}/files")

if [[ -z "$RAW_DIFF" ]]; then
  echo "ERROR: Empty response from GitHub API. Check GH_TOKEN permissions." >&2
  exit 1
fi

DIFF_TEXT=$(python3 - <<'PYEOF'
import sys, json, os

raw = os.environ.get("RAW_DIFF", "")
try:
    files = json.loads(raw)
except json.JSONDecodeError as e:
    print(f"Failed to parse diff JSON: {e}", file=sys.stderr)
    sys.exit(1)

output = []
for f in files:
    fname = f.get("filename", "unknown")
    patch = f.get("patch", "")
    if patch:
        output.append(f"### File: {fname}\n```diff\n{patch}\n```")

print("\n\n".join(output))
PYEOF
)

if [[ -z "$DIFF_TEXT" ]]; then
  echo "No diff content found — nothing to review."
  exit 0
fi

REVIEW_PROMPT="You are a senior code reviewer. Review this PR diff carefully and provide:
1. SUMMARY: One paragraph overview of what this PR does
2. ISSUES: List any bugs, logic errors, security vulnerabilities, or missing error handling. Use 🔴 Critical, 🟡 Warning, 🟢 Suggestion labels.
3. POSITIVES: What is done well
4. VERDICT: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
Be specific, reference file names and line numbers where possible.

${DIFF_TEXT}"

echo "Sending diff to Claude for review..."
REVIEW=$(echo "$REVIEW_PROMPT" | claude -p --output-format text 2>&1) || {
  echo "ERROR: Claude exited with code $?. Output: $REVIEW" >&2
  exit 1
}

export COMMENT_BODY="## 🤖 Claude Code Review

${REVIEW}"

echo "Posting review comment to PR #${PR_NUMBER}..."

python3 - <<PYEOF
import json, os, urllib.request, sys

body = os.environ["COMMENT_BODY"]
token = os.environ["GH_TOKEN"]
repo = os.environ["REPO"]
pr = os.environ["PR_NUMBER"]

data = json.dumps({"body": body}).encode()
req = urllib.request.Request(
    f"https://api.github.com/repos/{repo}/issues/{pr}/comments",
    data=data,
    headers={
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github.v3+json",
        "Content-Type": "application/json",
    }
)
try:
    urllib.request.urlopen(req)
    print(f"Review posted successfully to PR #{pr}.")
except urllib.error.HTTPError as e:
    print(f"Failed to post comment: {e.code} {e.read().decode()}", file=sys.stderr)
    sys.exit(1)
PYEOF
