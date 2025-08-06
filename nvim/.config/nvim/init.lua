-- ~/.config/nvim/init.lua

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

require("lazy").setup({
  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- Copilot
  {
    'github/copilot.vim',
    --[[
      插件安装后，需要手动进行一次性设置：
      1. 在 Neovim 中执行命令 :Copilot setup
      2. 根据提示在浏览器中完成 GitHub 设备授权
      (前提：需要拥有一个已激活的 GitHub Copilot 订阅)
    ]]
  },

  -- =======================================================
  -- Git 集成插件
  -- =======================================================

  -- 插件 1: Gitsigns - 在行号旁显示 Git 修改状态
  {
    'lewis6991/gitsigns.nvim',
    -- lazy = false, -- 如果您希望它立即加载
    config = function()
      require('gitsigns').setup({
        -- signs = { ... } -- 这里可以自定义标记符号，默认已经很好
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- 在代码块 (Hunk) 之间跳转
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

          -- 操作
          map('n', '<leader>hs', gs.stage_hunk, { desc = '暂存当前 Hunk (Git Stage)' })
          map('n', '<leader>hr', gs.reset_hunk, { desc = '重置当前 Hunk (Git Reset)' })
          map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = '暂存选中区域' })
          map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = '重置选中区域' })
          map('n', '<leader>hp', gs.preview_hunk, { desc = '预览 Hunk 内容' })
          map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { desc = '显示当前行 Git Blame' })
        end
      })
    end
  },

  -- 插件 2: Lazygit - Git 的可视化终端界面
  {
    'kdheepak/lazygit.nvim',
    cmd = { "LazyGit" }, -- 通过命令惰性加载
  },
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

-- =======================================================
-- 按键绑定 (Keymaps)
-- =======================================================
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- 禁用方向键
vim.keymap.set({'n', 'v', 'i'}, '<Up>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Down>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Left>', '<Nop>')
vim.keymap.set({'n', 'v', 'i'}, '<Right>', '<Nop>')

-- Telescope 按键绑定
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '查找文件 (Find Files)' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '全文搜索 (Live Grep)' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '查找缓冲区 (Buffers)' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '查找帮助 (Help Tags)' })

-- Git 插件按键绑定
vim.keymap.set('n', '<leader>gg', '<cmd>LazyGit<cr>', { desc = '打开 Lazygit' })


vim.cmd('colorscheme vim')
