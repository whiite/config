local status_ok, rust_tools = pcall(require, "rust_tools")
if not status_ok then
	return
end

rust_tools.setup({})
