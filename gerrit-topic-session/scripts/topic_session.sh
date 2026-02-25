#!/usr/bin/env bash
set -euo pipefail

STORE_FILE="${CODEX_GERRIT_TOPIC_STORE:-/tmp/codex-gerrit-topics-${USER}.txt}"

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
