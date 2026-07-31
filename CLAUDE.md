# phillip-mintmcp/Mintmcp-local

## Overview

This repository uses [Claude Code](https://docs.anthropic.com/en/docs/claude-code) via GitHub Actions.

## Development

- Follow existing code patterns and conventions
- Write clear commit messages
- Create PRs for all changes

## Agents

Agents live in top-level directories. Each agent has:
- `CLAUDE.md` — instructions for the agent
- `agent.yml` — configuration (triggers, secrets, environment)
- `progress.md` — persistent state across sessions
- `activity-log.csv` — audit trail of actions
- `inbound/` — directory for receiving messages

See existing agents in this repo for examples.
