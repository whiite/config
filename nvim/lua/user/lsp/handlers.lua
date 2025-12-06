-- 'M' nvim plugin convention
local M = {}

local border = {
	{ "🭽", "FloatBorder" },
	{ "▔", "FloatBorder" },
	{ "🭾", "FloatBorder" },
	{ "▕", "FloatBorder" },
	{ "🭿", "FloatBorder" },
	{ "▁", "FloatBorder" },
	{ "🭼", "FloatBorder" },
	{ "▏", "FloatBorder" },
}

M.setup = function()
	-- LSP bindings
	vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code Action" })
	vim.keymap.set("n", "<leader>ld", "<cmd>Telescope lsp_document_diagnostics<cr>", { desc = "Document Diagnostics" })
	vim.keymap.set(
		"n",
		"<leader>lw",
		"<cmd>Telescope lsp_workspace_diagnostics<cr>",
		{ desc = "Workspace Diagnostics" }
	)
	vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "Info" })
	vim.keymap.set("n", "<leader>ll", vim.lsp.codelens.run, { desc = "CodeLens Action" })
	vim.keymap.set("n", "<leader>lq", vim.diagnostic.setloclist, { desc = "Quickfix" })
	vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename" })
	vim.keymap.set("n", "<leader>lR", "<cmd>LspRestart<cr>", { desc = "Restart Language Servers" })
	vim.keymap.set("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document Symbols" })
	vim.keymap.set(
		"n",
		"<leader>lS",
		"<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
		{ desc = "Workspace Symbols" }
	)
end

-- Highlights tokens under the cursor
local function lsp_highlight_document(client)
	-- Set auto-commands conditional on server_capabilities
	if client.server_capabilities.document_highlight then
		vim.api.nvim_exec2([[
		    augroup lsp_document_highlight
			    autocmd! * <buffer>
				autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
				autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
		    augroup END
		]])
	end
end

-- Keymaps specifically for LSP
local function lsp_keymaps(bufnr)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration", buffer = true })
	vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, {
		desc = "Go to definition",
		buffer = bufnr,
	})
	vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show diagnostics" })
	vim.keymap.set("n", "K", function()
		vim.lsp.buf.hover({ border = border })
	end, { desc = "Hover", buffer = bufnr })
	vim.keymap.set(
		"n",
		"gi",
		vim.lsp.buf.implementation,
		{ desc = "Show all implementations for symbol", buffer = bufnr }
	)
	vim.keymap.set("n", "gs", require("telescope.builtin").lsp_definitions, {
		desc = "Go to definition",
		buffer = bufnr,
	})
	vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, {
		desc = "Find all references to symbol",
		buffer = bufnr,
	})

	local diagnostic_severity = { min = vim.diagnostic.severity.INFO }
	vim.keymap.set("n", "<leader>lk", function()
		vim.diagnostic.jump({
			count = -1,
			severity = diagnostic_severity,
		})
	end, {
		desc = "Prev diagnostic",
		buffer = bufnr,
	})
	vim.keymap.set("n", "<leader>lj", function()
		vim.diagnostic.jump({
			count = 1,
			severity = diagnostic_severity,
		})
	end, {
		desc = "Next diagnostic",
		buffer = bufnr,
	})
	vim.keymap.set("n", "<leader>lK", function()
		vim.diagnostic.jump({
			count = -1,
			severity = diagnostic_severity,
			pos = { 0, 0 },
		})
	end, {
		desc = "First diagnostic",
		buffer = bufnr,
	})
	vim.keymap.set("n", "<leader>lJ", function()
		vim.diagnostic.jump({
			count = 1,
			severity = diagnostic_severity,
			pos = { 0, 0 },
		})
	end, {
		desc = "Last diagnostic",
		buffer = bufnr,
	})
end

local format_exclude = {
	"ts_ls",
	"jsonls",
	"html",
	"somesass_ls",
}

M.on_attach = function(client, bufnr)
	if vim.tbl_contains(format_exclude, client.name) then
		client.server_capabilities.documentFormattingProvider = false
	end

	if client.name == "angularls" then
		client.server_capabilities.renameProvider = false
	end

	lsp_keymaps(bufnr)
	lsp_highlight_document(client)
end

return M
