local status_ok, dap = pcall(require, "dap")
if not status_ok then
	return
end

-- Icons --
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Error", linehl = "", numhl = "" })

-- Adapters --
local extension_path = require("mason-registry").get_package("codelldb"):get_install_path() .. "/extension"
local codelldb_path = extension_path .. "/adapter/codelldb"
local liblldb_path = extension_path .. "/lldb/lib/liblldb.dylib"

-- Configure the LLDB adapter
dap.adapters.codelldb = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)

dap.adapters.node2 = {
	type = "executable",
	command = "node",
	args = { os.getenv("HOME") .. "/dev/microsoft/vscode-node-debug2/out/src/nodeDebug.js" },
}

dap.adapters.chrome = {
	-- executable: launch the remote debug adapter - server: connect to an already running debug adapter
	type = "executable",
	-- command to launch the debug adapter - used only on executable type
	-- command = "chrome-debug-adaptor",
	command = os.getenv("HOME") .. "/.local/share/nvim/mason/bin/chrome-debug-adapter",
}

dap.adapters.firefox = {
	-- executable: launch the remote debug adapter - server: connect to an already running debug adapter
	type = "executable",
	-- command to launch the debug adapter - used only on executable type
	command = require("mason-registry").get_package("firefox-debug-adapter"):get_install_path()
		.. "firefox-debug-adapter",
}

-- Configurations --
dap.configurations.typescript = {
	{
		name = "Debug (Attach) - Remote",
		type = "firefox",
		request = "attach",
		sourceMaps = true,
		trace = true,
		webRoot = "${workspaceFolder}",
	},
	{
		name = "Debug (Attach) - Remote",
		type = "chrome",
		request = "attach",
		-- program = "${file}",
		-- cwd = vim.fn.getcwd(),
		sourceMaps = true,
		--      reAttach = true,
		trace = true,
		-- protocol = "inspector",
		-- hostName = "127.0.0.1",
		port = 9222,
		webRoot = "${workspaceFolder}",
	},
}

dap.configurations.javascript = {
	{
		name = "Launch",
		type = "node2",
		request = "launch",
		-- program = "${file}",
		program = "${workspaceFolder}/${file}",
		cwd = vim.fn.getcwd(),
		sourceMaps = true,
		protocol = "inspector",
		console = "integratedTerminal",
	},
	{
		-- For this to work you need to make sure the node process is started with the `--inspect` flag.
		name = "Attach",
		type = "node2",
		request = "attach",
		processId = require("dap.utils").pick_process,
	},
}

dap.configurations.cpp = {
	{
		name = "Launch",
		type = "lldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
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
