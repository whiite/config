local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.keymap.set("n", "<leader>p", "<cmd>Lazy<cr>", { desc = "Plugins" })

-- Install your plugins here
require("lazy").setup({
	-- General --
	{ "nvim-lua/plenary.nvim" }, -- Useful lua functions used by lots of plugins
	{
		"windwp/nvim-autopairs", -- Autopairs, integrates with both cmp and treesitter
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
				ts_config = {
					lua = { "string", "source" },
					javascript = { "string", "template_string" },
					java = false,
				},
				disable_filetype = { "TelescopePrompt", "spectre_panel" }, -- find file type with: `echo &ft`
				fast_wrap = {
					map = "<M-e>", -- 'M' = modifier = alt
					chars = { "{", "[", "(", '"', "'", "`", "<" },
					pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
					offset = 0, -- Offset from pattern match
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "PmenuSel",
					highlight_grey = "LineNr",
				},
			})
		end,
	},
	{
		"numToStr/Comment.nvim", -- Easily comment lines
		lazy = true,
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		opts = function()
			return {
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			}
		end,
		keys = {
			{
				"<C-/>",
				function()
					require("Comment.api").toggle.linewise.current()
				end,
				desc = "Toggle comment",
				mode = { "n", "i" },
			},
		},
	},
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		lazy = true,
		opts = function()
			vim.g.skip_ts_context_commentstring_module = true
			return {
				enable_autocmd = false,
			}
		end,
	},
	{
		"nvim-lualine/lualine.nvim", -- Status line at the bottom of the window
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = { "statusline", "winbar" },
				globalstatus = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					"branch",
					{
						"diff",
						colored = true,
						cond = function()
							return vim.fn.winwidth(0) > 80
						end,
					},
					"diagnostics",
				},
				lualine_c = { "filename" },
				lualine_x = { "lsp_status" },
				lualine_y = { "encoding", "filetype" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			extensions = {
				"neo-tree",
				"toggleterm",
			},
		},
	},
	{
		"akinsho/bufferline.nvim", -- Pretty tab bar
		lazy = false,
		version = "*",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			options = {
				offsets = {
					{ filetype = "NvimTree", text = "", padding = 1 },
					{ filetype = "neo-tree", text = "", padding = 1 },
				},
				buffer_close_icon = "󰅖",
				modified_icon = "●",
				close_icon = "",
				show_buffer_icons = true,
				show_buffer_close_icons = false,
				show_close_icon = false,
				diagnostics = false,
				always_show_bufferline = false,
				separator_style = "thin",
			},
		},
		keys = {
			{ "<leader>c", "<cmd>bprevious<bar>bdelete!#<cr>", desc = "Close Buffer" },
			{
				"<leader>C",
				"<cmd>%bdelete<cr>",
				desc = "Close All Buffers",
			},
			{ "<leader>bc", "<cmd>bprevious<bar>bdelete!#<cr>", desc = "Close current buffer" },
			{ "<leader>bC", "<cmd>%bdelete<cr>", desc = "Close All Buffers" },
			{ "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close All Other Buffers" },
			{
				"<leader>bf",
				function()
					require("telescope.builtin").buffers(
						require("telescope.themes").get_dropdown({ previewer = false })
					)
				end,
				desc = "Find buffer",
			},
			{ "<leader>bp", "<cmd>BufferLinePick<CR>", desc = "Pick buffer" },
			{ "<leader>bP", "<cmd>BufferLineTogglePin<CR>", desc = "Pin buffer" },
			{ "<leader>bL", "<cmd>BufferLineCloseLeft<CR>", desc = "Close left buffers" },
			{ "<leader>bR", "<cmd>BufferLineCloseRight<CR>", desc = "Close right buffers" },
		},
	},
	{
		"akinsho/toggleterm.nvim", -- Toggle terminals (float or split)
		version = "*",
		config = function()
			require("user.plugins.toggleterm")
		end,
	},
	{
		"nacro90/numb.nvim", -- Preview number lines by typing :<line-number>
		event = "CmdlineEnter",
		opts = {
			show_numbers = true, -- Enable 'number' for the window while peeking
			show_cursorline = true, -- Enable 'cursorline' for the window while peeking
			number_only = false, -- Peek only when the command is only a number instead of when it starts with a number
			centered_peeking = true, -- Peeked line will be centered relative to window
		},
	},
	{ "tpope/vim-surround", event = { "BufReadPre", "BufNewFile" } }, -- Easily modify surrounding characters
	{ "tpope/vim-sleuth", event = { "BufReadPre", "BufNewFile" } }, -- Auto detect indentation and tabstop (tab/space)
	{
		"ggandor/leap.nvim", -- Fast movement by using 's'/'S' followed by characters you wish to leap to
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("leap").add_default_mappings()
		end,
	},
	{
		"michaelrommel/nvim-silicon",
		lazy = true,
		cmd = "Silicon",
		opts = {
			theme = "Dracula",
			background = "#333",
			no_window_controls = true,
			pad_horiz = 0,
			pad_vert = 0,
			no_round_corner = true,
			output = function()
				return "~/Downloads/" .. os.date("!%Y-%m-%dT%H-%M-%S") .. "_code_screenshot.png"
			end,
		},
		keys = {
			{ "<leader>S", ":Silicon<cr>", desc = "Screenshot selected", mode = "v" },
			{ "<leader>S", "<cmd>Silicon<cr>", desc = "Screenshot file" },
		},
	},

	-- completion
	{
		"saghen/blink.cmp",
		dependencies = { "rafamadriz/friendly-snippets" },
		-- use a release tag to download pre-built binaries
		version = "1.*",
		-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
			-- 'super-tab' for mappings similar to vscode (tab to accept)
			-- 'enter' for enter to accept
			-- 'none' for no mappings
			--
			-- All presets have the following mappings:
			-- C-space: Open menu or open docs if already open
			-- C-n/C-p or Up/Down: Select next/previous item
			-- C-e: Hide menu
			-- C-k: Toggle signature help (if signature.enabled = true)
			--
			-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = { preset = "super-tab" },

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			-- (Default) Only show the documentation popup when manually triggered
			completion = { documentation = { auto_show = true } },

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},

			-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
			-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
			-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
			--
			-- See the fuzzy documentation for more information
			fuzzy = { implementation = "prefer_rust_with_warning" },
			cmdline = {
				enabled = true,
				keymap = { preset = "super-tab" },
				completion = {
					menu = {
						auto_show = true,
					},
				},
			},
		},
		opts_extend = { "sources.default" },
	},

	-- Prettier UI
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPre", "BufNewFile" },
		main = "ibl",
		opts = {},
		config = function()
			local highlight = {
				"RainbowRed",
				"RainbowYellow",
				"RainbowBlue",
				"RainbowOrange",
				"RainbowGreen",
				"RainbowViolet",
				"RainbowCyan",
			}
			local hooks = require("ibl.hooks")
			-- create the highlight groups in the highlight setup hook, so they are reset
			-- every time the colorscheme changes
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
				vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
				vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
				vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
				vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
				vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
			end)

			vim.g.rainbow_delimiters = { highlight = highlight }
			require("ibl").setup({ scope = { highlight = highlight } })

			hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
		end,
	}, -- Indent guides and invisible character support
	{
		"b0o/incline.nvim",
		event = "VeryLazy",
		config = function()
			require("incline").setup({
				hide = {
					cursorline = "focused_win",
				},
			})
		end,
	},
	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		opts = {
			filetypes = {
				"javascript",
				"typescript",
				sass = {
					names = true,
				},
				scss = {
					names = true,
				},
				css = {
					names = true,
				},
				html = {},
				svg = {},
			},
			user_default_options = { names = false, css = true },
		},
	},
	{
		"karb94/neoscroll.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			easing = "linear", -- linear, quadratic, cubic, quartic, quintic, circular, sine
			respect_scrolloff = true,
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},
	{
		"rcarriga/nvim-notify",
		priority = 500,
		config = function()
			local notify = require("notify")
			notify.setup({
				fps = 45,
				level = "info",
				render = "compact",
			})
			vim.notify = notify
		end,
	},
	{
		"folke/todo-comments.nvim",
		event = "LspAttach",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},

	-- Color schemes
	-- {
	-- 	"folke/tokyonight.nvim",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("tokyonight").setup({
	-- 			style = "storm", -- "storm" | "moon" | "night" | "day"
	-- 			styles = {
	-- 				sidebars = "dark",
	-- 			},
	-- 			lualine_bold = true,
	-- 			transparent = false,
	-- 			-- borderless telescope
	-- 			on_highlights = function(hl, c)
	-- 				local prompt = "#2d3149"
	-- 				hl.TelescopeNormal = {
	-- 					bg = c.bg_dark,
	-- 					fg = c.fg_dark,
	-- 				}
	-- 				hl.TelescopeBorder = {
	-- 					bg = c.bg_dark,
	-- 					fg = c.bg_dark,
	-- 				}
	-- 				hl.TelescopePromptNormal = {
	-- 					bg = prompt,
	-- 				}
	-- 				hl.TelescopePromptBorder = {
	-- 					bg = prompt,
	-- 					fg = prompt,
	-- 				}
	-- 				hl.TelescopePromptTitle = {
	-- 					bg = prompt,
	-- 					fg = prompt,
	-- 				}
	-- 				hl.TelescopePreviewTitle = {
	-- 					bg = c.bg_dark,
	-- 					fg = c.bg_dark,
	-- 				}
	-- 				hl.TelescopeResultsTitle = {
	-- 					bg = c.bg_dark,
	-- 					fg = c.bg_dark,
	-- 				}
	-- 			end,
	-- 		})
	-- 		-- require("user.utils.colorscheme").set_colorscheme("tokyonight")
	-- 	end,
	-- },
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				theme = "wave", -- wave | dragon | lotus
				overrides = function(colors)
					local theme = colors.theme
					return {
						-- Block style telescope
						TelescopeTitle = { fg = theme.ui.special, bold = true },
						TelescopePromptNormal = { bg = theme.ui.bg_p1 },
						TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
						TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
						TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
						TelescopePreviewNormal = { bg = theme.ui.bg_dim },
						TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
					}
				end,
			})
			require("user.utils.colorscheme").set_colorscheme("kanagawa")
		end,
	},

	-- Debugging
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		cmd = {
			"DapToggleBreakpoint",
			"DapContinue",
			"DapToggleRepl",
			"DapStepOver",
			"DapStepInto",
			"DapStepOut",
			"DapTerminate",
		},
		dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
		config = function()
			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Error", linehl = "", numhl = "" })
			local dap = require("dap")
			dap.adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = {
						"js-debug-adapter",
						"${port}",
					},
				},
			}
			dap.adapters.chrome = {
				type = "executable",
				command = "node",
				args = {
					"chrome-debug-adapter",
				},
			}

			dap.configurations.typescript = {
				{
					type = "pwa-node",
					request = "launch",
					name = "Debug file",
					cwd = "${workspaceFolder}",
					program = "${file}",
				},
				{
					type = "chrome",
					request = "attach",
					name = "Chrome attach",
					program = "${file}",
					cwd = vim.fn.getcwd(),
					sourceMaps = true,
					protocol = "inspector",
					port = 9222,
					webRoot = "${workspaceFolder}",
				},
			}
			dap.configurations.javascript = dap.configurations.typescript
			dap.configurations.javascriptreact = dap.configurations.typescript
			dap.configurations.typescriptreact = dap.configurations.typescript
		end,
		keys = {
			{
				"<leader>dd",
				function()
					require("dapui").toggle()
				end,
				desc = "Breakpoint toggle",
			},
			{ "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Breakpoint toggle" },
			{ "<leader>dc", "<cmd>DapContinue<cr>", desc = "Continue" },
			{ "<leader>dr", "<cmd>DapToggleRepl<cr>", desc = "REPL Toggle" },
			{ "<leader>do", "<cmd>DapStepOver<cr>", desc = "Step over" },
			{ "<leader>di", "<cmd>DapStepInto<cr>", desc = "Step into" },
			{ "<leader>dO", "<cmd>DapStepOut<cr>", desc = "Step out" },
			{ "<leader>dq", "<cmd>DapTerminate<cr>", desc = "Stop/Terminate" },
		},
	},
	{
		"rcarriga/nvim-dap-ui",
		lazy = true,
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("user.plugins.nvim-dap-ui")
		end,
	},
	{
		"leoluz/nvim-dap-go",
		ft = "go",
		dependencies = { "mfussenegger/nvim-dap" },
		opt = {},
	},
	{
		"mrcjkb/rustaceanvim", -- Rust LSP and DAP support
		dependencies = { "mason-org/mason.nvim" },
		version = "^6",
		lazy = false,
		config = function()
			vim.g.rustaceanvim = function()
				local lsp_handlers = require("user.lsp.handlers")
				-- debug setup
				local extension_path = vim.fn.expand("$MASON/share/codelldb") .. "/extension"
				local codelldb_path = extension_path .. "/adapter/codelldb"
				local liblldb_path = extension_path .. "/lldb/lib/liblldb.dylib"
				local rust_config = require("rustaceanvim.config")
				return {
					server = {
						on_attach = lsp_handlers.on_attach,
						capabilities = lsp_handlers.capabilities,
						settings = function(project_root)
							local ra = require("rustaceanvim.config.server")
							return ra.load_rust_analyzer_settings(project_root, {
								settings_file_pattern = "rust-analyzer.json",
							})
						end,
					},
					dap = {
						adapter = rust_config.get_codelldb_adapter(codelldb_path, liblldb_path),
					},
				}
			end
		end,
	},
	{
		"saecki/crates.nvim", -- Manage Rust dependencies inside Cargo.toml
		tag = "stable",
		event = { "BufRead Cargo.toml" },
		config = function()
			require("crates").setup()
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim", -- fuzzy file/text finder UI
		lazy = true,
		event = { "BufReadPre", "BufNewFile" },
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			require("user.plugins.telescope")
		end,
		keys = {
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Find files",
			},
			{
				"<leader>fg",
				function()
					require("telescope.builtin").git_files()
				end,
				desc = "Find git files",
			},
			{
				"<leader>ft",
				function()
					require("telescope.builtin").live_grep(require("telescope.themes").get_ivy())
				end,
				desc = "Find text",
			},
			{ "<leader>fT", "<cmd>lua require('telescope.builtin').treesitter()<cr>", desc = "Find in treesitter" },
			{
				"<leader>fb",
				function()
					require("telescope.builtin").git_branches()
				end,
				desc = "Find branch",
			},
			{
				"<leader>fs",
				function()
					require("telescope.builtin").git_status()
				end,
				desc = "Find git status files",
			},
			{
				"<leader>fR",
				function()
					require("telescope.builtin").resume()
				end,
				desc = "Resume Telescope",
			},
			{ "<leader>fc", "<cmd>TodoTelescope<cr>", desc = "Find todo comments" },
			{
				"<leader>f>",
				function()
					require("telescope.builtin").commands()
				end,
				desc = "Find commands",
			},
			{
				"<leader>fC",
				function()
					require("telescope.builtin").colorscheme()
				end,
				desc = "Find colorscheme",
			},
		},
	},

	-- File explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		lazy = true,
		branch = "v3.x",
		cmd = { "Neotree" },
		opts = {
			close_if_last_window = true,
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = false,
				},
				follow_current_file = {
					enabled = true,
					leave_dirs_open = false,
				},
				use_libuv_file_watcher = true,
				group_empty_dirs = true,
			},
			event_handlers = {
				{
					event = "neo_tree_window_after_open",
					handler = function(args)
						if args.position == "left" or args.position == "right" then
							vim.cmd("wincmd =")
						end
					end,
				},
				{
					event = "neo_tree_window_after_close",
					handler = function(args)
						if args.position == "left" or args.position == "right" then
							vim.cmd("wincmd =")
						end
					end,
				},
				{
					event = "file_open_requested",
					handler = function()
						require("neo-tree.command").execute({ action = "close" })
					end,
				},
			},
			window = {
				mappings = {
					["h"] = function(state)
						local node = state.tree:get_node()
						if node.type == "directory" and node:is_expanded() then
							require("neo-tree.sources.filesystem").toggle_directory(state, node)
						else
							require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
						end
					end,
					["l"] = function(state)
						local node = state.tree:get_node()
						if node.type == "directory" then
							if not node:is_expanded() then
								require("neo-tree.sources.filesystem").toggle_directory(state, node)
							elseif node:has_children() then
								require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
							end
						end
					end,
				},
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle left<cr>", desc = "Explorer" },
			{ "<leader>E", "<cmd>Neotree focus<cr>", desc = "Focus on explorer" },
		},
	},

	-- AI
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.opts = {
		build = "make",
		dependencies = {
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			{
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		opts = {
			provider = "ollama",
			behaviour = {
				enable_cursor_planning_mode = true,
			},
			providers = {
				ollama = {
					model = "qwen2.5-coder:7b",
				},
			},
		},
	},

	-- LSP
	{ "neovim/nvim-lspconfig", lazy = true }, -- enable LSP
	{
		"mason-org/mason.nvim",
		keys = {
			{ "<leader>m", "<cmd>Mason<cr>", desc = "Open Mason installer" },
		},
	}, -- LSP/lint and debug manager
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "neovim/nvim-lspconfig" },
	}, -- lspconfig compatibility
	{
		"nvimtools/none-ls.nvim", -- for formatters and linters
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim", "davidmh/cspell.nvim" },
	},
	{
		"folke/trouble.nvim",
		opts = {},
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle diagnostics" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Toggle buffer diagnostics" },
			{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
			{
				"<leader>xl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				"LazyVim",
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	}, -- typings for neovim within lua files
	{ "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "master",
		build = ":TSUpdate",
		dependencies = {
			-- extensions
			"nvim-treesitter/nvim-treesitter-context",
			"JoosepAlviste/nvim-ts-context-commentstring",
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				highlight = {
					enable = true,
				},
				-- Extensions
				autopairs = {
					enable = true,
				},
				indent = {
					enable = true,
					disable = { "yaml" },
				},
				rainbow = {
					enable = true,
					extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
					max_file_lines = nil, -- Do not enable for files with more than n lines, int
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = { query = "@function.outer", desc = "Select outer part of a function" },
							["if"] = { query = "@function.inner", desc = "Select inner part of a function" },
							["ac"] = { query = "@class.outer", desc = "Select outer part of a class region" },
							["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
							["as"] = {
								query = "@scope.outer",
								query_group = "locals",
								desc = "Select inner language scope",
							},
							["is"] = {
								query = "@scope.inner",
								query_group = "locals",
								desc = "Select outer language scope",
							},
						},
						selection_modes = {
							["@parameter.outer"] = "v", -- charwise
							["@function.outer"] = "V", -- linewise
							["@class.outer"] = "<c-v>", -- blockwise
						},
						include_surrounding_whitespace = true,
					},
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
			max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
			trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
			patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
				-- For all filetypes
				-- Note that setting an entry here replaces all other patterns for this entry.
				-- By setting the 'default' entry below, you can control which nodes you want to
				-- appear in the context window.
				default = {
					"class",
					"function",
					"method",
					"for",
					"while",
					"if",
					"switch",
					"case",
				},
				-- Patterns for specific filetypes
				-- If a pattern is missing, *open a PR* so everyone can benefit.
				tex = {
					"chapter",
					"section",
					"subsection",
					"subsubsection",
				},
				-- rust = {
				-- 	"impl_item",
				-- 	"struct",
				-- 	"enum",
				-- },
				scala = {
					"object_definition",
				},
				vhdl = {
					"process_statement",
					"architecture_body",
					"entity_declaration",
				},
				markdown = {
					"section",
				},
			},
			exact_patterns = {
				-- Example for a specific filetype with Lua patterns
				-- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
				-- exactly match "impl_item" only)
				-- rust = true,
			},

			-- [!] The options below are exposed but shouldn't require your attention,
			--     you can safely ignore them.

			zindex = 20, -- The Z-index of the context window
			mode = "topline", -- Line used to calculate context. Choices: 'cursor', 'topline'
			separator = nil, -- Separator between context and content. Should be a single character string, like '-'.
		},
	},
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")
			---@type rainbow_delimiters.config
			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					vim = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					lua = "rainbow-blocks",
				},
				highlight = {
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
				},
			}
		end,
	}, -- rainbow parenthesis

	-- Git
	{
		"lewis6991/gitsigns.nvim",
		lazy = false,
		opts = {
			watch_gitdir = {
				interval = 1000,
				follow_files = true,
			},
			attach_to_untracked = true,
			current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
				virt_text_priority = 100, -- 'eol' | 'overlay' | 'right_align'
				ignore_whitespace = false,
				delay = 500,
			},
			current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
		},
		keys = {
			{
				"<leader>gj",
				function()
					require("gitsigns").nav_hunk("next")
				end,
				desc = "Next Hunk",
			},
			{
				"<leader>gk",
				function()
					require("gitsigns").nav_hunk("prev")
				end,
				desc = "Prev Hunk",
			},
			{
				"<leader>gB",
				function()
					require("gitsigns").blame_line()
				end,
				desc = "Blame",
			},
			{
				"<leader>gp",
				function()
					require("gitsigns").preview_hunk()
				end,
				desc = "Preview Hunk",
			},
			{
				"<leader>gr",
				function()
					require("gitsigns").reset_hunk()
				end,
				desc = "Reset Hunk",
			},
			{
				"<leader>gR",
				function()
					require("gitsigns").reset_buffer()
				end,
				desc = "Reset Buffer",
			},
			{
				"<leader>gs",
				function()
					require("gitsigns").stage_hunk()
				end,
				desc = "Stage Hunk Toggle",
			},
			{ "<leader>go", "<cmd>Telescope git_status<cr>", desc = "Open changed file" },
			{ "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
			{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Checkout commit" },
			{ "<leader>gd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff this" },
		},
	}, -- git info in the gutter (like VSCode)
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		event = { "BufReadPre", "BufNewFile" },
		config = true,
		keys = {
			{ "<leader>gCj", "<cmd>GitConflictNextConflict<cr>", desc = "Next conflict" },
			{ "<leader>gCk", "<cmd>GitConflictPrevConflict<cr>", desc = "Previous conflict" },
			{ "<leader>gCo", "<cmd>GitConflictChooseOurs<cr>", desc = "Choose ours" },
			{ "<leader>gCt", "<cmd>GitConflictChooseTheirs<cr>", desc = "Choose theirs" },
			{ "<leader>gCb", "<cmd>GitConflictChooseBoth<cr>", desc = "Choose both" },
			{ "<leader>gCn", "<cmd>GitConflictChooseNone<cr>", desc = "Choose none" },
			{ "<leader>gCB", "<cmd>GitConflictChooseBase<cr>", desc = "Choose base" },
			{ "<leader>gCr", "<cmd>GitConflictRefresh<cr>", desc = "Refresh" },
		},
	}, -- show and resolve git conflicts within files
})
