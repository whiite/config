vim.lsp.config("stylelint", {
	settings = {
		filetypes = {
			"css",
			"less",
			"scss",
			"sugarss",
			"vue",
			"wxss",
			-- 'javascript',
			"javascriptreact",
			-- 'typescript',
			"typescriptreact",
		},
	},
})
