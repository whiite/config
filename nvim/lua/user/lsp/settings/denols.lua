vim.lsp.config("denols", {
	single_file_support = false,
	root_dir = require("lspconfig").util.root_pattern("deno.json", "deno.jsonc"),
	-- root_markers = { "deno.json", "deno.jsonc" },
	init_options = {
		enable = true,
		unstable = false,
		lint = true,
	},
})
