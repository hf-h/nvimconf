--"vim.opt" for editor settings
--"vim.keymap" for key remaping
--"vim.g" is global? idk it has mapleader in it
--"vim.cmd" for vim editor commands

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.tabstop = 2
vim.opt.shiftwidth = 4

vim.g.mapleader = ' '

--Insert mode binds

vim.keymap.set('i', 'jj', '<Esc>')

--Normal mode binds

--Editing
vim.keymap.set('n', '<leader>d', 'dd')

--Project navigation
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

--The package manager "Lazy"
--If the path doesnt excist clone the lazy repo
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
--Slap the path into the run time path
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
		--Color theme
  {
    "folke/tokyonight.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
  },
	{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			config = function () 
				local configs = require("nvim-treesitter.configs")

				configs.setup({
						ensure_installed = { "c", "lua", "vim", "vimdoc" },
						sync_install = false,
						highlight = { enable = true },
						indent = { enable = true },  
					})
			end
	 },
		--Tree sitter
		{
				{
				'nvim-telescope/telescope.nvim', tag = '0.1.3',
					dependencies = { 'nvim-lua/plenary.nvim' }
				}
		}
})

--Key binds post package setup
--Idk of this makes sense

--Telescope binds
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

--Color scheme customization
require("tokyonight").setup({
		style = "moon",
		styles = {
				comments = { italic = true }
		}
})

--Color scheme Init
vim.cmd([[colorscheme tokyonight]])
