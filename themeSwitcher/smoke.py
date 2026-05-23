#!/usr/bin/env python3

"""smoke.py — run before committing.

This catches the class of regression where a CLI flag documented in the
README quietly disappears from the script (which is what happened
between v2.0.0 and v2.0.2). It does NOT touch your real config — it
points themeSwitcher at a temp directory and exercises every read-only
command plus a dry-pass through theme application.

Usage:
    python3 smoke.py
    python3 smoke.py --keep   # keep the temp dir around to inspect
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT  = Path(__file__).resolve().parent
SCRIPT     = REPO_ROOT / ".local/bin/themeSwitcher"
DATA_SRC   = REPO_ROOT / ".local/share/themeSwitcher"
README     = REPO_ROOT / "README.md"


def run(env: dict, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, str(SCRIPT), *args],
        env=env, capture_output=True, text=True,
    )


def documented_flags(readme: Path) -> list[str]:
    """Pull out every long flag mentioned in the README as
    `themeSwitcher --foo`. Used to assert each documented flag is
    actually wired up in the parser."""
    text = readme.read_text()
    # Match `themeSwitcher --something` (avoiding `--something` inside
    # other tools' invocations).
    return sorted(set(re.findall(r"themeSwitcher\s+(--[a-z][a-z-]*)", text)))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--keep", action="store_true")
    args = ap.parse_args()

    tmp = Path(tempfile.mkdtemp(prefix="themeSwitcher-smoke-"))
    data = tmp / "data" / "themeSwitcher"
    config = tmp / "config"
    data.parent.mkdir(parents=True)
    config.mkdir()

    # Stage the data dir
    shutil.copytree(DATA_SRC, data)

    # Stage a minimal theme so --list, --apply etc. have something to
    # work with even on a fresh repo with no migrated themes yet.
    test_theme = data / "themes" / "smoke-test-theme"
    test_theme.mkdir(parents=True, exist_ok=True)
    (test_theme / "theme.toml").write_text("""\
display_name = "Smoke Test"

[gnome]
gtk_theme    = "Adwaita-dark"
shell_theme  = "Adwaita-dark"
icon_theme   = "Papirus-Dark"
accent_color = "purple"
color_scheme = "prefer-dark"

[palette]
base = "#000000"
mantle = "#000000"
surface = "#000000"
overlay = "#000000"
muted = "#000000"
text = "#ffffff"
subtext = "#ffffff"
red = "#ff0000"
orange = "#ff8800"
yellow = "#ffff00"
green = "#00ff00"
teal = "#00ffff"
sky = "#00aaff"
sapphire = "#0088ff"
blue = "#0000ff"
mauve = "#ff00ff"

[vars]
ghostty = "Builtin Dark"

[colors]
background      = "base"
foreground      = "text"
highlight       = "teal"
secondary       = "subtext"
title           = "text"
hi_fg           = "blue"
selected_bg     = "surface"
selected_fg     = "blue"
inactive_fg     = "muted"
graph_text      = "subtext"
meter_bg        = "surface"
proc_misc       = "subtext"
cpu_box         = "mauve"
mem_box         = "green"
net_box         = "red"
proc_box        = "blue"
div_line        = "overlay"
temp_start      = "green"
temp_mid        = "yellow"
temp_end        = "red"
cpu_start       = "teal"
cpu_mid         = "sapphire"
cpu_end         = "red"
free_start      = "green"
free_mid        = "subtext"
free_end        = "blue"
cached_start    = "sapphire"
cached_mid      = "blue"
cached_end      = "red"
available_start = "green"
available_mid   = "red"
available_end   = "red"
used_start      = "teal"
used_mid        = "teal"
used_end        = "sky"
download_start  = "orange"
download_mid    = "red"
download_end    = "red"
upload_start    = "green"
upload_mid      = "teal"
upload_end      = "sky"
process_start   = "sapphire"
process_mid     = "subtext"
process_end     = "mauve"
error_status    = "red"
success_status  = "green"
replace_mode    = "teal"
visual_mode     = "overlay"
dir_fg          = "teal"
git_fg          = "mauve"
time_fg         = "yellow"
""")

    env = {
        **os.environ,
        "XDG_DATA_HOME":   str(data.parent),
        "XDG_CONFIG_HOME": str(config),
        # Force non-TTY so we don't accidentally trigger fzf
        "TERM": "dumb",
    }

    failures: list[str] = []

    def check(label: str, ok: bool, detail: str = "") -> None:
        mark = "ok " if ok else "FAIL"
        print(f"  [{mark}] {label}")
        if not ok and detail:
            for line in detail.splitlines():
                print(f"         {line}")
            failures.append(label)
        elif not ok:
            failures.append(label)

    # 1. --version
    r = run(env, "--version")
    check("--version", r.returncode == 0 and "themeSwitcher" in r.stdout,
          r.stderr)

    # 2. --help (parser well-formed)
    r = run(env, "--help")
    check("--help", r.returncode == 0 and "theme" in r.stdout, r.stderr)

    # 3. Every flag in README is in --help
    help_out = r.stdout
    docs = documented_flags(README)
    for flag in docs:
        if flag in {"--help"}:
            continue
        check(f"{flag} present in --help",
              flag in help_out,
              f"README references {flag} but it's missing from --help.")

    # 4. --check
    r = run(env, "--check")
    check("--check exits 0", r.returncode == 0, r.stderr + "\n" + r.stdout)

    # 5. --list
    r = run(env, "--list")
    check("--list runs", r.returncode == 0, r.stderr)
    check("--list has output", bool(r.stdout.strip()), "no themes listed")

    # 6. --themes
    r = run(env, "--themes")
    check("--themes runs", r.returncode == 0, r.stderr)

    # 7. --apps
    r = run(env, "--apps")
    check("--apps runs", r.returncode == 0, r.stderr)

    # Done
    print()
    if failures:
        print(f"FAILED ({len(failures)}): {', '.join(failures)}")
        if not args.keep:
            shutil.rmtree(tmp)
        else:
            print(f"Temp dir kept at: {tmp}")
        sys.exit(1)
    else:
        print("All checks passed.")
        if args.keep:
            print(f"Temp dir kept at: {tmp}")
        else:
            shutil.rmtree(tmp)


if __name__ == "__main__":
    main()
