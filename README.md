I have a FastAPI project ready. Now I want to add an automated GitLab MR 
reviewer to this project. Do the following step by step:

## Goal
When a Merge Request is opened or updated on GitLab, Claude Code should 
automatically review the code diff and post a structured comment back on 
the MR.

## Step 1: Create review script
Create a file called `mr_review.sh` in the project root with this logic:
- Accept MR_IID and PROJECT_ID as arguments
- Fetch the MR diff using GitLab REST API:
  GET $GITLAB_API_URL/projects/$PROJECT_ID/merge_requests/$MR_IID/diffs
  with header: PRIVATE-TOKEN: $GITLAB_TOKEN
- Parse the diff using python3 and extract file name + diff content
- Pipe the diff into claude -p with this review prompt:
  "You are a senior code reviewer. Review this MR diff carefully and provide:
   1. SUMMARY: One paragraph overview of what this MR does
   2. ISSUES: List any bugs, logic errors, security vulnerabilities, or 
      missing error handling. Use 🔴 Critical, 🟡 Warning, 🟢 Suggestion labels.
   3. POSITIVES: What is done well
   4. VERDICT: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
   Be specific, reference file names and line numbers where possible."
- Capture Claude's review output into a variable called REVIEW
- Post REVIEW as a comment on the MR using GitLab API:
  POST $GITLAB_API_URL/projects/$PROJECT_ID/merge_requests/$MR_IID/notes
  body: { "body": "## 🤖 Claude Code Review\n\n$REVIEW" }

## Step 2: Create CLAUDE.md
Create a CLAUDE.md file in the project root with these review rules 
specific to our FastAPI project:
- Always check for missing input validation on Pydantic models
- Flag any endpoint missing error handling (HTTPException)
- Check for proper HTTP status codes (201 for POST, 404 for not found, etc.)
- Look for hardcoded values that should be config/env variables
- Ensure no sensitive data is logged or returned in responses
- Check CORS settings are not too permissive for production

## Step 3: Create .gitlab-ci.yml
Create a .gitlab-ci.yml file with:

stages:
  - review

variables:
  GITLAB_API_URL: "https://gitlab.com/api/v4"

claude-mr-review:
  stage: review
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  before_script:
    - apk add --no-cache git curl bash python3
    - npm install -g @anthropic-ai/claude-code
  script:
    - chmod +x mr_review.sh
    - bash mr_review.sh $CI_MERGE_REQUEST_IID $CI_PROJECT_ID
  timeout: 10 minutes

## Step 4: Create .env.example
Create a .env.example file showing required environment variables:
GITLAB_TOKEN=your_gitlab_personal_access_token
GITLAB_API_URL=https://gitlab.com/api/v4
CLAUDE_CODE_OAUTH_TOKEN=your_claude_oauth_token

## Step 5: Update README.md
Add a new section "## MR Reviewer Setup" to the existing README.md with:
1. Prerequisites (Claude Code installed, GitLab token, Claude OAuth token)
2. GitLab CI/CD Variables to set:
   - GITLAB_TOKEN (masked)
   - CLAUDE_CODE_OAUTH_TOKEN (masked)
3. How it works (short explanation)
4. How to trigger manually from GitLab UI

## Step 6: Test the script locally
- Set these env variables using dummy values and do a dry run of mr_review.sh
  to confirm the script has no syntax errors
- Run: bash -n mr_review.sh to check syntax
- Show me the final file tree of the project

After all steps are done, show me the complete contents of:
- mr_review.sh
- .gitlab-ci.yml
- CLAUDE.md

---

## MR Reviewer Setup

Automatically reviews every Merge Request using Claude Code and posts a structured comment directly on the MR.

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed (`npm install -g @anthropic-ai/claude-code`)
- A GitLab Personal Access Token with `api` scope
- A Claude Code OAuth token (`CLAUDE_CODE_OAUTH_TOKEN`)

### GitLab CI/CD Variables

Set the following variables in **GitLab → Settings → CI/CD → Variables** (mark both as **Masked**):

| Variable | Description |
|---|---|
| `GITLAB_TOKEN` | GitLab Personal Access Token with `api` scope |
| `CLAUDE_CODE_OAUTH_TOKEN` | Claude Code OAuth token for authentication |

### How It Works

1. A Merge Request is opened or updated on GitLab.
2. GitLab CI triggers the `claude-mr-review` job (only on `merge_request_event`).
3. `mr_review.sh` fetches the MR diff via the GitLab REST API.
4. The diff is piped into `claude -p` with a structured senior-reviewer prompt.
5. Claude's response is posted back as a comment on the MR using the GitLab Notes API.

### Triggering Manually from GitLab UI

1. Navigate to your project → **CI/CD → Pipelines**.
2. Click **Run pipeline**.
3. Set the source to the branch associated with your MR.
4. Add the variable `CI_PIPELINE_SOURCE` = `merge_request_event` if running outside a real MR context.
5. Click **Run pipeline** — the `claude-mr-review` job will execute and post the review.