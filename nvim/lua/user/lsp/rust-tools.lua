local status_ok, rust_tools = pcall(require, "rust-tools")
if not status_ok then
	return
end

local lsp_handlers = require("user.lsp.handlers")

rust_tools.setup({
	server = {
		on_attach = lsp_handlers.on_attach,
		capabilities = lsp_handlers.capabilities,
	},
})
