# Usage

Topics are stored per Codex chat (keyed by `CODEX_THREAD_ID` when available), so
different chats do not share topic state.

Set topics for this session:

```bash
~/.codex/skills/gerrit/gerrit-topic-session/scripts/topic_session.sh set sdk-migration ios-bench
```

Show topics:

```bash
~/.codex/skills/gerrit/gerrit-topic-session/scripts/topic_session.sh show
```

Clear topics:

```bash
~/.codex/skills/gerrit/gerrit-topic-session/scripts/topic_session.sh clear
```

Get Gerrit option suffix entries:

```bash
~/.codex/skills/gerrit/gerrit-topic-session/scripts/topic_session.sh options
# topic=sdk-migration,topic=ios-bench
```
