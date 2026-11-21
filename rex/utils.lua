local M = {}

M.shell = "com.superlogical.terminal.shell"

-- Run lazygit inside a shell so quitting it returns to the prompt.
function M.lazygit_block(dir)
	return rex.layout.block({
		flavor = M.shell,
		label = "lazygit",
		options = { cwd = dir, initial_input = "lazygit\n" },
	})
end

-- Actions run from the CLI may not have a block, so fall back to the session's focus.
function M.current_block_id(ctx)
	if ctx.block_id ~= nil then
		return ctx.block_id
	end
	local view = rex.session.view({})
	if view == nil then
		return nil
	end
	for _, window in ipairs(view.windows) do
		if window.window_id == view.active_window_id and window.focused_block_id ~= nil then
			return window.focused_block_id
		end
	end
	for _, window in ipairs(view.windows) do
		if window.focused_block_id ~= nil then
			return window.focused_block_id
		end
	end
	return nil
end

-- The window holding a block, falling back to the session's active window.
function M.window_id_for_block(block_id)
	local view = rex.session.view({})
	if view == nil then
		return nil
	end
	if block_id ~= nil then
		for _, window in ipairs(view.windows) do
			for _, layer in ipairs(window.layers or {}) do
				for _, block in ipairs(layer.blocks or {}) do
					if block.block_id == block_id then
						return window.window_id
					end
				end
			end
		end
	end
	return view.active_window_id
end

-- The working directory of a terminal block, without the file:// URL prefix.
function M.block_dir(block_id)
	if block_id == nil then
		return nil
	end
	local result, err = rex.block.call("com.superlogical.terminal", "pwd", { block_id = block_id })
	if result == nil or result.pwd == nil then
		return nil, err
	end
	return (result.pwd:gsub("^file://[^/]*", ""))
end

-- Prefer the repository root, but fall back to the directory itself outside Git.
function M.repo_dir(dir)
	if dir == nil then
		return nil
	end
	local result = rex.exec({ "git", "-C", dir, "rev-parse", "--show-toplevel" })
	if result ~= nil and result.ok and result.stdout ~= "" then
		return (result.stdout:gsub("%s+$", ""))
	end
	return dir
end

return M
