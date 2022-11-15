local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
	return
end

return {
	single_file_support = true,
	root_dir = lspconfig.util.root_pattern("!package.json"),
	init_options = {
		lint = true,
	},
}
