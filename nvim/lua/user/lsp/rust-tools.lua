local status_ok, rust_tools = pcall(require, "rust-tools")
if not status_ok then
	return
end

local lsp_handlers = require("user.lsp.handlers")

-- debug setup
local extension_path = require("mason-registry").get_package("codelldb"):get_install_path() .. "/extension"
local codelldb_path = extension_path .. "/adapter/codelldb"
local liblldb_path = extension_path .. "/lldb/lib/liblldb.dylib"

rust_tools.setup({
	server = {
		on_attach = lsp_handlers.on_attach,
		capabilities = lsp_handlers.capabilities,
		settings = {
			["rust-analyzer"] = {
				rustfmt = {
					overrideCommand = { "leptosfmt", "--stdin", "--rustfmt" },
				},
				-- procMacro = {
				-- 	ignored = {
				-- 		leptos_macro = {
				-- 			"component",
				-- 			"server",
				-- 		},
				-- 	},
				-- },
			},
		},
	},
	dap = {
		adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
	},
})
