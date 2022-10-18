local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
	return
end

local opts = {
	workingDirectories = {
		mode = "location",
	},
}

return opts
