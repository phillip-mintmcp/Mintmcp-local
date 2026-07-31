#!/bin/bash
# Shared agent directory isolation enforcement
# Prevents agents from writing to protected files on main branch
# Returns exit code 1 if blocked, 0 if OK
#
# Required env vars:
#   AGENT_NAME  - Display name (e.g., "Max")
#   AGENT_DIR   - Directory name (e.g., "max-deal-agent")

if [ -z "$AGENT_NAME" ] || [ -z "$AGENT_DIR" ]; then
  echo "ERROR: AGENT_NAME and AGENT_DIR must be set"
  exit 1
fi

# Patterns agent IS allowed to write to
ALLOWED_PATTERNS=(
  "${AGENT_DIR}/"
  "*/inbound/"
)

# Patterns that are ALWAYS protected (require PR)
PROTECTED_PATTERNS=(
  ".github/workflows/"
  "AGENTS.md"
  "CLAUDE.md"
  "scripts/"
)

# Get current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

# If not on main, allow everything (PRs are fine)
if [ "$BRANCH" != "main" ]; then
  exit 0
fi

# Check staged files against protected patterns
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null)
if [ -z "$STAGED_FILES" ]; then
  # No staged files, check committed but not pushed
  STAGED_FILES=$(git diff origin/main --name-only 2>/dev/null || echo "")
fi

# If no files to check, allow
if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

BLOCKED_FILES=""
for file in $STAGED_FILES; do
  IS_ALLOWED=false
  IS_PROTECTED=false

  # Check if file is in protected patterns first
  for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if [[ "$file" == $pattern* ]] || [[ "$file" == *"/$pattern"* ]]; then
      IS_PROTECTED=true
      break
    fi
  done

  # Check if file is in allowed patterns
  for pattern in "${ALLOWED_PATTERNS[@]}"; do
    if [[ "$file" == $pattern* ]]; then
      # But skip instruction files, which require PRs
      if [[ "$file" == *"CLAUDE.md" || "$file" == *"AGENTS.md" ]]; then
        IS_PROTECTED=true
      else
        IS_ALLOWED=true
      fi
      break
    fi
  done

  # If protected OR not in allowed list, block it
  if [ "$IS_PROTECTED" = true ] || [ "$IS_ALLOWED" = false ]; then
    BLOCKED_FILES="$BLOCKED_FILES\n  - $file"
  fi
done

if [ -n "$BLOCKED_FILES" ]; then
  echo "ERROR: ${AGENT_NAME} cannot push these files directly to main!"
  echo ""
  echo "Blocked files:"
  echo -e "$BLOCKED_FILES"
  echo ""
  echo "${AGENT_NAME} can only write to:"
  echo "  - ${AGENT_DIR}/ (except CLAUDE.md and AGENTS.md)"
  echo "  - */inbound/ (inter-agent messages)"
  echo ""
  echo "For other changes, create a PR instead:"
  AGENT_LOWER=$(echo "$AGENT_NAME" | tr '[:upper:]' '[:lower:]')
  echo "  1. git checkout -b ${AGENT_LOWER}/<description>"
  echo "  2. git push -u origin <branch>"
  echo "  3. gh pr create"
  exit 1
fi

exit 0
