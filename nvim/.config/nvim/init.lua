-- ==========================================
-- 1. 核心路径与包管理器设置 (Lazy.nvim)
-- ==========================================
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

-- 设置 leader 键 (空格) - 必须在加载插件前设置
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ==========================================
-- 2. 基础设置 (Options)
-- ==========================================
vim.opt.number = true            -- 显示行号
vim.opt.relativenumber = true    -- 显示相对行号
vim.opt.tabstop = 4              -- Tab 宽度
vim.opt.shiftwidth = 4           -- 缩进宽度
vim.opt.expandtab = true         -- 将 Tab 转为空格
vim.opt.smartindent = true       -- 智能缩进
vim.opt.autoindent = true        -- 自动缩进
vim.opt.wrap = false             -- 默认不自动换行
vim.opt.linebreak = true         -- 软换行时不打断单词
vim.opt.showbreak = "↪ "         -- 换行提示符
vim.opt.mouse = "a"              -- 允许鼠标操作
vim.opt.hlsearch = true          -- 高亮搜索结果
vim.opt.incsearch = true         -- 增量搜索
vim.opt.undofile = true          -- 保留撤销历史
vim.opt.termguicolors = true     -- 开启真彩色支持
vim.opt.clipboard = "unnamedplus" -- 使用系统剪切板
vim.opt.updatetime = 300         -- 更新时间 (影响 gitsigns 等刷新速度)
vim.opt.signcolumn = "yes"       -- 始终显示左侧符号列

-- ==========================================
-- 3. 插件管理 (Plugins)
-- ==========================================
require("lazy").setup({
    -- [主题] Tokyonight
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

    -- [文件浏览器] Neo-tree
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                close_if_last_window = true,
                popup_border_style = "rounded",
                enable_git_status = true,
                enable_diagnostics = true,
                filesystem = {
                    filtered_items = {
                        visible = true,
                        hide_dotfiles = false,
                        hide_gitignored = false,
                    },
                    follow_current_file = { enabled = true },
                    use_libuv_file_watcher = true,
                    hijack_netrw_behavior = "open_default",
                },
            })

            -- Neo-tree 专用快捷键
            vim.keymap.set("n", "<leader>ft", ":Neotree toggle<CR>", { desc = "Explorer: Toggle Neo-tree" })
            vim.keymap.set("n", "<leader>bf", ":Neotree buffers<CR>", { desc = "Explorer: Open Buffers" })
            vim.keymap.set("n", "<leader>o", ":Neotree reveal<CR>", { desc = "Explorer: Reveal Current File" })
        end,
    },

    -- [语法高亮] Treesitter
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

    -- [模糊搜索] Telescope
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

    -- [Git 信息] Gitsigns
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
                -- Gitsigns 快捷键
                map("n", "]c", function() if vim.wo.diff then return "]c" end vim.schedule(function() gs.next_hunk() end) return "<Ignore>" end, { expr = true })
                map("n", "[c", function() if vim.wo.diff then return "[c" end vim.schedule(function() gs.prev_hunk() end) return "<Ignore>" end, { expr = true })
                map("n", "<leader>gp", gs.preview_hunk, { desc = "Git: Preview Hunk" })
                map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Git: Blame Line" })
            end,
        },
    },

    -- [Java 开发] nvim-java
    -- 严格按照官方 README 的 lazy.nvim 章节配置
    -- 文档要求 Neovim 0.11.5+
    {
        'nvim-java/nvim-java',
        config = function()
            require('java').setup()
            vim.lsp.enable('jdtls')
        end,
    },
})

-- ==========================================
-- 4. 通用快捷键设置 (Keymaps)
-- ==========================================

-- 移动优化 (处理自动换行时的移动)
vim.keymap.set({ "n", "v" }, "j", "gj")
vim.keymap.set({ "n", "v" }, "k", "gk")

-- 禁用方向键 (强制养成 hjkl 习惯)
vim.keymap.set({ "n", "v", "i" }, "<Up>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Down>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Left>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Right>", "<Nop>")

-- Telescope 快捷键
vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files({ hidden = true }) end, { desc = "Find: Files" })
vim.keymap.set("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "Find: Buffers" })
vim.keymap.set("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "Find: Text (Grep)" })
vim.keymap.set("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "Find: Help" })

-- UI 切换
vim.keymap.set("n", "<leader>uw", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "UI: Toggle Wrap" })
