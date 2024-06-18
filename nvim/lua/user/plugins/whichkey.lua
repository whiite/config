local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
	return
end

local setup = {
	plugins = {
		marks = true, -- shows a list of your marks on ' and `
		registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
		spelling = {
			enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
			suggestions = 20, -- how many suggestions should be shown in the list?
		},
		-- the presets plugin, adds help for a bunch of default keybindings in Neovim
		-- No actual key bindings are created
		presets = {
			operators = false, -- adds help for operators like d, y, ... and registers them for motion / text object completion
			motions = false, -- adds help for motions
			text_objects = false, -- help for text objects triggered after entering an operator
			windows = true, -- default bindings on <c-w>
			nav = true, -- misc bindings to work with windows
			z = true, -- bindings for folds, spelling and others prefixed with z
			g = true, -- bindings for prefixed with g
		},
	},
	-- add operators that will trigger motion and text object completion
	-- to enable all native operators, set the preset / operators plugin above
	-- operators = { gc = "Comments" },
	key_labels = {
		-- override the label used to display some keys. It doesn't effect WK in any other way.
		-- For example:
		-- ["<space>"] = "SPC",
		-- ["<cr>"] = "RET",
		-- ["<tab>"] = "TAB",
	},
	icons = {
		breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
		separator = "➜", -- symbol used between a key and it's label
		group = "+", -- symbol prepended to a group
	},
	popup_mappings = {
		scroll_down = "<c-d>", -- binding to scroll down inside the popup
		scroll_up = "<c-u>", -- binding to scroll up inside the popup
	},
	window = {
		border = "rounded", -- none, single, double, shadow
		position = "bottom", -- bottom, top
		margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
		padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
		winblend = 10,
	},
	layout = {
		height = { min = 4, max = 25 }, -- min and max height of the columns
		width = { min = 20, max = 50 }, -- min and max width of the columns
		spacing = 3, -- spacing between columns
		align = "left", -- align columns left, center or right
	},
	ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
	hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
	show_help = true, -- show help message on the command line when the popup is visible
	triggers = "auto", -- automatically setup triggers
	-- triggers = {"<leader>"} -- or specify a list manually
	triggers_blacklist = {
		-- list of mode / prefixes that should never be hooked by WhichKey
		-- this is mostly relevant for key maps that start with a native binding
		-- most people should not need to change this
		i = { "j", "k" },
		v = { "j", "k" },
	},
}

local mappings = {
	rn = { '<cmd>lua require("renamer").rename()<cr>', "Rename symbol" },
	e = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
	E = { "<cmd>NvimTreeFocus<cr>", "Focus on explorer" },
	w = { "<cmd>w!<CR>", "Save" },
	q = { "<cmd>q!<CR>", "Quit" },
	c = { "<cmd>Bdelete!<cr>", "Close Buffer" },
	C = { "<cmd>BufferLineCloseOthers<cr><cmd>Bdelete!<cr>", "Close All Buffers" },
	h = { "<cmd>lua vim.opt.hlsearch = not vim.opt.hlsearch:get()<cr>", "Toggle Highlight Search" },
	f = {
		name = "Find",
		f = { "<cmd>lua require('telescope.builtin').find_files()<cr>", "Find files" },
		t = {
			"<cmd>lua require('telescope.builtin').live_grep(require('telescope.themes').get_ivy())<cr>",
			"Find text",
		},
		T = { "<cmd>lua require('telescope.builtin').treesitter()<cr>", "Find in treesitter" },
		b = {
			"<cmd>lua require('telescope.builtin').git_branches()<cr>",
			"Find branch",
		},
		g = { "<cmd>lua require('telescope.builtin').git_files()<cr>", "Find git files" },
		s = { "<cmd>lua require('telescope.builtin').git_status()<cr>", "Find git status files" },
		R = { "<cmd>lua require('telescope.builtin').resume()<cr>", "Resume Telescope" },
		c = { "<cmd>lua require('telescope.builtin').commands()<cr>", "Find commands" },
		C = { "<cmd>lua require('telescope.builtin').colorscheme()<cr>", "Find colorscheme" },
	},
	m = { "<cmd>Mason<cr>", "Open Mason Installer" },
	r = { "<cmd>lua vim.opt.relativenumber = not vim.opt.relativenumber:get()<cr>", "Toggle relative line numbers" },
	F = {
		"<cmd>Format<cr>",
		"Format current buffer",
	},
	b = {
		name = "Buffers",
		c = { "<cmd>Bdelete!<CR>", "Close current buffer" },
		C = { "<cmd>BufferLineCloseOthers<cr><cmd>Bdelete!<cr>", "Close All Buffers" },
		o = { "<cmd>BufferLineCloseOthers<cr>", "Close All Other Buffers" },
		f = {
			"<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>",
			"Find buffer",
		},
		p = { "<cmd>BufferLinePick<CR>", "Pick buffer" },
		P = { "<cmd>BufferLineTogglePin<CR>", "Pin buffer" },
		L = { "<cmd>BufferLineCloseLeft<CR>", "Close left buffers" },
		R = { "<cmd>BufferLineCloseRight<CR>", "Close right buffers" },
	},
	d = {
		name = "Debug",
		d = { "<cmd>lua require 'dapui'.toggle()<cr>", "Breakpoint toggle" },
		b = { "<cmd>DapToggleBreakpoint<cr>", "Breakpoint toggle" },
		c = { "<cmd>DapContinue<cr>", "Continue" },
		r = { "<cmd>DapToggleRepl<cr>", "REPL Toggle" },
		o = { "<cmd>DapStepOver<cr>", "Step over" },
		i = { "<cmd>DapStepInto<cr>", "Step into" },
		O = { "<cmd>DapStepOut<cr>", "Step out" },
		q = { "<cmd>DapTerminate<cr>", "Stop/Terminate" },
	},
	p = { "<cmd>Lazy<cr>", "Plugins" },
	x = {
		name = "Trouble",
		x = { "<cmd>TroubleToggle<cr>", "Toggle diagnostics" },
		w = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace diagnostics" },
		d = { "<cmd>Trouble document_diagnostics<cr>", "Document diagnostics" },
		l = { "<cmd>Trouble loclist<cr>", "Items from the window location list" },
		q = { "<cmd>Trouble quickfix<cr>", "Quickfix items" },
	},
	g = {
		name = "Git",
		g = { "<cmd>lua _LAZYGIT_TOGGLE()<CR>", "Lazygit" },
		j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
		k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
		B = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
		p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
		r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
		R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
		s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
		u = {
			"<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
			"Undo Stage Hunk",
		},
		o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
		b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
		c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
		d = {
			"<cmd>Gitsigns diffthis<cr>",
			"Diff this",
		},
		C = {
			name = "Conflict",
			j = { "<cmd>GitConflictNextConflict<cr>", "Next conflict" },
			k = { "<cmd>GitConflictPrevConflict<cr>", "Previous conflict" },
			o = { "<cmd>GitConflictChooseOurs<cr>", "Choose ours" },
			t = { "<cmd>GitConflictChooseTheirs<cr>", "Choose theirs" },
			b = { "<cmd>GitConflictChooseBoth<cr>", "Choose both" },
			n = { "<cmd>GitConflictChooseNone<cr>", "Choose none" },
			B = { "<cmd>GitConflictChooseBase<cr>", "Choose base" },
			r = { "<cmd>GitConflictRefresh<cr>", "Refresh" },
		},
	},
	l = {
		name = "LSP",
		a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
		d = {
			"<cmd>Telescope lsp_document_diagnostics<cr>",
			"Document Diagnostics",
		},
		w = {
			"<cmd>Telescope lsp_workspace_diagnostics<cr>",
			"Workspace Diagnostics",
		},
		f = { "<cmd>Format<cr>", "Format" },
		i = { "<cmd>LspInfo<cr>", "Info" },
		I = { "<cmd>Mason<cr>", "Open Installer" },
		j = {
			"<cmd>lua vim.diagnostic.goto_next({ severity = { min = vim.diagnostic.severity.INFO } })<CR>",
			"Next Diagnostic",
		},
		J = {
			"<cmd>lua vim.diagnostic.goto_prev({ severity = { min = vim.diagnostic.severity.INFO }, cursor_position = {0, 0} })<CR>",
			"Last Diagnostic",
		},
		k = {
			"<cmd>lua vim.diagnostic.goto_prev({ severity = { min = vim.diagnostic.severity.INFO } })<cr>",
			"Prev Diagnostic",
		},
		K = {
			"<cmd>lua vim.diagnostic.goto_next({ severity = { min = vim.diagnostic.severity.INFO }, cursor_position = {0, 0} })<cr>",
			"First Diagnostic",
		},
		l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
		q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
		r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
		R = { "<cmd>LspRestart<cr>", "Restart Language Servers" },
		s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
		S = {
			"<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
			"Workspace Symbols",
		},
	},
	s = {
		name = "Search",
		b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
		c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
		h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
		M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
		r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
		R = { "<cmd>Telescope registers<cr>", "Registers" },
		k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
		C = { "<cmd>Telescope commands<cr>", "Commands" },
	},
	t = {
		name = "Terminal",
		n = { "<cmd>lua _NODE_TOGGLE()<cr>", "Node" },
		d = { "<cmd>lua _DENO_TOGGLE()<cr>", "Deno" },
		p = { "<cmd>lua _PYTHON_TOGGLE()<cr>", "Python" },
		g = { "<cmd>lua _LAZYGIT_TOGGLE()<cr>", "Lazygit" },
		f = { "<cmd>ToggleTerm direction=float<cr>", "Float" },
		h = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", "Horizontal" },
		v = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", "Vertical" },
	},
	S = { "<cmd>Silicon<cr>", "Screenshot file" },
}

which_key.setup(setup)
which_key.register(mappings, {
	mode = "n", -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
})
which_key.register({
	S = { ":Silicon<cr>", "Screenshot selected" },
}, {
	mode = "v",
	prefix = "<leader>",
})
which_key.register({
	d = {
		"<cmd>lua require('telescope.builtin').lsp_definitions()<cr>",
		"Go to definition",
	},
	D = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Go to declaration" },
	l = { "<cmd>lua vim.diagnostic.open_float()<cr>", "Show diagnostics" },
	i = { "<cmd>lua vim.lsp.implementation()<cr>", "Show all implementations for symbol" },
	-- s = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Show signature help for symbol" },
	s = "Leap over splits",
	r = {
		"<cmd>lua require('telescope.builtin').lsp_references()<cr>",
		"Find all references to symbol",
	},
}, { mode = "n", prefix = "g" })
