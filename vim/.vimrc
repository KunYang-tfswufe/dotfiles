" ==========================================
" 1. 插件管理器设置 (vim-plug)
" ==========================================
" 自动安装 vim-plug (如果未安装)
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" 设置 Leader 键 (必须在加载插件前)
let mapleader = " "
let maplocalleader = " "

call plug#begin('~/.vim/plugged')

    " [文件浏览器] NERDTree (替代 Neo-tree)
    Plug 'preservim/nerdtree'
    Plug 'ryanoasis/vim-devicons' " 需要安装 Nerd Fonts

    " [语法高亮] vim-polyglot (替代 Treesitter)
    " Vim 不支持 Treesitter，Polyglot 是最好的语言包合集
    Plug 'sheerun/vim-polyglot'

    " [模糊搜索] CtrlP (替代 Telescope)
    " 纯 Vimscript 实现，开箱即用，无需外部依赖
    Plug 'ctrlpvim/ctrlp.vim'

    " [Git 信息] vim-gitgutter (替代 Gitsigns)
    Plug 'airblade/vim-gitgutter'

call plug#end()

" ==========================================
" 2. 基础设置 (Options)
" ==========================================
set number              " 显示行号
set relativenumber      " 显示相对行号
set tabstop=4           " Tab 宽度
set shiftwidth=4        " 缩进宽度
set expandtab           " 将 Tab 转为空格
set smartindent         " 智能缩进
set autoindent          " 自动缩进
set nowrap              " 默认不自动换行
set linebreak           " 软换行时不打断单词
set showbreak=↪\        " 换行提示符 (注意空格转义)
set mouse=a             " 允许鼠标操作
set hlsearch            " 高亮搜索结果
set incsearch           " 增量搜索
set undofile            " 保留撤销历史
if has('termguicolors')
    set termguicolors   " 开启真彩色支持
endif
set clipboard=unnamedplus " 使用系统剪切板
set updatetime=300      " 更新时间
set signcolumn=yes      " 始终显示左侧符号列

" ==========================================
" 3. 插件配置 (Plugin Configs)
" ==========================================

" --- 配色设置 (使用默认) ---
syntax on
colorscheme default

" --- NERDTree (替代 Neo-tree) ---
" 快捷键映射: <leader>ft 打开/关闭
nnoremap <leader>ft :NERDTreeToggle<CR>
" 映射: <leader>o 定位当前文件
nnoremap <leader>o :NERDTreeFind<CR>
let NERDTreeShowHidden=1

" --- CtrlP (替代 Telescope) ---
" 忽略 git 目录和构建目录
let g:ctrlp_custom_ignore = '\v[\/](\.git|target|build|node_modules)$'
" 快捷键映射: <leader>ff 找文件 (CtrlP 默认是 <C-p>，这里增加一个映射)
nnoremap <leader>ff :CtrlP<CR>
" 快捷键映射: <leader>fb 找 Buffer
nnoremap <leader>fb :CtrlPBuffer<CR>

" --- GitGutter (替代 Gitsigns) ---
" 快捷键跳转 Hunk
nmap ]c <Plug>(GitGutterNextHunk)
nmap [c <Plug>(GitGutterPrevHunk)
" 预览 Hunk
nmap <leader>gp <Plug>(GitGutterPreviewHunk)

" ==========================================
" 4. 通用快捷键设置 (Keymaps)
" ==========================================

" 移动优化 (处理自动换行时的移动)
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

" 禁用方向键 (强制养成 hjkl 习惯)
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

" UI 切换: 自动换行开关
nnoremap <leader>uw :set wrap!<CR>

" 清楚搜索高亮 (Neovim 默认可能有优化，Vim 通常手动清除比较好)
nnoremap <leader>nh :nohlsearch<CR>
