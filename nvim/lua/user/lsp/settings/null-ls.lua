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
			diagnostics.cspell.with({
				disabled_filetypes = { "NvimTree", "toggleterm" },
				diagnostics_postprocess = function(diagnostic)
					diagnostic.severity = vim.diagnostic.severity.HINT
				end,
			}),
			diagnostics.fish,
			diagnostics.flake8,

			-- Actions
			actions.gitsigns,
			actions.cspell,
		},
		on_attach = on_attach,
	})
end

return M
