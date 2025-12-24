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

-- 优化：只保留 Java 生态相关的核心扩展
-- 移除了 pyright, vimlsp, sh
vim.g.coc_global_extensions = {
    'coc-java',     -- 核心
    'coc-xml',      -- 新增：Maven/Mybatis 必备
    'coc-yaml',     -- Spring Boot 配置
    'coc-json',     -- 通用配置
    'coc-toml',     -- 偶尔用到
    'coc-lua',      -- 维护本配置文件用
    'coc-snippets', -- 代码片段
    -- 'coc-prettier' -- 可选：如果你不写前端代码，这个也可以注释掉，用 IDEA 或 CLI 格式化
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
        build = ":TSUpdate",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        config = function()
            require("nvim-treesitter.configs").setup({
                -- 优化：移除 python，添加 java 常用关联语言
                ensure_installed = {
                    "lua", "vim", "vimdoc", "query", 
                    "java", "xml", "sql", "dockerfile", -- Java 程序员四件套
                    "json", "bash", "yaml", "toml", "markdown", "markdown_inline",
                },
                sync_install = false,
                auto_install = true,
                highlight = { enable = true },
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
    },
    -- Telescope (模糊搜索)
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    -- 优化：忽略 Java 编译目录
                    file_ignore_patterns = { "%.git/", "target/", "build/", "node_modules/" },
                },
            })
        end,
    },
    -- Gitsigns (Git 集成) - 保持不变，轻量且好用
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
                map("n", "<leader>gp", gs.preview_hunk)
                map("n", "<leader>gb", function() gs.blame_line({ full = true }) end)
            end,
        },
    },
    -- LazyGit - 你的重型 Git 工具
    {
        "kdheepak/lazygit.nvim",
        cmd = { "LazyGit" }, -- 懒加载
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Git: LazyGit" } }
    },
    -- 移除 auto-save (Java 编译杀手)
    -- 移除 indent-blankline (减少视觉噪音)
    
    -- Leap (高效跳转) - 如果你习惯了就留着，这是提升效率的，不算bloat
    {
        "ggandor/leap.nvim",
        event = "VeryLazy",
        dependencies = { "tpope/vim-repeat" },
        config = function()
            local leap = require("leap")
            -- 保持你原有的配置
            leap.opts.preview = function(ch0, ch1, ch2)
                return not (ch1:match("%s") or (ch0:match("%a") and ch1:match("%a") and ch2:match("%a")))
            end
            vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)", { desc = "Motion: Leap forward" })
            vim.keymap.set("n", "S", "<Plug>(leap-from-window)", { desc = "Motion: Leap windows" })
        end,
    },
    -- 自动括号
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function() require("nvim-autopairs").setup({ map_cr = false }) end,
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

            -- Tab 和 CR 逻辑保持不变
            keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
            keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
            keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

            function _G.check_back_space()
                local col = vim.fn.col('.') - 1
                return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
            end

            -- LSP 核心导航
            keyset("n", "gd", "<Plug>(coc-definition)", { silent = true })
            keyset("n", "gD", "<Plug>(coc-declaration)", { silent = true })
            keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true })
            keyset("n", "gr", "<Plug>(coc-references)", { silent = true })

            -- K 文档
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
            keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', { silent = true })

            -- 重命名、CodeAction、格式化
            keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })
            keyset("n", "<leader>ca", "<Plug>(coc-codeaction-cursor)", { silent = true })
            keyset("x", "<leader>ca", "<Plug>(coc-codeaction-selected)", { silent = true })
            keyset("n", "<leader>cf", "<Plug>(coc-format)", { silent = true })
            
            -- 诊断
            keyset("n", "[d", "<Plug>(coc-diagnostic-prev)", { silent = true })
            keyset("n", "]d", "<Plug>(coc-diagnostic-next)", { silent = true })
            keyset("n", "<leader>e", ":CocList diagnostics<CR>", { silent = true })
            
            -- 优化导入 (Java 常用)
            keyset("n", "<leader>ci", ":call CocActionAsync('runCommand', 'editor.action.organizeImport')<CR>", { silent = true })
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
vim.opt.linebreak = true -- 虽然关了 wrap，但保留这个以防万一手动开启
vim.opt.mouse = "a"
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.undofile = true -- 必须保留，这是撤销历史
vim.o.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.updatetime = 300
vim.opt.signcolumn = "yes"

-- ==================== 基础快捷键 ====================
-- 视觉行移动
vim.keymap.set({ "n", "v" }, "j", "gj")
vim.keymap.set({ "n", "v" }, "k", "gk")

-- [移除] Hard Mode 强制禁用方向键的代码块已被删除 (既然都会了就删掉)

-- Telescope
vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files({ hidden = true }) end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { desc = "Grep" })
vim.keymap.set("n", "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<cr>", { desc = "Help" })

-- UI Toggle
vim.keymap.set("n", "<leader>uw", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "Toggle Wrap" })

-- 你的自定义映射 (保留，这是个人习惯)
vim.keymap.set("n", "M", "daw", { desc = "Delete Word" })
vim.keymap.set("n", "Q", "ciw", { desc = "Change Word" })
