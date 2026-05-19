# Claude Code Review Rules — FastAPI Task Manager

These rules apply whenever Claude reviews code in this repository.

## Input Validation
- Always check that Pydantic models enforce constraints (e.g., `min_length`, `max_length`, `gt`, `ge`) where the domain requires them.
- Flag any route that accepts user-supplied data without a typed Pydantic schema.

## Error Handling
- Every endpoint that looks up a resource by ID must raise `HTTPException(status_code=404)` when the resource is not found.
- Any operation that can fail (I/O, external calls) must have explicit exception handling with an appropriate HTTP status code.

## HTTP Status Codes
- `POST` endpoints that create a resource must return `201 Created`.
- Successful `DELETE` endpoints should return `204 No Content`.
- Validation errors should surface as `422 Unprocessable Entity` (FastAPI default — do not suppress).
- Do not return `200` for errors.

## Configuration & Secrets
- Flag any hardcoded URLs, tokens, passwords, or environment-specific values that belong in environment variables or a config file.
- Credentials must never appear in source code; use `os.getenv()` or a settings model backed by `.env`.

## Sensitive Data
- Ensure no passwords, tokens, or PII are logged (via `print`, `logging`, etc.) or returned in API responses.
- Internal error details (stack traces, DB errors) must not be forwarded to clients; return a generic message instead.

## CORS
- `allow_origins=["*"]` is acceptable for local development only.
- Flag permissive CORS settings (`*`) in any code intended for production; require explicit origin whitelisting.

## General
- Prefer `response_model` on all endpoints to prevent accidental data leakage.
- Async route handlers (`async def`) should be used when the handler performs I/O.

## Skill Usage
- ALWAYS invoke the `api-design-patterns` skill before writing any new API endpoint. Use the Skill tool with skill name `api-design-patterns` and apply its guidelines to the new endpoint before writing any code.
