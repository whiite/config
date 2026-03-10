vim.lsp.config("nil_ls", {
	single_file_support = true,
	settings = {
		["nil"] = {
			formatting = {
				command = { "alejandra" }
			}
		}
	}
})
