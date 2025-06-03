require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup()

local on_attach = require("user.lsp.handlers").on_attach
vim.lsp.config("*", {
	on_attach = on_attach,
	capabilities = vim.lsp.protocol.make_client_capabilities(),
})

-- Useful for allowing plugins to configure and setup a server instead
local server_exclude = {
	"rust_analyzer", -- Handled by rustaceanvim
}
-- LSPs requiring the lspconfig[server_name].setup(...)
local server_legacy = {
	-- "angularls",
}

local server_list = vim.tbl_filter(function(item)
	return not (vim.tbl_contains(server_exclude, item) or vim.tbl_contains(server_legacy, item))
end, mason_lspconfig.get_installed_servers())

for _, server_name in pairs(server_legacy) do
	require("lspconfig")[server_name].setup({
		on_attach = on_attach,
		capabilities = vim.lsp.protocol.make_client_capabilities(),
	})
end

for _, server_name in pairs(server_list) do
	local server_settings_path = "user.lsp.settings." .. server_name
	pcall(require, server_settings_path)
end
-- vim.lsp.enable(server_list)
require("user.lsp.settings.null-ls").setup(on_attach)
require("user.lsp.handlers").setup()
