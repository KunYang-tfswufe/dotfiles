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
    {
        'folke/tokyonight.nvim',
        priority = 1000,
        opts = {
            on_colors = function(colors)
                colors.bg = "#000000"
            end,
        },
    },
    -- ================================================ --

    -- ================================================ --
    -- ================ nvim-treesitter =============== --
    -- ================================================ --
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter.configs').setup({
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query",
                    "rust", "python", "json", "bash", "yaml", "toml", "markdown", "markdown_inline"
                },
                sync_install = false,
                auto_install = true,
                highlight = {
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

    -- 快捷键提示插件: which-key.nvim
    {
        'folke/which-key.nvim',
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {},
    },

    -- GitHub Copilot 插件
    {
        'github/copilot.vim',
        init = function()
            vim.g.copilot_enabled = 1
        end,
    },

    -- Git 状态指示插件: Gitsigns
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    },

    -- 通用格式化插件: conform.nvim
    {
        'stevearc/conform.nvim',
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                markdown = { "prettier" },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        },
    },

    -- ================================================ --
    -- =========== [新增] 终端管理插件 =========== --
    -- ================================================ --
    -- 插件: toggleterm.nvim
    -- 功能: 优雅地管理终端窗口，用于实现 Glow 浮动预览
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        opts = {
            -- 在这里可以配置 toggleterm 的默认行为
            direction = 'float',  -- 默认打开浮动窗口
            open_mapping = [[<c-\>]], -- 设置一个全局的终端切换键
        }
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

-- =============================================================================
-- [新增] Glow 预览功能函数
-- =============================================================================
-- 定义一个全局函数，用于在浮动终端中用 Glow 预览当前文件
function _G.GlowPreview()
    -- 检查 toggleterm 是否已加载
    if not pcall(require, 'toggleterm') then
        print("Toggleterm not loaded")
        return
    end

    -- 构建 glow 命令，使用 %:p 来获取当前文件的完整路径
    local command = 'glow ' .. vim.fn.expand('%:p')

    -- 创建一个新的 toggleterm 终端实例
    local term = require('toggleterm.terminal').Terminal:new({
        cmd = command,
        direction = 'float', -- 确保是浮动窗口
        hidden = true,   -- 创建时不显示
        on_close = function(t)
            -- 当终端关闭时，删除其对应的 Neovim 缓冲区
            vim.cmd('bdelete! ' .. t.bufnr)
        end
    })

    -- 打开或切换该终端
    term:toggle()
end

-- Copilot 切换函数
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
vim.keymap.set({ 'n', 'v', 'i' }, '<Down>', 'nop')
vim.keymap.set({ 'n', 'v', 'i' }, '<Left>', '<Nop>')
vim.keymap.set({ 'n', 'v', 'i' }, '<Right>', '<Nop>')

-- Telescope 快捷键
vim.keymap.set('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>", { desc = '查找文件' })
vim.keymap.set('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = '全局文本搜索' })
vim.keymap.set('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = '查找缓冲区' })
vim.keymap.set('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = '查找帮助文档' })

-- Copilot 开关快捷键
vim.keymap.set('n', '<leader>ct', '<cmd>lua _G.toggle_copilot()<cr>', { desc = '切换 Copilot' })

-- LSP 诊断功能快捷键
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "上一个诊断" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "下一个诊断" })

-- 手动格式化快捷键
vim.keymap.set({ "n", "v" }, "<leader>fm",
    function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "格式化文件" })

-- -----------------------------------------------------------------------------
-- [新增] Glow 预览快捷键
-- -----------------------------------------------------------------------------
-- 在 Normal 模式下，按下 <leader>pv (Preview View) 来调用 Glow 预览函数
vim.keymap.set("n", "<leader>pv", "<cmd>lua _G.GlowPreview()<CR>", { desc = "预览 Markdown (Glow)" })
-- -----------------------------------------------------------------------------

-- 实用的快捷键增强
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
