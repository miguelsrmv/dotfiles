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
	"https://github.com/tahayvr/matteblack.nvim",
	"https://github.com/ribru17/bamboo.nvim",
	"https://github.com/loctvl842/monokai-pro.nvim",
})

-- Apply current theme
local theme_file = "/home/miguel/.local/share/themeSwitcher/current_theme.txt"

local function read_theme()
	local f = io.open(theme_file, "r")
	if not f then
		return nil
	end

	local theme = f:read("*l")
	f:close()

	return vim.trim(theme or "")
end

local theme = read_theme()

local map = {
	["catppuccin"] = "catppuccin-macchiato",
	["catppuccin-latte"] = "catppuccin-latte",
	["dracula"] = "dracula",
	["default"] = "default",
	["everforest"] = "everforest",
	["gruvbox"] = "gruvbox",
	["kanagawa"] = "kanagawa",
	["nightfox"] = "nightfox",
	["nord"] = "nord",
	["one-dark-pro"] = "onedark",
	["ristretto"] = "monokai-pro-ristretto",
	["rose-pine"] = "rose-pine",
	["tokyo-night"] = "tokyonight-night",
}

local colorscheme = map[theme] or "default"

vim.cmd("colorscheme " .. colorscheme)
