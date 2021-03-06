scriptencoding utf-8

"-----------------------------------------------------------------------
" Vim settings file for Ciaran McCreesh
"
" I finally added some comments, so you can have some vague idea of
" what all this does.
"
" Don't just blindly copy this vimrc. There's some rather idiosyncratic
" stuff in here...
"
"-----------------------------------------------------------------------

"-----------------------------------------------------------------------
" terminal setup
"-----------------------------------------------------------------------

" Extra terminal things
if (&term =~ "xterm") && (&termencoding == "")
    set termencoding=utf-8
endif

if &term =~ "xterm"
    " use xterm titles
    if has('title')
        set title
    endif

    " change cursor colour depending upon mode
    if exists('&t_SI')
        let &t_SI = "\<Esc>]12;lightgoldenrod\x7"
        let &t_EI = "\<Esc>]12;grey80\x7"
    endif
endif

"-----------------------------------------------------------------------
" settings
"-----------------------------------------------------------------------

" Don't be compatible with vi
set nocompatible

" pathogen
silent! execute pathogen#infect()

" Enable a nice big viminfo file
set viminfo='1000,f1,:1000,/1000
set history=500

" Make backspace delete lots of things
set backspace=indent,eol,start

" Create backups
set backup

" Show us the command we're typing
set showcmd

" Highlight matching parens
set showmatch

" Search options: incremental search, highlight search
set hlsearch
set incsearch

" Selective case insensitivity
if has("autocmd")
    autocmd BufEnter *
                \ if &filetype == "cpp" || &filetype == "c" || &filetype == "java" || &filetype == "haskell" |
                \     set noignorecase noinfercase |
                \ else |
                \     set ignorecase infercase |
                \ endif
else
    set ignorecase
    set infercase
endif

" Show full tags when doing search completion
set showfulltag

" Speed up macros
set lazyredraw

" No annoying error noises
set noerrorbells
set visualbell t_vb=
if has("autocmd")
    autocmd GUIEnter * set visualbell t_vb=
endif

" Try to show at least three lines and two columns of context when
" scrolling
set scrolloff=3
set sidescrolloff=2

" Wrap on these
set whichwrap+=<,>,[,]

" Use the cool tab complete menu
set wildmenu
set wildignore+=*.o,*~,.lo,*.hi
set suffixes+=.in,.a,.1

" Allow edit buffers to be hidden
set hidden

" 1 height windows
set winminheight=1

" Enable syntax highlighting
if has("syntax")
    syntax on
endif

" enable virtual edit in vblock mode, and one past the end
set virtualedit=block,onemore

" Set our fonts
if has("gui_gtk")
    if hostname() == "snowblower" || hostname() == "snowflex"
        set guifont=Source\ Code\ Pro\ Light\ 16
    elseif hostname() == "snowtea"
        set guifont=Source\ Code\ Pro\ Light\ 20
    elseif hostname() == "padang"
        set guifont=Source\ Code\ Pro\ Medium\ 14
    else
        set guifont=Source\ Code\ Pro\ Light\ 12
    endif
endif

" Try to load a nice colourscheme
if has("eval")
    fun! LoadColourScheme(schemes)
        let l:schemes = a:schemes . ":"
        while l:schemes != ""
            let l:scheme = strpart(l:schemes, 0, stridx(l:schemes, ":"))
            let l:schemes = strpart(l:schemes, stridx(l:schemes, ":") + 1)
            try
                exec "colorscheme" l:scheme
                break
            catch
            endtry
        endwhile
    endfun

    if hostname() == "snowflex"
        set background=dark
    endif
    call LoadColourScheme("bubblegum-256-light:inkpot:elflord")
endif

" No icky toolbar, menu or scrollbars in the GUI
if has('gui')
    set guioptions-=m
    set guioptions-=T
    set guioptions-=l
    set guioptions-=L
    set guioptions-=r
    set guioptions-=R
end

" By default, go for an indent of 4
set shiftwidth=4
set expandtab

" Don't make a # force column zero.
inoremap # X<BS>#

" Enable folds
if has("folding")
    set foldenable
    set foldmethod=manual
    set foldlevelstart=99
endif

" Syntax when printing
set popt+=syntax:y

" Enable filetype settings
if has("eval")
    filetype on
    filetype plugin on
    filetype indent on
endif

" Disable modelines, use securemodelines.vim instead
set nomodeline
let g:secure_modelines_verbose = 0
let g:secure_modelines_modelines = 15
au VimEnter * call filter(exists("g:secure_modelines_allowed_items") ? g:secure_modelines_allowed_items : [],
            \ 'v:val != "fdm" && v:val != "foldmethod"')

" Nice window title
if has('title') && (has('gui_running') || &title)
    set titlestring=
    set titlestring+=%f\                                              " file name
    set titlestring+=%h%m%r%w                                         " flags
    set titlestring+=\ -\ %{v:progname}                               " program name
    set titlestring+=\ -\ %{substitute(getcwd(),\ $HOME,\ '~',\ '')}  " working directory
endif

" Status line
set laststatus=2

" If possible, try to use a narrow number column.
if v:version >= 700
    try
        setlocal numberwidth=3
    catch
    endtry
endif

" If possible and in gvim with inkpot, use cursor row highlighting
if has("gui_running") && v:version >= 700
    set cursorline
end

" Include $HOME in cdpath
if has("file_in_path")
    let &cdpath=','.expand("$HOME").','.expand("$HOME").'/work'
endif

" Better include path handling
set path+=src/
let &inc.=' ["<]'

" Show tabs and trailing whitespace visually
if (&termencoding == "utf-8") || has("gui_running")
    if v:version >= 700
        if has("gui_running")
            set list listchars=tab:»·,trail:·,extends:…,nbsp:‗
        else
            " xterm + terminus hates these
            set list listchars=tab:»·,trail:·,extends:>,nbsp:_
        endif
    else
        set list listchars=tab:»·,trail:·,extends:…
    endif
else
    if v:version >= 700
        set list listchars=tab:>-,trail:.,extends:>,nbsp:_
    else
        set list listchars=tab:>-,trail:.,extends:>
    endif
endif

set fillchars=fold:-

" Filter expected errors from make
if has("eval") && v:version >= 700
    let &makeprg="nice -n7 make -j`sh -c 'nproc \\|\\| echo 2'` 2>&1"

    " ignore libtool links with version-info
    let &errorformat="%-G%.%#libtool%.%#version-info%.%#,".&errorformat

    " ignore doxygen things
    let &errorformat="%-G%.%#Warning: %.%# is not documented.,".&errorformat
    let &errorformat="%-G%.%#Warning: no uniquely matching class member found for%.%#,".&errorformat
    let &errorformat="%-G%.%#Warning: documented function%.%#was not declared or defined.%.%#,".&errorformat

    " paludis things
    let &errorformat="%-G%.%#test_cases::FailTest::run()%.%#,".&errorformat
    let &errorformat="%-G%.%#%\\w%\\+/%\\w%\\+-%[a-zA-Z0-9.%\\-_]%\\+:%\\w%\\+::%\\w%\\+%.%#,".&errorformat
    let &errorformat="%-G%.%#Writing VDB entry to%.%#,".&errorformat
    let &errorformat="%-G%\\(install%\\|upgrade%\\)_TEST> %.%#,".&errorformat

    " catch internal errors
    let &errorformat="%.%#Internal error at %.%# at %f:%l: %m,".&errorformat
endif

"-----------------------------------------------------------------------
" completion
"-----------------------------------------------------------------------
set dictionary=/usr/share/dict/words

"-----------------------------------------------------------------------
" autocmds
"-----------------------------------------------------------------------

if has("eval")

    " If we're in a wide window, enable line numbers.
    fun! <SID>WindowWidth()
        if winwidth(0) > 90
            setlocal foldcolumn=2
            setlocal number
        else
            setlocal nonumber
            setlocal foldcolumn=0
        endif
    endfun

    " Force active window to the top of the screen without losing its
    " size.
    fun! <SID>WindowToTop()
        let l:h=winheight(0)
        wincmd K
        execute "resize" l:h
    endfun

    if v:version >= 700
        fun! <SID>UpdateCopyrightHeaders()
            let l:a = 0
            for l:x in getline(1, 10)
                let l:a = l:a + 1
                if -1 != match(l:x, 'Copyright (c) [- 0-9,]*20\(0[456789]\|1[012]\) Ciaran McCreesh')
                    if input("Update copyright header? (y/N) ") == "y"
                        call setline(l:a, substitute(l:x, '\(20[01][0123456789]\) Ciaran',
                                    \ '\1, 2014 Ciaran', ""))
                    endif
                endif
            endfor
        endfun
    endif
endif

" autocmds
if has("autocmd") && has("eval")
    augroup ciaranm
        autocmd!

        " Automagic line numbers
        autocmd BufEnter * :call <SID>WindowWidth()

        " Always do a full syntax refresh
        autocmd BufEnter * syntax sync fromstart

        " For help files, move them to the top window and make <Return>
        " behave like <C-]> (jump to tag)
        autocmd FileType help :call <SID>WindowToTop()
        autocmd FileType help nmap <buffer> <Return> <C-]>

        " For svn-commit, don't create backups
        autocmd BufRead svn-commit.tmp :setlocal nobackup

        " m4 matchit support
        autocmd FileType m4 :let b:match_words="(:),`:',[:],{:}"

        " bash-completion ftdetects
        autocmd BufNewFile,BufRead /*/*bash*completion*/*
                    \ if expand("<amatch>") !~# "ChangeLog" |
                    \     let b:is_bash = 1 | set filetype=sh |
                    \ endif

        " update copyright headers
        autocmd BufWritePre * call <SID>UpdateCopyrightHeaders()

        try
            " if we have a vim which supports QuickFixCmdPost (vim7),
            " give us an error window after running make, grep etc, but
            " only if results are available.
            autocmd QuickFixCmdPost * botright cwindow 5

            autocmd QuickFixCmdPre make
                        \ let g:make_start_time=localtime()

            let g:paludis_configure_command = "! ./configure --prefix=/usr --sysconfdir=/etc" .
                        \ " --localstatedir=/var/lib --enable-qa " .
                        \ " --enable-ruby --enable-python --enable-vim --enable-bash-completion" .
                        \ " --enable-zsh-completion --with-repositories=all --with-clients=all --with-environments=all" .
                        \ " --enable-visibility --enable-gnu-ldconfig --enable-htmltidy" .
                        \ " --enable-ruby-doc --enable-python-doc --enable-xml --enable-pbins" .
                        \ " --enable-search-index"

            " Similarly, try to automatically run ./configure and / or
            " autogen if necessary.
            autocmd QuickFixCmdPre make
                        \ if ! filereadable('Makefile') |
                        \     if ! filereadable("configure") |
                        \         if filereadable("autogen.bash") |
                        \             exec "! ./autogen.bash" |
                        \         elseif filereadable("quagify.sh") |
                        \             exec "! ./quagify.sh" |
                        \         endif |
                        \     endif |
                        \     if filereadable("configure") |
                        \         if (isdirectory(getcwd() . "/paludis/util")) |
                        \             exec g:paludis_configure_command |
                        \         elseif (match(getcwd(), "libwrapiter") >= 0) |
                        \             exec "! ./configure --prefix=/usr --sysconfdir=/etc" |
                        \         else |
                        \             exec "! ./configure" |
                        \         endif |
                        \     endif |
                        \ endif

            autocmd QuickFixCmdPost make
                        \ let g:make_total_time=localtime() - g:make_start_time |
                        \ echo printf("Time taken: %dm%2.2ds", g:make_total_time / 60,
                        \     g:make_total_time % 60)

            autocmd QuickFixCmdPre *
                        \ let g:old_titlestring=&titlestring |
                        \ let &titlestring="[ " . expand("<amatch>") . " ] " . &titlestring |
                        \ redraw

            autocmd QuickFixCmdPost *
                        \ let &titlestring=g:old_titlestring

            autocmd QuickFixCmdPre make
                        \ let g:active_line=getpid() . " vim:" . substitute(getcwd(), "^.*/", "", "") |
                        \ exec "silent !echo '" . g:active_line . "' >> ~/.config/awesome/active"

            autocmd QuickFixCmdPost make
                        \ exec "silent !sed -i -e '/^" . getpid() . " /d' ~/.config/awesome/active"

        catch
        endtry

        try
            autocmd Syntax *
                        \ syn match VimModelineLine /^.\{-1,}vim:[^:]\{-1,}:.*/ contains=VimModeline |
                        \ syn match VimModeline contained /vim:[^:]\{-1,}:/
            hi def link VimModelineLine comment
            hi def link VimModeline     special
        catch
        endtry
    augroup END
endif

" content creation
if has("autocmd")
    augroup content
        autocmd!

        autocmd BufNewFile *.hs 0put ='-- vim: set sw=4 sts=4 et tw=80 :' |
                    \ set sw=4 sts=4 et tw=80 |
                    \ norm G

        autocmd BufNewFile *.rb 0put ='# vim: set sw=4 sts=4 et tw=80 :' |
                    \ 0put ='#!/usr/bin/ruby' | set sw=4 sts=4 et tw=80 |
                    \ norm G

        autocmd BufNewFile *.hh 0put ='/* vim: set sw=4 sts=4 et foldmethod=syntax : */' |
                    \ 1put ='' | call MakeIncludeGuards() |
                    \ set sw=4 sts=4 et tw=80 | norm G

        autocmd BufNewFile *.cc 0put ='/* vim: set sw=4 sts=4 et foldmethod=syntax : */' |
                    \ 1put ='' | 2put ='' | call setline(3, '#include "' .
                    \ substitute(expand("%:t"), ".cc$", ".hh", "") . '"') |
                    \ set sw=4 sts=4 et tw=80 | norm G

        autocmd BufNewFile *.pml 0put ='/* vim: set sw=4 sts=4 et foldmethod=syntax : */' |
                    \ set sw=4 sts=4 et tw=80 | norm G

        autocmd BufNewFile *.java 0put ='/* vim: set sw=4 sts=4 et foldmethod=syntax : */' |
                    \ 1put ='' |
                    \ set sw=4 sts=4 et tw=80 | norm G
    augroup END
endif

"-----------------------------------------------------------------------
" mappings
"-----------------------------------------------------------------------

" v_K is really really annoying
vmap K k

" K is really really annoying too, and S is pointless
if has("eval")
    fun! SaveLastInsert()
        let l:c = getchar()
        if l:c >= char2nr('a') && l:c <= char2nr('z')
            exec "let @" . nr2char(l:c) . "=substitute(@., '^[\\d23\\d8]\\+', '', '')"
        endif
    endfun

    nmap K :call SaveLastChange()<CR>
    nmap S :call SaveLastInsert()<CR>
endif

" Delete a buffer but keep layout
if has("eval")
    command! Kwbd enew|bw #
    nmap     <C-w>!   :Kwbd<CR>
endif

" Next buffer
nmap <C-w>. :bn<CR>

" quickfix things
nmap <Leader>cwc :cclose<CR>
nmap <Leader>cwo :botright copen 5<CR><C-w>p
nmap <Leader>cn  :cnext<CR>
nmap <Leader>cf  :cnf<CR>
nmap - :cnext<CR>
nmap <Leader>- :cnf<CR>
nmap <Leader>cp  :cprevious<CR>
nmap <Leader>ce  :clast<CR>

" Annoying default mappings
inoremap <S-Up>   <C-o>gk
inoremap <S-Down> <C-o>gj
noremap  <S-Up>   gk
noremap  <S-Down> gj

" <PageUp> and <PageDown> do silly things in normal mode with folds
noremap <PageUp> <C-u>
noremap <PageDown> <C-d>

" Make <space> in normal mode go down a page rather than left a
" character
noremap <space> <C-f>

" Useful things from inside imode
inoremap <C-z>w <C-o>:w<CR>
inoremap <C-z>q <C-o>gq}<C-o>k<C-o>$

fun! GetCurrentTest()
    let l:r = expand("%:p:t:r")
    if match(l:r, '_TEST') == -1
        let l:r = l:r . "_TEST"
    endif
    return l:r
endfun

" Commonly used commands
nmap <silent> <F3> :silent nohlsearch<CR>
imap <silent> <F3> <C-o>:silent nohlsearch<CR>
nmap <F4> :Kwbd<CR>
nmap <F5> <C-w>c
nmap <F6> :exec "make check TESTS_ENVIRONMENT=true LOG_COMPILER=true XFAIL_TESTS="<CR>
nmap <Leader><F6> :exec "make -C " . expand("%:p:h") . " check TESTS_ENVIRONMENT=true LOG_COMPILER=true XFAIL_TESTS="<CR>
nmap <F7> :make all-then-check<CR>
nmap <Leader><F7> :exec "make -C " . expand("%:p:h") . " check"<CR>
nmap <F8> :make<CR>
nmap <Leader><F8> :exec "make -C " . expand("%:p:h")<CR>
nmap <F9> :exec "make -C " . expand("%:p:h") . " check SUBDIRS= check_PROGRAMS=" . GetCurrentTest()
            \ . " TESTS=" . GetCurrentTest() <CR>

" Insert a single char
noremap <Leader>i i<Space><Esc>r

" Split the line
nmap <Leader>n \i<CR>

" Pull the following line to the cursor position
noremap <Leader>J :s/\%#\(.*\)\n\(.*\)/\2\1<CR>

" In normal mode, jj escapes
inoremap jj <Esc>

" Kill line
noremap <C-k> "_dd

" Edit something in the current directory
noremap <Leader>ed :e <C-r>=expand("%:p:h")<CR>/<C-d>

" Select thing just pasted
noremap <Leader>v `[v`]

" Enable fancy % matching
if has("eval")
    runtime! macros/matchit.vim
endif

" q: sucks
nmap q: :q

" * is silly
noremap * :let @/='\<'.expand('<cword>').'\>'<bar>:set hls<CR>
noremap g* :let @/=expand('<cword>')<bar>:set hls<CR>

" set up some more useful digraphs
if has("digraphs")
    digraph ., 8230    " ellipsis (…)
endif

if has("eval")
    " Work out include guard text
    fun! IncludeGuardText()
        let l:p = substitute(substitute(getcwd(), "/trunk", "", ""), '^.*/', "", "")
        let l:t = substitute(expand("%"), "[./]", "_", "g")
        return substitute(toupper(l:p . "_GUARD_" . l:t), "-", "_", "g")
    endfun

    " Make include guards
    fun! MakeIncludeGuards()
        norm gg
        /^$/
        norm 2O
        call setline(line("."), "#ifndef " . IncludeGuardText())
        norm o
        call setline(line("."), "#define " . IncludeGuardText() . " 1")
        norm G
        norm o
        call setline(line("."), "#endif")
    endfun
    noremap <Leader>ig :call MakeIncludeGuards()<CR>
endif

" fast buffer switching
if v:version >= 700 && has("eval")
    let g:switch_header_map = {
                \ 'cc':    'hh',
                \ 'hh':    'cc',
                \ 'c':     'h',
                \ 'h':     'c',
                \ 'cpp':   'hpp',
                \ 'hpp':   'cpp' }

    fun! SwitchTo(f, split) abort
        if ! filereadable(a:f)
            echoerr "File '" . a:f . "' does not exist"
        else
            if a:split
                new
            endif
            if 0 != bufexists(a:f)
                exec ':buffer ' . bufnr(a:f)
            else
                exec ':edit ' . a:f
            endif
        endif
    endfun

    fun! SwitchHeader(split) abort
        let filename = expand("%:p:r")
        let suffix = expand("%:p:e")
        if suffix == ''
            echoerr "Cannot determine header file (no suffix)"
            return
        endif

        let new_suffix = g:switch_header_map[suffix]
        if new_suffix == ''
            echoerr "Don't know how to find the header (suffix is " . suffix . ")"
            return
        end

        call SwitchTo(filename . '.' . new_suffix, a:split)
    endfun

    fun! SwitchTest(split) abort
        let filename = expand("%:p:r")
        let suffix = expand("%:p:e")
        if -1 != match(filename, '_TEST$')
            let new_filename = substitute(filename, '_TEST$', '.' . suffix, '')
        else
            let new_filename = filename . '_TEST.' . suffix
        end
        call SwitchTo(new_filename, a:split)
    endfun

    fun! SwitchMakefile(split) abort
        let dirname = expand("%:p:h")
        if filereadable(dirname . "/Makefile.am.m4")
            call SwitchTo(dirname . "/Makefile.am.m4", a:split)
        elseif filereadable(dirname . "/Makefile.am")
            call SwitchTo(dirname . "/Makefile.am", a:split)
        else
            call SwitchTo(dirname . "/Makefile", a:split)
        endif
    endfun
endif

" super i_c-y / i_c-e
if v:version >= 700 && has("eval")
    fun! SuperYank(offset)
        let l:cursor_pos = col(".")
        let l:this_line = line(".")
        let l:source_line = l:this_line + a:offset
        let l:this_line_text = getline(l:this_line)
        let l:source_line_text = getline(l:source_line)
        let l:add_text = ""

        let l:motion = "" . nr2char(getchar())
        if -1 != match(l:motion, '\d')
            let l:count = 0
            while -1 != match(l:motion, '\d')
                let l:count = l:count * 10 + l:motion
                let l:motion = "" . nr2char(getchar())
            endwhile
        else
            let l:count = 1
        endif

        if l:motion == "$"
            let l:add_text = strpart(l:source_line_text, l:cursor_pos - 1)
        elseif l:motion == "w"
            let l:add_text = strpart(l:source_line_text, l:cursor_pos - 1)
            let l:add_text = substitute(l:add_text,
                        \ '^\(\s*\%(\S\+\s*\)\{,' . l:count . '}\)\?.*', '\1', '')
        elseif l:motion == "f" || l:motion == "t"
            let l:add_text = strpart(l:source_line_text, l:cursor_pos - 1)
            let l:char = nr2char(getchar())
            let l:pos = matchend(l:add_text,
                        \ '^\%([^' . l:char . ']\{-}' . l:char . '\)\{' . l:count . '}')
            if -1 != l:pos
                let l:add_text = strpart(l:add_text, 0, l:motion == "f" ? l:pos : l:pos - 1)
            else
                let l:add_text = ''
            endif
        else
            echo "Unknown motion: " . l:motion
        endif

        if l:add_text != ""
            let l:new_text = strpart(l:this_line_text, 0, l:cursor_pos - 1) .
                        \ l:add_text . strpart(l:this_line_text, l:cursor_pos - 1)
            call setline(l:this_line, l:new_text)
            call cursor(l:this_line, l:cursor_pos + strlen(l:add_text))
        endif
    endfun

    inoremap <C-g>y <C-\><C-o>:call SuperYank(-1)<CR>
    inoremap <C-g>e <C-\><C-o>:call SuperYank(1)<CR>
endif

" tab completion
if has("eval")
    function! CleverTab()
        if strpart(getline('.'), 0, col('.') - 1) =~ '^\s*$'
            return "\<Tab>"
        else
            return "\<C-N>"
        endif
    endfun
    inoremap <Tab> <C-R>=CleverTab()<CR>
    inoremap <S-Tab> <C-P>
endif

"-----------------------------------------------------------------------
" abbreviations
"-----------------------------------------------------------------------

if has("eval") && has("autocmd")
    fun! <SID>abbrev_cpp()
        iabbrev <buffer> jan PALUDIS_ATTRIBUTE((noreturn))
        iabbrev <buffer> jav PALUDIS_VISIBLE
        iabbrev <buffer> jaw PALUDIS_ATTRIBUTE((warn_unused_result))
        iabbrev <buffer> jci const_iterator
        iabbrev <buffer> jcl class
        iabbrev <buffer> jco const
        iabbrev <buffer> jdg \ingroup
        iabbrev <buffer> jdx /**<CR><CR>/<Up>
        iabbrev <buffer> jin #include
        iabbrev <buffer> jit iterator
        iabbrev <buffer> jmp std::make_pair
        iabbrev <buffer> jns namespace
        iabbrev <buffer> jpl std::placeholders
        iabbrev <buffer> jpr protected
        iabbrev <buffer> jpu public
        iabbrev <buffer> jpv private
        iabbrev <buffer> jsl std::list
        iabbrev <buffer> jsm std::map
        iabbrev <buffer> jsp std::shared_ptr
        iabbrev <buffer> jms std::make_shared
        iabbrev <buffer> jss std::string
        iabbrev <buffer> jsv std::vector
        iabbrev <buffer> jty typedef
        iabbrev <buffer> jun using namespace
        iabbrev <buffer> jup std::unique_ptr
        iabbrev <buffer> jvi virtual
    endfun

    augroup abbreviations
        autocmd!
        autocmd FileType cpp :call <SID>abbrev_cpp()
    augroup END
endif

"-----------------------------------------------------------------------
" special less.sh and man modes
"-----------------------------------------------------------------------

if has("eval") && has("autocmd")
    fun! <SID>check_pager_mode()
        if exists("g:loaded_less") && g:loaded_less
            " we're in vimpager / less.sh / man mode
            set laststatus=0
            set ruler
            set foldmethod=manual
            set foldlevel=99
            set nolist
        endif
    endfun
    autocmd VimEnter * :call <SID>check_pager_mode()
endif

"-----------------------------------------------------------------------
" plugin / script / app settings
"-----------------------------------------------------------------------

if has("eval")
    " latex
    let g:tex_flavor = "latex"

    " Vim specific options
    let g:vimsyntax_noerror=1
    let g:vimembedscript=0

    " c specific options
    let g:c_gnu=1
    let g:c_no_curly_error=1

    " doxygen
    let g:load_doxygen_syntax=1
    let g:doxygen_end_punctuation='[.?]'

    " Settings for explorer.vim
    let g:explHideFiles='^\.'

    " Settings for netrw
    let g:netrw_list_hide='^\.,\~$'
endif

"-----------------------------------------------------------------------
" final commands
"-----------------------------------------------------------------------

" turn off any existing search
if has("autocmd")
    au VimEnter * nohls
endif

"-----------------------------------------------------------------------
" vim: set shiftwidth=4 softtabstop=4 expandtab tw=120                 :
