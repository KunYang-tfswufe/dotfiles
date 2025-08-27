-- init.lua
-- Neovim 配置文件入口
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
        "--branch=stable", -- 使用 stable 分支
        lazypath,
    })
end
-- 将 lazy.nvim 添加到运行时路径 (runtimepath) 的头部
vim.opt.rtp:prepend(lazypath)
-- 使用 lazy.nvim 设置并加载插件
require("lazy").setup({
    -- ================================================ --
    -- =================== 主题方案 =================== --
    -- ================================================ --
    -- 使用 Tokyo Night 主题，并强制设置纯黑 (#000000) 背景
    {
        'folke/tokyonight.nvim',
        priority = 1000, -- 确保它最先加载
        opts = {
            -- on_colors 是一个回调函数，在主题加载颜色时执行
            on_colors = function(colors)
                -- 将背景色强制设置为纯黑色
                colors.bg = "#000000"
            end,
        },
    },
    -- ================================================ --

    -- ================================================ --
    -- ================ nvim-treesitter =============== --
    -- ================================================ --
    -- 提供更优秀、更精准的语法高亮
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate', -- 在安装或更新时自动运行 :TSUpdate 命令
        config = function()
            require('nvim-treesitter.configs').setup({
                -- 需要确保安装的语言解析器列表
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query",
                    "rust", "python", "json", "bash", "yaml", "toml", "markdown", "markdown_inline"
                },
                -- 同步安装解析器 (仅对 `ensure_installed` 列表中的解析器生效)
                sync_install = false,
                -- 当打开文件时，如果对应的解析器未安装，则自动安装
                auto_install = true,
                -- 语法高亮模块
                highlight = {
                    -- 启用基于 treesitter 的语法高亮
                    enable = true,
                },
            })
        end
    },

    -- 模糊搜索插件: Telescope
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },

    -- ================================================ --
    -- ================= which-key.nvim ================ --
    -- ================================================ --
    -- 按下 <leader> 键后，显示一个包含可用快捷键的弹出窗口
    {
        'folke/which-key.nvim',
        event = "VeryLazy", -- 延迟加载
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {
            -- 在此配置自定义选项；留空则使用默认值
        }
    },
    -- ================================================ --

    -- GitHub Copilot 插件
    {
        'github/copilot.vim',
        init = function()
            -- 设置为 1 表示默认启用 Copilot
            vim.g.copilot_enabled = 1
        end,
    },

    -- Git 状态指示插件: Gitsigns
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            -- 只需调用 setup() 即可启用左侧的 Git 状态标记，无需任何额外参数
            require('gitsigns').setup()
        end
    },

    -- ================================================ --
    -- =========== [新增] 通用格式化插件 =========== --
    -- ================================================ --
    -- 插件: conform.nvim
    -- 功能: 一个轻量、高效的格式化插件，通过外部工具格式化代码
    {
        'stevearc/conform.nvim',
        event = { "BufWritePre" }, -- 在写入文件前触发
        cmd = { "ConformInfo" },
        opts = {
            -- 定义不同文件类型的格式化工具
            -- 提示: 你需要确保这些工具已经在你的系统上安装
            -- 例如: sudo pacman -S stylua, sudo npm install -g prettier
            formatters_by_ft = {
                lua = { "stylua" },
                markdown = { "prettier" },
                -- 你可以在这里为其他语言添加格式化工具
                -- python = { "black" },
                -- rust = { "rustfmt" },
            },
            -- 设置保存时自动格式化
            format_on_save = {
                -- 等待 500 毫秒，避免过于频繁的格式化
                timeout_ms = 500,
                -- 使用 LSP 客户端的格式化能力作为备选
                lsp_fallback = true,
            },
        },
    },
    -- ================================================ --

    -- LSP (语言服务器协议) 快速配置: lsp-zero
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'L3MON4D3/LuaSnip' },
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            lsp_zero.on_attach(function(client, bufnr)
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs,
                        { buffer = bufnr, noremap = true, silent = true, desc = 'LSP: ' .. desc })
                end
                map('n', 'gd', vim.lsp.buf.definition, '跳转到定义')
                map('n', 'gD', vim.lsp.buf.declaration, '跳转到声明')
                map('n', 'K', vim.lsp.buf.hover, '显示悬浮文档')
                map('n', 'gi', vim.lsp.buf.implementation, '跳转到实现')
                map('n', 'gr', vim.lsp.buf.references, '查找引用')
                map('n', '<leader>ca', vim.lsp.buf.code_action, '代码操作')
                map('n', '<leader>rn', vim.lsp.buf.rename, '重命名符号')
                map({ 'n', 'v' }, '<leader>df', vim.diagnostic.open_float, '显示诊断信息')
            end)
            require('mason').setup({})
            require('mason-lspconfig').setup({
                ensure_installed = {
                    'rust_analyzer', 'jsonls',
                    'bashls', 'yamlls', 'taplo', 'gopls', 'lua_ls', 'pyright'
                },
                handlers = { lsp_zero.default_setup },
            })
            local cmp = require('cmp')
            cmp.setup({
                sources = { { name = 'nvim_lsp' }, { name = 'luasnip' }, { name = 'buffer' }, { name = 'path' } },
                snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<C-Space>'] = cmp.mapping.complete(),
                }),
            })
        end
    },

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
vim.opt.clipboard = "unnamedplus"

-- =============================================================================
-- 3. 全局变量与快捷键映射
-- =============================================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

function _G.toggle_copilot()
    if vim.g.copilot_enabled == 1 then
        vim.cmd('Copilot disable')
        print('Copilot 已禁用。')
    else
        vim.cmd('Copilot enable')
        print('Copilot 已启用。')
    end
end

vim.keymap.set({ 'n', 'v', 'i' }, '<Up>', '<Nop>')
vim.keymap.set({ 'n', 'v', 'i' }, '<Down>', '<Nop>')
vim.keymap.set({ 'n', 'v', 'i' }, '<Left>', '<Nop>')
vim.keymap.set({ 'n', 'v', 'i' }, '<Right>', '<Nop>')

-- Telescope 快捷键
vim.keymap.set('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", { desc = '查找文件' })
vim.keymap.set('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = '全局文本搜索' })
vim.keymap.set('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = '查找缓冲区' })
vim.keymap.set('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = '查找帮助文档' })

-- Copilot 开关快捷键
vim.keymap.set('n', '<leader>ct', '<cmd>lua _G.toggle_copilot()<cr>', { desc = '切换 Copilot (启用/禁用)' })

-- LSP 诊断功能快捷键
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "跳转到上一个诊断" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "跳转到下一个诊断" })

-- -----------------------------------------------------------------------------
-- [新增] 手动格式化快捷键
-- -----------------------------------------------------------------------------
vim.keymap.set({ "n", "v" }, "<leader>fm", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "格式化文件" })
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- 实用的快捷键增强
-- -----------------------------------------------------------------------------
vim.keymap.set('n', '<leader>h', '<C-w>h', { desc = '移动到左侧窗口' })
vim.keymap.set('n', '<leader>l', '<C-w>l', { desc = '移动到右侧窗口' })
vim.keymap.set('n', '<leader>k', '<C-w>k', { desc = '移动到上方窗口' })
vim.keymap.set('n', '<leader>j', '<C-w>j', { desc = '移动到下方窗口' })
vim.keymap.set('n', '<leader>sv', '<C-w>v', { desc = '垂直分割窗口' })
vim.keymap.set('n', '<leader>sh', '<C-w>s', { desc = '水平分割窗口' })


-- =============================================================================
-- 4. 应用主题方案
-- =============================================================================
vim.cmd('colorscheme tokyonight')
