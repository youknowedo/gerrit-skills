# Usage

Run from the repo you want to push:

```bash
~/.codex/skills/gerrit/gerrit-push-yubikey/scripts/push_for_master.sh
```

Optional flags:

- `--skip-unlock-prompt`: skip the pre-push "Press Enter" pause.
- `--dry-run`: print the command without pushing.

Push target is fixed to:

```bash
git push origin HEAD:refs/for/master%wip
```
