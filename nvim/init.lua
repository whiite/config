require("user.options")
require("user.keymaps")
require("user.lazy")
require("user.lsp")

vim.filetype.add({
	pattern = {
		[".*/%.github/workflows/.*%.ya?ml"] = "yaml.ghactions",
	},
})
