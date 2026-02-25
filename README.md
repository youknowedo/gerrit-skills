# Gerrit Skills

Local Codex skills for Gerrit workflows.

## Included Skills

- `gerrit-commit-message`: Generates and applies commit messages in Gerrit style (imperative subject, wrapped body, Jira footer handling, no manual Gerrit metadata).
- `gerrit-push-yubikey`: Pushes to `refs/for/master%wip` with YubiKey reminders and optional session topic support.
- `gerrit-topic-session`: Stores session-scoped Gerrit topics and formats them as push options.

## Quick Usage

### Commit message formatting

```bash
python3 gerrit-commit-message/scripts/format_commit_message.py \
  --subject "Upgrade to 1.2.3" \
  --body-file /tmp/body.txt \
  --jira HUB-1234 \
  --commit
```

### Set or inspect session topics

```bash
gerrit-topic-session/scripts/topic_session.sh set release-prep
gerrit-topic-session/scripts/topic_session.sh show
```

### Push for Gerrit review

```bash
gerrit-push-yubikey/scripts/push_for_master.sh
```

## License

MIT. See `LICENSE`.
