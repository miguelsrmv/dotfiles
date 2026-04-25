# Contributing

Thanks for your interest. Contributions are welcome and actively wanted — the more the merrier. In particular:

- **New themes** — from the Omarchy ecosystem, popular community themes, or anything you use daily
- **New terminal support** — Kitty, Alacritty, WezTerm, Foot, and others
- **New app support** — app launchers (Rofi, Walker, Fuzzel), notification daemons (Dunst, Mako), bars (Waybar, Polybar), and anything else that takes colour config
- **New desktop environments** — Hyprland, Niri, KDE, XFCE, Sway
- **Bug fixes and improvements** — to existing themes, colour mappings, or the switcher itself

This document explains how to contribute each type.

---

## Repository layout

This repo is a [GNU Stow](https://www.gnu.org/software/stow/) package. The `themeSwitcher/` subdirectory is the Stow package, and its contents mirror `$HOME`. Running `stow themeSwitcher` from your dotfiles root creates two symlinks:

- `~/.local/bin/themeSwitcher` → the executable
- `~/.local/share/themeSwitcher/` → the data directory

The Ghostty theme files in `ghostty_themes/` are managed by a separate `ghostty` Stow package via symlinks into `~/.config/ghostty/themes/`.

Keep this in mind when adding files:
- The executable belongs under `themeSwitcher/.local/bin/`
- Data files (manifest, templates, themes, backgrounds) belong under `themeSwitcher/.local/share/themeSwitcher/`
- Ghostty palette source files belong under `themeSwitcher/.local/share/themeSwitcher/ghostty_themes/`
- Docs (`README.md`, `CONTRIBUTING.md`) and repo config (`.gitignore`) sit at the repo root, outside the Stow package

---

## Wanted contributions

### Themes

The following themes are good candidates for adding — they have established palettes, nvim plugins, and would complement the existing collection well. PRs for any of these are welcome:

**From the Omarchy ecosystem** ([github.com/topics/omarchy-theme](https://github.com/topics/omarchy-theme)) — Omarchy has a rich community of themes, each with coordinated terminal palettes, nvim plugins, and wallpapers. Any Omarchy theme is a welcome addition here. The `bjarneo/*` themes in particular have first-class nvim support via `aether.nvim`. The ones not yet in this repo:

| Theme | Nvim plugin | Notes |
|---|---|---|
| Ash | `bjarneo/ash.nvim` | Dark minimal, grey-blue tones |
| Aura | `bjarneo/aura.nvim` | Purple-accented dark |
| Futurism | `bjarneo/futurism.nvim` | High contrast neon |
| Pixel | `bjarneo/pixel.nvim` | Terminal-palette only |

**Community themes with good nvim support:**

| Theme | Nvim plugin | Notes |
|---|---|---|
| Catppuccin Moon (Rosé Pine variant) | `rose-pine/neovim` | `colorscheme rose-pine-moon` |
| Rosé Pine Dawn | `rose-pine/neovim` | Light variant, `colorscheme rose-pine-dawn` |
| Gruvbox Material | `sainnhe/gruvbox-material` | Softer gruvbox |
| Nightfly | `bluz71/vim-nightfly-colors` | Dark blue, more saturated than Nightfox |
| Mellow | `kvrohit/mellow.nvim` | Low contrast, warm earthy |
| Decay | `decaycs/decay.nvim` | Dark green, popular in ricing community |
| Cyberdream | `scottmckendry/cyberdream.nvim` | High contrast neon cyberpunk |

**If you add a theme**, follow the steps in [Adding a new theme](#adding-a-new-theme) below.

---

### Terminals

Currently only **Ghostty** is supported. The following terminals are widely used and a PR adding support for any of them would be very welcome:

**Alacritty** — writes a TOML colour config at `~/.config/alacritty/colors.toml`. Template-based, straightforward. The theme file format uses `[colors.primary]`, `[colors.normal]`, and `[colors.bright]` sections.

**Kitty** — writes a colour theme file at `~/.config/kitty/current-theme.conf` and sends `kitty @ set-colors` for live reload. Kitty's remote control requires `allow_remote_control yes` in the kitty config.

**WezTerm** — writes a Lua colour override file. Live reload via `wezterm cli activate-pane` or a signal.

**Foot** — writes an INI-format colour file, supports live reload via SIGHUP.

To add a terminal:

1. Add an `apply_<terminal>` function following the pattern in [Adding support for a new app](#adding-support-for-a-new-app)
2. Add a `<terminal>.theme` template to `templates/` using `{color_key}` substitution
3. Add the terminal's built-in theme name (if applicable) as a per-theme key in `manifest.toml` alongside `ghostty`
4. Register it in `ALL_APPS` and `APP_REGISTRY`
5. Add it to the `[apps]` section in `manifest.toml`

---

### Multiplexers

Currently only **tmux** is supported. The following are good candidates:

**Zellij** — KDL-format theme files at `~/.config/zellij/themes/`. Template-based, very similar to tmux.

**GNU Screen** — `.screenrc` colour overrides. Niche but still used.

To add a multiplexer, follow the same four-step pattern as any other app.

---

### App launchers and UI components

Currently no app launchers, notification daemons, or status bars are supported. These are natural extensions and PRs are very welcome:

**Rofi** — writes a colour theme to `~/.config/rofi/colors.rasi` and imports it from the main config. Template-based.

**Walker** — writes a CSS colour override to `~/.config/walker/style.css` or equivalent. Template-based.

**Fuzzel** — writes an INI colour config at `~/.config/fuzzel/fuzzel.ini`. Template-based.

**Wofi** — writes a CSS file. Template-based.

**Dunst** — writes colour overrides to `~/.config/dunst/dunstrc`. Supports live reload via `dunstctl reload`. Template-based.

**Mako** — writes a colour config to `~/.config/mako/config`. Supports live reload via `makoctl reload`. Template-based.

**Waybar** — writes a CSS colour override file. More structural than pure colour — a per-theme file approach may work better than a template.

**Polybar** — writes colour variables to an include file. Template-based.

To add any of these, follow the same four-step pattern in [Adding support for a new app](#adding-support-for-a-new-app).

---

### Desktop environments

Currently only **GNOME** is supported. The following DEs are well-suited for integration:

**Hyprland** — sets colours via `hyprctl setprop` or by writing `~/.config/hypr/colors.conf` and sourcing it. Waybar, Mako, and Walker also need per-theme config files. A Hyprland PR should include `apply_hyprland`, `apply_waybar`, `apply_mako`, and `apply_walker` at minimum.

**Niri** — similar to Hyprland. Writes to `~/.config/niri/colors.kdl` or equivalent.

**KDE Plasma** — uses `plasma-apply-colorscheme` and `plasma-apply-wallpaperimage`. KDE colour schemes are `.colors` files under `~/.local/share/color-schemes/`. More complex than GNOME but well-documented.

**XFCE** — `xfconf-query` for colour settings, similar in spirit to `gsettings`.

DE integrations are more complex than app integrations — they typically involve multiple components (panel, notifications, app launcher, lock screen) that each need their own apply function or template. A good PR for a new DE includes at minimum the wallpaper and accent colour, with component configs as optional extras.

---

## Adding a new theme

### 1. Add a block to `manifest.toml`

Follow the existing pattern:

```toml
[mytheme]
display_name = "My Theme"
ghostty      = "My Theme"    # theme name exactly as Ghostty knows it

[mytheme.gnome]
gtk_theme    = "MyTheme-Dark"
shell_theme  = "MyTheme-Dark"
icon_theme   = "Papirus-Dark"
accent_color = "blue"        # named GNOME accent colour (see valid values below)
color_scheme = "prefer-dark" # or "prefer-light" for light themes

[mytheme.palette]
base     = "#1a1b26"
mantle   = "#16161e"
# … all 16 keys required (see README for full list)

[mytheme.colors]
background = "base"
foreground = "text"
# … all color keys, referencing palette names or raw hex values
```

Valid GNOME accent colours: `blue`, `teal`, `green`, `yellow`, `orange`, `red`, `pink`, `purple`, `slate`, `bark`, `sage`, `olive`, `viridian`. Note that `bark`, `sage`, `olive`, and `viridian` require GNOME 47+.

Also add the theme to the `[themes]` section:

```toml
[themes]
# … existing themes …
mytheme = true
```

### 2. Add a Ghostty theme file

If the theme isn't built into Ghostty, create `themeSwitcher/.local/share/themeSwitcher/ghostty_themes/My Theme`:

```
background           = #1a1b26
foreground           = #c0caf5
cursor-color         = #c0caf5
cursor-text          = #1a1b26
selection-background = #28344a
selection-foreground = #c0caf5

palette = 0=#15161e
palette = 1=#f7768e
palette = 2=#9ece6a
palette = 3=#e0af68
palette = 4=#7aa2f7
palette = 5=#bb9af7
palette = 6=#7dcfff
palette = 7=#a9b1d6
palette = 8=#414868
palette = 9=#f7768e
palette = 10=#9ece6a
palette = 11=#e0af68
palette = 12=#7aa2f7
palette = 13=#bb9af7
palette = 14=#7dcfff
palette = 15=#c0caf5
```

The file needs to be symlinked into `~/.config/ghostty/themes/` via the `ghostty` Stow package.

### 3. Configure Neovim

Choose the appropriate strategy based on whether a matching Neovim plugin exists:

**Dedicated plugin** (theme ID matches nvim colorscheme name) — add the plugin to `vim.pack.add` in `colorschemes.lua`. Nothing else needed.

**Name mismatch** (theme ID differs from the plugin's colorscheme name) — add the plugin to `vim.pack.add` and add an entry to `nvim_overrides`:
```lua
["mytheme"] = "actual-colorscheme-name",
```

**Terminal-palette theme** (no matching plugin — nvim should inherit the terminal's colours) — add to `pixel_themes` in `colorschemes.lua`:
```lua
["mytheme"] = true,
```
`pixel.nvim` disables `termguicolors` and reads directly from the terminal's ANSI palette, so nvim matches the terminal automatically.

**Aether-based theme** (no matching plugin but you want proper syntax highlighting with the theme's exact colours) — add a palette entry to `aether_palettes` in `colorschemes.lua`:
```lua
["mytheme"] = {
    bg = "#...",  bg_dark = "#...",  bg_highlight = "#...",
    fg = "#...",  fg_dark = "#...",  comment = "#...",
    red = "#...", orange = "#...",   yellow = "#...",
    green = "#...", cyan = "#...",   blue = "#...",
    purple = "#...", magenta = "#...",
},
```

### 4. Add wallpapers

```
themeSwitcher/.local/share/themeSwitcher/backgrounds/mytheme/1-mytheme.png
```

### 5. Validate

```bash
themeSwitcher --check
```

### Palette guidelines

- Map palette key names to their closest **semantic** colour in the theme. `red` should be the theme's error/danger colour, `green` its success colour, `blue` its primary accent, and so on.
- If a theme has no distinct `subtext`, set it equal to `text`.
- Two palette keys mapping to the same hex value is fine — semantic clarity in `[colors]` is the goal.
- For monochromatic themes (vantablack, white, lumon) map the palette keys to shades of the dominant colour family and accept that gradients will be subtle.

---

## Adding support for a new app

All app integrations follow the same four-step pattern.

### 1. Write an apply function

In `themeSwitcher`, add a function with this exact signature:

```python
def apply_myapp(theme_id: str, cfg: ThemeConfig, resolved: ColorMap) -> None:
    ...
```

- `theme_id` — the current theme ID string (e.g. `"catppuccin-macchiato"`)
- `cfg` — the full theme config dict from the manifest (use for non-colour metadata like `ghostty`)
- `resolved` — the fully resolved `{color_key: hex_value}` dict (use for colour substitution into templates)

**Template-based** (pure colour config — most common):

```python
def apply_myapp(theme_id: str, cfg: ThemeConfig, resolved: ColorMap) -> None:
    """Apply theme to myapp."""
    content: str = render_template("myapp.theme", resolved)
    write_config(content, CONFIG_HOME / "myapp/colors.conf")
    signal_process("myapp")   # if the app supports live reload via signal
```

**Per-theme file** (structural config that varies per theme):

```python
def apply_myapp(theme_id: str, cfg: ThemeConfig, resolved: ColorMap) -> None:
    """Apply theme to myapp via per-theme config file."""
    src: Path = THEME_DIR / theme_id / "myapp.conf"
    if src.exists():
        symlink(src, CONFIG_HOME / "myapp/myapp.conf")
```

### 2. Register it

Add to `ALL_APPS` (controls application order) and `APP_REGISTRY` in `themeSwitcher`:

```python
ALL_APPS: tuple[str, ...] = (
    "ghostty",
    "tmux",
    # ...
    "myapp",
)

APP_REGISTRY: dict[str, object] = {
    "ghostty":  apply_ghostty,
    "tmux":     apply_tmux,
    # ...
    "myapp":    apply_myapp,
}
```

### 3. Add it to the manifest

```toml
[apps]
ghostty  = true
tmux     = true
# ...
myapp    = true
```

If your app needs per-theme metadata (like `ghostty`), add a top-level key to each `[theme]` block in the manifest.

If your app uses a template, create `themeSwitcher/.local/share/themeSwitcher/templates/myapp.theme` using `{color_key}` substitution. All keys in `[mytheme.colors]` are available — see any existing template for reference.

### 4. Update the README

Add your app to the "What it changes" table and the per-component dependencies list.

---

## General guidelines

- Type-annotate all functions. The existing code uses `str`, `Path`, `ColorMap`, `ThemeConfig`, and `Manifest` — follow the same pattern.
- Add docstrings to new functions following the existing style.
- Run `themeSwitcher --check` before submitting — it validates all palettes and colour references.
- If you change `PALETTE_KEYS` (add or rename a key), update all theme palettes in `manifest.toml` accordingly.
- `current_theme` and `current_bg` are runtime state — do not remove them from `.gitignore`.
- The state file (`current_theme`) is written **before** the apply loop so that Neovim's `colorschemes.lua` re-source reads the correct theme ID.
