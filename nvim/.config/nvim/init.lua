-- ~/.config/nvim/init.lua

-- =======================================================
-- 插件管理器: Lazy.nvim
-- =======================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =======================================================
-- 插件列表与配置
-- =======================================================
require("lazy").setup({
  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- Copilot (保持默认，无任何配置)
  {
    'github/copilot.vim',
  },

  -- =======================================================
  -- Git 集成插件
  -- =======================================================
  -- Gitsigns
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
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = '跳转到下一个 Git Hunk' })

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = '跳转到上一个 Git Hunk' })

          map('n', '<leader>hs', gs.stage_hunk, { desc = '暂存当前 Hunk' })
          map('n', '<leader>hr', gs.reset_hunk, { desc = '重置当前 Hunk' })
          map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = '暂存选中区域' })
          map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = '重置选中区域' })
          map('n', '<leader>hp', gs.preview_hunk, { desc = '预览 Hunk 内容' })
          map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { desc = '显示当前行 Blame' })
        end
      })
    end
  },
  -- Lazygit
  {
    'kdheepak/lazygit.nvim',
    cmd = { "LazyGit" },
  },

  -- =======================================================
  -- LSP (语言服务器协议) 和自动补全
  -- =======================================================
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
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = 'LSP: ' .. desc })
            end
            map('n', 'gd', vim.lsp.buf.definition, '跳转到定义')
            map('n', 'gD', vim.lsp.buf.declaration, '跳转到声明')
            map('n', 'K', vim.lsp.buf.hover, '悬浮提示')
            map('n', 'gi', vim.lsp.buf.implementation, '跳转到实现')
            map('n', 'gr', vim.lsp.buf.references, '查找引用')
            map('n', '<leader>ca', vim.lsp.buf.code_action, '代码操作')
            map('n', '<leader>rn', vim.lsp.buf.rename, '重命名')
            map({ 'n', 'v' }, '<leader>df', vim.diagnostic.open_float, '显示诊断信息')
        end)
        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = {'tsserver','pyright','gopls','rust_analyzer','lua_ls'},
            handlers = { lsp_zero.default_setup },
        })

        -- =======================================================
        -- ★★★ 终极简化的 nvim-cmp 配置 ★★★
        -- =======================================================
        local cmp = require('cmp')
        cmp.setup({
            sources = {{name = 'nvim_lsp'}, {name = 'luasnip'}, {name = 'buffer'}, {name = 'path'}},
            snippet = {
                expand = function(args) require('luasnip').lsp_expand(args.body) end,
            },
            -- 映射配置：只保留最核心的功能，移除所有冲突项
            mapping = cmp.mapping.preset.insert({
                -- 当你选择了补全项后，按回车进行确认
                ['<CR>'] = cmp.mapping.confirm({ select = true }),

                -- 手动触发补全
                ['<C-Space>'] = cmp.mapping.complete(),

                -- ★★ 不再为 <Tab> 和 <S-Tab> 设置任何映射！★★
                -- 你可以像您发现的那样，直接使用键盘的 ↑ 和 ↓ 来选择项目。
            }),
        })
    end
  }
})

-- =======================================================
-- 通用编辑器设置
-- =======================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.wrap = false
vim.opt.mouse = 'a'
vim.cmd('syntax enable')
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.undofile = true
vim.o.termguicolors = true

-- =======================================================
-- 按键绑定 (Keymaps)
-- =======================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 禁用方向键 (这不影响您在LSP菜单中使用它们)
vim.keymap.set({'n', 'v', 'i'}, '<Up>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Down>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Left>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Right>', '<Nop>')

-- Telescope 按键绑定
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '查找文件' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '全文搜索' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '查找缓冲区' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '查找帮助' })
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = '打开 Lazygit' })

-- diagnostics 导航
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "上一个诊断" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "下一个诊断" })

-- =======================================================
-- 主题与外观
-- =======================================================
vim.cmd('colorscheme vim')
