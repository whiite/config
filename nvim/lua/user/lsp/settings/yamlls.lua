vim.lsp.config("yamlls", {
	settings = {
		schemaStore = {
			enable = true,
		},
		format = {
			enable = false,
			bracketSpacing = true,
		},
		keyOrdering = false,
		validate = true,
		completion = true,
	},
})
