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
