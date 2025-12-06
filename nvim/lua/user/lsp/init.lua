require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup()

vim.keymap.set("n", "<leader>F", "<cmd>Format<cr>", { desc = "Format buffer", buffer = bufnr })

local on_attach = require("user.lsp.handlers").on_attach
vim.lsp.config("*", {
	on_attach = on_attach,
	capabilities = vim.lsp.protocol.make_client_capabilities(),
})

vim.diagnostic.config({
	-- diagnostic text appears at the end of the line
	virtual_text = {
		severity = {
			min = vim.diagnostic.severity.INFO,
		},
	},
	-- show signs
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "󰌶",
			DapBreakpoint = ""
		}
	},
	update_in_insert = true,
	underline = true,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		-- border = border,
		source = true,
		header = "",
		prefix = "",
	},
})


-- Useful for allowing plugins to configure and setup a server instead
local server_exclude = {
	"rust_analyzer", -- Handled by rustaceanvim
}

local server_list = vim.tbl_filter(function(item)
	return not (vim.tbl_contains(server_exclude, item))
end, mason_lspconfig.get_installed_servers())

for _, server_name in pairs(server_list) do
	local server_settings_path = "user.lsp.settings." .. server_name
	pcall(require, server_settings_path)
end
vim.lsp.enable(server_list)

require("user.lsp.settings.null-ls").setup(on_attach)
require("user.lsp.handlers").setup()
