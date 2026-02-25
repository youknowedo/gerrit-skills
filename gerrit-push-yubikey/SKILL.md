---
name: gerrit-push-yubikey
description: Push changes to Gerrit using `git push origin HEAD:refs/for/master%wip` with YubiKey guidance. Use when the user asks to push for review to master and may need reminders to unlock their YubiKey and physically touch it during signing. If session topics exist, append them to the push as Gerrit options.
---

# Gerrit Push with YubiKey

Use this skill to perform Gerrit pushes that may require hardware-signing interaction.

## Workflow

1. Confirm this is a Gerrit repository:
- Run `git remote get-url origin` and verify Gerrit indicators, for example:
- remote host contains `gerrit`, or SSH port is `29418`, or URL path contains `/gerrit/`.
- If not Gerrit, stop and use normal `git push` instead of this skill.

2. Pre-check repository state:
- Run `git status --short`.
- Confirm there is a commit to push.

3. Optional: set session topics:
- Use `$gerrit-topic-session` to store topics for this session.

4. Run the push helper:
- `scripts/push_for_master.sh`
- This prints clear terminal reminders and sends desktop notifications.
- If session topics exist, it appends them as `topic=...` push options.

5. YubiKey guidance behavior:
- Before push starts, remind user to unlock YubiKey if needed.
- When push starts, send a notification telling user to touch/click the YubiKey.
- After push completes, send success/failure notification.

## Rules

- Base push target is `git push origin HEAD:refs/for/master%wip`.
- Do not use this skill when `origin` is not a Gerrit remote.
- If topics exist, append as additional push options.
- Do not force-push unless user explicitly requests it.
- Keep reminders concise and actionable.
- If desktop notifications are unavailable, keep terminal prompts as fallback.
