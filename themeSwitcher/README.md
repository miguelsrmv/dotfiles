# themeSwitcher

A desktop theme switcher for Linux that applies a colour theme cohesively across your terminal, editor, prompt, system monitor, and desktop environment in one command.

Themes are defined in a single TOML manifest with a 16-colour palette per theme. Components are toggled on or off per-user — no code changes needed to skip apps you don't use.

---

## Themes included

| ID | Name |
|---|---|
| `catppuccin-macchiato` | Catppuccin Macchiato |
| `dracula` | Dracula |
| `everforest` | Everforest |
| `gruvbox` | Gruvbox |
| `kanagawa` | Kanagawa |
| `monokai-pro-ristretto` | Monokai Pro Ristretto |
| `nightfox` | Nightfox |
| `nord` | Nord |
| `onedark` | One Dark Pro |
| `rose-pine` | Rosé Pine |
| `tokyonight-night` | Tokyo Night |

---

## What it changes

| Component | How |
|---|---|
| **Ghostty** | Writes `~/.config/ghostty/ghostty.theme`, signals Ghostty to reload |
| **tmux** | Renders and writes `~/.config/tmux/themes/theme.colors`, reloads config |
| **Starship** | Renders and writes `~/.config/starship/starship.toml` |
| **btop** | Renders and writes `~/.config/btop/themes/current.theme`, signals btop to reload |
| **Neovim** | Reads colorscheme name from `current_theme`, applies live to running instances via socket |
| **GNOME** | Sets GTK theme, shell theme, icon theme, accent colour, and wallpaper via `gsettings` |

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
The GTK and shell themes referenced in `manifest.toml` must be installed separately. If a theme package is missing, `gsettings` will fail silently on that call and everything else will still apply. The shell theme requires the [User Themes](https://extensions.gnome.org/extension/19/user-themes/) GNOME extension — without it the shell theme call is silently skipped.

| Theme | Source |
|---|---|
| Catppuccin GTK | [github.com/catppuccin/gtk](https://github.com/catppuccin/gtk) |
| Dracula GTK | [github.com/dracula/gtk](https://github.com/dracula/gtk) |
| Nordic (Nord / Nightfox) | [github.com/EliverLara/Nordic](https://github.com/EliverLara/Nordic) |
| Gruvbox GTK | [github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme](https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme) |
| Tokyo Night GTK | [github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme](https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme) |

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
│       ├── .config/
│       │   └── ghostty/themes/
│       └── .local/
│           ├── bin/themeSwitcher
│           └── share/themeSwitcher/
├── nvim/
├── zsh/
└── …
```

### 2. Stow it

```bash
cd ~/dotfiles
stow themeSwitcher
```

This creates three symlinks:
- `~/.local/bin/themeSwitcher` → the executable
- `~/.local/share/themeSwitcher` → the data directory
- `~/.config/ghostty/themes` → bundled Ghostty palette source files

### 3. Make sure `~/.local/bin` is in your PATH

```bash
# In ~/.zshenv, ~/.bashrc, etc. — if not already present
export PATH="$HOME/.local/bin:$PATH"
```

No environment variables to set — the script locates its data directory via `XDG_DATA_HOME` (defaulting to `~/.local/share`).

### 4. Add your wallpapers

Drop wallpaper images into `backgrounds/<theme_id>/` inside the data directory:

```
~/.local/share/themeSwitcher/backgrounds/catppuccin-macchiato/1-waves.png
~/.local/share/themeSwitcher/backgrounds/catppuccin-macchiato/2-mountain.png
~/.local/share/themeSwitcher/backgrounds/dracula/1-bats.png
```

They are cycled in alphabetical order by `--bg`. The first wallpaper in a theme's directory is used automatically when you switch to that theme for the first time.

### 5. Configure Neovim to read the persisted theme

Add to your `init.lua`:

```lua
local xdg_data = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
local f = io.open(xdg_data .. "/themeSwitcher/current_theme", "r")
if f then
    local theme_id = f:read("*l"):gsub("%s+", "")
    f:close()
    local ok, err = pcall(vim.cmd, "colorscheme " .. theme_id)
    if not ok then
        vim.notify("themeSwitcher: colorscheme '" .. theme_id .. "' not found", vim.log.levels.WARN)
    end
end
```

The theme ID is also the Neovim colorscheme name — no mapping table needed.

### 6. Configure btop to load the generated theme

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
    ├── .config/
    │   └── ghostty/
    │       └── themes/                     ← Ghostty palette source files (→ ~/.config/)
    │           ├── dracula_mofiqul.theme
    │           └── everforest_dark.theme
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
                ├── backgrounds/            ← wallpapers, organised by theme ID
                │   ├── catppuccin-macchiato/
                │   │   ├── 1-catppuccin.png
                │   │   └── 2-cat-waves.png
                │   └── dracula/
                │       └── 1-bats.png
                ├── themes/                 ← theme dirs (structural configs if needed)
                │   └── catppuccin-macchiato/
                ├── current_theme       ← runtime state (gitignored)
                └── current_bg             ← symlink → current wallpaper (gitignored)
```

After `stow themeSwitcher`, Stow creates three symlinks:
- `~/.local/bin/themeSwitcher` → the executable
- `~/.local/share/themeSwitcher` → the data directory
- `~/.config/ghostty/themes` → the Ghostty palette source files

`current_theme` and `current_bg` are written at runtime and excluded from git.

---

## Adding a theme

1. Add a `[mytheme]` block to `manifest.toml` with:
   - `[mytheme.palette]` — 16 named colours (see [Palette keys](#palette-keys))
   - `[mytheme.colors]` — semantic mappings referencing palette key names
   - `[mytheme.gnome]` — GTK/shell/icon theme names and accent colour
   - `ghostty` — the theme name as Ghostty knows it
2. Create `backgrounds/mytheme/` and add at least one wallpaper.
3. Run `themeSwitcher --check` to validate.

The theme ID must match the Neovim colorscheme name — this is how `current_theme` serves double duty as both the switcher's state file and Neovim's colorscheme source.

### Palette keys

Every theme must define all 16 of these in `[mytheme.palette]`:

```
base      mantle    surface   overlay   muted
text      subtext
red       orange    yellow    green
teal      sky       sapphire  blue      mauve
```

The names follow the Catppuccin convention but are not Catppuccin-specific — map each key to the closest semantic colour in your theme. The `[mytheme.colors]` section then references these by name rather than hardcoding hex values everywhere.

---

## Licence

MIT
