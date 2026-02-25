---
name: gerrit-push-yubikey
description: Push changes to Gerrit using `git push origin HEAD:refs/for/master%wip` with YubiKey guidance. Use when the user asks to push for review to master and may need reminders to unlock their YubiKey and physically touch it during signing. If session topics exist, append them to the push as Gerrit options.
---

# Gerrit Push with YubiKey

Use this skill to perform Gerrit pushes that may require hardware-signing interaction.

## Workflow

1. Pre-check repository state:
- Run `git status --short`.
- Confirm there is a commit to push.

2. Optional: set session topics:
- Use `$gerrit-topic-session` to store topics for this session.

3. Run the push helper:
- `scripts/push_for_master.sh`
- This prints clear terminal reminders and sends desktop notifications.
- If session topics exist, it appends them as `topic=...` push options.

4. YubiKey guidance behavior:
- Before push starts, remind user to unlock YubiKey if needed.
- When push starts, send a notification telling user to touch/click the YubiKey.
- After push completes, send success/failure notification.

## Rules

- Base push target is `git push origin HEAD:refs/for/master%wip`.
- If topics exist, append as additional push options.
- Do not force-push unless user explicitly requests it.
- Keep reminders concise and actionable.
- If desktop notifications are unavailable, keep terminal prompts as fallback.

