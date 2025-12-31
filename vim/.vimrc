" ==========================================
" 0. 全局设置
" ==========================================
let mapleader=" "

" ==========================================
" 1. 插件管理
" ==========================================
call plug#begin('~/.vim/plugged')

    " 文件浏览器
    Plug 'preservim/nerdtree'

    " 模糊查找
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'

    " Git 集成
    " 保留了 GitGutter (左侧显示增删改)，删除了 Fugitive
    Plug 'airblade/vim-gitgutter'

    " *** 核心修复：Wayland 剪切板原生支持 ***
    " 这个插件会自动配置 g:clipboard 变量，让 y/p 直接调用 wl-copy/wl-paste
    Plug 'jasonccox/vim-wayland-clipboard'

call plug#end()

" ==========================================
" 2. 剪切板集成 (关键设置)
" ==========================================
" 必须开启此选项，才能让 y/p 操作与系统剪切板（unnamedplus）同步
" 配合上面的插件，它会自动走 Wayland 通道，而非 X11
set clipboard+=unnamedplus

" ==========================================
" 3. 基础设置
" ==========================================
set nocompatible
filetype plugin indent on
syntax on

" Git 标记优化 (配合 vim-gitgutter 使用)
set updatetime=100
set signcolumn=yes

" 界面行为
set wrap
set showcmd
set wildmenu
set nobackup
set noswapfile

" 搜索
set hlsearch
set incsearch
set ignorecase
set smartcase


" ==========================================
" 4. 缩进设置
" ==========================================
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent

" ==========================================
" 5. 持久化撤销
" ==========================================
if has("persistent_undo")
    let target_path = expand('~/.vim/undodir')
    if !isdirectory(target_path)
        call mkdir(target_path, "p", 0700)
    endif
    let &undodir = target_path
    set undofile
endif

" ==========================================
" 7. 快捷键配置
" ==========================================
" NERDTree
nnoremap <leader>e :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen = 1

" FZF
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :Rg<CR>

" 常用快捷键
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <silent> <Esc> :nohlsearch<CR>
