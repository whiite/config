vim.g.rustaceanvim = function()
	local lsp_handlers = require("user.lsp.handlers")
	-- debug setup
	local extension_path = require("mason-registry").get_package("codelldb"):get_install_path() .. "/extension"
	local codelldb_path = extension_path .. "/adapter/codelldb"
	local liblldb_path = extension_path .. "/lldb/lib/liblldb.dylib"
	local rust_config = require("rustaceanvim.config")
	return {
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
			adapter = rust_config.get_codelldb_adapter(codelldb_path, liblldb_path),
		},
	}
end
