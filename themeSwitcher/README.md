# themeSwitcher

Coherent theming for GNOME and the terminal stack. One command swaps GTK,
GNOME Shell, accent colour, wallpaper, terminal colours, prompt, system
monitor, multiplexer, and editor at once.

```
$ themeSwitcher catppuccin-macchiato
  Catppuccin Macchiato
$ themeSwitcher --list
  Catppuccin Macchiato     (catppuccin-macchiato) <
  Dracula                  (dracula)
  Nord                     (nord)
  ...
$ themeSwitcher           # opens an fzf picker
```

## How it works

Themes live in `$XDG_DATA_HOME/themeSwitcher/themes/`, one directory per
theme. Each contains a `theme.toml` (palette + metadata) and any per-app
template files. An app gets themed if a template exists for it — either
in the theme's own directory or in the shared `_default/` directory.

```
themes/
├── _default/                ← shared templates used by every theme
│   ├── btop.theme
│   ├── ghostty.theme
│   ├── starship.toml
│   └── ...
├── catppuccin-macchiato/
│   ├── theme.toml           ← palette + display name + gnome config
│   └── backgrounds/         ← optional wallpapers for this theme
│       └── 1-totoro.png
├── dracula/
│   └── theme.toml
└── ...
```

Apps themselves are declared in `apps.toml`. Adding a new terminal or
tool is a single config edit — no Python required. See
[CONTRIBUTING.md](CONTRIBUTING.md) for the recipe.

### Themes vs themes-extras

The shipped repo splits themes into two folders:

- `.local/share/themeSwitcher/themes/` — the curated set, visible in
  the picker and on `--list`. Currently 23 themes: well-known palettes
  (Catppuccin variants, Dracula, Gruvbox, Nord, Tokyo Night, Rose Pine,
  Everforest, Solarized Dark, Kanagawa, One Dark, Nightfox, Monokai
  Pro) plus character themes only this project ships (Lumon, Hackerman,
  Vantablack, Retro 82, Matte Black, Miasma, Osaka Jade, Ethereal).
- `.local/share/themeSwitcher/themes-extras/` — additional themes that
  didn't make the curated cut (mostly Tokyo Night-adjacent or duplicates
  of existing palettes). Drop any directory from here into `themes/`
  to enable it. themeSwitcher only reads `themes/`.

## Supported apps

Out of the box, themeSwitcher knows how to theme:

- **Terminals**: Ghostty, Alacritty, Kitty, WezTerm, foot
- **Shell**: Starship
- **System monitor**: btop
- **Multiplexer**: tmux
- **Editor**: Neovim
- **Desktop (GNOME)**: GTK theme, shell theme, icon theme, cursor,
  accent colour, wallpaper
- **Desktop (Niri)**: focus ring, border, shadow, tab indicator
- **Bar / notifications / launchers**: Waybar, Mako, Wofi, SwayOSD
- **Browser**: Chromium

You don't need to install all of these. **themeSwitcher checks each
app's binary on `$PATH` before applying** and silently skips any that
aren't installed — running it on a GNOME-only box won't pollute
`~/.config/waybar/` with files for apps you don't have. You can also
explicitly opt out of any app per-user in
`~/.config/themeSwitcher/config.toml`.

`themeSwitcher --apps` shows the status of each app: `[on]` for
detected and enabled, `[skip]` for enabled but binary not found,
`[off]` for explicitly disabled in config.

DankMaterialShell is deliberately not in this list. DMS ships its own
theme switcher; running both against `~/.config/DankMaterialShell/`
would race. Manage DMS theming via its native tool.

## Install

This is currently distributed as a [GNU Stow](https://www.gnu.org/software/stow/)
package:

```bash
git clone https://github.com/<you>/themeSwitcher.git ~/.dotfiles/themeSwitcher
cd ~/.dotfiles
stow themeSwitcher
```

That symlinks the script into `~/.local/bin/themeSwitcher` and the
data into `~/.local/share/themeSwitcher/`.

A non-Stow install is on the roadmap.

### Requirements

- Python 3.11+ (for `tomllib`)
- `fzf` for the interactive picker (optional — `themeSwitcher <name>`
  works without it)
- `gsettings` for GNOME integration

## Usage

```
themeSwitcher [theme-id]    Apply a theme (or open fzf picker if no ID)
themeSwitcher [theme-id]    Apply a theme (or open the picker if no ID)
themeSwitcher --list        List all enabled themes
themeSwitcher --current     Print the currently active theme ID (scripting)
themeSwitcher --themes      Show which themes are enabled / disabled
themeSwitcher --apps        Show which apps are enabled / disabled
themeSwitcher --bg          Open a picker to choose a wallpaper
themeSwitcher --bg-next     Cycle to the next wallpaper (good for keybinds)
themeSwitcher --check       Validate every theme without applying
themeSwitcher --version
```

### The picker

When you run `themeSwitcher` with no arguments (or `--bg` for wallpapers),
it opens an interactive picker with thumbnail previews.

- **In a terminal**: `fzf` with image previews rendered by `chafa` in
  a side pane. Image format auto-detects from `$TERM` / `$TERM_PROGRAM`:
  Kitty and Ghostty use the Kitty graphics protocol (sharpest), WezTerm
  and foot use Sixel, everything else falls back to truecolor unicode
  block art. If `chafa` isn't installed you get plain `fzf` without
  previews.
- **From a keybind / app launcher** (not a TTY): a GUI launcher chosen
  by compositor:
  - niri → `fuzzel` (with `rofi` fallback)
  - GNOME, KDE, sway, anything else → `rofi`

  Both speak the dmenu-with-icons protocol, so themes and wallpapers
  appear as rows with thumbnails. If neither launcher is installed,
  falls back to fzf.

#### Optional: grid layout for rofi

themeSwitcher ships a custom rofi theme that lays the picker out as a
4-column grid of thumbnails (similar to Omarchy's theme menu) instead
of a vertical list. It works automatically — themeSwitcher passes
`-theme` pointing at the bundled `themeSwitcher.rasi` whenever it
invokes rofi. No setup needed.

For **fuzzel** there's no grid option — fuzzel only supports vertical
lists. Styling comes from your `~/.config/fuzzel/fuzzel.ini`.

Install whichever combination matches your setup:

```bash
# Minimum (terminal picker only): fzf
# Recommended (terminal picker with previews): fzf + chafa
# GUI on GNOME: + rofi
# GUI on niri: + fuzzel
```

### User config

Opt-outs live at `~/.config/themeSwitcher/config.toml`. The file is
entirely optional. Anything not listed is enabled by default.

```toml
[apps]
# Don't touch alacritty's config even if a template exists
alacritty = false

[themes]
# Hide these from the picker
white = false
vantablack = false
```

## Migrating from v2

If you're coming from the single-`manifest.toml` v2 layout, run the
included migration script once:

```bash
python3 migrate-v2-to-v3.py
```

It produces a v3-shaped tree under `themes/`, carries over your
opt-outs into the new user config, and tells you which old files
to remove once you've verified everything works.

## Authoring a theme

Create a directory under `themes/` with a `theme.toml`. The minimum:

```toml
display_name = "My Theme"

[gnome]
gtk_theme    = "Adwaita-dark"
shell_theme  = "Adwaita-dark"
icon_theme   = "Papirus-Dark"
accent_color = "purple"
color_scheme = "prefer-dark"   # or "prefer-light"

[palette]
base     = "#1e1e2e"
mantle   = "#181825"
surface  = "#313244"
overlay  = "#6c7086"
muted    = "#7f849c"
text     = "#cdd6f4"
subtext  = "#bac2de"
red      = "#f38ba8"
orange   = "#fab387"
yellow   = "#f9e2af"
green    = "#a6e3a1"
teal     = "#94e2d5"
sky      = "#89dceb"
sapphire = "#74c7ec"
blue     = "#89b4fa"
mauve    = "#cba6f7"

[colors]
# Map semantic names used in templates to palette keys
background  = "base"
foreground  = "text"
hi_fg       = "blue"
# ... (see any existing theme for the full list)
```

The 16 `[palette]` keys are required. The `[colors]` keys are whatever
your templates reference — `themeSwitcher --check` will tell you what's
missing.

For optional sections (`[nvim]`, `[vars]`) and how to handle plugin
colorschemes that need `require(...).setup()`, see CONTRIBUTING.md.

## Authoring an app

Add an entry to `apps.toml` and drop a default template in
`themes/_default/`. That's it. See CONTRIBUTING.md for the full recipe
including the available reload mechanisms and template variables.

## License

MIT.
