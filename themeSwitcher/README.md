# themeSwitcher

A desktop theme switcher for Linux that applies a colour theme cohesively across your terminal, editor, prompt, system monitor, and desktop environment in one command.

Themes are defined in a single TOML manifest with a 16-colour palette per theme. Components are toggled on or off per-user — no code changes needed to skip apps you don't use.

---

## Themes included

### Dark themes

| ID | Name |
|---|---|
| `ayu-mirage` | Ayu Mirage |
| `catppuccin-frappe` | Catppuccin Frappe |
| `catppuccin-macchiato` | Catppuccin Macchiato |
| `catppuccin-mocha` | Catppuccin Mocha |
| `dracula` | Dracula |
| `ethereal` | Ethereal |
| `everforest` | Everforest |
| `gruvbox` | Gruvbox |
| `hackerman` | Hackerman |
| `kanagawa` | Kanagawa |
| `lumon` | Lumon |
| `matte-black` | Matte Black |
| `miasma` | Miasma |
| `monokai` | Monokai Pro |
| `monokai-pro-ristretto` | Monokai Pro Ristretto |
| `nightfox` | Nightfox |
| `nord` | Nord |
| `onedark` | One Dark Pro |
| `osaka-jade` | Osaka Jade |
| `poimandres` | Poimandres |
| `retro-82` | Retro 82 |
| `rose-pine` | Rosé Pine |
| `solarized-dark` | Solarized Dark |
| `tokyonight-night` | Tokyo Night |
| `vantablack` | Vantablack |
| `vesper` | Vesper |

### Light themes

| ID | Name |
|---|---|
| `catppuccin-latte` | Catppuccin Latte |
| `flexoki-light` | Flexoki Light |
| `white` | White |

---

## What it changes

| Component | How |
|---|---|
| **Ghostty** | Writes `~/.config/ghostty/ghostty.theme`, signals Ghostty to reload |
| **tmux** | Renders and writes `~/.config/tmux/themes/theme.colors`, reloads config |
| **Starship** | Renders and writes `~/.config/starship/starship.toml` |
| **btop** | Renders and writes `~/.config/btop/themes/current.theme`, signals btop to reload |
| **Neovim** | Writes state file, re-sources colorschemes.lua or sends colorscheme command to running instances via socket |
| **GNOME** | Sets GTK theme, shell theme, icon theme, accent colour, colour scheme, and wallpaper via `gsettings` |

Each component can be individually disabled in `manifest.toml`. See [Enabling and disabling apps](#enabling-and-disabling-apps).

---

## Dependencies

### Required
- Python 3.11+
- `fzf` — for the interactive picker (not required when passing a theme name directly)

### Per component
Only install what you use. themeSwitcher skips any component that is disabled.

- **Ghostty** — `ghostty`
- **tmux** — `tmux`
- **Starship** — `starship`
- **btop** — `btop`
- **Neovim** — `nvim`
- **GNOME** — `gsettings` (included with GNOME)

### GNOME themes
The GTK and shell themes referenced in `manifest.toml` must be installed separately. If a theme package is missing, `gsettings` will fail silently on that call and everything else will still apply. The shell theme requires the [User Themes](https://extensions.gnome.org/extension/19/user-themes/) GNOME extension — without it that call is silently skipped.

| Theme | Source |
|---|---|
| Catppuccin GTK | [github.com/catppuccin/gtk](https://github.com/catppuccin/gtk) |
| Dracula GTK | [github.com/dracula/gtk](https://github.com/dracula/gtk) |
| Nordic (Nord / Nightfox) | [github.com/EliverLara/Nordic](https://github.com/EliverLara/Nordic) |
| Gruvbox GTK | [github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme](https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme) |
| Tokyo Night GTK | [github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme](https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme) |

Most other themes fall back to `Adwaita-dark` or `Adwaita` (for light themes), which requires no installation.

---

## Installation

This repo is designed to be managed with [GNU Stow](https://www.gnu.org/software/stow/). The directory tree mirrors `$HOME`, so `stow` symlinks everything into the right place automatically.

### 1. Clone into your dotfiles

```bash
cd ~/dotfiles
git clone https://github.com/yourname/themeSwitcher
```

The repo sits alongside your other Stow packages:

```
~/dotfiles/
├── themeSwitcher/          ← this repo
│   ├── .gitignore
│   ├── README.md
│   ├── CONTRIBUTING.md
│   └── themeSwitcher/      ← Stow package
│       └── .local/
│           ├── bin/themeSwitcher
│           └── share/themeSwitcher/
├── ghostty/                ← your ghostty Stow package
│   └── .config/
│       └── ghostty/
│           ├── config
│           └── themes/     ← symlinks into themeSwitcher/ghostty_themes/
├── nvim/
├── zsh/
└── …
```

### 2. Stow it

```bash
cd ~/dotfiles
stow themeSwitcher
```

This creates two symlinks:
- `~/.local/bin/themeSwitcher` → the executable
- `~/.local/share/themeSwitcher` → the data directory

The Ghostty theme files live in `ghostty_themes/` inside the data directory and are managed by your existing ghostty Stow package — see [Ghostty themes](#ghostty-themes) below.

### 3. Link the Ghostty theme files

In your `ghostty` Stow package, add symlinks from `~/.config/ghostty/themes/` to `ghostty_themes/` in the themeSwitcher data directory:

```bash
mkdir -p ~/dotfiles/ghostty/.config/ghostty/themes
cd ~/dotfiles/ghostty/.config/ghostty/themes
for theme in Dracula Ethereal "Everforest Dark" "Flexoki light" Hackerman Lumon Miasma "Osaka Jade" "Retro 82" Vantablack White; do
    ln -s ~/.local/share/themeSwitcher/ghostty_themes/"$theme" "$theme"
done
```

Then restow your ghostty package:

```bash
cd ~/dotfiles
stow --restow ghostty
```

### 4. Make sure `~/.local/bin` is in your PATH

```bash
# In ~/.zshenv, ~/.bashrc, etc. — if not already present
export PATH="$HOME/.local/bin:$PATH"
```

No environment variables to set — the script locates its data directory via `XDG_DATA_HOME` (defaulting to `~/.local/share`).

### 5. Add your wallpapers

Drop wallpaper images into `backgrounds/<theme_id>/` inside the data directory:

```
~/.local/share/themeSwitcher/backgrounds/catppuccin-macchiato/1-waves.png
~/.local/share/themeSwitcher/backgrounds/catppuccin-macchiato/2-mountain.png
~/.local/share/themeSwitcher/backgrounds/dracula/1-bats.png
```

They cycle in alphabetical order via `--bg`. The first wallpaper in a theme's directory is used automatically when switching to that theme for the first time.

### 6. Configure Neovim

themeSwitcher uses two strategies for Neovim depending on the theme:

- **Dedicated plugin themes** — themes with a matching Neovim colorscheme plugin (catppuccin, dracula, nord, etc.) apply directly via `colorscheme <name>`
- **Terminal-palette themes** — themes without a matching plugin (hackerman, lumon, miasma, osaka-jade, ethereal, retro-82, vantablack, white) use `pixel.nvim` to inherit the terminal's ANSI palette, or `aether.nvim` configured with the theme's exact hex values
- **Name-mismatch themes** — themes where the ID doesn't match the nvim plugin name (matte-black → matteblack, monokai → monokai_pro_classic, solarized-dark → solarized, ayu-mirage → ayu-mirage) are handled via an override table

Add the following to your `colorschemes.lua` (or equivalent):

```lua
-- INFO: Colorschemes
vim.pack.add({
    "https://github.com/EdenEast/nightfox.nvim",
    "https://github.com/folke/tokyonight.nvim",
    "https://github.com/catppuccin/nvim",
    "https://github.com/gbprod/nord.nvim",
    "https://github.com/neanias/everforest-nvim",
    "https://github.com/ellisonleao/gruvbox.nvim",
    "https://github.com/rebelot/kanagawa.nvim",
    "https://github.com/rose-pine/neovim",
    "https://github.com/olimorris/onedarkpro.nvim",
    "https://github.com/mofiqul/dracula.nvim",
    "https://github.com/loctvl842/monokai-pro.nvim",
    "https://github.com/kepano/flexoki-neovim",
    "https://github.com/tahayvr/matteblack.nvim",
    "https://github.com/olivercederborg/poimandres.nvim",
    "https://github.com/Shatur/neovim-ayu",
    "https://github.com/datsfilipe/vesper.nvim",
    "https://github.com/shaunsingh/solarized.nvim",
    "https://github.com/bjarneo/aether.nvim",
    "https://github.com/bjarneo/pixel.nvim",
})

-- Aether palette definitions for themes that use aether.nvim
local aether_palettes = {
    ["lumon"] = {
        bg = "#16242d", bg_dark = "#0f1a21", bg_highlight = "#304860",
        fg = "#d6e2ee", fg_dark = "#b4e4f6", comment = "#304860",
        red = "#4d86b0", orange = "#6fb8e3", yellow = "#6fa4c9",
        green = "#5e95bc", cyan = "#b4e4f6", blue = "#8bc9eb",
        purple = "#73a6cb", magenta = "#d1eef8",
    },
    ["miasma"] = {
        bg = "#222222", bg_dark = "#111111", bg_highlight = "#444444",
        fg = "#c2c2b0", fg_dark = "#d7c483", comment = "#666666",
        red = "#685742", orange = "#bb7744", yellow = "#b36d43",
        green = "#5f875f", cyan = "#c9a554", blue = "#78824b",
        purple = "#d7c483", magenta = "#bb7744",
    },
    ["osaka-jade"] = {
        bg = "#111c18", bg_dark = "#0a1410", bg_highlight = "#23372B",
        fg = "#C1C497", fg_dark = "#F6F5DD", comment = "#53685B",
        red = "#FF5345", orange = "#db9f9c", yellow = "#E5C736",
        green = "#549e6a", cyan = "#2DD5B7", blue = "#509475",
        purple = "#ACD4CF", magenta = "#D2689C",
    },
}

-- Apply current theme
local xdg_data = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
local f = io.open(xdg_data .. "/themeSwitcher/current_theme", "r")
if f then
    local theme_id = f:read("*l"):gsub("%s+", "")
    f:close()

    local light_themes = {
        ["catppuccin-latte"] = true,
        ["flexoki-light"]    = true,
        ["white"]            = true,
    }

    -- Themes that inherit the terminal ANSI palette via pixel.nvim
    local pixel_themes = {
        ["hackerman"]  = true,
        ["ethereal"]   = true,
        ["vantablack"] = true,
        ["white"]      = true,
        ["retro-82"]   = true,
    }

    -- Themes where the nvim colorscheme name differs from the theme ID
    local nvim_overrides = {
        ["monokai-pro-ristretto"] = "monokai-pro",
        ["monokai"]               = "monokai_pro_classic",
        ["onedark"]               = "onedark",
        ["matte-black"]           = "matteblack",
        ["solarized-dark"]        = "solarized",
        ["ayu-mirage"]            = "ayu-mirage",
    }

    vim.o.background = light_themes[theme_id] and "light" or "dark"

    if aether_palettes[theme_id] then
        vim.o.termguicolors = true
        local ok, aether = pcall(require, "aether")
        if ok then
            aether.setup({ transparent = false, colors = aether_palettes[theme_id] })
            vim.cmd("colorscheme aether")
        else
            vim.notify("themeSwitcher: aether.nvim not found", vim.log.levels.WARN)
        end
    elseif pixel_themes[theme_id] then
        vim.o.termguicolors = false
        local ok = pcall(vim.cmd, "colorscheme pixel")
        if not ok then
            vim.notify("themeSwitcher: pixel.nvim not found", vim.log.levels.WARN)
        end
    else
        vim.o.termguicolors = true
        local colorscheme = nvim_overrides[theme_id] or theme_id
        local ok = pcall(vim.cmd, "colorscheme " .. colorscheme)
        if not ok then
            vim.notify("themeSwitcher: colorscheme '" .. colorscheme .. "' not found", vim.log.levels.WARN)
        end
    end
end
```

### 7. Configure btop

In `~/.config/btop/btop.conf`:

```
color_theme = "~/.config/btop/themes/current.theme"
```

---

## Usage

```
themeSwitcher                        # interactive fzf picker
themeSwitcher catppuccin-macchiato   # apply by theme ID
themeSwitcher "Catppuccin Macchiato" # apply by display name
themeSwitcher --list                 # list all themes, marks current with <
themeSwitcher --apps                 # show which apps are enabled
themeSwitcher --themes               # show which themes are enabled
themeSwitcher --bg                   # cycle wallpaper for the current theme
themeSwitcher --check                # validate manifest without applying anything
themeSwitcher --version
themeSwitcher --help
```

---

## Enabling and disabling apps

Edit the `[apps]` section at the top of `manifest.toml`:

```toml
[apps]
ghostty  = true
tmux     = true
starship = true
btop     = false   # skip btop
nvim     = true
gnome    = true
```

Omitting the `[apps]` section entirely enables all apps. Run `themeSwitcher --apps` to see the current state.

---

## Directory structure

```
themeSwitcher/                              ← git repo root
├── .gitignore
├── README.md
├── CONTRIBUTING.md
└── themeSwitcher/                          ← Stow package
    └── .local/
        ├── bin/
        │   └── themeSwitcher               ← executable (→ ~/.local/bin/)
        └── share/
            └── themeSwitcher/              ← data dir (→ ~/.local/share/themeSwitcher/)
                ├── manifest.toml           ← app selector, palettes, theme metadata
                ├── templates/              ← rendered at switch time into ~/.config/
                │   ├── btop.theme
                │   ├── ghostty.theme
                │   ├── starship.toml
                │   └── tmux.theme
                ├── ghostty_themes/         ← custom Ghostty palette source files
                │   ├── Dracula
                │   ├── Ethereal
                │   ├── Everforest Dark
                │   ├── Flexoki light
                │   ├── Hackerman
                │   ├── Lumon
                │   ├── Miasma
                │   ├── Osaka Jade
                │   ├── Retro 82
                │   ├── Vantablack
                │   └── White
                ├── backgrounds/            ← wallpapers, organised by theme ID
                │   ├── ayu-mirage/
                │   ├── catppuccin-frappe/
                │   ├── catppuccin-latte/
                │   ├── catppuccin-macchiato/
                │   ├── catppuccin-mocha/
                │   ├── dracula/
                │   ├── ethereal/
                │   ├── everforest/
                │   ├── flexoki-light/
                │   ├── gruvbox/
                │   ├── hackerman/
                │   ├── kanagawa/
                │   ├── lumon/
                │   ├── matte-black/
                │   ├── miasma/
                │   ├── monokai/
                │   ├── monokai-pro-ristretto/
                │   ├── nightfox/
                │   ├── nord/
                │   ├── onedark/
                │   ├── osaka-jade/
                │   ├── poimandres/
                │   ├── retro-82/
                │   ├── rose-pine/
                │   ├── solarized-dark/
                │   ├── tokyonight-night/
                │   ├── vantablack/
                │   ├── vesper/
                │   └── white/
                ├── current_theme           ← runtime state (gitignored)
                └── current_bg              ← symlink → current wallpaper (gitignored)
```

After `stow themeSwitcher`, Stow creates two symlinks:
- `~/.local/bin/themeSwitcher` → the executable
- `~/.local/share/themeSwitcher` → the data directory

`current_theme` and `current_bg` are written at runtime and excluded from git.

---

## Ghostty themes

The custom Ghostty palette files live in `ghostty_themes/` inside the data directory. They are not managed by the themeSwitcher Stow package — instead, your `ghostty` Stow package should symlink them into `~/.config/ghostty/themes/`:

```
dotfiles/ghostty/.config/ghostty/themes/
├── Dracula          -> ~/.local/share/themeSwitcher/ghostty_themes/Dracula
├── Ethereal         -> ~/.local/share/themeSwitcher/ghostty_themes/Ethereal
├── Everforest Dark  -> ~/.local/share/themeSwitcher/ghostty_themes/Everforest Dark
├── Flexoki light    -> ~/.local/share/themeSwitcher/ghostty_themes/Flexoki light
├── Hackerman        -> ~/.local/share/themeSwitcher/ghostty_themes/Hackerman
├── Lumon            -> ~/.local/share/themeSwitcher/ghostty_themes/Lumon
├── Miasma           -> ~/.local/share/themeSwitcher/ghostty_themes/Miasma
├── Osaka Jade       -> ~/.local/share/themeSwitcher/ghostty_themes/Osaka Jade
├── Retro 82         -> ~/.local/share/themeSwitcher/ghostty_themes/Retro 82
├── Vantablack       -> ~/.local/share/themeSwitcher/ghostty_themes/Vantablack
└── White            -> ~/.local/share/themeSwitcher/ghostty_themes/White
```

This keeps both Stow packages conflict-free: `ghostty` owns `~/.config/ghostty/themes/`, and `themeSwitcher` owns the data directory where the files actually live.

Themes that are built into Ghostty (catppuccin, dracula, nord, etc.) need no file — the `ghostty` key in `manifest.toml` refers to them by their built-in name.

---

## Adding a theme

### 1. Add a block to `manifest.toml`

```toml
[mytheme]
display_name = "My Theme"
ghostty      = "My Theme"    # theme name as Ghostty knows it

[mytheme.gnome]
gtk_theme    = "MyTheme-Dark"
shell_theme  = "MyTheme-Dark"
icon_theme   = "Papirus-Dark"
accent_color = "blue"        # named GNOME accent colour
color_scheme = "prefer-dark" # or "prefer-light" for light themes

[mytheme.palette]
base     = "#1a1b26"
mantle   = "#16161e"
# … all 16 keys required (see Palette keys below)

[mytheme.colors]
background = "base"
foreground = "text"
# … all color keys, referencing palette names
```

### 2. Add a Ghostty theme file

If the theme isn't built into Ghostty, add a palette file to `themeSwitcher/.config/ghostty/themes/mytheme.theme`:

```
background           = #1a1b26
foreground           = #c0caf5
cursor-color         = #c0caf5
cursor-text          = #1a1b26
selection-background = #28344a
selection-foreground = #c0caf5

palette = 0=#15161e
palette = 1=#f7768e
# … palette = 0 through 15
```

### 3. Configure Neovim

Choose the appropriate strategy based on whether a matching Neovim plugin exists:

**Dedicated plugin** (theme ID matches nvim colorscheme name) — nothing to do, it works automatically.

**Name mismatch** — add to `nvim_overrides` in `colorschemes.lua`:
```lua
["mytheme"] = "actual-colorscheme-name",
```

**Terminal-palette theme** (no matching plugin, should inherit Ghostty colours) — add to `pixel_themes`:
```lua
["mytheme"] = true,
```

**Aether-based theme** (custom palette with proper syntax highlighting) — add to `aether_palettes` with the 14 colour slots mapped from the theme's palette.

### 4. Add wallpapers

```
themeSwitcher/.local/share/themeSwitcher/backgrounds/mytheme/1-mytheme.png
```

### 5. Validate

```bash
themeSwitcher --check
```

### Palette keys

Every theme must define all 16 of these in `[mytheme.palette]`:

```
base      mantle    surface   overlay   muted
text      subtext
red       orange    yellow    green
teal      sky       sapphire  blue      mauve
```

Map each key to the closest semantic colour in your theme — `red` for errors, `green` for success, `blue` for the primary accent, etc.

---

## Licence

MIT
