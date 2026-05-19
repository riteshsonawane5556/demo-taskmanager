Good progress! The "Failed to parse diff JSON" error is gone, meaning the API call and parsing now work. The script is failing at the "Sending diff to Claude for review..." step — so claude -p is exiting with code 1.
The most likely cause is Claude Code isn't authenticated in the CI environment. The CLAUDE_CODE_OAUTH_TOKEN variable exists but Claude Code may not be picking it up automatically.
Fix — set the correct environment variable name:
Claude Code looks for ANTHROPIC_API_KEY or needs explicit OAuth config. Add this to your script right before the claude call:
bash# Add after the DIFF_TEXT block, before the claude call
export ANTHROPIC_API_KEY="${CLAUDE_CODE_OAUTH_TOKEN}"
Or in your .gitlab-ci.yml, rename/alias the variable:
yamlvariables:
  ANTHROPIC_API_KEY: $CLAUDE_CODE_OAUTH_TOKEN
Also add error output to see the real failure:
Change this line in your script:
bash# FROM:
REVIEW=$(echo "$REVIEW_PROMPT" | claude -p --output-format text)

# TO:
REVIEW=$(echo "$REVIEW_PROMPT" | claude -p --output-format text 2>&1) || {
  echo "ERROR: Claude exited with code $?. Output: $REVIEW" >&2
  exit 1
}
And verify Claude Code installed correctly by adding before the claude call:
bashecho "Claude version: $(claude --version 2>&1)"
echo "Auth check: $(claude -p 'say hi' --output-format text 2>&1 | head -5)"
If you're using an Anthropic API key (not OAuth), replace CLAUDE_CODE_OAUTH_TOKEN entirely with ANTHROPIC_API_KEY in your GitLab CI variables — that's the correct variable name Claude Code expects.