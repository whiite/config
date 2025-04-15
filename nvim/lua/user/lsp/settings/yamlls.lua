local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
	return
end

return {
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
}
