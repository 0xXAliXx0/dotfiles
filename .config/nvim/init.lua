vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmatch = true
vim.cmd('filetype plugin indent on')

-- Better indentation settings
vim.opt.tabstop = 2        -- Number of spaces that a <Tab> in the file counts for
vim.opt.softtabstop = 2    -- Number of spaces that a <Tab> counts for while editing
vim.opt.shiftwidth = 2     -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true   -- Use spaces instead of tabs
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
vim.keymap.set('n', '<leader>wc', function()
  local line = vim.api.nvim_get_current_line()
  local new_line = '{/* ' .. line .. ' */}'
  vim.api.nvim_set_current_line(new_line)
end, { desc = 'Wrap line in {/* */}' })

-- Load Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("Lazy.nvim is not installed. Please install it manually.")
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup
require("lazy").setup({
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end
  },

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
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = { 'lua_ls', 'html', 'cssls', 'ts_ls', 'tailwindcss', 'emmet_ls' }
      }
    end
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function()
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      
      -- Enhanced HTML LSP setup with better formatting
      lspconfig.html.setup({
        capabilities = capabilities,
        filetypes = { 'html', 'javascriptreact', 'typescriptreact' },
        settings = {
          html = {
            suggest = {
              html5 = true,
            },
            completion = {
              attributeDefaultValue = "doublequotes"
            },
            format = {
              enable = true,
              indentInnerHtml = true,
              indentHandlebars = true,
              insertFinalNewline = true,
              tabSize = 2,
              insertSpaces = true,
              wrapLineLength = 120,
              unformatted = 'wbr',
              contentUnformatted = 'pre,code,textarea',
              endWithNewline = true,
              extraLiners = 'head,body,/html',
              wrapAttributes = 'auto'
            }
          },
        },
      })
      
      -- Add Emmet LSP for better HTML completion
 lspconfig.emmet_ls.setup({
   capabilities = capabilities,
   filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less' },
   init_options = {
     html = {
       options = {
         ["bem.enabled"] = true,
       },
     },
   }
 })
      
      lspconfig.tailwindcss.setup({
        capabilities = capabilities,
        filetypes = { 'html', 'css', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
      })
      
      lspconfig.ts_ls.setup({ capabilities = capabilities })
      lspconfig.cssls.setup({ capabilities = capabilities })
      lspconfig.lua_ls.setup({ capabilities = capabilities })
    end
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
          lua = {'string'},
          javascript = {'template_string'},
          java = false,
        }
      })
    end
  },
  {
    'L3MON4D3/LuaSnip',
    dependencies = { 'rafamadriz/friendly-snippets' },
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()
    end
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      
      cmp.setup({
        completion = {
          completeopt = 'menu,menuone,noinsert',
          keyword_length = 1,
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'luasnip', priority = 750 },
          { name = 'buffer', priority = 500 },
          { name = 'path', priority = 250 },
            -- Add this line to include emmet but with lower priority
          { name = 'emmet_ls', priority = 100 },
        }),
      })
      
      -- Enhanced completion for HTML files
      cmp.setup.filetype('html', {
        sources = cmp.config.sources({
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'luasnip', priority = 750 },
          { name = 'buffer', priority = 500, keyword_length = 2 },
          { name = 'path', priority = 250 },
        })
      })
    end
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    config = function()
      vim.cmd('colorscheme rose-pine')
    end
  },
})

-- File-specific settings for better HTML formatting
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "javascriptreact", "typescriptreact" },
  callback = function()
    -- Set HTML-specific indentation
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = true
    
    -- Enable HTML-specific formatting options
    vim.opt_local.formatoptions:append('r') -- Continue comments when pressing enter
    vim.opt_local.formatoptions:append('o') -- Continue comments when pressing o or O
    
    -- HTML-specific keymaps
    vim.keymap.set('i', '<CR>', function()
      -- Check if we're between HTML tags
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local before = line:sub(1, col)
      local after = line:sub(col + 1)
      
      if before:match('>[^<]*$') and after:match('^[^>]*<') then
        -- We're between tags, add proper indentation
        return '<CR><CR><Up><Tab>'
      else
        return '<CR>'
      end
    end, { buffer = true, desc = 'Smart HTML enter', expr = true })
    
    -- Format current buffer
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, { buffer = true, desc = 'Format HTML' })
    
    -- Auto-format on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = 0,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
})

-- Additional CSS/SCSS specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "css", "scss", "sass" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- JavaScript/TypeScript specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})
