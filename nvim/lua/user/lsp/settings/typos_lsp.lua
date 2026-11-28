vim.lsp.config("typos_lsp", {
	init_options = {
		diagnosticSeverity = vim.diagnostic.severity.HINT,
		config = vim.fn.expand("~/.config/typos/typos.toml"),
	},
})
