" ==========================================
" 1. 插件管理 (Plugins)
" ==========================================
call plug#begin('~/.vim/plugged')

    " 文件浏览器 (File Explorer)
    Plug 'preservim/nerdtree'
    " 显示文件图标 (可选，需要安装 Nerd Fonts)
    Plug 'ryanoasis/vim-devicons'

    " 模糊查找 (Fuzzy Finder)
    " 需要系统先安装 fzf (brew install fzf 或 apt install fzf)
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'

    " Git 集成
    Plug 'tpope/vim-fugitive'       " 也就是 Git 命令行包装器 (:Gstatus, :Gblame)
    Plug 'airblade/vim-gitgutter'   " 在行号旁显示 Git 增删改状态

    " 状态栏美化 (让 Git 分支显示更清晰)
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'

    " 配色方案 (Gruvbox)
    Plug 'morhetz/gruvbox'

call plug#end()

" ==========================================
" 2. 基础设置 (Basic Settings)
" ==========================================
set nocompatible            " 关闭 vi 兼容模式
filetype plugin indent on   " 开启文件类型侦测

" 行号设置
set number                  " 显示绝对行号
set relativenumber          " 显示相对行号 (方便 j/k 跳转)

" 外观与高亮
syntax on                   " 开启语法高亮
set cursorline              " 高亮当前行
set wrap                    " 自动换行
set showcmd                 " 显示输入的命令
set wildmenu                " 命令行补全增强

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
set expandtab               " 将 Tab 转为空格 (推荐)
set autoindent              " 换行时继承上一行的缩进
set smartindent             " 智能缩进

" ==========================================
" 4. 剪切板集成 (Clipboard)
" ==========================================
" 允许 Vim 访问系统剪切板 (+clipboard 特性)
" 在 Linux/Mac 上通常是 unnamedplus，Windows 上是 unnamed
set clipboard+=unnamedplus

" ==========================================
" 5. 持久化撤销 (Persistent Undo)
" ==========================================
" 即使关闭文件再打开，也能撤销之前的修改
if has("persistent_undo")
    let target_path = expand('~/.vim/undodir')
    " 如果目录不存在，自动创建
    if !isdirectory(target_path)
        call mkdir(target_path, "p", 0700)
    endif
    let &undodir = target_path
    set undofile
endif

" ==========================================
" 6. 禁用方向键 (Hard Mode)
" ==========================================
" 强迫自己使用 hjkl，快速建立肌肉记忆
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" 插入模式下也禁用 (强迫先 ESC 再移动)
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

" ==========================================
" 7. 插件与快捷键配置 (Mappings & Configs)
" ==========================================
" 设置 Leader 键为空格 (Space)，按起来更顺手
let mapleader=" "

" --- NERDTree (文件浏览器) ---
" 使用 <Leader> + e 打开/关闭文件树
nnoremap <leader>e :NERDTreeToggle<CR>
" 打开文件后自动关闭 NERDTree
let NERDTreeQuitOnOpen = 1

" --- FZF (模糊查找) ---
" 使用 <Leader> + f 查找当前目录下的文件
nnoremap <leader>f :Files<CR>
" 使用 <Leader> + b 查找已打开的 Buffer
nnoremap <leader>b :Buffers<CR>
" 使用 <Leader> + g 在文件中搜索文本 (需要安装 ripgrep 或 ag)
nnoremap <leader>g :Rg<CR>

" --- Git Fugitive ---
" 使用 <Leader> + gs 查看 Git 状态
nnoremap <leader>gs :G<CR>
" 使用 <Leader> + gb 查看 Git Blame
nnoremap <leader>gb :Gblame<CR>

" --- 快速保存与退出 ---
" <Leader> + w 保存
nnoremap <leader>w :w<CR>
" <Leader> + q 退出
nnoremap <leader>q :q<CR>

" --- 清除搜索高亮 ---
" 按下 Esc 取消高亮
nnoremap <silent> <Esc> :nohlsearch<CR>

" ==========================================
" 8. 主题设置 (Theme)
" ==========================================
set background=dark
try
    colorscheme gruvbox
catch
    colorscheme desert
endtry
