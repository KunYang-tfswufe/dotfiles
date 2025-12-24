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

-- 自动安装 coc 扩展 (Java 极简版)
-- 移除了 pyright, vimlsp, sh 等非 Java 核心扩展
vim.g.coc_global_extensions = {
    'coc-java',     -- 核心：Eclipse JDT.LS
    'coc-xml',      -- 核心：Maven (pom.xml) 和 MyBatis (mapper.xml) 支持
    'coc-yaml',     -- Spring Boot 配置 (application.yml)
    'coc-json',     -- 通用配置
    'coc-toml',     -- 偶尔用到
    'coc-lua',      -- 维护本配置文件用
    'coc-snippets', -- 代码片段
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
                transparent = true, -- 保持透明
                styles = {
                    sidebars = "transparent",
                    floats = "transparent",
                },
            })
            vim.cmd("colorscheme tokyonight")
        end,
    },
-- Treesitter (语法高亮)
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,    -- 你的设置：强制立即加载
        priority = 1000, 
        build = ":TSUpdate",
        dependencies = {
            -- 明确声明依赖
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        config = function()
            -- 保护性调用：如果 require 失败，不会让整个 nvim 崩溃
            local status, configs = pcall(require, "nvim-treesitter.configs")
            if not status then
                return
            end

            configs.setup({
                -- 优化：移除 python，保留 Java 常用四件套
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query",
                    "java", "xml", "sql", "dockerfile",
                    "json", "bash", "yaml", "toml", "markdown", "markdown_inline",
                },
                sync_install = false,
                auto_install = true,
                highlight = { enable = true },
                
                -- textobjects 配置
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                },
            })
        end,
    }, -- Telescope (模糊搜索)
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    -- 优化：忽略 Java 编译产物和 Git 目录
                    file_ignore_patterns = { "%.git/", "target/", "build/", "node_modules/" },
                },
            })
        end,
    },
    -- Gitsigns (轻量级 Git 集成，只看变动，不操作)
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
    -- [已移除] LazyGit (你要求做减法)
    -- [已移除] auto-save (避免干扰 Java 编译)
    -- [已移除] indent-blankline (视觉减负)
    
    { "tpope/vim-repeat" },
    
    -- Leap (快速跳转，保留以维持高效率)
    {
        "ggandor/leap.nvim",
        event = "VeryLazy",
        dependencies = { "tpope/vim-repeat" },
        config = function()
            local leap = require("leap")
            leap.opts.preview = function(ch0, ch1, ch2)
                return not (ch1:match("%s") or (ch0:match("%a") and ch1:match("%a") and ch2:match("%a")))
            end
            vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)", { desc = "Motion: Leap forward" })
            vim.keymap.set("n", "S", "<Plug>(leap-from-window)", { desc = "Motion: Leap windows" })
        end,
    },
    -- 自动括号插件
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({ map_cr = false })
        end,
    },
    -- Surround (修改环绕字符)
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function() require("nvim-surround").setup({}) end,
    },

    -- ==================== COC.NVIM ====================
    {
        "neoclide/coc.nvim",
        branch = "release",
        config = function()
            local keyset = vim.keymap.set
            local opts = { silent = true, noremap = true, expr = true, replace_keycodes = true }

            -- Tab 键补全选择
            keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
            keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

            -- 回车确认补全
            keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

            function _G.check_back_space()
                local col = vim.fn.col('.') - 1
                return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
            end

            -- LSP 导航
            keyset("n", "gd", "<Plug>(coc-definition)", { silent = true, desc = "LSP: Definition" })
            keyset("n", "gD", "<Plug>(coc-declaration)", { silent = true, desc = "LSP: Declaration" })
            keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true, desc = "LSP: Implementation" })
            keyset("n", "gr", "<Plug>(coc-references)", { silent = true, desc = "LSP: References" })

            -- K 显示文档
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

            -- 重命名、代码操作、格式化
            keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true, desc = "LSP: Rename" })
            keyset("n", "<leader>ca", "<Plug>(coc-codeaction-cursor)", { silent = true, desc = "LSP: Code Action" })
            keyset("x", "<leader>ca", "<Plug>(coc-codeaction-selected)", { silent = true, desc = "LSP: Code Action (Selected)" })
            keyset("n", "<leader>cf", "<Plug>(coc-format)", { silent = true, desc = "Code: Format File" })

            -- 诊断
            keyset("n", "[d", "<Plug>(coc-diagnostic-prev)", { silent = true, desc = "Diagnostic: Prev" })
            keyset("n", "]d", "<Plug>(coc-diagnostic-next)", { silent = true, desc = "Diagnostic: Next" })
            keyset("n", "<leader>e", ":CocList diagnostics<CR>", { silent = true, desc = "LSP: Show Diagnostics List" })

            -- 组织导入 (Java常用)
            keyset("n", "<leader>ci", ":call CocActionAsync('runCommand', 'editor.action.organizeImport')<CR>", { silent = true, desc = "Code: Organize Imports" })
        end
    }
})

-- ==================== 基础选项 ====================
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

-- ==================== 基础快捷键 ====================
vim.keymap.set({ "n", "v" }, "j", "gj", { desc = "Motion: Move down visual" })
vim.keymap.set({ "n", "v" }, "k", "gk", { desc = "Motion: Move up visual" })

-- [保留] 强制禁用方向键 (Hard Mode)
vim.keymap.set({ "n", "v", "i" }, "<Up>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Down>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Left>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<Right>", "<Nop>")

-- Telescope 搜索
vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files({ hidden = true }) end, { desc = "Find: Files" })
vim.keymap.set("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "Find: Buffers" })
vim.keymap.set("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "Find: Text (Grep)" })
vim.keymap.set("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "Find: Help" })

-- UI Toggle
vim.keymap.set("n", "<leader>uw", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "UI: Toggle Wrap" })

-- [已移除] 自定义 M/Q 映射
