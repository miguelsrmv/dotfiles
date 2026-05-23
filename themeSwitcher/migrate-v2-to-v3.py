#!/usr/bin/env python3

"""migrate-v2-to-v3.py — one-shot converter from themeSwitcher v2 layout
to v3.

Reads the old monolithic manifest.toml plus the surrounding directories
(backgrounds/, ghostty_themes/) and produces a v3-shaped tree under
$XDG_DATA_HOME/themeSwitcher/themes/, plus a user config file at
$XDG_CONFIG_HOME/themeSwitcher/config.toml carrying over the old [apps]
and [themes] opt-out tables.

Run once after upgrading. Idempotent — running it twice is harmless.
Existing v3 theme directories are not touched; only missing ones are
created.

Usage:
    python3 migrate-v2-to-v3.py [--data-dir PATH] [--dry-run]

Defaults to $XDG_DATA_HOME/themeSwitcher (or ~/.local/share/themeSwitcher).
"""

from __future__ import annotations

import argparse
import os
import shutil
import sys
import tomllib
from pathlib import Path

# Themes whose Neovim integration uses the "luafile" strategy in v3
# (because their colorscheme plugins need require(...).setup() to run
# from colorschemes.lua, not just :colorscheme name).
LUAFILE_THEMES: frozenset[str] = frozenset({
    "hackerman", "ethereal", "vantablack", "white",
    "retro-82", "matte-black", "lumon", "miasma", "osaka-jade",
})

NON_THEME_KEYS: frozenset[str] = frozenset({"apps", "themes"})


def write_theme_toml(theme_id: str, cfg: dict, out_dir: Path) -> None:
    """Write themes/<theme_id>/theme.toml in v3 format.

    The v3 theme.toml has these top-level sections:
      display_name (scalar)
      [gnome]   — unchanged from v2
      [palette] — unchanged from v2
      [colors]  — unchanged from v2
      [nvim]    — new in v3; carries strategy + colorscheme
      [vars]    — new in v3; free-form template variables
                  (currently just ghostty's theme name reference)
      omit      — list of app IDs to skip even if templates exist
    """
    lines: list[str] = []
    lines.append(f'display_name = "{cfg["display_name"]}"')
    lines.append("")

    # [vars] — anything that was a per-theme scalar in v2 other than
    # display_name and nvim_theme. Currently that's just `ghostty`.
    if "ghostty" in cfg:
        lines.append("[vars]")
        lines.append(f'ghostty = "{cfg["ghostty"]}"')
        lines.append("")

    # [nvim]
    nvim_lines: list[str] = []
    if theme_id in LUAFILE_THEMES:
        nvim_lines.append('strategy = "luafile"')
    elif "nvim_theme" in cfg:
        nvim_lines.append(f'colorscheme = "{cfg["nvim_theme"]}"')
    if nvim_lines:
        lines.append("[nvim]")
        lines.extend(nvim_lines)
        lines.append("")

    # [gnome] — copy verbatim, with a default color_scheme = "prefer-dark"
    # if v2 didn't have one (v2 didn't enforce it; v3 --check does).
    if "gnome" in cfg:
        lines.append("[gnome]")
        gnome_block = dict(cfg["gnome"])
        gnome_block.setdefault("color_scheme", "prefer-dark")
        for k, v in gnome_block.items():
            lines.append(f'{k} = "{v}"')
        lines.append("")

    # [palette] — copy verbatim
    if "palette" in cfg:
        lines.append("[palette]")
        for k, v in cfg["palette"].items():
            lines.append(f'{k:<8} = "{v}"')
        lines.append("")

    # [colors] — copy verbatim
    if "colors" in cfg:
        lines.append("[colors]")
        for k, v in cfg["colors"].items():
            lines.append(f'{k:<15} = "{v}"')
        lines.append("")

    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "theme.toml").write_text("\n".join(lines).rstrip() + "\n")


def write_user_config(manifest: dict, config_path: Path, dry_run: bool) -> None:
    """Write ~/.config/themeSwitcher/config.toml from the old opt-out
    tables.

    If neither [apps] nor [themes] was present in the v2 manifest, no
    file is created — the user had no opt-outs.
    """
    apps_cfg = manifest.get("apps", {})
    themes_cfg = manifest.get("themes", {})

    # Only carry over entries that were explicitly set to false; an
    # explicit `true` is the default in v3 and adds noise.
    apps_off = {k: v for k, v in apps_cfg.items() if v is False}
    themes_off = {k: v for k, v in themes_cfg.items() if v is False}

    if not apps_off and not themes_off:
        return

    lines: list[str] = [
        "# themeSwitcher user opt-outs. Anything not listed here is",
        "# enabled by default. Migrated from v2 manifest.toml.",
        "",
    ]
    if apps_off:
        lines.append("[apps]")
        for k in sorted(apps_off):
            lines.append(f"{k} = false")
        lines.append("")
    if themes_off:
        lines.append("[themes]")
        for k in sorted(themes_off):
            lines.append(f"{k} = false")
        lines.append("")

    if dry_run:
        print(f"  would write: {config_path}")
        return
    config_path.parent.mkdir(parents=True, exist_ok=True)
    config_path.write_text("\n".join(lines).rstrip() + "\n")
    print(f"  wrote: {config_path}")


def copy_backgrounds(theme_id: str, old_bg_root: Path, new_theme_dir: Path,
                     dry_run: bool) -> int:
    """Copy themes/<old>/backgrounds/<theme_id>/* into
    themes/<theme_id>/backgrounds/. Returns the number of files copied.
    """
    src: Path = old_bg_root / theme_id
    if not src.is_dir():
        return 0
    dst: Path = new_theme_dir / "backgrounds"
    if dry_run:
        return len(list(src.iterdir()))
    dst.mkdir(parents=True, exist_ok=True)
    count: int = 0
    for f in src.iterdir():
        target = dst / f.name
        if target.exists():
            continue
        shutil.copy2(f, target)
        count += 1
    return count


def copy_ghostty_palette(theme_id: str, ghostty_name: str | None,
                         old_ghostty_root: Path, new_theme_dir: Path,
                         dry_run: bool) -> bool:
    """If a custom ghostty palette file exists in v2's ghostty_themes/,
    install it as the theme's own ghostty.theme override.

    In v2, themes referenced custom Ghostty palettes by name
    ("Lumon", "Hackerman", …) and the palette files lived in a
    separate ghostty_themes/ directory that Ghostty itself never read.
    The result was that `theme = Lumon` in Ghostty's config didn't
    resolve unless the user had also manually installed those palette
    files into ~/.config/ghostty/themes/.

    In v3, the per-theme ghostty.theme template *is* the rendered
    Ghostty config. By writing the palette file's contents to
    themes/<id>/ghostty.theme, the theme becomes self-contained — the
    palette is inlined on apply and Ghostty just reads the result. No
    separate install step.

    Themes without a custom palette fall through to _default/ghostty.theme
    which writes `theme = {{ghostty}}` — fine for built-in Ghostty names
    like "Catppuccin Macchiato", "Dracula", "Nord".
    """
    if not ghostty_name:
        return False
    src: Path = old_ghostty_root / ghostty_name
    if not src.is_file():
        return False
    if dry_run:
        return True
    # Write to ghostty.theme — the per-theme template override path.
    # Contents are the palette directly; no placeholders to substitute.
    dst: Path = new_theme_dir / "ghostty.theme"
    shutil.copy2(src, dst)
    return True


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Migrate themeSwitcher v2 layout to v3."
    )
    parser.add_argument(
        "--data-dir", type=Path,
        default=Path(os.environ.get(
            "XDG_DATA_HOME", Path.home() / ".local/share"
        )) / "themeSwitcher",
        help="themeSwitcher data dir (default: $XDG_DATA_HOME/themeSwitcher).",
    )
    parser.add_argument(
        "--config-dir", type=Path,
        default=Path(os.environ.get(
            "XDG_CONFIG_HOME", Path.home() / ".config"
        )) / "themeSwitcher",
        help="themeSwitcher user config dir.",
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Print what would happen without writing anything.",
    )
    args = parser.parse_args()

    data_dir: Path = args.data_dir
    manifest_path: Path = data_dir / "manifest.toml"
    if not manifest_path.is_file():
        sys.exit(f"No v2 manifest found at {manifest_path}. Nothing to migrate.")

    with open(manifest_path, "rb") as f:
        manifest = tomllib.load(f)

    new_themes_root: Path = data_dir / "themes"
    old_bg_root:      Path = data_dir / "backgrounds"
    old_ghostty_root: Path = data_dir / "ghostty_themes"

    theme_ids: list[str] = [k for k in manifest if k not in NON_THEME_KEYS]
    print(f"Found {len(theme_ids)} themes in v2 manifest.")
    print(f"Migrating to: {new_themes_root}/")
    if args.dry_run:
        print("(dry run — no files will be written)")
    print()

    for theme_id in theme_ids:
        theme_dir: Path = new_themes_root / theme_id
        if (theme_dir / "theme.toml").exists():
            print(f"  - {theme_id}: already migrated, skipping")
            continue

        cfg: dict = manifest[theme_id]
        if not args.dry_run:
            write_theme_toml(theme_id, cfg, theme_dir)

        bg_count: int = copy_backgrounds(theme_id, old_bg_root, theme_dir, args.dry_run)
        ghostty_copied: bool = copy_ghostty_palette(
            theme_id, cfg.get("ghostty"),
            old_ghostty_root, theme_dir, args.dry_run,
        )

        tag_bg: str = f" +{bg_count} bg" if bg_count else ""
        tag_g:  str = " +ghostty-palette" if ghostty_copied else ""
        print(f"  + {theme_id}{tag_bg}{tag_g}")

    print()
    write_user_config(manifest, args.config_dir / "config.toml", args.dry_run)

    print()
    if args.dry_run:
        print("Dry run complete. Re-run without --dry-run to migrate.")
    else:
        print("Migration complete.")
        print()
        print("Recommended next steps:")
        print(f"  1. Verify: themeSwitcher --check")
        print(f"  2. Test:   themeSwitcher --list")
        print(f"  3. Once happy, remove:")
        print(f"       {manifest_path}")
        print(f"       {old_bg_root}/")
        print(f"       {old_ghostty_root}/")
        print(f"       {data_dir}/templates/")


if __name__ == "__main__":
    main()
