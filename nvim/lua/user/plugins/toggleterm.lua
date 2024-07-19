local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
	return
end

toggleterm.setup({
	size = 20,
	open_mapping = [[<c-\>]],
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 1,
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	persist_mode = true,
	direction = "float",
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
		border = "curved",
		winblend = 8,
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
})

function _G.set_terminal_keymaps()
	local opts = { noremap = true }
	vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<esc>]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-[>", [[<C-\><C-n>]], opts)
	vim.api.nvim_buf_set_keymap(0, "n", "<C-c>", [[<C-\><C-n>i<C-c>]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
	vim.api.nvim_buf_set_keymap(0, "t", "<C-q>", [[<cmd>bdelete!<cr>]], opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

-- Toggle term shell keymaps
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Toggle floating terminal" })
vim.keymap.set(
	"n",
	"<leader>th",
	"<cmd>ToggleTerm size=10 direction=horizontal<cr>",
	{ desc = "Toggle horizontal terminal" }
)
vim.keymap.set(
	"n",
	"<leader>tv",
	"<cmd>ToggleTerm size=80 direction=vertical<cr>",
	{ desc = "Toggle vertial terminal" }
)

-- Toggle term program keymaps
local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new({ cmd = "lazygit", hidden = false })
vim.keymap.set("n", "<leader>gg", function()
	lazygit:toggle()
end, { desc = "Toggle lazygit" })

local node = Terminal:new({ cmd = "node", hidden = false })
vim.keymap.set("n", "<leader>tg", function()
	node:toggle()
end, { desc = "Toggle Node REPL" })

local deno = Terminal:new({ cmd = "deno", hidden = false })
vim.keymap.set("n", "<leader>tg", function()
	deno:toggle()
end, { desc = "Toggle Deno REPL" })

local python = Terminal:new({ cmd = "python3", hidden = false })
vim.keymap.set("n", "<leader>tg", function()
	python:toggle()
end, { desc = "Toggle Python REPL" })
