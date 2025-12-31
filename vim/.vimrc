" ==========================================
" 1. 插件管理 (Plugins)
" ==========================================
call plug#begin('~/.vim/plugged')

    " 文件浏览器
    Plug 'preservim/nerdtree'

    " 模糊查找 (Fuzzy Finder)
    " 需先安装 fzf 系统工具
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'

    " Git 集成
    Plug 'tpope/vim-fugitive'       " Git 命令 (:G)
    Plug 'airblade/vim-gitgutter'   " 左侧显示 Git 增删改状态

call plug#end()

" ==========================================
" 2. 基础设置 (Basic Settings)
" ==========================================
set nocompatible            " 关闭 vi 兼容模式
filetype plugin indent on   " 开启文件类型侦测
syntax on                   " 开启基本语法高亮 (但不使用外部主题)

" *** 解决 Git 标记不显示的核心设置 ***
" Vim 默认 4000ms 才刷新一次状态，改为 100ms
set updatetime=100
" 强制显示左侧符号列 (Sign Column)，避免 Git 标记出现时文字抖动
set signcolumn=yes

" 杂项
set wrap                    " 自动换行
set showcmd                 " 显示输入的命令
set wildmenu                " 命令行补全增强
set nobackup                " 不生成备份文件
set noswapfile              " 不生成交换文件

" 搜索设置
set hlsearch                " 高亮搜索结果
set incsearch               " 边输入边搜索
set ignorecase              " 搜索忽略大小写
set smartcase               " 若包含大写则严格匹配

" ==========================================
" 3. 缩进设置 (Indentation)
" ==========================================
set tabstop=4               " Tab 键宽度为 4
set shiftwidth=4            " 自动缩进宽度为 4
set softtabstop=4           " 退格键删除 4 个空格
set expandtab               " 将 Tab 转为空格
set autoindent              " 换行时继承上一行的缩进

" ==========================================
" 4. 剪切板集成 (Clipboard)
" ==========================================
" 允许 Vim 访问系统剪切板
set clipboard+=unnamedplus

" ==========================================
" 5. 持久化撤销 (Persistent Undo)
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
" 6. 禁用方向键 (Hard Mode)
" ==========================================
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

" ==========================================
" 7. 快捷键配置 (Mappings)
" ==========================================
let mapleader=" "

" NERDTree (文件浏览器)
nnoremap <leader>e :NERDTreeToggle<CR>
let NERDTreeQuitOnOpen = 1

" FZF (模糊查找)
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :Rg<CR>

" Git Fugitive
nnoremap <leader>gs :G<CR>

" 快速保存与退出
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" 清除搜索高亮
nnoremap <silent> <Esc> :nohlsearch<CR>
