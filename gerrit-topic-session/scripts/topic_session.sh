#!/usr/bin/env bash
set -euo pipefail

resolve_store_file() {
  if [[ -n "${CODEX_GERRIT_TOPIC_STORE:-}" ]]; then
    printf '%s\n' "$CODEX_GERRIT_TOPIC_STORE"
    return
  fi

  local scope_raw scope
  scope_raw="${CODEX_GERRIT_TOPIC_SCOPE:-${CODEX_THREAD_ID:-${CODEX_SESSION_ID:-}}}"
  if [[ -n "$scope_raw" ]]; then
    scope="$(printf '%s' "$scope_raw" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9._-' '-')"
    printf '/tmp/codex-gerrit-topics-%s-%s.txt\n' "$USER" "$scope"
    return
  fi

  printf '/tmp/codex-gerrit-topics-%s.txt\n' "$USER"
}

STORE_FILE="$(resolve_store_file)"

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
    echo "Do not use Gerrit topic session commands in non-Gerrit repositories." >&2
    exit 2
  fi
}

usage() {
  cat <<USAGE
Usage: $0 <set|add|show|clear|options> [topics...]

Commands:
  set <topics...>   Replace session topics.
  add <topics...>   Add topics to existing session topics.
  show              Print current topics (one per line).
  clear             Remove all session topics.
  options           Print Gerrit push option list (comma-separated topic=... entries).
USAGE
}

normalize_topic() {
  local t
  t="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  if [[ ! "$t" =~ ^[a-z0-9._-]+$ ]]; then
    echo "Invalid topic '$1'. Allowed: [a-z0-9._-]" >&2
    exit 2
  fi
  printf '%s\n' "$t"
}

read_topics() {
  if [[ -f "$STORE_FILE" ]]; then
    cat "$STORE_FILE"
  fi
}

write_topics() {
  awk 'NF' | awk '!seen[$0]++' > "$STORE_FILE"
}

require_gerrit_origin

cmd="${1:-}"
shift || true

case "$cmd" in
  set)
    if [[ $# -eq 0 ]]; then
      echo "set requires at least one topic" >&2
      exit 2
    fi
    {
      for topic in "$@"; do
        normalize_topic "$topic"
      done
    } | write_topics
    echo "Saved topics to $STORE_FILE"
    ;;
  add)
    if [[ $# -eq 0 ]]; then
      echo "add requires at least one topic" >&2
      exit 2
    fi
    {
      read_topics
      for topic in "$@"; do
        normalize_topic "$topic"
      done
    } | write_topics
    echo "Updated topics in $STORE_FILE"
    ;;
  show)
    read_topics
    ;;
  clear)
    rm -f "$STORE_FILE"
    echo "Cleared topics"
    ;;
  options)
    if [[ ! -f "$STORE_FILE" ]]; then
      exit 0
    fi
    awk 'NF { printf("%stopic=%s", sep, $0); sep="," } END { print "" }' "$STORE_FILE"
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
