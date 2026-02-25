---
name: gerrit-topic-session
description: Manage session-scoped Gerrit topics and apply them during push. Use when the user gives one or more topics to remember for this Codex session and wants `git push ... refs/for/master%wip` to include those topics automatically.
---

# Gerrit Topic Session

Store and retrieve Gerrit topics for the current session, then include them in push refspec options.

## Workflow

1. Set topics for this session:
- `scripts/topic_session.sh set topic-a topic-b`

2. Inspect current topics:
- `scripts/topic_session.sh show`

3. Clear topics:
- `scripts/topic_session.sh clear`

4. Build push options string (for other scripts):
- `scripts/topic_session.sh options`
- Output example: `topic=topic-a,topic=topic-b`

## Rules

- Topics are session-scoped via `/tmp` storage and are not committed.
- Topic names are normalized to lowercase and must match `[a-z0-9._-]+`.
- Keep topic names short and meaningful.

