# Test agent

## Goals

- Define the specific objectives this agent should accomplish each run.

## Behavior

- Describe how the agent should approach tasks, communicate, and handle edge cases.

## Constraints

- List any boundaries, rate limits, or safety guidelines the agent should follow.

---

## Operating Guide

### Session lifecycle

1. **Start of session** — Read `progress.md` to restore context from prior runs.
2. **Check inbound/** — Process any new files in your `inbound/` directory. Each file is a task or message. After processing, delete the file.
3. **Do work** — Execute your goals. Use the tools available to you.
4. **Update progress.md** — Before ending, update `progress.md` with:
   - Current status (what's done, what's in progress)
   - Decisions made this session and why
   - Context the next session will need
5. **Log activity** — Append a row to `activity-log.csv` for each significant action.

### Run modes

Your agent can be triggered in three ways. Check the trigger context appended to your prompt to determine which mode you're in.

- **Scheduled** (`schedule` event) — Automated periodic run. Execute your goals autonomously. If there's nothing to do, log it and exit cleanly without posting to Slack.
- **Slack** (`repository_dispatch` event) — A human or bot sent a message in Slack. Read the full Slack thread (using `thread_ts` from the payload) to understand the conversation context before responding. Always reply in the same thread. Send an initial reply early so the user knows you're working on it, and post updates as you make progress.
- **Manual** (`workflow_dispatch` event) — A human triggered you from the GitHub Actions UI with a custom prompt. Follow those instructions.

### progress.md

This is your persistent memory across sessions. Keep it concise and current — overwrite stale sections rather than appending indefinitely. Structure:

- **Status** — One-line summary of where things stand.
- **Current Work** — Active tasks, next steps, blockers.
- **Decisions** — Key choices and rationale (so future sessions don't re-debate).
- **Context** — Anything the next session needs to know (links, data, open questions).

### activity-log.csv

Append-only audit trail. Format: `timestamp,action,type,details`

- **timestamp** — ISO 8601 (e.g. `2025-01-15T14:30:00Z`)
- **action** — What you did (e.g. `processed_inbound`, `created_pr`, `updated_config`)
- **type** — Category (e.g. `inbound`, `code`, `communication`, `maintenance`)
- **details** — Brief description

### inbound/ directory

Other agents and humans send you work by dropping files here. Naming convention: `YYYY-MM-DD-short-description.md`. Process files in chronological order, then delete them after handling.

To send messages to other agents, write files to their `inbound/` directories (e.g. `../other-agent/inbound/2025-01-15-request.md`).

### Write isolation

On the main branch, you can only write to:
- Your own directory (`test-agent/`) for routine operational updates (progress, logs, inbound tasks)
- Any agent's `inbound/` directory (for inter-agent messaging)

For source-code or repo-level config changes, create a PR instead of committing directly.
For instruction updates to `AGENTS.md`, create a PR when requested.

### Git workflow

- Commit your progress.md and activity-log.csv updates directly to main.
- For code changes or anything outside your directory, create a branch and open a PR.
- Write clear, concise commit messages.
