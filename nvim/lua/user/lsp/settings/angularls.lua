vim.lsp.config("angularls", {
	root_markers = { "angular.json" },
	root_dir = require("lspconfig").util.root_pattern("angular.json"),
})
