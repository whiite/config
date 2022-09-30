local status_ok, mason = pcall(require, "mason")
if not status_ok then
	return
end
mason.setup()

local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup()

local on_attach = require("user.lsp.handlers").on_attach

local function create_lsp_opts(settings_dir, server_name)
	local opts = {
		on_attach = on_attach,
		capabilities = require("user.lsp.handlers").capabilities,
	}

	local lsp_settings_ok, lsp_opts = pcall(require, settings_dir .. "." .. server_name)
	if not lsp_settings_ok then
		return opts
	end

	return vim.tbl_deep_extend("force", lsp_opts, opts)
end

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
	return
end

local server_list = mason_lspconfig.get_installed_servers()
for _, server_name in pairs(server_list) do
	local opts = create_lsp_opts("user.lsp.settings", server_name)
	lspconfig[server_name].setup(opts)
end
require("user.lsp.settings.null-ls").setup(on_attach)
