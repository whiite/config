local status_ok, mason = pcall(require, "mason")
if not status_ok then
	return
end
mason.setup()

local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup()

local on_attach = require("user.lsp.handlers").on_attach

---Load server settings
---@param settings_dir string
---@param server_name string
---@return table
local function create_lsp_opts(settings_dir, server_name)
	local opts = {
		on_attach = on_attach,
		capabilities = require("user.lsp.handlers").capabilities,
	}

	local server_settings_path = settings_dir .. "." .. server_name
	local lsp_settings_ok, lsp_opts = pcall(require, server_settings_path)
	if not lsp_settings_ok then
		return opts
	end

	return vim.tbl_deep_extend("keep", lsp_opts, opts)
end

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
	return
end

-- Useful for allowing plugins to configer and setup a server instead
local server_exclude = {
	"rust_analyzer", -- Handled by rustaceanvim
}
local server_list = vim.tbl_filter(function(item)
	return not vim.tbl_contains(server_exclude, item)
end, mason_lspconfig.get_installed_servers())

for _, server_name in pairs(server_list) do
	local opts = create_lsp_opts("user.lsp.settings", server_name)
	lspconfig[server_name].setup(opts)
end
require("user.lsp.settings.null-ls").setup(on_attach)
