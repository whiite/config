local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- Have packer manage itself
  use "wbthomason/packer.nvim"


  -- Plugin installs --
  use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
  use "nvim-lua/plenary.nvim" -- Useful lua functions used lots of plugins
  use "windwp/nvim-autopairs" -- Autopairs, integrates with both cmp and treesitter
  use {
	"numToStr/Comment.nvim", -- Easily comment stuff
	requires = {
		'JoosepAlviste/nvim-ts-context-commentstring'
	}
  }
  use {
  	'nvim-lualine/lualine.nvim',
  	requires = { 'kyazdani42/nvim-web-devicons' }
  }
  use {
	'akinsho/bufferline.nvim', -- Pretty tab bar
	tag = "v2.*",
	requires = {
		'kyazdani42/nvim-web-devicons',
		"moll/vim-bbye" -- Bbye allows you to do delete buffers (close files) without closing your windows or messing up your layout.
	}
  }
  use "akinsho/toggleterm.nvim"

  -- Colorschemes
  use "lunarvim/colorschemes" -- A bunch of colorschemes to try out
  use "folke/tokyonight.nvim"

  -- Prettier UI
  use "lukas-reineke/indent-blankline.nvim" -- Indent guides and invisible character support
  use "norcalli/nvim-colorizer.lua"

  -- cmp plugins
  use {
	"hrsh7th/nvim-cmp", -- The completion plugin
	requires = {
	  "hrsh7th/cmp-buffer", -- buffer completions
	  "hrsh7th/cmp-path", -- path completions
	  "hrsh7th/cmp-cmdline", -- cmdline completions
	  "saadparwaiz1/cmp_luasnip", -- snippet completions
	  "hrsh7th/cmp-nvim-lsp", -- LSP completions
	  "hrsh7th/cmp-nvim-lua", -- Neovim completions for lua
	}
  }

  -- snippets
  use "L3MON4D3/LuaSnip" --snippet engine
  use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

  -- LSP
  use "neovim/nvim-lspconfig" -- enable LSP
  use "williamboman/nvim-lsp-installer" -- simple to use language server installer
  use {
	'filipdutescu/renamer.nvim',
	branch = 'master',
	requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Telescope
  use {
  	'nvim-telescope/telescope.nvim', -- fuzzy file/text finder UI
  	requires = {
		{'nvim-lua/plenary.nvim'},
		-- extensions
		{'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
	}
  }

  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
	requires = {
		-- extensions
		{"p00f/nvim-ts-rainbow"}, -- rainbow parenthesis
		-- {"nvim-treesitter/playground"}, -- useful for creating parsers/extensions
		{'JoosepAlviste/nvim-ts-context-commentstring'}
	}
  }

  -- Git
  use 'lewis6991/gitsigns.nvim' -- git info in the gutter (like VSCode)

  -- File explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
    	'kyazdani42/nvim-web-devicons', -- file icons
    }
  }



  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
