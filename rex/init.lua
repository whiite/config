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
