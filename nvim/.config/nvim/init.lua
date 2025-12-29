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

-- 设置 leader 键 (空格)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [已删除] coc_global_extensions 配置

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

    -- Neo-tree (文件资源管理器)
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
                    follow_current_file = {
                        enabled = true,
                    },
                    use_libuv_file_watcher = true,
                    hijack_netrw_behavior = "open_default",
                },
            })

            -- Neo-tree 快捷键设置
            vim.keymap.set("n", "<leader>ft", ":Neotree toggle<CR>", { desc = "Explorer: Toggle Neo-tree" })
            vim.keymap.set("n", "<leader>bf", ":Neotree buffers<CR>", { desc = "Explorer: Open Buffers" })
            vim.keymap.set("n", "<leader>o", ":Neotree reveal<CR>", { desc = "Explorer: Reveal Current File" })
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

    -- [已删除] COC.NVIM 插件块及其快捷键配置
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

vim.keymap.set({ "n", "v" }, "j", "gj")
vim.keymap.set({ "n", "v" }, "k", "gk")

vim.keymap.set({ "n", "v", "i" }, "<Up>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Down>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Left>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Right>", "<Nop>")

vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files({ hidden = true }) end, { desc = "Find: Files" })
vim.keymap.set("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "Find: Buffers" })
vim.keymap.set("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "Find: Text (Grep)" })
vim.keymap.set("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "Find: Help" })
vim.keymap.set("n", "<leader>uw", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "UI: Toggle Wrap" })
