# wt1 Commit Message Style (Last 100 Commits)

Source analyzed: `git log -n 100 --pretty=full` in `wt1`.

## Observed conventions

- Subject is always capitalized and imperative.
- Subject has no trailing period.
- Subject length is usually concise (average ~32 chars, max 50 in sampled 100).
- Body is usually present for non-trivial changes.
- `Jira issue HUB-####` appears in many commits (64/100 in this sample).
- Gerrit footers (`Change-Id`, `Reviewed-on`, `Reviewed-by`, `Tested-by`) appear after commit creation and must not be manually authored.

## Typical subject patterns

- `Add ...`
- `Fix ...`
- `Remove ...`
- `Update ...`
- `Enable ...`
- `Rename ...`
- `Upgrade to <version>`
- `Address vulnerable <dependency> dependency`

## Body guidance

- First paragraph: what changed.
- Second paragraph (optional): why and impact.
- Keep lines wrapped around 72 chars.
- Keep tense present/imperative, consistent with subject.

## Footer guidance

- Preferred ticket footer format:
  `Jira issue HUB-1234`
- Multiple tickets are acceptable when needed:
  `Jira issue HUB-2579, Jira issue HUB-2555`

## Real examples from sampled commits

- Subject: `Add quickstart notebook example`
  - Body includes short rationale and scope.
  - Includes `Jira issue HUB-2695`.

- Subject: `Fix broken steps in quickstart`
  - Body explains two concrete fixes and cause.
  - Includes `Jira issue HUB-2506`.

- Subject: `Upgrade to 2026.2.4.dev0`
  - Body is short (`Upgrade python package version.`).
  - May omit Jira footer in some version-bump commits.

- Subject: `Address fast-xml-parser vulnerability`
  - Body names advisory and mitigation.
  - Includes Jira footer.

