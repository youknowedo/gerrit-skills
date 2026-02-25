#!/usr/bin/env bash
set -euo pipefail

SKIP_UNLOCK_PROMPT=0
DRY_RUN=0

TOPIC_SCRIPT="${CODEX_GERRIT_TOPIC_SCRIPT:-$HOME/.codex/skills/gerrit/gerrit-topic-session/scripts/topic_session.sh}"

for arg in "$@"; do
  case "$arg" in
    --skip-unlock-prompt)
      SKIP_UNLOCK_PROMPT=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: $0 [--skip-unlock-prompt] [--dry-run]" >&2
      exit 2
      ;;
  esac
done

require_gerrit_origin() {
  local origin_url lower_url host_port host
  if ! origin_url="$(git remote get-url origin 2>/dev/null)"; then
    echo "Could not read remote 'origin'. This script requires a Gerrit repository." >&2
    exit 2
  fi

  if [[ "$origin_url" =~ ^ssh://([^/@]+@)?([^/:]+)(:([0-9]+))?/ ]]; then
    host="${BASH_REMATCH[2]}"
    host_port="${BASH_REMATCH[4]:-}"
  elif [[ "$origin_url" =~ ^([^/@]+@)?([^:]+):.+$ ]]; then
    host="${BASH_REMATCH[2]}"
    host_port=""
  elif [[ "$origin_url" =~ ^https?://([^/]+)/ ]]; then
    host="${BASH_REMATCH[1]}"
    host_port=""
  else
    host=""
    host_port=""
  fi

  lower_url="$(printf '%s' "$origin_url" | tr '[:upper:]' '[:lower:]')"
  host="$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]')"
  if [[ "$host" != *gerrit* && "$host_port" != "29418" && "$lower_url" != *"/gerrit/"* ]]; then
    echo "Remote origin does not look like Gerrit: $origin_url" >&2
    echo "Use normal git push for non-Gerrit repositories." >&2
    exit 2
  fi
}

notify() {
  local title="$1"
  local msg="$2"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$msg" >/dev/null 2>/dev/null || true
  fi
}

require_gerrit_origin

gerrit_options="wip"
if [[ -x "$TOPIC_SCRIPT" ]]; then
  topic_options="$($TOPIC_SCRIPT options 2>/dev/null || true)"
  if [[ -n "$topic_options" ]]; then
    gerrit_options+="${gerrit_options:+,}${topic_options}"
  fi
fi

refspec="HEAD:refs/for/master%${gerrit_options}"

if [[ $SKIP_UNLOCK_PROMPT -eq 0 ]]; then
  echo "YubiKey signing may be required for this push."
  echo "If your key is locked, unlock it now."
  read -r -p "Press Enter to continue with Gerrit push..." _
fi

echo "Starting Gerrit push to ${refspec}. If prompted, physically touch/click your YubiKey now."
notify "Gerrit push started" "If prompted, unlock and touch/click your YubiKey now."

PUSH_CMD=(git push origin "$refspec")

if [[ $DRY_RUN -eq 1 ]]; then
  echo "DRY RUN: ${PUSH_CMD[*]}"
  exit 0
fi

set +e
"${PUSH_CMD[@]}"
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "Push completed successfully."
  notify "Gerrit push success" "Push to ${refspec} completed successfully."
else
  echo "Push failed with exit code $status." >&2
  notify "Gerrit push failed" "Push failed. Check terminal output; YubiKey touch may have been missed."
fi

exit "$status"
