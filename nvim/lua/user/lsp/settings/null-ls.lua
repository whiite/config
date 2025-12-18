local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

local M = {}

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

function M.setup(on_attach)
	null_ls.setup({
		debug = false,
		sources = {
			-- Diagnostics
			diagnostics.actionlint,
		},
		on_attach = on_attach,
	})
end

return M
