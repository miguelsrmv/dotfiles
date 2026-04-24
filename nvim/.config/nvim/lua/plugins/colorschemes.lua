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
	"https://github.com/bjarneo/aether.nvim",
	"https://github.com/bjarneo/pixel.nvim",
})

-- Aether palette definitions per theme
local aether_palettes = {
	["lumon"] = {
		bg = "#16242d",
		bg_dark = "#0f1a21",
		bg_highlight = "#304860",
		fg = "#d6e2ee",
		fg_dark = "#b4e4f6",
		comment = "#304860",
		red = "#4d86b0",
		orange = "#6fb8e3",
		yellow = "#6fa4c9",
		green = "#5e95bc",
		cyan = "#b4e4f6",
		blue = "#8bc9eb",
		purple = "#73a6cb",
		magenta = "#d1eef8",
	},
	["miasma"] = {
		bg = "#222222",
		bg_dark = "#111111",
		bg_highlight = "#444444",
		fg = "#c2c2b0",
		fg_dark = "#d7c483",
		comment = "#666666",
		red = "#685742",
		orange = "#bb7744",
		yellow = "#b36d43",
		green = "#5f875f",
		cyan = "#c9a554",
		blue = "#78824b",
		purple = "#d7c483",
		magenta = "#bb7744",
	},
	["osaka-jade"] = {
		bg = "#111c18",
		bg_dark = "#0a1410",
		bg_highlight = "#23372B",
		fg = "#C1C497",
		fg_dark = "#F6F5DD",
		comment = "#53685B",
		red = "#FF5345",
		orange = "#db9f9c",
		yellow = "#E5C736",
		green = "#549e6a",
		cyan = "#2DD5B7",
		blue = "#509475",
		purple = "#ACD4CF",
		magenta = "#D2689C",
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
		["flexoki-light"] = true,
		["white"] = true,
	}

	local pixel_themes = {
		["hackerman"] = true,
		["ethereal"] = true,
		["vantablack"] = true,
		["white"] = true,
		["retro-82"] = true,
	}

	local nvim_overrides = {
		["monokai-pro-ristretto"] = "monokai-pro",
		["onedark"] = "onedark",
		["matte-black"] = "matteblack",
	}

	vim.o.background = light_themes[theme_id] and "light" or "dark"

	if aether_palettes[theme_id] then
		-- aether-based theme: setup with custom palette then apply
		vim.o.termguicolors = true
		local ok, aether = pcall(require, "aether")
		if ok then
			aether.setup({ transparent = false, colors = aether_palettes[theme_id] })
			vim.cmd("colorscheme aether")
		else
			vim.notify("themeSwitcher: aether.nvim not found", vim.log.levels.WARN)
		end
	elseif pixel_themes[theme_id] then
		-- pixel: inherit terminal palette directly
		vim.o.termguicolors = false
		local ok, err = pcall(vim.cmd, "colorscheme pixel")
		if not ok then
			vim.notify("themeSwitcher: pixel.nvim not found", vim.log.levels.WARN)
		end
	else
		-- standard dedicated plugin
		vim.o.termguicolors = true
		local colorscheme = nvim_overrides[theme_id] or theme_id
		local ok, err = pcall(vim.cmd, "colorscheme " .. colorscheme)
		if not ok then
			vim.notify("themeSwitcher: colorscheme '" .. colorscheme .. "' not found", vim.log.levels.WARN)
		end
	end
end
