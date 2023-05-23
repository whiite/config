local status_ok, dap = pcall(require, "dap")
if not status_ok then
	return
end

-- Icons --
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Error", linehl = "", numhl = "" })

-- Adapters --
local codelldb_extension_path = require("mason-registry").get_package("codelldb"):get_install_path() .. "/extension"
local codelldb_path = codelldb_extension_path .. "/adapter/codelldb"
local liblldb_path = codelldb_extension_path .. "/lldb/lib/liblldb.dylib"

dap.adapters.codelldb = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)

dap.adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "js-debug-adapter",
		args = { "${port}" },
	},
}

dap.configurations.typescript = {
	{
		type = "pwa-node",
		request = "launch",
		name = "Launch JS-Debug",
		cwd = "${workspaceFolder}",
	},
}
dap.configurations.javascript = dap.configurations.typescript

dap.configurations.cpp = {
	{
		name = "Launch",
		type = "lldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: " .. vim.fn.getcwd() .. "/file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
		-- 💀
		-- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
		--
		--    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
		--
		-- Otherwise you might get the following error:
		--
		--    Error on launch: Failed to attach to the target process
		--
		-- But you should be aware of the implications:
		-- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
		-- runInTerminal = false,
	},
}
dap.configurations.c = dap.configurations.cpp
