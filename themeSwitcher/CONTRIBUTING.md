# Contributing to themeSwitcher

themeSwitcher's architecture is designed so that the two most common
contributions — adding a theme and adding an app — don't require
touching Python. This document explains how.

## Adding a theme

1. Create a directory: `themes/<your-theme-id>/`. The ID is lowercase
   with dashes (`tokyo-night`, `catppuccin-mocha`, not `Tokyo Night`).
2. Add `theme.toml` with palette and metadata (see the section below).
3. Optionally add per-app templates if your theme needs to override
   the shared `_default/` ones (rare; see "Per-theme template overrides"
   below).
4. Optionally add a `backgrounds/` subdirectory with wallpaper images.
5. Run `themeSwitcher --check`. Fix anything it complains about.
6. Apply it (`themeSwitcher <your-theme-id>`) and eyeball the result.
7. Open a PR with just the new directory. Reviewers can scan one folder
   instead of grepping a monolithic file.

### theme.toml structure

The required parts are `display_name`, `[palette]`, and `[colors]`.

```toml
display_name = "My Theme"

# Optional: free-form values templates can reference via {name}.
# Currently the only convention is `ghostty`, which is the Ghostty
# theme name the ghostty.theme template references.
[vars]
ghostty = "Some Ghostty Theme Name"

# Optional: how Neovim should switch to this theme.
[nvim]
strategy    = "direct"     # default. Runs :colorscheme <name>
colorscheme = "tokyonight" # defaults to the theme ID if omitted

# Optional alternative: re-source colorschemes.lua. Use this for plugins
# whose colorscheme needs require(...).setup() to be called — without
# it a bare :colorscheme <name> fails.
# [nvim]
# strategy = "luafile"
# luafile  = "~/.config/nvim/lua/plugins/colorschemes.lua"   # default

# Required: GNOME desktop settings.
[gnome]
gtk_theme    = "Adwaita-dark"
shell_theme  = "Adwaita-dark"
icon_theme   = "Papirus-Dark"
accent_color = "purple"
color_scheme = "prefer-dark"

# Required: the 16-colour palette. All keys must be present even if you
# don't use all of them — the validator enforces this so the
# [colors] section can rely on every key resolving.
[palette]
base     = "#..."
mantle   = "#..."
surface  = "#..."
overlay  = "#..."
muted    = "#..."
text     = "#..."
subtext  = "#..."
red      = "#..."
orange   = "#..."
yellow   = "#..."
green    = "#..."
teal     = "#..."
sky      = "#..."
sapphire = "#..."
blue     = "#..."
mauve    = "#..."

# Required: semantic names used by templates. Each value is either:
#   - a palette key      "blue"      → resolves to that hex
#   - an empty string    ""          → kept as-is (btop gradient gaps)
#   - a raw hex          "#ff5500"   → used verbatim (escape hatch)
[colors]
background  = "base"
foreground  = "text"
hi_fg       = "blue"
selected_bg = "surface"
# ... see any existing theme for the complete list of keys
# the default templates need. `themeSwitcher --check` enforces
# every key actually referenced by a template is defined.
```

### Per-theme template overrides

If your theme needs a custom Ghostty palette (because no built-in
matches), drop a `ghostty.theme` file inside `themes/<your-theme>/`.
themeSwitcher looks there first, then falls back to `_default/`.

This is the right move when the upstream tool's "named theme" approach
doesn't fit — for example a custom palette you've authored. For 95% of
themes, the `_default/ghostty.theme` template (which just writes a
`theme = {ghostty}` line) is enough.

### Wallpapers

Put images in `themes/<your-theme>/backgrounds/`. Any image format
GNOME understands is fine. Filenames sort alphabetically, and that's
the cycle order of `themeSwitcher --bg`. Prefix with numbers
(`1-name.jpg`, `2-name.jpg`) to control order.

If you ship third-party art, include a `CREDITS.md` in `backgrounds/`
naming the source and license. Don't ship copyrighted material
(production stills from TV shows, brand assets, etc.) — link to the
source instead and let users download their own.

---

## Adding an app

This is the part that's new in v3 and the part Omarchy got right:
**adding an app should be configuration, not code.**

### Recipe

1. Add an entry to `apps.toml`:

   ```toml
   [alacritty]
   template = "alacritty.toml"
   dest     = "~/.config/alacritty/themes/current.toml"
   ensure_include = { file = "~/.config/alacritty/alacritty.toml", line = 'import = ["~/.config/alacritty/themes/current.toml"]' }
   ```

2. Write a default template at `themes/_default/alacritty.toml`. Use
   `{{key}}` (double-brace) placeholders for any template variable.
   Single `{` and `}` are passed through verbatim, which is essential
   for CSS (Waybar, Wofi, SwayOSD) and other brace-using config syntax.

   ```toml
   [colors.primary]
   background = "{{background}}"
   foreground = "{{foreground}}"
   # ...
   ```

3. Run `themeSwitcher --check`. If your template references an unknown
   key it'll fail loudly with the theme and missing variable named.

4. PR. No Python touched.

### apps.toml reference

Each top-level table declares one app. Recognised keys:

| Key              | Type             | Purpose                                                                                                       |
| ---------------- | ---------------- | ------------------------------------------------------------------------------------------------------------- |
| `template`       | string           | Filename to find at `themes/<id>/<template>` or `themes/_default/<template>`. If neither, the app is skipped. |
| `dest`           | string           | Where to write the rendered file. `~` and `$VARS` expand.                                                     |
| `binary`         | string \| list   | Optional. Binary name(s) to look for on `$PATH`. If set and not found, the app is skipped entirely.           |
| `ensure_include` | table            | Add a line to a separate config file once (idempotent).                                                       |
| `reload`         | table            | How to make the running app pick up the new config. See below.                                                |
| `order`          | integer          | Apply order. Lower runs first. Default 500; nvim is 900; gnome is 1000.                                       |

### Reload mechanisms

Three flavours, pick the one your app supports:

```toml
# Signal-based reload (Ghostty, btop, foot, kitty, waybar)
reload = { signal = "SIGUSR2", process = "ghostty" }

# Free-form shell command (mako, sway, etc.)
reload = { command = "makoctl reload" }

# tmux source-file the dest into the running session
reload = { tmux_source = true }
```

If your app live-reloads on file change (Alacritty, WezTerm), omit
`reload` entirely.

### Template variables

Templates receive every variable below. Wrap each in `{{ }}` to
substitute (double-brace; single braces pass through, so CSS blocks
are fine without escaping):

- **Palette colours** — every key from `[palette]` is available as
  `{{base}}`, `{{red}}`, `{{blue}}`, etc. (16 keys per theme.)
- **Semantic colours** — every key from `[colors]`, resolved to a hex.
  These override palette names on collision.
- **`_strip` variants** — every colour value is also exposed without
  its leading `#`. Use `{{accent_strip}}` inside any CSS-in-JSON or
  `rgb(...)` style context where a literal `#` would be invalid.
- **`{{accent}}` / `{{accent_strip}}`** — convenience: pulls from
  `[colors].accent` if defined, else `[colors].hi_fg`.
- **`{{mode}}`** — `"light"` or `"dark"`, derived from the theme's
  `[gnome].color_scheme`. Useful for apps with light/dark variants.
- **`{{theme_id}}`** — the theme directory name. Useful for things
  like Starship's palette name.
- **Theme vars** — everything in the theme's `[vars]` block.
  Currently the only convention is `{{ghostty}}` for the Ghostty
  theme name.

To add a new convention (say, `{{kitty_theme}}` for Kitty's built-in
theme picker), document it here and have themes set it in their
`[vars]` block. Don't hardcode app-specific knowledge into the Python.

### When to skip the declarative path

Two apps in the current registry have `builtin = true`:

- `nvim` — needs to do socket RPC into running Neovim instances
- `gnome` — needs to call gsettings, not write a file

If your app fits the "render file + reload" pattern (which most do),
stay declarative. The built-in path exists for the genuinely
runtime-dynamic cases, not as a general-purpose escape hatch.

---

## Coding style

- Python 3.11+; we use `tomllib` from the stdlib.
- Type hints everywhere. We don't run mypy in CI yet but the types
  are accurate and PRs adding them are welcome.
- No third-party dependencies. `fzf` is shelled out to; everything
  else is stdlib.
- Docstrings on every function. Match the existing style — a one-line
  summary followed by a short paragraph if more context is needed.
- Keep the file readable end-to-end. If the script grows past ~800
  lines, that's the point to split into a package.

## Bug reports

If `themeSwitcher --check` passes but applying a theme breaks something,
that's a real bug. Include:

- The output of `themeSwitcher --version`
- The theme ID that failed
- The terminal/app whose theming is wrong
- Whether `themeSwitcher --check` is clean

If `--check` fails, the error message should tell you exactly which
theme and key are at fault. Fix that first; if the fix isn't obvious,
that's also a bug — open an issue.
