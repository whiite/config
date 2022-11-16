local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
	return
end

return {
	single_file_support = false,
	root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
	init_options = {
		lint = true,
	},
}
