" Copyright (C) 2020 Matthew Marting
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <https://www.gnu.org/licenses/>.

" See 'encoding'.
"
"   Changing this option [. . . .]
"   It should normally be kept at its default value, or set when Vim starts up.
"   [. . . .]
"
"   For GTK+ 2 or later, it is highly recommended to set 'encoding' to "utf-8".
"
set encoding=utf-8

" Append `~/.vim/after/after` to 'runtimepath' for filetype plugins in `~/.vim/after/after/ftplugin`.
"
" To overrule a filetype plugin in `$VIMRUNTIME . '/ftplugin'`, a filetype plugin must be created.
" This is automated with a Makefile.
" The Makefile makes a symbolic link in `~/.vim/after/ftplugin` to `~/.vim/after/ftplugin.vim` for the filetype of each filetype plugin in `$VIMRUNTIME . '/ftplugin'`.
" Thus, these filetype plugins cannot be changed.
" To overrule one of these filetype plugins, another filetype plugin must be created in another directory that is later in 'runtimepath' than `~/.vim/after`.
"
" Initializing vim-plug executes `filetype plugin indent on`, so append `~/.vim/after/after` to 'runtimepath' before initializing vim-plug.
set runtimepath+=~/.vim/after/after

" Prefer option settings specified in modelines.
set modeline

" # "Soft" default option settings
"
" These option settings can be overruled by filetype plugins in `$VIMRUNTIME . '/ftplugin'`.
" Set them before initializing vim-plug.
"
" {

" Most file types use spaces instead of tabs.
set expandtab

" }

" # Plugins
"
" {

packadd! matchit

" Make a shell command with the arguments `arguments`.
"
" Escape each of the arguments.
function! s:MakeCommand(arguments)
  return join(map(a:arguments,
    \ 'shellescape(v:val)'), ' ')
endfunction

" Group a compound shell command `command` so that its order of evaluation cannot be changed.
function! s:GroupCommand(command)
  return '{ ' . a:command . '; }'
endfunction

" Make a compound shell command that executes each command in `commands` only if each of the previous commands returns zero.
function! s:MakeCompoundCommandAnd(commands)
  return s:GroupCommand(join(a:commands, ' && '))
endfunction

" Make a command to install the packages that are named by `package_names`.
function! s:MakeInstallPackagesCommand(package_names)
  let l:arguments =
    \ [
      \ 'sudo',
        \ 'apt-get',
          \ 'install',
    \ ]
    \ +
            \ a:package_names
  return s:MakeCommand(l:arguments)
endfunction

" Install Black
function! Install_Black(info)
  execute '!' . s:MakeInstallPackagesCommand(['python3-venv'])
endfunction

" Install vim-flake8
function! Install_vim_flake8(info)
  execute '!' . s:MakeInstallPackagesCommand(['flake8'])
endfunction

" Get the name of the liblua development files package for the version of Lua for which Vim is compiled.
function! s:GetLibluaPackageName()
  let l:lua_version = luaeval('_VERSION')
  let l:lua_version_major_minor = substitute(l:lua_version, '^Lua ', '', '')
  return 'liblua' . l:lua_version_major_minor . '-dev'
endfunction

" Install color_coded.
function! Install_color_coded(info)
  let l:package_names =
    \ [
      \ 'build-essential',
      \ 'cmake',
      \ 'libclang-3.9-dev',
      \ 'libncurses-dev',
      \ 'libpthread-workqueue-dev',
      \ 'libz-dev',
      \ 'xz-utils',
    \ ]
  let l:package_names += [s:GetLibluaPackageName()]
  let l:commands =
    \ [
      \ s:MakeInstallPackagesCommand(l:package_names),
      \ 'rm -f CMakeCache.txt',
      \ 'cmake .',
      \ 'make',
      \ 'make install',
    \ ]
  execute '!' . s:MakeCompoundCommandAnd(l:commands)
endfunction

" Install YouCompleteMe.
function! Install_YouCompleteMe(info)
  let l:package_names =
    \ [
      \ 'build-essential',
      \ 'cmake',
      \ 'python3-dev',
    \ ]
  let l:commands =
    \ [
      \ s:MakeInstallPackagesCommand(l:package_names),
      \ 'python3 install.py --clangd-completer',
    \ ]
  execute '!' . s:MakeCompoundCommandAnd(l:commands)
endfunction

" Initialize vim-plug.
function! s:Plug()
  call plug#begin('~/.vim/plugged')
  Plug 'morhetz/gruvbox'
  Plug 'tpope/vim-fugitive'
  Plug 'psf/black'
    \,
    \ {
      \ 'branch': 'stable',
      \ 'do': function('Install_Black'),
    \ }
  Plug 'nvie/vim-flake8'
    \,
    \ {
      \ 'do': function('Install_vim_flake8'),
    \ }
  Plug 'rdnetto/YCM-Generator'
    \,
    \ {
      \ 'branch': 'stable',
    \ }
  Plug 'jeaye/color_coded'
    \,
    \ {
      \ 'do': function('Install_color_coded'),
    \ }
  Plug 'Valloric/YouCompleteMe'
    \,
    \ {
      \ 'do': function('Install_YouCompleteMe'),
    \ }
  call plug#end()
endfunction

" Initialize vim-plug.
" If vim-plug is not installed, then install it, and then install all of the packages.
"
" See <https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation>.
if empty(glob('~/.vim/autoload/plug.vim'))
  " vim-plug is not installed.

  " If cURL is not installed, then install it.
  if !executable('curl')
    execute '!' . s:MakeInstallPackagesCommand(['curl'])
  endif

  " Install vim-plug.
  !curl
    "\ See the "Curl Manual".
    "\ 
    "\   [. . . .]
    "\   In normal cases when an HTTP server fails to deliver a document, it returns an HTML document stating so (which often also describes why and more).
    "\   This flag will prevent curl from outputting that and return error 22.
    "\ 
    \ --fail
    "\ 
    "\   [. . .] If the server reports that the requested page has moved to a different location [. . .] this option will make curl redo the request on the new place.
    "\   [. . . .]
    "\ 
    \ --location
    \ --create-dirs --output
      \ ~/.vim/autoload/plug.vim
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  call s:Plug()

  " Install all of the plugins.
  "
  " Without the `--sync` flag, this command would not block.
  PlugInstall --sync
else
  call s:Plug()
endif

" }

" # Appearance
"
" {

set lazyredraw

" ## The screen
"
" {

set termguicolors
set background=light
let g:gruvbox_italic = 0

" Display all "undercurl" text as "underline" text.
"
" As of 2020-02-04, Konsole 17.12.3 does not support "undercurl" text.
let &t_Ce = &t_ue
let &t_Cs = &t_us

colorscheme gruvbox

" }

" ## Columns
"
" {

" YouCompleteMe uses the sign column.
" When a window is split, it looks better for the text in all of the buffers to be aligned.
set signcolumn=yes

set numberwidth=11
set number
set relativenumber

" Disable relative line numbers in insert mode.
augroup insert_norelativenumber
  autocmd!
  autocmd InsertEnter *
    \ setlocal norelativenumber
  autocmd InsertLeave *
    \ setlocal relativenumber
augroup END

" }

" ## Buffers
"
" {

" ### One or more lines
set foldmethod=marker

" ### One line
"
" {

set breakat=\ 	
set linebreak

" Get all of the items in 'breakindentopt'.
function! s:GetBreakindentoptItems()
  return split(&l:breakindentopt, ',')
endfunction

" BreakindentoptItems
"
" {

" private:

" Remove the "shift:{n}" item.
function! s:BreakindentoptItemsFilterShift(breakindentopt_items)
  return filter(a:breakindentopt_items,
    \ 'v:val !~# "shift:.*"')
endfunction

" public:

" Set the "shift:{n}" item's value to `shift`.
function! s:BreakindentoptItemsSetShift(breakindentopt_items, shift)
  return s:BreakindentoptItemsFilterShift(a:breakindentopt_items) +
    \ ['shift:' . a:shift]
endfunction

" }

" Set the value of the "shift:{n}" item in 'breakindentopt' to the effective value of 'shiftwidth'.
function! SetBreakindentoptShiftShiftwidth()
  let l:breakindentopt_items = s:GetBreakindentoptItems()
  let l:breakindentopt_items =
    \ s:BreakindentoptItems
    \SetShift(l:breakindentopt_items, shiftwidth())
  let &l:breakindentopt = join(l:breakindentopt_items)
endfunction

augroup set_shiftwidth_set_breakindentopt_shift_shiftwidth
  autocmd!
  autocmd OptionSet tabstop,shiftwidth
    "\ If the value of 'shiftwidth' is zero, then the effective value of 'shiftwidth' is 'tabstop'.
    \ call SetBreakindentoptShiftShiftwidth()
  autocmd BufWinEnter *
    "\ Processing the modelines may set 'tabstop' or 'shiftwidth'.
    \ call SetBreakindentoptShiftShiftwidth()
augroup END

set breakindent

" }

" ### One word
set spell

" }

" ## Status line
"
" {

" See mode().
let s:mode_text =
  \ {
    \ 'v': 'v',
    \ 'V': 'V',
    \ '': '^V',
    \ 's': 'gh',
    \ 'S': 'gH',
    \ '': 'g^H',
    \ 'i': 'i',
    \ 'R': 'R',
    \ 'Rv': 'gR',
  \ }

" Get a representation of the current mode.
"
" The representation is a string that would be displayed in a buffer if a key sequence that could have entered the current mode were to be inserted into the buffer.
" Note that a literal "CTRL-V" is represented as "^V", and a literal "CTRL-H" is represented as "^H".
"
" If the current mode is normal mode, then this function returns `' '`.
function! GetModeText()
  return get(s:mode_text, mode(), ' ')
endf

" Get a representation of whether the buffer is modified.
"
" If the buffer is modified, then return `'+'`.
" Otherwise, return `' '`.
function! GetIsBufferModifiedText()
  if &modified
    return '+'
  endif
  return ' '
endf

set statusline=

" Align the status line with the number column.
"
" The number column is immediately to the right of the sign column.
" The sign column is the leftmost column.
" The sign column is 2 columns wide.
" Thus, the status line needs to be indented 2 columns.
set statusline+=\ \ 

" Show the cursor column number left-aligned to the number column.
"
" Although
"
"   set numberwidth=11
"
" was executed, the width of the numbers in the number column is 1 column less than 'numberwidth'.
" A space follows the numbers before the buffer text.
" Thus, the width of the cursor column is 10 columns.
set statusline+=%-10.10c

" Indicate the mode.
"
" The widest mode representation is 3 characters wide.
" Note that, if GetModeText() were to return `''`, then this 'statusline' item would not be displayed, so the next 'statusline' item's alignment would change depending on the current mode.
set statusline+=\ %-3.3{GetModeText()}
set noshowmode

" Indicate whether the buffer has been modified.
"
" idem for if GetIsBufferModifiedText() were to return `''`.
set statusline+=\ %-1.1{GetIsBufferModifiedText()}

" Show the file name.
"
" See "filename-modifiers".
"
"   For maximum shortness, use ":~:.".
"
set statusline+=\ %-{expand('%:p:~:.')}

" Add fugitive.vim to the status line.
set statusline+=%=%{fugitive#statusline()}

" Always show the status line.
set laststatus=2

" }

" ## The last line
set showcmd

" }

" # Commands
"
" {

" See 'history'.
"
"   The maximum value is 10000.
"
set history=10000

" See <https://stackoverflow.com/a/7078429>.
cnoremap w!! w !sudo tee >/dev/null %

" This completion mode is most similar to Bash tab completion.
set wildmode=list:longest

" List all of the buffers.
" In anticipation of a buffer command, autocomplete ":b".
nnoremap <Leader><Space> :ls<CR>:b

" }

set nrformats-=octal

set hlsearch
set scrolloff=3
set incsearch

nnoremap 0 g0
nnoremap g0 0
nnoremap ^ g^
nnoremap g^ ^
nnoremap $ g$
nnoremap g$ $
nnoremap k gk
nnoremap gk k
nnoremap j gj
nnoremap gj j
inoremap <Home> <C-O>g0
inoremap <End> <C-O>g$
inoremap <Up> <C-O>gk
inoremap <Down> <C-O>gj
xnoremap 0 g0
xnoremap g0 0
xnoremap ^ g^
xnoremap g^ ^
xnoremap $ g$
xnoremap g$ $
xnoremap k gk
xnoremap gk k
xnoremap j gj
xnoremap gj j

set backspace=indent,eol,start

set mouse=a

let g:black_linelength = 116
