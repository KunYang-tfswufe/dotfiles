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

-- 设置 leader 键
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 自动安装 coc 扩展
vim.g.coc_global_extensions = {
    'coc-java',
    'coc-xml',
    'coc-yaml',
    'coc-json',
    'coc-toml',
    'coc-lua',
    'coc-snippets',
}

require("lazy").setup({
    -- 主题
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        lazy = false,
        config = function()
            require("tokyonight").setup({
                style = "storm",
                transparent = true,
                styles = { sidebars = "transparent", floats = "transparent" },
            })
            vim.cmd("colorscheme tokyonight")
        end,
    },

    -- Treesitter (语法高亮)
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" },
        build = ":TSUpdate",
        config = function()
            local status, configs = pcall(require, "nvim-treesitter.configs")
            if not status then return end

            configs.setup({
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query",
                    "java", "xml", "sql", "dockerfile",
                    "json", "bash", "yaml", "toml", "markdown", "markdown_inline",
                },
                sync_install = false,
                auto_install = true,
                highlight = { enable = true },
            })
        end,
    },

    -- Telescope (模糊搜索)
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    file_ignore_patterns = { "%.git/", "target/", "build/", "node_modules/" },
                },
            })
        end,
    },

    -- Nvim Tree (文件资源管理器)
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            -- 禁用 netrw (nvim-tree 推荐设置)
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            require("nvim-tree").setup({
                sort = {
                    sorter = "case_sensitive",
                },
                view = {
                    width = 30,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = false,
                },
            })

            -- 目录树专用快捷键
            -- <leader>t: 打开/关闭目录树
            vim.keymap.set("n", "<leader>t", ":NvimTreeToggle<CR>", { desc = "Explorer: Toggle Tree" })
            -- <leader>tf: 在目录树中定位当前文件
            vim.keymap.set("n", "<leader>tf", ":NvimTreeFindFile<CR>", { desc = "Explorer: Find File" })
        end,
    },

    -- Gitsigns (Git状态提示)
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end
                map("n", "]c", function() if vim.wo.diff then return "]c" end vim.schedule(function() gs.next_hunk() end) return "<Ignore>" end, { expr = true })
                map("n", "[c", function() if vim.wo.diff then return "[c" end vim.schedule(function() gs.prev_hunk() end) return "<Ignore>" end, { expr = true })
                map("n", "<leader>gp", gs.preview_hunk, { desc = "Git: Preview Hunk" })
                map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Git: Blame Line" })
            end,
        },
    },

    -- ==================== Auto Save (自动保存) ====================
    {
        "pocco81/auto-save.nvim",
        config = function()
            require("auto-save").setup({
                enabled = true,
                execution_message = {
                    message = function()
                        return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
                    end,
                    dim = 0.18,
                    cleaning_interval = 1000,
                },
                trigger_events = { "InsertLeave", "TextChanged" },
                condition = function(buf)
                    local fn = vim.fn
                    local utils = require("auto-save.utils.data")
                    if fn.getbufvar(buf, "&modifiable") == 1 and
                       utils.not_in(fn.getbufvar(buf, "&filetype"), {}) then
                        return true
                    end
                    return false
                end,
                write_all_buffers = false,
                debounce_delay = 135,
            })
            -- 快捷键：开关自动保存 <leader>as
            vim.keymap.set("n", "<leader>as", ":ASToggle<CR>", { desc = "System: Toggle Auto Save" })
        end,
    },

    -- ==================== COC.NVIM ====================
    {
        "neoclide/coc.nvim",
        branch = "release",
        config = function()
            local keyset = vim.keymap.set
            local opts = { silent = true, noremap = true, expr = true, replace_keycodes = true }
            keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
            keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
            keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
            function _G.check_back_space()
                local col = vim.fn.col('.') - 1
                return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
            end
            keyset("n", "gd", "<Plug>(coc-definition)", { silent = true, desc = "LSP: Definition" })
            keyset("n", "gD", "<Plug>(coc-declaration)", { silent = true, desc = "LSP: Declaration" })
            keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true, desc = "LSP: Implementation" })
            keyset("n", "gr", "<Plug>(coc-references)", { silent = true, desc = "LSP: References" })
            function _G.show_docs()
                local cw = vim.fn.expand('<cword>')
                if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
                    vim.api.nvim_command('h ' .. cw)
                elseif vim.api.nvim_eval('coc#rpc#ready()') then
                    vim.fn.CocActionAsync('doHover')
                else
                    vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
                end
            end
            keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', { silent = true, desc = "LSP: Hover" })
            keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true, desc = "LSP: Rename" })
            keyset("n", "<leader>ca", "<Plug>(coc-codeaction-cursor)", { silent = true, desc = "LSP: Code Action" })
            keyset("x", "<leader>ca", "<Plug>(coc-codeaction-selected)", { silent = true, desc = "LSP: Code Action (Selected)" })
            keyset("n", "<leader>cf", "<Plug>(coc-format)", { silent = true, desc = "Code: Format File" })
            keyset("n", "[d", "<Plug>(coc-diagnostic-prev)", { silent = true, desc = "Diagnostic: Prev" })
            keyset("n", "]d", "<Plug>(coc-diagnostic-next)", { silent = true, desc = "Diagnostic: Next" })
            keyset("n", "<leader>e", ":CocList diagnostics<CR>", { silent = true, desc = "LSP: Show Diagnostics List" })
            keyset("n", "<leader>ci", ":call CocActionAsync('runCommand', 'editor.action.organizeImport')<CR>", { silent = true, desc = "Code: Organize Imports" })
        end
    }
})

-- 基础设置
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "
vim.opt.mouse = "a"
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.undofile = true
vim.o.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.updatetime = 300
vim.opt.signcolumn = "yes"

-- ==========================================
-- 快捷键设置 (Keymaps)
-- ==========================================

-- 更好的行内移动 (wrap 时)
vim.keymap.set({ "n", "v" }, "j", "gj")
vim.keymap.set({ "n", "v" }, "k", "gk")

-- 禁用方向键 (强制养成肌肉记忆)
vim.keymap.set({ "n", "v", "i" }, "<Up>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Down>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Left>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Right>", "<Nop>")

-- Telescope 搜索
vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files({ hidden = true }) end, { desc = "Find: Files" })
vim.keymap.set("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "Find: Buffers" })
vim.keymap.set("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "Find: Text (Grep)" })
vim.keymap.set("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "Find: Help" })
vim.keymap.set("n", "<leader>uw", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "UI: Toggle Wrap" })

-- 窗口焦点切换
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window: Focus Left" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window: Focus Right" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window: Focus Down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window: Focus Up" })
