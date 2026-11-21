---@diagnostic disable: undefined-global

-- Toggles --
rex.bind("cmd+e", "pane.zoom")
rex.bind("shift+cmd+/", "session.collapse")

-- Tab bindings --
rex.bind("ctrl+cmd+w", "client.tab.close")

-- Pane bindings --
-- Sizing
rex.bind("cmd+b", "pane.balance")

-- Moving
rex.bind("shift+cmd+h", "pane.focus.left")
rex.bind("shift+cmd+l", "pane.focus.right")
rex.bind("shift+cmd+j", "pane.focus.down")
rex.bind("shift+cmd+k", "pane.focus.up")

rex.bind("shift+cmd+left", "pane.focus.left")
rex.bind("shift+cmd+right", "pane.focus.right")
rex.bind("shift+cmd+down", "pane.focus.down")
rex.bind("shift+cmd+up", "pane.focus.up")

local utils = require("utils")
local shell = utils.shell

rex.action({
	name = "dev_layout",
	title = "Dev Layout",
	description = "Turn the current tab into lazygit and a shell for the current repository.",
	category = "Workspace",
	run = function(ctx, args)
		local block_id = utils.current_block_id(ctx)
		local dir, err = utils.block_dir(block_id)
		if dir == nil then
			error(err or "the current block has no working directory", 0)
		end
		dir = utils.repo_dir(dir)

		local window_id = utils.window_id_for_block(block_id)
		if window_id == nil then
			error("the current block is not in a window", 0)
		end

		local split, serr = rex.session.new_split({
			anchor_id = block_id,
			direction = "horizontal",
			side = "before",
			ratio = 0.5,
			layout = utils.lazygit_block(dir),
		})
		if split == nil then
			error(serr, 0)
		end

		local name = dir:match("([^/\\]+)$") or "Dev Layout"
		local renamed, rerr = rex.session.set_window_label({
			window_id = window_id,
			label = name,
		})
		if renamed == nil then
			error(rerr, 0)
		end

		return { window_id = window_id, block_ids = split.block_ids, cwd = dir, name = name }
	end,
})

rex.action({
	name = "web_dev_layout",
	title = "Web Dev Layout",
	description = "Turn the current tab into lazygit and two shells for the current repository.",
	category = "Workspace",
	run = function(ctx, args)
		local block_id = utils.current_block_id(ctx)
		local dir, err = utils.block_dir(block_id)
		if dir == nil then
			error(err or "the current block has no working directory", 0)
		end
		dir = utils.repo_dir(dir)

		local window_id = utils.window_id_for_block(block_id)
		if window_id == nil then
			error("the current block is not in a window", 0)
		end

		local lazygit, lerr = rex.session.new_split({
			anchor_id = block_id,
			direction = "horizontal",
			side = "before",
			ratio = 0.5,
			layout = utils.lazygit_block(dir),
		})
		if lazygit == nil then
			error(lerr, 0)
		end

		local bottom, berr = rex.session.new_split({
			anchor_id = block_id,
			direction = "vertical",
			side = "after",
			ratio = 0.7,
			layout = rex.layout.block({
				flavor = shell,
				label = "shell",
				options = { cwd = dir },
			}),
		})
		if bottom == nil then
			error(berr, 0)
		end

		local name = dir:match("([^/\\]+)$") or "Web Dev Layout"
		local renamed, rerr = rex.session.set_window_label({
			window_id = window_id,
			label = name,
		})
		if renamed == nil then
			error(rerr, 0)
		end

		return {
			window_id = window_id,
			block_ids = { lazygit.block_ids[1], bottom.block_ids[1] },
			cwd = dir,
			name = name,
		}
	end,
})
