-- WezTerm theme written by themeSwitcher.
-- In your wezterm.lua:
--   local colors = require 'colors.current'
--   config.colors = colors

return {
    foreground = "{{foreground}}",
    background = "{{background}}",
    cursor_bg  = "{{accent}}",
    cursor_fg  = "{{background}}",

    selection_fg = "{{selected_fg}}",
    selection_bg = "{{selected_bg}}",

    ansi = {
        "{{background}}",
        "{{red}}",
        "{{green}}",
        "{{yellow}}",
        "{{blue}}",
        "{{mauve}}",
        "{{teal}}",
        "{{foreground}}",
    },
    brights = {
        "{{muted}}",
        "{{red}}",
        "{{green}}",
        "{{orange}}",
        "{{sapphire}}",
        "{{mauve}}",
        "{{sky}}",
        "{{foreground}}",
    },

    tab_bar = {
        background = "{{mantle}}",
        active_tab = {
            bg_color = "{{accent}}",
            fg_color = "{{background}}",
        },
        inactive_tab = {
            bg_color = "{{surface}}",
            fg_color = "{{muted}}",
        },
    },
}
