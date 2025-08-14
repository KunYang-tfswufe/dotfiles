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

  -- GitHub Copilot 插件 (按您的要求保留)
  {
    'github/copilot.vim',
  },

  -- Git 状态行提示插件 Gitsigns
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        -- on_attach 会在 gitsigns 加载到缓冲区时运行，用于设置快捷键
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          -- 定义一个局部函数来简化快捷键映射
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- 跳转到上/下一个 git hunk
          map('n', ']c', function()
            -- 如果在 diff 模式下，保留原生 ]c 功能
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = '跳转到下一个 Git Hunk' })

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true, desc = '跳转到上一个 Git Hunk' })

          -- Hunk 操作
          map('n', '<leader>hs', gs.stage_hunk, { desc = 'Git: 暂存当前 Hunk' })
          map('n', '<leader>hr', gs.reset_hunk, { desc = 'Git: 重置当前 Hunk' })
          map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = 'Git: 暂存选中区域' })
          map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = 'Git: 重置选中区域' })
          map('n', '<leader>hp', gs.preview_hunk, { desc = 'Git: 预览 Hunk 内容' })
          map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { desc = 'Git: 显示当前行 Blame' })
        end
      })
    end
  },

  -- Lazygit 终端界面集成
  {
    'kdheepak/lazygit.nvim',
    -- 仅在执行 "LazyGit" 命令时才加载此插件
    cmd = { "LazyGit" },
  },

  -- LSP (语言服务器协议) 快速配置方案 lsp-zero
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x', -- 锁定在 v3.x 大版本以保证稳定
    dependencies = {
      -- LSP 核心配置
      {'neovim/nvim-lspconfig'},
      -- LSP 服务自动安装和管理
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},
      -- 自动补全引擎
      {'hrsh7th/nvim-cmp'},
      -- 补全源
      {'hrsh7th/cmp-nvim-lsp'},      -- LSP 来源
      {'hrsh7th/cmp-buffer'},      -- 当前缓冲区文本来源
      {'hrsh7th/cmp-path'},        -- 文件路径来源
      {'saadparwaiz1/cmp_luasnip'},-- 代码片段来源
      -- 代码片段引擎
      {'L3MON4D3/LuaSnip'},
    },
    config = function()
        local lsp_zero = require('lsp-zero')
        -- LSP 客户端 attach 到缓冲区时执行的回调
        lsp_zero.on_attach(function(client, bufnr)
            -- 定义一个局部函数来简化 LSP 快捷键映射
            local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = 'LSP: ' .. desc })
            end
            -- 设置常用 LSP 功能的快捷键
            map('n', 'gd', vim.lsp.buf.definition, '跳转到定义')
            map('n', 'gD', vim.lsp.buf.declaration, '跳转到声明')
            map('n', 'K', vim.lsp.buf.hover, '悬浮提示')
            map('n', 'gi', vim.lsp.buf.implementation, '跳转到实现')
            map('n', 'gr', vim.lsp.buf.references, '查找引用')
            map('n', '<leader>ca', vim.lsp.buf.code_action, '代码操作')
            map('n', '<leader>rn', vim.lsp.buf.rename, '重命名')
            map({ 'n', 'v' }, '<leader>df', vim.diagnostic.open_float, '显示诊断信息')
        end)

        -- 初始化 Mason，用于管理 LSP 服务器、Linter 等
        require('mason').setup({})
        -- 初始化 mason-lspconfig，它负责将 Mason 和 nvim-lspconfig 连接起来
        require('mason-lspconfig').setup({
            -- 确保这些 LSP 服务器已安装
            ensure_installed = {'tsserver','pyright','gopls','rust_analyzer','lua_ls'},
            -- 设置 lsp-zero 为默认的 LSP 服务器配置处理器
            handlers = { lsp_zero.default_setup },
        })

        -- 配置 nvim-cmp 自动补全
        local cmp = require('cmp')
        cmp.setup({
            -- 配置补全源
            sources = {{name = 'nvim_lsp'}, {name = 'luasnip'}, {name = 'buffer'}, {name = 'path'}},
            -- 配置代码片段引擎
            snippet = {
                expand = function(args) require('luasnip').lsp_expand(args.body) end,
            },
            -- 配置快捷键
            mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = true }), -- 回车键确认选中项
                ['<C-Space>'] = cmp.mapping.complete(), -- Ctrl+Space 触发补全
            }),
        })
    end
  }
})

-- =============================================================================
-- 2. 通用编辑器选项
-- =============================================================================
-- 行号设置
vim.opt.number = true          -- 显示绝对行号
vim.opt.relativenumber = true  -- 显示相对行号

-- 缩进设置
vim.opt.tabstop = 4            -- Tab 宽度为 4 个空格
vim.opt.shiftwidth = 4         -- 自动缩进宽度为 4 个空格
vim.opt.expandtab = true       -- 将 Tab 转换为空格
vim.opt.smartindent = true     -- 智能缩进
vim.opt.autoindent = true      -- 自动缩进

-- 界面与行为
vim.opt.wrap = false           -- 关闭自动换行
vim.opt.mouse = 'a'            -- 在所有模式下启用鼠标
-- [已移除] 'syntax enable' 是冗余的，现代 Neovim 默认开启
vim.opt.hlsearch = true        -- 高亮搜索结果
vim.opt.incsearch = true       -- 输入搜索词时即时高亮
vim.opt.undofile = true        -- 启用撤销文件，实现持久化撤销
vim.o.termguicolors = true     -- 启用真彩色，以获得更好的配色方案支持

-- =============================================================================
-- 3. 全局变量和快捷键
-- =============================================================================
-- 设置 Leader 键为空格键，这是推荐的做法
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 禁用方向键，强制使用 hjkl 进行导航（个人习惯）
-- 如果您想使用方向键，请注释掉或删除以下四行
vim.keymap.set({'n', 'v', 'i'}, '<Up>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Down>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Left>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Right>', '<Nop>')

-- Telescope 快捷键
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '查找文件' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '全文搜索' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '查找缓冲区' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '查找帮助文档' })

-- Lazygit 快捷键
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = '打开 Lazygit' })

-- 诊断信息导航 (LSP Diagnostics)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "跳转到上一个诊断信息" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "跳转到下一个诊断信息" })

-- =============================================================================
-- 4. 配色方案
-- =============================================================================
-- 设置配色方案 (按您的要求保留)
vim.cmd('colorscheme vim')
