local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
	return
end

local opts = {
	root_dir = lspconfig.util.root_pattern("package.json"),
	init_options = {
		lint = true,
	},
}

return opts
