local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

local M = {}

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/code_actions
local actions = null_ls.builtins.code_actions

function M.setup(on_attach)
	local cspell = require("cspell")
	local cspell_config = {
		disabled_filetypes = { "NvimTree", "toggleterm" },
		diagnostics_postprocess = function(diagnostic)
			diagnostic.severity = vim.diagnostic.severity.HINT
		end,
	}
	null_ls.setup({
		debug = false,
		sources = {
			-- Formatters
			formatting.prettierd.with({
				condition = function(utils)
					return not utils.root_has_file("deno.json")
				end,
			}),
			formatting.black.with({ extra_args = { "--fast" } }),
			formatting.stylua,
			formatting.fish_indent,

			-- Diagnostics
			cspell.diagnostics.with(cspell_config),
			diagnostics.fish,

			-- Actions
			actions.gitsigns,
			cspell.code_actions.with(cspell_config),
		},
		on_attach = on_attach,
	})
end

return M
