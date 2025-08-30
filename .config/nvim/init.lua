vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmatch = true
vim.cmd('filetype plugin indent on')

-- Better indentation settings
vim.opt.tabstop = 4        -- Number of spaces that a <Tab> in the file counts for
vim.opt.softtabstop = 4    -- Number of spaces that a <Tab> counts for while editing
vim.opt.shiftwidth = 4     -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = false  -- Use spaces instead of tabs
vim.opt.autoindent = true  -- Copy indent from current line when starting a new line
vim.opt.smartindent = true -- Smart autoindenting when starting a new line

-- Set <Space> as leader key
vim.g.mapleader = " "
-- Keymap: <leader>pv opens the file explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open directory view" })

vim.g.clipboard = {
	name = 'OSC 52',
	copy = {
		['+'] = require('vim.ui.clipboard.osc52').copy('+'),
		['*'] = require('vim.ui.clipboard.osc52').copy('*'),
	},
	paste = {
		['+'] = require('vim.ui.clipboard.osc52').paste('+'),
		['*'] = require('vim.ui.clipboard.osc52').paste('*'),
	},
}

-- Wrap current line in {/* */}
vim.keymap.set('n', '<leader>we', function()
	local line = vim.api.nvim_get_current_line()
	local new_line = '{/* ' .. line .. ' */}'
	vim.api.nvim_set_current_line(new_line)
end, { desc = 'Wrap line in {/* */}' })

vim.keymap.set('n', '<leader>qe', function()
	local line = vim.api.nvim_get_current_line()
	local new_line = line:gsub('^%s*{/%*%s*(.-)%s*%*/%s*}%s*$', '%1')
	vim.api.nvim_set_current_line(new_line)
end, { desc = 'Remove {/* */} wrapper' })

-- Load Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	print("Lazy.nvim is not installed. Please install it manually.")
end
vim.opt.rtp:prepend(lazypath)



vim.lsp.enable('luals')
vim.lsp.enable('ts_ls')


-- LSP Keymaps
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(event)
		local opts = { buffer = event.buf }

		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', '<leader>f', function()
			vim.lsp.buf.format { async = true }
		end, opts)
	end,
})


-- Plugin setup
require("lazy").setup({
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.8',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			-- Setup telescope
			require('telescope').setup({
				defaults = {
					-- Optional: customize telescope defaults
					prompt_prefix = "🔍 ",
					selection_caret = "➤ ",
					path_display = { "truncate" },
				},
			})

			-- Set up keybindings
			local builtin = require('telescope.builtin')

			-- Leader + f for find files
			vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })

			-- Optional: Additional useful telescope keybinds
			vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })
			vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
			vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find help' })
			vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			require('nvim-treesitter.configs').setup {
				ensure_installed = { 'html', 'javascript', 'typescript', 'tsx', 'css' },
				highlight = { enable = true },
				autotag = { enable = true },
				indent = { enable = true }, -- Enable treesitter-based indentation
			}
		end
	},
	{
		'ThePrimeagen/harpoon',
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()
			-- Basic keymaps
			vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
			vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

			vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
			vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
			vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
			vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
			vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end)
		end,
	},
	{
		'windwp/nvim-ts-autotag',
		dependencies = { 'nvim-treesitter/nvim-treesitter' },
		ft = { 'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
		config = function()
			require('nvim-ts-autotag').setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false
				}
			})
		end
	},
	-- Add auto-pairs for better bracket handling
	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		config = function()
			require('nvim-autopairs').setup({
				disable_filetype = { "TelescopePrompt", "vim" },
				check_ts = true,
				ts_config = {
					lua = { 'string' },
					javascript = { 'template_string' },
					java = false,
				}
			})
		end
	},
	{
		"mason-org/mason.nvim",
		opts = {}
	},
	{
		'rose-pine/neovim',
		name = 'rose-pine',
		config = function()
			vim.cmd('colorscheme rose-pine')
		end
	},
})
