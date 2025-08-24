-- init.lua
-- Neovim configuration entry point

-- =============================================================================
-- 1. lazy.nvim Plugin Manager Setup
-- =============================================================================
-- Define the installation path for lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- If lazy.nvim is not installed, clone it from GitHub
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- Use the stable branch
    lazypath,
  })
end
-- Prepend lazy.nvim to the runtime path
vim.opt.rtp:prepend(lazypath)

-- Setup and load plugins using lazy.nvim
require("lazy").setup({
  -- ================================================ --
  -- =================== Colorscheme ================== --
  -- ================================================ --
  -- Using Tokyo Night and forcing a pure black (#000000) background
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Ensure it loads first
    opts = {
      -- This is the key part to force a pure black background
      on_colors = function(colors)
        colors.bg = "#000000"
      end,
    },
  },
  -- ================================================ --

  -- ================================================ --
  -- =========== nvim-treesitter =========== --
  -- ================================================ --
  -- For better syntax highlighting and more
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate', -- 在安装或更新时自动运行 :TSUpdate 命令
    config = function()
      require('nvim-treesitter.configs').setup({
        -- 你常用的语言解析器列表
        ensure_installed = {
            "c","lua", "vim", "vimdoc", "query",
            "rust", "python","json", "bash", "yaml", "toml",
            "java" -- (新添加)
        },

        -- 同步安装 (仅对 `ensure_installed` 生效)
        sync_install = false,

        -- 当进入文件时，如果缺少解析器则自动安装
        auto_install = true,

        highlight = {
          -- 启用基于 treesitter 的语法高亮
          enable = true,
        },
      })
    end
  },

  -- Fuzzy finder plugin: Telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- ================================================ --
  -- ============ which-key.nvim ============ --
  -- ================================================ --
  -- This plugin displays a popup with available keybindings after pressing the leader key
  {
    'folke/which-key.nvim',
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- Custom options can be configured here; leave empty for defaults
    }
  },
  -- ================================================ --

  -- GitHub Copilot plugin
  {
    'github/copilot.vim',
    init = function()
      -- 设置为 1 表示默认启用
      vim.g.copilot_enabled = 1
    end,
  },

  -- Git status indicators plugin: Gitsigns
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
          map('n', ']c', function() if vim.wo.diff then return ']c' end vim.schedule(function() gs.next_hunk() end) return '<Ignore>' end, { expr = true, desc = 'Git: Jump to next hunk' })
          map('n', '[c', function() if vim.wo.diff then return '[c' end vim.schedule(function() gs.prev_hunk() end) return '<Ignore>' end, { expr = true, desc = 'Git: Jump to previous hunk' })
          map('n', '<leader>hs', gs.stage_hunk, { desc = 'Git: Stage current hunk' })
          map('n', '<leader>hr', gs.reset_hunk, { desc = 'Git: Reset current hunk' })
          map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = 'Git: Stage selected region' })
          map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = 'Git: Reset selected region' })
          map('n', '<leader>hp', gs.preview_hunk, { desc = 'Git: Preview hunk content' })
          map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { desc = 'Git: Blame current line' })
        end
      })
    end
  },

  -- Lazygit terminal UI integration
  {
    'kdheepak/lazygit.nvim',
    cmd = { "LazyGit" },
  },

  -- LSP (Language Server Protocol) quick setup: lsp-zero
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
            map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
            map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
            map('n', 'K', vim.lsp.buf.hover, 'Hover documentation')
            map('n', 'gi', vim.lsp.buf.implementation, 'Go to implementation')
            map('n', 'gr', vim.lsp.buf.references, 'Find references')
            map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code actions')
            map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
            map({ 'n', 'v' }, '<leader>df', vim.diagnostic.open_float, 'Show diagnostics')
        end)
        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = {
                'clangd', 'rust_analyzer', 'jsonls',
                'bashls', 'yamlls', 'taplo', 'gopls', 'lua_ls', 'pyright',
                'jdtls' -- (新添加)
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
  },

  -- ================================================ --
  -- =================== Java (新添加的) ============== --
  -- ================================================ --
  {
    'mfussenegger/nvim-jdtls',
    -- 仅在打开 java 文件时加载，提升启动速度
    ft = { 'java' },
    dependencies = {
      -- nvim-jdtls 需要 nvim-dap 来提供调试功能
      'mfussenegger/nvim-dap',
    },
    config = function()
      -- jdtls 需要知道你的 Java 安装路径。
      -- 以下代码会自动探测常见的安装位置。
      -- 如果探测失败，你需要手动指定 JAVA_HOME, 例如:
      -- local java_home = '/usr/lib/jvm/java-17-openjdk'
      local java_home = vim.fn.environ().JAVA_HOME or (vim.fn.has('mac') and '/usr/libexec/java_home' or nil)
      if java_home == nil and vim.fn.executable('java') == 1 then
        -- 尝试从 'java' 命令的符号链接中解析
        local java_path = vim.fn.resolve(vim.fn.exepath('java'))
        if java_path then
          -- 典型的路径是 /path/to/jdk/bin/java, 我们需要 /path/to/jdk
          java_home = vim.fn.fnamemodify(java_path, ':h:h')
        end
      end
      if java_home == nil then
        print("JAVA_HOME not found. jdtls might not start.")
        return
      end

      -- jdtls 的启动配置
      -- mason 会将 jdtls 安装在 stdpath('data')/mason/packages/jdtls
      local jdtls_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'

      -- 获取项目的根目录 (例如，包含 pom.xml 或 build.gradle 的目录)
      local root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'})
      if root_dir == nil then return end

      -- 项目特定的数据目录，用于存放 jdtls 生成的工作区数据
      local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
      local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

      local config = {
        -- 指定 jdtls 的启动命令
        cmd = {
          java_home .. '/bin/java',
          '-Declipse.application=org.eclipse.jdt.ls.core.id1.application',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Dlog.protocol=true',
          '-Dlog.level=ALL',
          '-Xms1g',
          '--add-modules=ALL-SYSTEM',
          '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
          '--add-opens', 'java.base/java.io=ALL-UNNAMED',
          '--add-opens', 'java.base/java.util=ALL-UNNAMED',
          '-jar', vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
          '-configuration', jdtls_path .. '/config_linux', -- 对于 Archlinux, 这里是 'config_linux'
          '-data', workspace_dir,
        },
        root_dir = root_dir,

        -- 在 LSP 服务器 attach 到 buffer 时运行的回调函数
        on_attach = function(client, bufnr)
          -- 启用 lsp-zero 提供的默认 keymaps
          require('lsp-zero').on_attach(client, bufnr)

          -- 添加 Java 特有的 keymaps
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = 'Java: ' .. desc })
          end
          map('n', '<leader>jo', '<Cmd>JavaOrganizeImports<CR>', 'Organize Imports')
          map('n', '<leader>jt', '<Cmd>JavaTestNearestMethod<CR>', 'Test Nearest Method')
          map('n', '<leader>jT', '<Cmd>JavaTestFile<CR>', 'Test File')
          map('v', '<leader>je', ":'<,'>JavaExtractMethod<CR>", 'Extract Method')
          map('n', '<leader>jc', '<Cmd>JavaCleanUp<CR>', 'Clean Up')
        end,
      }

      -- 启动 jdtls
      require('jdtls').start_or_attach(config)

      -- 调试器 (DAP) 的快捷键
      local dap_map = function(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { silent = true, desc = 'DAP: ' .. desc })
      end
      dap_map('<F5>', require('dap').continue, 'Continue')
      dap_map('<F10>', require('dap').step_over, 'Step Over')
      dap_map('<F11>', require('dap').step_into, 'Step Into')
      dap_map('<F12>', require('dap').step_out, 'Step Out')
      dap_map('<leader>b', require('dap').toggle_breakpoint, 'Toggle Breakpoint')
      dap_map('<leader>B', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, 'Set Conditional Breakpoint')
    end
  },
  -- ================================================ --

})

-- =============================================================================
-- 2. General Editor Options
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

-- 打通系统剪贴板
vim.opt.clipboard = "unnamedplus"

-- =============================================================================
-- 3. Global Variables and Keymaps
-- =============================================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Copilot 切换函数
function _G.toggle_copilot()
  if vim.g.copilot_enabled == 1 then
    vim.cmd('Copilot disable')
    print('Copilot disabled.')
  else
    vim.cmd('Copilot enable')
    print('Copilot enabled.')
  end
end

-- Disable arrow keys for a more disciplined hjkl navigation
vim.keymap.set({'n', 'v', 'i'}, '<Up>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Down>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Left>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Right>', '<Nop>')

-- Lazygit
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = 'Open Lazygit' })

-- Telescope
vim.keymap.set('n', '<leader>ff', "<cmd>lua require('telescope.builtin').find_files()<cr>",  { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>",   { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>",     { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>",   { desc = 'Find help tags' })

-- Copilot 开关
vim.keymap.set('n', '<leader>ct', '<cmd>lua _G.toggle_copilot()<cr>', { desc = 'Toggle Copilot (启用/禁用)' })

-- Diagnostics (LSP)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })

-- -----------------------------------------------------------------------------
-- Pragmatic Keybinding Enhancements
-- -----------------------------------------------------------------------------

-- Fast window (split) navigation
vim.keymap.set('n', '<leader>h', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<leader>l', '<C-w>l', { desc = 'Move to right window' })
vim.keymap.set('n', '<leader>k', '<C-w>k', { desc = 'Move to upper window' })
vim.keymap.set('n', '<leader>j', '<C-w>j', { desc = 'Move to lower window' })

-- Intuitive split creation
vim.keymap.set('n', '<leader>sv', '<C-w>v', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>sh', '<C-w>s', { desc = 'Split window horizontally' })


-- =============================================================================
-- 4. Colorscheme
-- =============================================================================
-- Load the tokyonight colorscheme after setup
vim.cmd('colorscheme tokyonight')
