Run anthropics/claude-code-action@v1
Run oven-sh/setup-bun@0c5077e51419868618aeaa5fe8019c62421857d6
Downloading a new version of Bun: https://github.com/oven-sh/bun/releases/download/bun-v1.3.14/bun-linux-x64.zip
/usr/bin/unzip -o -q /home/runner/work/_temp/70448578-982b-462b-a9b2-2b936df3cd56.zip
/home/runner/.bun/bin/bun --revision
1.3.14+0d9b296af
Run cd ${GITHUB_ACTION_PATH}
bun install v1.3.14 (0d9b296a)

+ @actions/core@1.11.1
+ @actions/github@6.0.1
+ @anthropic-ai/claude-agent-sdk@0.3.144
+ @modelcontextprotocol/sdk@1.16.0
+ @octokit/graphql@8.2.2
+ @octokit/rest@21.1.1
+ @octokit/webhooks-types@7.6.1
+ node-fetch@3.3.2
+ shell-quote@1.8.3
+ zod@3.25.76

140 packages installed [964.00ms]
Run bun --no-env-file \
Auto-detected mode: agent for event: pull_request
Requesting OIDC token...
Attempt 1 of 3...
OIDC token successfully obtained
Exchanging OIDC token for app token...
Attempt 1 of 3...
App token successfully obtained
Using GITHUB_TOKEN from OIDC
Checking permissions for actor: riteshsonawane5556
Permission level retrieved: admin
Actor has write access: admin
Mode: agent
Context prompt: /code-review:code-review riteshsonawane5556/demo-taskmanager/pull/6
Trigger result: true
Preparing with mode: agent for event: pull_request
Actor type: User
Verified human actor: riteshsonawane5556
Configuring git authentication for non-signing mode
Configuring git user...
Setting git user as claude[bot]...
✓ Set git user as claude[bot]
Removing existing git authentication headers...
✓ Removed existing authentication headers
Updating remote URL with authentication...
✓ Updated remote URL with authentication token
Git authentication configured successfully
Installing Claude Code v2.1.144...
Installation attempt 1...
Setting up Claude Code...

Checking installation status...
Installing Claude Code native build 2.1.144...
Setting up launcher and shell integration...
✔ Claude Code successfully installed!

  Version: 2.1.144

  Location: ~/.local/bin/claude


  Next: Run claude --help to get started

✅ Installation complete!

Claude Code installed successfully
Restoring .claude, .mcp.json, .claude.json, .gitmodules, .ripgreprc, CLAUDE.md, CLAUDE.local.md, .husky from origin/main (PR head is untrusted)
Preserved PR's sensitive paths -> .claude-pr/ for review agents (not executed)
From https://github.com/riteshsonawane5556/demo-taskmanager
 * branch            main       -> FETCH_HEAD
 * [new branch]      main       -> origin/main
Setting up Claude settings at: /home/runner/.claude/settings.json
Creating .claude directory...
No existing settings file found, creating new one
Updated settings with enableAllProjectMcpServers: true
Settings saved successfully
Adding 1 marketplace(s)...
Adding marketplace: https://github.com/anthropics/claude-code.git
Adding marketplace…Refreshing marketplace cache (timeout: 120s)…
Cloning repository (timeout: 120s): https://github.com/anthropics/claude-code.git
Clone complete, validating marketplace…
Cleaning up old marketplace cache…
✔ Successfully added marketplace: claude-code-plugins (declared in user settings)
✓ Successfully added marketplace: https://github.com/anthropics/claude-code.git
Installing 1 plugin(s)...
Installing plugin: code-review@claude-code-plugins
Installing plugin "code-review@claude-code-plugins"...✔ Successfully installed plugin: code-review@claude-code-plugins (scope: user)
✓ Successfully installed: code-review@claude-code-plugins
Running Claude Code via SDK (full output hidden for security)...
Rerun in debug mode or enable `show_full_output: true` in your workflow file for full output.
Running Claude with prompt from file: /home/runner/work/_temp/claude-prompts/claude-prompt.txt
SDK options: {
  "systemPrompt": {
    "type": "preset",
    "preset": "claude_code"
  },
  "pathToClaudeCodeExecutable": "/home/runner/.local/bin/claude",
  "settingSources": [
    "user",
    "project",
    "local"
  ]
}
{
  "type": "system",
  "subtype": "init",
  "message": "Claude Code initialized",
  "model": "claude-sonnet-4-6"
}
{
  "type": "result",
  "subtype": "success",
  "is_error": false,
  "duration_ms": 122611,
  "num_turns": 9,
  "total_cost_usd": 0.41370375000000004,
  "permission_denials_count": 0
}
Log saved to /home/runner/work/_temp/claude-execution-output.json
Set session_id: 35c6b740-7bd7-4567-9437-2629f41b9561
Internal error: directory mismatch for directory "/home/runner/work/_actions/anthropics/claude-code-action/v1/tsconfig.json", fd 4. You don't need to do anything, but this indicates a bug.
Run BUN_BIN="${GITHUB_ACTION_PATH}/bin/bun"
No buffered inline comments
Internal error: directory mismatch for directory "/home/runner/work/_actions/anthropics/claude-code-action/v1/tsconfig.json", fd 4. You don't need to do anything, but this indicates a bug.
Run curl -L \
  curl -L \
    -X DELETE \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: ***" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    ${GITHUB_API_URL:-https://api.github.com}/installation/token
  shell: /usr/bin/bash --noprofile --norc -e -o pipefail {0}
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed

  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0