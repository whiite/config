-- 'M' nvim plugin convention
local M = {}

-- TODO: backfill this to template
M.setup = function()
	-- Diganostic sign setup
	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	local config = {
		-- diagnostic text appears at the end of the line
		virtual_text = {
			severity = {
				min = vim.diagnostic.severity.INFO,
			},
		},
		-- show signs
		signs = {
			active = signs,
		},
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	vim.diagnostic.config(config)

	-- Hover window settings
	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
	})

	-- Signature settings
	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
	})
end

-- Highlights tokens under the cursor
local function lsp_highlight_document(client)
	-- Set autocommands conditional on server_capabilities
	if client.server_capabilities.document_highlight then
		vim.api.nvim_exec(
			[[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
			false
		)
	end
end

-- Keymaps specifically for LSP
local function lsp_keymaps(bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }
	-- NOTE: set under whichkey
	-- vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	-- vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	-- vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	-- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	-- vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)
	-- vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	-- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
	-- vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
	vim.api.nvim_create_user_command("Format", function()
		vim.lsp.buf.format({ async = true })
	end, {
		nargs = "*",
		desc = "Format the current file using the language server",
	})
end

local format_exclude = {
	"tsserver",
	"sumneko_lua",
	"jsonls",
}

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
M.on_attach = function(client, bufnr)
	if vim.tbl_contains(format_exclude, client.name) then
		client.server_capabilities.documentFormattingProvider = false
	end

	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end,
		})
	end

	if client.name == "angularls" then
		client.server_capabilities.renameProvider = false
	end

	lsp_keymaps(bufnr)
	lsp_highlight_document(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
	return
end

-- cmp hook to enable LSP capabilities
M.capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

return M
