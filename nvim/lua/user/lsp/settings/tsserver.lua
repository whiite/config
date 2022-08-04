local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
	return
end

return {
	root_dir = lspconfig.util.root_pattern("package.json"),
}
