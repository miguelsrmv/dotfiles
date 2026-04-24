# Contributing

Thanks for your interest. Contributions are welcome — new themes, new app integrations, and bug fixes are all fair game.

---

## Repository layout

This repo is a [GNU Stow](https://www.gnu.org/software/stow/) package. The `themeSwitcher/` subdirectory is the Stow package, and its contents mirror `$HOME`. Running `stow themeSwitcher` from your dotfiles root creates three symlinks:

- `~/.local/bin/themeSwitcher` → the executable
- `~/.local/share/themeSwitcher/` → the data directory
- `~/.config/ghostty/themes/` → the bundled Ghostty palette source files

Keep this in mind when adding files:
- The executable belongs under `themeSwitcher/.local/bin/`
- Data files (manifest, templates, themes, backgrounds) belong under `themeSwitcher/.local/share/themeSwitcher/`
- Ghostty palette source files belong under `themeSwitcher/.config/ghostty/themes/`
- Docs (`README.md`, `CONTRIBUTING.md`) and repo config (`.gitignore`) sit at the repo root, outside the Stow package

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

### 2. Add a Ghostty theme file

If the theme isn't built into Ghostty, create `themeSwitcher/.config/ghostty/themes/mytheme.theme`:

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

### 3. Configure Neovim

Choose the appropriate strategy based on whether a matching Neovim plugin exists:

**Dedicated plugin** (theme ID matches nvim colorscheme name) — add the plugin to `vim.pack.add` in `colorschemes.lua`. Nothing else needed.

**Name mismatch** (theme ID differs from the plugin's colorscheme name) — add the plugin to `vim.pack.add` and add an entry to `nvim_overrides`:
```lua
["mytheme"] = "actual-colorscheme-name",
```

**Terminal-palette theme** (no matching plugin — nvim should inherit Ghostty's colours) — add to `pixel_themes` in `colorschemes.lua`:
```lua
["mytheme"] = true,
```
`pixel.nvim` disables `termguicolors` and reads directly from the terminal's ANSI palette, so nvim matches Ghostty automatically.

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
Map the 14 aether colour slots to the theme's palette values. `aether.nvim` then generates full syntax highlighting from these colours.

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
    content: str = render_template("myapp.theme", resolved)
    write_config(content, CONFIG_HOME / "myapp/colors.conf")
    signal_process("myapp")   # if the app supports live reload via signal
```

**Per-theme file** (structural config that varies per theme):

```python
def apply_myapp(theme_id: str, cfg: ThemeConfig, resolved: ColorMap) -> None:
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

---

## What is not in scope

- **Wayland compositors** (Hyprland, Sway, etc.) — out of scope for now, but a well-structured PR with a clear `apply_hyprland` implementation would be considered.
- **Vim (not Neovim)** — the socket-based live reload relies on Neovim's `--server` flag. Classic Vim has no equivalent.
- **GUI theme pickers** — this is a CLI tool and will stay one.
