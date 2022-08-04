local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
	return
end

local on_attach = require("user.lsp.handlers").on_attach
require("user.lsp.settings.null-ls").setup(on_attach)

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

lsp_installer.setup()

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
	return
end

local servers = lsp_installer.get_installed_servers()
for _, server in pairs(servers) do
	local opts = create_lsp_opts("user.lsp.settings", server.name)
	lspconfig[server.name].setup(opts)
end
