---
name: gerrit-topic-session
description: Manage session-scoped Gerrit topics and apply them during push. Use when the user gives one or more topics to remember for this Codex session and wants `git push ... refs/for/master%wip` to include those topics automatically.
---

# Gerrit Topic Session

Store and retrieve Gerrit topics for the current Codex chat, then include them
in push refspec options.

## Workflow

1. Confirm this is a Gerrit repository:
- Run `git remote get-url origin` and verify Gerrit indicators, for example:
- remote host contains `gerrit`, or SSH port is `29418`, or URL path contains `/gerrit/`.
- If not Gerrit, stop and do not manage Gerrit topic options for this repo.

2. Set topics for this session:
- `scripts/topic_session.sh set topic-a topic-b`

3. Inspect current topics:
- `scripts/topic_session.sh show`

4. Clear topics:
- `scripts/topic_session.sh clear`

5. Build push options string (for other scripts):
- `scripts/topic_session.sh options`
- Output example: `topic=topic-a,topic=topic-b`

## Rules

- Topics are chat-scoped via `/tmp` storage keyed by `CODEX_THREAD_ID` (or
  `CODEX_GERRIT_TOPIC_SCOPE`) and are not committed.
- Do not use this skill when `origin` is not a Gerrit remote.
- Topic names are normalized to lowercase and must match `[a-z0-9._-]+`.
- Keep topic names short and meaningful.
