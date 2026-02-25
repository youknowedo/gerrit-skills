#!/usr/bin/env python3
"""Format and optionally apply a Gerrit-style commit message."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
import textwrap
from pathlib import Path


SUBJECT_MAX = 50
BODY_WRAP = 72
DEFAULT_CONFIG_PATH = Path.home() / ".codex/skills/gerrit/gerrit-commit-message/config.env"


def _read_body(body: str | None, body_file: str | None) -> str:
    if body and body_file:
        raise ValueError("Use either --body or --body-file, not both.")
    if body_file:
        return Path(body_file).read_text(encoding="utf-8").strip()
    return (body or "").strip()


def _validate_subject(subject: str) -> list[str]:
    warnings: list[str] = []
    if not subject:
        raise ValueError("Subject cannot be empty.")
    if subject.endswith("."):
        warnings.append("Subject should not end with a period.")
    if not subject[0].isupper():
        warnings.append("Subject should start with an uppercase letter.")
    if len(subject) > SUBJECT_MAX:
        warnings.append(
            f"Subject is {len(subject)} chars (target <= {SUBJECT_MAX})."
        )
    return warnings


def _normalize_jira(jira: str | None) -> str | None:
    if not jira:
        return None
    jira = jira.strip()
    m = re.fullmatch(r"(?:Jira issue\s+)?(HUB-\d+)", jira, flags=re.IGNORECASE)
    if not m:
        raise ValueError("Jira must look like HUB-1234 or 'Jira issue HUB-1234'.")
    return f"Jira issue {m.group(1).upper()}"


def _wrap_paragraphs(text: str, width: int) -> str:
    if not text:
        return ""
    paragraphs = [p.strip() for p in re.split(r"\n\s*\n", text.strip())]
    wrapped = [
        textwrap.fill(p, width=width, break_long_words=False, break_on_hyphens=False)
        for p in paragraphs
        if p
    ]
    return "\n\n".join(wrapped)


def _as_bool(value: str) -> bool:
    return value.strip().lower() in {"1", "true", "yes", "on"}


def _load_config(config_path: Path) -> dict[str, str]:
    config: dict[str, str] = {}
    if not config_path.exists():
        return config

    for raw_line in config_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        config[key.strip()] = value.strip()
    return config


def _prompt_for_jira(current_jira: str | None) -> str | None:
    if current_jira:
        prompt = f"Jira issue (HUB-1234, Enter to keep {current_jira}): "
    else:
        prompt = "Jira issue (HUB-1234, optional): "

    jira = input(prompt).strip()
    if jira:
        return jira
    if current_jira:
        return current_jira

    confirm = input("No Jira issue provided. Continue without Jira footer? [y/N]: ")
    if confirm.strip().lower() in {"y", "yes"}:
        return None
    raise ValueError("Aborted: Jira issue not provided.")


def build_message(subject: str, body: str, jira_footer: str | None) -> str:
    parts = [subject.strip()]
    wrapped_body = _wrap_paragraphs(body, BODY_WRAP)
    if wrapped_body:
        parts.append(wrapped_body)
    if jira_footer:
        parts.append(jira_footer)
    return "\n\n".join(parts).rstrip() + "\n"


def commit_with_message(message: str) -> None:
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", delete=False) as tf:
        tf.write(message)
        tmp_path = tf.name
    try:
        subprocess.run(["git", "commit", "-F", tmp_path], check=True)
    finally:
        Path(tmp_path).unlink(missing_ok=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--subject", required=True, help="Commit subject line")
    parser.add_argument("--body", help="Commit body text")
    parser.add_argument("--body-file", help="Path to file with commit body text")
    parser.add_argument("--jira", help="Jira key (HUB-1234) or full footer")
    parser.add_argument(
        "--always-ask-jira",
        action="store_true",
        help="Always prompt for Jira in interactive commit mode",
    )
    parser.add_argument(
        "--config",
        default=str(DEFAULT_CONFIG_PATH),
        help=f"Config file path (default: {DEFAULT_CONFIG_PATH})",
    )
    parser.add_argument(
        "--allow-no-jira",
        action="store_true",
        help="Allow commit without Jira in non-interactive mode",
    )
    parser.add_argument(
        "--commit",
        action="store_true",
        help="Run git commit -F with the generated message",
    )
    args = parser.parse_args()

    try:
        body = _read_body(args.body, args.body_file)
        warnings = _validate_subject(args.subject.strip())

        config = _load_config(Path(args.config))
        config_always_ask = _as_bool(config.get("ALWAYS_ASK_JIRA", "false"))
        always_ask_jira = bool(args.always_ask_jira or config_always_ask)

        jira_value = args.jira
        if args.commit:
            if sys.stdin.isatty() and (always_ask_jira or not jira_value):
                jira_value = _prompt_for_jira(jira_value)
            elif not jira_value and not args.allow_no_jira:
                raise ValueError(
                    "--jira is required with --commit in non-interactive mode "
                    "(or pass --allow-no-jira)."
                )

        jira_footer = _normalize_jira(jira_value)
        message = build_message(args.subject, body, jira_footer)
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    for warning in warnings:
        print(f"warning: {warning}", file=sys.stderr)

    if args.commit:
        commit_with_message(message)
    else:
        sys.stdout.write(message)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
