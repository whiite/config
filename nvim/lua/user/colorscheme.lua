local colorscheme = "catppuccin"

-- tokyonight settings
vim.g.tokyonight_style = "storm" -- "storm" | "night" | "day"
vim.g.tokyonight_lualine_bold = true
vim.g.tokyonight_dark_sidebar = true
vim.g.tokyonight_transparent_sidebar = false

-- catpuccin settings
vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha

-- colorscheme init
if colorscheme == "catppuccin" then
	local theme_status_ok, theme = pcall(require, "catppuccin")
	if not theme_status_ok then
		vim.notify("unable to setup colorscheme '" .. colorscheme .. "' plugin")
	else
		theme.setup()
	end
end

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
	vim.notify("colorscheme " .. colorscheme .. " not found!")
	return
end
