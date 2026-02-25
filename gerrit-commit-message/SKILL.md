---
name: gerrit-commit-message
description: Write and apply commit messages that match Gerrit style. Use when creating commits in the current repository, especially when the user asks to commit, asks for a commit message, or wants the message to follow existing wt1 conventions (imperative subject, wrapped body, Jira footer handling, no manual Change-Id footer).
---

# Gerrit Commit Message

Use this skill to generate and apply commit messages that match the observed `wt1` history style.

## Workflow

1. Confirm this is a Gerrit repository:
- Run `git remote get-url origin` and verify Gerrit indicators, for example:
- remote host contains `gerrit`, or SSH port is `29418`, or URL path contains `/gerrit/`.
- If not Gerrit, stop and use normal Git commit flow instead of this skill.

2. Inspect the pending change:
- Run `git status --short`.
- Run `git diff --staged` (or `git diff` if nothing is staged yet).
- Identify the intent: feature, fix, refactor, docs, infra, dependency/security upgrade, release bump.

3. Build the message using the style guide:
- Read [wt1-commit-style.md](references/wt1-commit-style.md).
- Subject: imperative, first letter uppercase, no trailing period, target <= 50 characters.
- Body: explain what changed and why in past tense; wrap around 72 chars.
- Jira footer format: `Jira issue HUB-####`.

4. Jira prompting controls:
- Default behavior: do not ask for Jira; commits may proceed without Jira footer.
- CLI flag: add `--always-ask-jira` to always prompt in interactive commit mode.
- Config file: set `ALWAYS_ASK_JIRA=true` in `config.env` to enable always-ask by default.
- CLI `--always-ask-jira` overrides config by forcing prompt.

5. Create and apply commit message:
- Prefer `scripts/format_commit_message.py` for deterministic formatting and validation.
- Standard use:
  `python3 scripts/format_commit_message.py --subject "..." --body-file /tmp/body.txt --jira HUB-1234 --commit`
- Always ask mode (one-off):
  `python3 scripts/format_commit_message.py --subject "..." --body-file /tmp/body.txt --commit --always-ask-jira`
- Always ask mode (persistent):
  set `ALWAYS_ASK_JIRA=true` in `/home/filip/.codex/skills/gerrit/gerrit-commit-message/config.env`.

6. Verify result:
- Run `git log -1 --pretty=full` and confirm:
  - Subject format is correct.
  - Body exists when needed.
  - Footer is correct.
  - No manually-added `Change-Id`, `Reviewed-on`, `Reviewed-by`, or `Tested-by` lines.

## Rules

- Do not ask for Jira unless always-ask mode is enabled.
- Do not use this skill when `origin` is not a Gerrit remote.
- Do not add Gerrit-generated metadata (`Change-Id`, `Reviewed-on`, `Reviewed-by`, `Tested-by`) manually.
- Keep subject specific and action-oriented; avoid generic subjects like `Update stuff`.
- For release/version bumps, use subject pattern `Upgrade to X.Y.Z` or `Upgrade to X.Y.Z.devN`.
- For security fixes, include vulnerable package/CVE in subject when relevant.
