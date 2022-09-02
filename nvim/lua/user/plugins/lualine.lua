local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
	return
end

local hide_in_width = function()
	return vim.fn.winwidth(0) > 80
end

local diff = {
	"diff",
	colored = true,
	-- diff_color = {
	-- 	added = "DiffAdd", -- Changes the diff's added color
	-- 	modified = "DiffChange", -- Changes the diff's modified color
	-- 	removed = "DiffDelete", -- Changes the diff's removed color you
	-- },
	-- symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
	-- symbols = { added = "[+] ", modified = "[~] ", removed = "[-] " }, -- changes diff symbols
	cond = hide_in_width,
}

lualine.setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = { "statusline", "winbar" },
		always_divide_middle = true,
		globalstatus = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", diff, "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	extensions = {
		"nvim-tree",
		"toggleterm",
		"nvim-dap-ui",
	},
})
