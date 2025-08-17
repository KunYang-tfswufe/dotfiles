-- init.lua
-- Neovim 配置入口文件

-- =============================================================================
-- 1. lazy.nvim 插件管理器设置
-- =============================================================================
-- 定义 lazy.nvim 的安装路径
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- 如果 lazy.nvim 未安装，则从 GitHub 克隆
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- 使用稳定分支
    lazypath,
  })
end
-- 将 lazy.nvim 添加到运行时路径中
vim.opt.rtp:prepend(lazypath)

-- 使用 lazy.nvim 设置和加载插件
require("lazy").setup({
  -- 模糊查找插件 Telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- ================================================ --
  -- ============ which-key.nvim ============ --
  -- ================================================ --
  -- 这个插件可以在你按下 leader 键后，弹窗提示所有可用快捷键
  {
    'folke/which-key.nvim',
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- 可以在这里进行自定义配置，留空则使用默认值
    }
  },
  -- ================================================ --

  -- GitHub Copilot 插件
  {
    'github/copilot.vim',
  },

  -- Git 状态行提示插件 Gitsigns
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          map('n', ']c', function() if vim.wo.diff then return ']c' end vim.schedule(function() gs.next_hunk() end) return '<Ignore>' end, { expr = true, desc = '🐙 跳转到下一个 Git Hunk' })
          map('n', '[c', function() if vim.wo.diff then return '[c' end vim.schedule(function() gs.prev_hunk() end) return '<Ignore>' end, { expr = true, desc = '🐙 跳转到上一个 Git Hunk' })
          map('n', '<leader>hs', gs.stage_hunk, { desc = '🐙 Git: 暂存当前 Hunk' })
          map('n', '<leader>hr', gs.reset_hunk, { desc = '🐙 Git: 重置当前 Hunk' })
          map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = '🐙 Git: 暂存选中区域' })
          map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = '🐙 Git: 重置选中区域' })
          map('n', '<leader>hp', gs.preview_hunk, { desc = '🐙 Git: 预览 Hunk 内容' })
          map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { desc = '🐙 Git: 显示当前行 Blame' })
        end
      })
    end
  },

  -- Lazygit 终端界面集成
  {
    'kdheepak/lazygit.nvim',
    cmd = { "LazyGit" },
  },

  -- LSP (语言服务器协议) 快速配置方案 lsp-zero
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    dependencies = {
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'saadparwaiz1/cmp_luasnip'},
      {'L3MON4D3/LuaSnip'},
    },
    config = function()
        local lsp_zero = require('lsp-zero')
        lsp_zero.on_attach(function(client, bufnr)
            local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = '💡 LSP: ' .. desc })
            end
            map('n', 'gd', vim.lsp.buf.definition, '跳转到定义')
            map('n', 'gD', vim.lsp.buf.declaration, '跳转到声明')
            map('n', 'K', vim.lsp.buf.hover, '悬浮提示')
            map('n', 'gi', vim.lsp.buf.implementation, '跳转到实现')
            map('n', 'gr', vim.lsp.buf.references, '查找引用')
            map('n', '<leader>ca', vim.lsp.buf.code_action, '代码操作')
            map('n', '<leader>rn', vim.lsp.buf.rename, '重命名')
            map({ 'n', 'v' }, '<leader>df', vim.diagnostic.open_float, '🩺 显示诊断信息')
        end)
        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = {
                -- 已删除 jdtls, tsserver, html, cssls
                'clangd', 'rust_analyzer', 'jsonls',
                'bashls', 'yamlls', 'taplo', 'gopls', 'lua_ls', 'pyright'
            },
            handlers = { lsp_zero.default_setup },
        })
        local cmp = require('cmp')
        cmp.setup({
            sources = {{name = 'nvim_lsp'}, {name = 'luasnip'}, {name = 'buffer'}, {name = 'path'}},
            snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
            mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ['<C-Space>'] = cmp.mapping.complete(),
            }),
        })
    end
  }
})

-- =============================================================================
-- 2. 通用编辑器选项
-- =============================================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.wrap = false
vim.opt.mouse = 'a'
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.undofile = true
vim.o.termguicolors = true

-- =============================================================================
-- 3. 全局变量和快捷键
-- =============================================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set({'n', 'v', 'i'}, '<Up>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Down>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Left>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Right>', '<Nop>')

-- Lazygit 快捷键
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = '🐙 打开 Lazygit' })

-- Telescope 快捷键
vim.keymap.set('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>",  { desc = '🔭 查找文件' })
vim.keymap.set('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>",   { desc = '🔭 全文搜索' })
vim.keymap.set('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>",     { desc = '🔭 查找缓冲区' })
vim.keymap.set('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>",   { desc = '🔭 查找帮助文档' })


-- 诊断信息导航 (LSP Diagnostics)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "🩺 跳转到上一个诊断信息" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "🩺 跳转到下一个诊断信息" })

-- =============================================================================
-- 4. 配色方案
-- =============================================================================
vim.cmd('colorscheme vim')
