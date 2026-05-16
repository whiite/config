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
				disable_filetype = { "spectre_panel" }, -- find file type with: `echo &ft`
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
					require("fzf-lua").buffers()
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
	{ "nmac427/guess-indent.nvim", opts = {
		filetype_exclude = {
			"Neotree",
			"ToggleTerm",
		},
	} }, -- Auto detect indentation and tabstop (tab/space)
	{
		url = "https://codeberg.org/andyg/leap.nvim", -- Fast movement by using 's'/'S' followed by characters you wish to leap to
		lazy = false,
		keys = {
			{ "s", "<Plug>(leap)", desc = "Leap to", mode = { "n", "x", "o" } },
			{ "S", "<Plug>(leap-from-window)", desc = "Leap backward to", mode = "n" },
		},
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
			-- 'super-tab' tab to accept
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
			completion = { menu = { border = "none" }, documentation = { auto_show = true } },

			signature = { window = { border = "none" } },

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
			filetypes = { "*" },
			options = {
				parsers = {
					names = { enable = false },
					hex = {
						default = true, -- default value for format keys (see above)
						rgb = false, -- #RGB
						rgba = false, -- #RGBA
						rrggbb = false, -- #RRGGBB
						rrggbbaa = false, -- #RRGGBBAA
						aarrggbb = false, -- 0xAARRGGBB
					},
					rgb = { enable = true },
					hsl = { enable = true },
					oklch = { enable = true },
					tailwind = { enable = true, lsp = true, update_names = true },
					sass = { enable = true },
				},
			},
		},
	},
	{
		"karb94/neoscroll.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			easing = "sine", -- linear, quadratic, cubic, quartic, quintic, circular, sine
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
				colors = {
					theme = {
						all = {
							ui = {
								bg_gutter = "none",
							},
						},
					},
				},
				dimInactive = false,
				transparent = true,
				overrides = function(colors)
					local theme = colors.theme
					return {
						-- Preserve transparency
						NormalFloat = { bg = "none" },
						FloatBorder = { bg = "none" },
						FloatTitle = { bg = "none" },

						-- Popular plugins that open floats will link to NormalFloat by default;
						-- set their background accordingly if you wish to keep them dark and borderless
						LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
						MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
						checkhealth = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
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

	-- Search
	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		-- or if using mini.icons/mini.nvim
		-- dependencies = { "nvim-mini/mini.icons" },
		---@module "fzf-lua"
		---@type fzf-lua.Config|{}
		---@diagnostic disable: missing-fields
		opts = {
			keymap = {
				builtin = {
					true, -- inherit defaults
					["<C-U>"] = "preview-page-up",
					["<C-D>"] = "preview-page-down",
					["<C-P>"] = "toggle-preview",
					["<C-C>"] = "abort",
				},
			},
			defaults = {
				hidden = true,
				follow = true,
				no_ignore = true,
				file_ignore_patterns = {
					"^%.git/",
					"node_modules",
					"target",
					"%.yarn/",
					"dist",
					"build",
					"%.svelte%-kit/",
				},
			},
			grep = {
				file_ignore_patterns = {
					"^%.git/",
					"node_modules",
					"target",
					"%.yarn/",
					"dist",
					"build",
					"%.svelte%-kit/",
					".*-lock%..+$",
					".%.lock.?$",
				},
			},
			lsp = {
				code_actions = {
					previewer = "codeaction_native",
				},
			},
		},
		---@diagnostic enable: missing-fields
		keys = {
			{
				"<leader>ff",
				function()
					require("fzf-lua").files()
				end,
				desc = "Find files",
			},
			{
				"<leader>fg",
				function()
					require("fzf-lua").git_files()
				end,
				desc = "Find git files",
			},
			{
				"<leader>fb",
				function()
					require("fzf-lua").git_branches()
				end,
				desc = "Find branch",
			},
			{
				"<leader>ft",
				function()
					require("fzf-lua").live_grep()
				end,
				desc = "Find text",
			},
			{
				"<leader>fR",
				function()
					require("fzf-lua").resume()
				end,
				desc = "Resume find",
			},
			{
				"<leader>fs",
				function()
					require("fzf-lua").git_status()
				end,
				desc = "Find git status files",
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
				group_empty_dirs = false,
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
					["<S-CR>"] = "open_with_window_picker",
					["w"] = "open_with_window_picker",
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
			"s1n7ax/nvim-window-picker",
		},
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle left<cr>", desc = "Explorer" },
			{ "<leader>E", "<cmd>Neotree focus<cr>", desc = "Focus on explorer" },
		},
	},
	{
		"s1n7ax/nvim-window-picker",
		version = "2.*",
		opts = {
			hint = "floating-big-letter",
			-- selection_chars = 'FJDKSLA;CMRUEIWOQP', -- qwerty
			-- selection_chars = "TNSERIAOCMPLFUWYQ:", -- colemak
			selection_chars = "1234567890", -- numerical
			show_prompt = false,
			filter_rules = {
				include_current_win = true,
				autoselect_one = true,
				-- filter using buffer options
				bo = {
					-- if the file type is one of following, the window will be ignored
					filetype = { "neo-tree", "neo-tree-popup", "notify" },
					-- if the buffer type is one of following, the window will be ignored
					buftype = { "terminal", "quickfix" },
				},
			},
		},
	},

	-- LSP
	{ "neovim/nvim-lspconfig", lazy = true }, -- enable LSP
	{
		"mason-org/mason.nvim",
		opts = {
			ui = {
				border = "",
			},
		},
		keys = {
			{ "<leader>m", "<cmd>Mason<cr>", desc = "Open Mason installer" },
		},
	}, -- LSP/lint and debug manager
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "neovim/nvim-lspconfig" },
	}, -- lspconfig compatibility
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters = {
					prettierd = {
						inherit = "prettierd",
						condition = function(self, ctx)
							return not require("conform.util").root_file({ "deno.json", "deno.jsonc" })
						end,
					},
				},
				formatters_by_ft = {
					lua = { "stylua", lsp_format = "fallback" },
					markdown = { "deno_fmt" },
					fish = { "fish_indent" },
					javascript = { "prettierd", lsp_format = "fallback" },
					typescript = { "prettierd", lsp_format = "fallback" },
					json = { "deno_fmt", lsp_format = "prefer" },
				},
				format_on_save = function(bufnr)
					-- Disable with a global or buffer-local variable
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					return { timeout_ms = 500, lsp_format = "fallback" }
				end,
			})
			vim.api.nvim_create_user_command("Format", function()
				require("conform").format({ lsp_format = "fallback" })
			end, {
				desc = "Format buffer",
			})
			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					-- FormatDisable! will disable formatting just for this buffer
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true,
			})
			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters = {
					deno_fmt_markdown = {
						inherit = "deno_fmt",
						append_args = { "--indent-width", "4" },
					},
				},
				formatters_by_ft = {
					lua = { "stylua", lsp_format = "fallback" },
					markdown = { "deno_fmt" },
					fish = { "fish_indent" },
					javascript = { "prettierd" },
					typescript = { "prettierd" },
				},
				format_on_save = function(bufnr)
					-- Disable with a global or buffer-local variable
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					return { timeout_ms = 500, lsp_format = "fallback" }
				end,
			})
			vim.api.nvim_create_user_command("Format", function()
				require("conform").format({ lsp_format = "fallback" })
			end, {
				desc = "Format buffer",
			})
			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					-- FormatDisable! will disable formatting just for this buffer
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true,
			})
			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
			})
		end,
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
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					-- Enable treesitter highlighting and disable regex syntax
					pcall(vim.treesitter.start)
					-- Enable treesitter-based indentation
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		init = function()
			-- Disable entire built-in ftplugin mappings to avoid conflicts.
			-- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
			vim.g.no_plugin_maps = true

			-- Or, disable per filetype (add as you like)
			-- vim.g.no_python_maps = true
			-- vim.g.no_ruby_maps = true
			-- vim.g.no_rust_maps = true
			-- vim.g.no_go_maps = true
		end,
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					-- Automatically jump forward to text object
					lookahead = true,
					selection_modes = {
						["@parameter.outer"] = "v", -- charwise
						["@function.outer"] = "V", -- linewise
						["@class.outer"] = "<c-v>", -- blockwise
						["@block.outer"] = "V",
					},
					include_surrounding_whitespace = false,
				},
			})
			-- keymaps
			-- You can use the capture groups defined in `textobjects.scm`
			vim.keymap.set({ "x", "o" }, "af", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
			end, { desc = "Select outer part of a function" })
			vim.keymap.set({ "x", "o" }, "if", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
			end, { desc = "Select inner part of a function" })
			vim.keymap.set({ "x", "o" }, "ac", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
			end, { desc = "Select outer part of class region" })
			vim.keymap.set({ "x", "o" }, "ic", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
			end, { desc = "Select inner part of class region" })
			vim.keymap.set({ "x", "o" }, "ab", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@block.outer", "textobjects")
			end, { desc = "Select outer language scope" })
			vim.keymap.set({ "x", "o" }, "ib", function()
				require("nvim-treesitter-textobjects.select").select_textobject("@block.inner", "textobjects")
			end, { desc = "Select inner language scope" })
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
			multiwindow = false, -- Enable multiwindow support.
			max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
			min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
			line_numbers = true,
			multiline_threshold = 20, -- Maximum number of lines to show for a single context
			trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
			mode = "topline", -- Line used to calculate context. Choices: 'cursor', 'topline'
			-- Separator between context and content. Should be a single character string, like '-'.
			-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
			separator = nil,
			zindex = 20, -- The Z-index of the context window
			on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
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
	{
		dir = (vim.env.GHOSTTY_RESOURCES_DIR or "") .. "/../vim/vimfiles",
		lazy = false, -- Ensures it loads for Ghostty config detection
		name = "ghostty", -- Avoids the name being "vimfiles"
		cond = vim.env.GHOSTTY_RESOURCES_DIR ~= nil, -- Only load if Ghostty is installed
	},

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
			{ "<leader>gd", "<cmd>Gitsigns diffthis<cr>", desc = "Diff this" },
		},
	}, -- git info in the gutter
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
