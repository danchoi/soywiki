" Vim script that turns Vim into a personal wiki
" Maintainer:	Daniel Choi <dhchoi@gmail.com>
" License: MIT License (c) 2011 Daniel Choi

if exists("g:SoyWikiLoaded") || &cp || version < 700
  finish
endif
let g:SoyWikiLoaded = 1

let mapleader = ','

" This regex matches namedspaced WikiWords and unqualified WikiWords 
let s:wiki_link_pattern =  '\C\m\<\([a-z][[:alnum:]_]\+\.\)\?[A-Z][a-z]\+[A-Z]\w*\>'
let s:http_link_pattern = 'https\?:[^ >)\]]\+'
let s:wiki_or_web_link_pattern =  '\C\<\([a-z][[:alnum:]_]\+\.\)\?[A-Z][a-z]\+[A-Z]\w*\>\|https\?:[^ >)\]]\+'

let s:rename_links_command = 'soywiki-rename '
let s:find_pages_linking_in_command = 'soywiki-pages-linking-in '
let s:expand_command = 'soywiki-expand '
let s:ls_command = 'soywiki-ls-t '
let s:search_for_link = ""

func! s:trimString(string)
  let string = substitute(a:string, '\s\+$', '', '')
  return substitute(string, '^\s\+', '', '')
endfunc

func! s:page_title()
  return substitute(bufname(''), '\/', '.', '')
endfunc

func! s:display_missing_namespace_error(num_segments, page_title)
  if a:num_segments == 1
    call s:error("Invalid wiki page: ".a:page_title." is missing a namespace. Put it in a namespace subdirectory.")
  elseif a:num_segments > 2
    call s:error("Invalid wiki page: ".a:page_title." is nested too deeply. Namespaces are limited to one level.")
  endif 
endfunc

func! s:display_invalid_wiki_word_error(word)
  call s:error(a:word . " is not a valid WikiWord.")
endfunc

func! s:namespace_of_title(page_title)
  let segments = split(a:page_title, '[./]')
  " page must have namespace
  if len(segments) == 2
    return get(segments, 0)
  else
    call s:display_missing_namespace_error(len(segments), a:page_title)
    return ""
  endif
endfunc

func! s:page_namespace()
  return s:namespace_of_title(s:page_title())
endfunc

func! s:title_without_namespace(page_title)
  let segments = split(a:page_title, '\.')
  if len(segments) == 2
    return "." . get(segments, 1)
  else
    call s:display_missing_namespace_error(len(segments), a:page_title)
  endif
endfunc

" returns 1 or 0
func! s:has_namespace(link)
  return (match(a:link, '\w\.') != -1) 
endfunc

" adds current page's namespace to the link
func! s:infer_namespace(link)
  if s:has_namespace(s:filename2pagetitle(a:link))
    return s:filename2pagetitle(a:link)
  else
    let x = s:page_namespace() . "." . a:link
    return x
  endif
endfunc

func! s:valid_wiki_word(link)
  return (match(a:link, s:wiki_link_pattern) == 0)
endfunc

func! s:is_wiki_page()
  return s:valid_wiki_word(s:page_title())
endfunc

func! s:pagetitle2file(page)
  return substitute(a:page, '\.', '/', 'g')
endfunc

func! s:filename2pagetitle(page)
  return substitute(a:page, '/', '.', 'g')
endfunc

func! s:list_pages()
  let s:search_for_link = ""
  let pages = s:get_page_list()
  if len(pages) == 0
    echom "There are no wiki pages yet but this one."
  else
    call s:page_list_window(pages, 'select-page', "Select page: ")
  end
endfunc

func! s:list_namespaces()
  let s:search_for_link = ""
  let pages = s:get_namespace_list()
  call s:page_list_window(pages, 'select-page', "Select namespace: ")
endfunc

func! s:trim_link(link)
  let link = matchstr(a:link, s:wiki_link_pattern)
  return link
endfunc

" returns a fully namespaced link
func! s:link_under_cursor()
  let link = s:trim_link(expand("<cWORD>"))
  " strip off non-letters at the end and beginning (e.g., a comma)
  if ! s:has_namespace(link)
    let link = s:infer_namespace(link)
  endif
  if match(link, s:wiki_link_pattern) == -1
    return ""
  else
    return link
  end
endfunc

func! s:find_next_wiki_link(backward)
  let n = 0
  " don't wrap
  if a:backward == 1 
    normal lb
    let result = search(s:wiki_or_web_link_pattern, 'Wb') 
  else
    let result = search(s:wiki_or_web_link_pattern, 'W')
  endif
  if (result == 0) 
    return ""
  end
  return s:link_under_cursor()
endfunc

func! s:follow_link_under_cursor(split)
  let word = expand("<cWORD>")
  if match(word, s:http_link_pattern) != -1
    call s:open_href_under_cursor()
    return
  endif
  let link = s:link_under_cursor()
  if link == ""
    echom ""
    return ""
  elseif line('.') == 1
    " SPECIAL CASE
    " close window
    if winnr('$') > 1
      close
    endif
    return
  else
    call s:load_page(link, a:split)
  endif
endfunc


" If no link under cursor, tries to find the next one
func! s:fuzzy_follow_link(split)
  let link = s:link_under_cursor()
  if link == ""
    let link = s:find_next_wiki_link(0)
    if link == ""
      echom "No links found"
      return
    endif
  endif
  call s:load_page(link, a:split)  
endfunc

" -------------------------------------------------------------------------------- 
" LOAD PAGE

func! s:load_page(page, split)
  if (s:is_wiki_page())
    write
  endif
  let file = s:pagetitle2file(a:page)
  let title = s:filename2pagetitle(a:page)
  if bufwinnr(file) != -1
    exec bufwinnr(file)."wincmd w"    
    return
  endif
  if (!filereadable(file)) 
    " create the file
    let namespace = s:namespace_of_title(a:page)
    if namespace == ""
      return
    end
    call system("mkdir -p " . namespace)
    call writefile([title, '', ''], file) 
  endif
  if (a:split == 2) 
    exec "botright vsplit ". file
  elseif (a:split == 1)
    exec "rightbelow split ". file
  elseif (a:split == 0) 
    exec "e ".file
  endif
  if s:search_for_link != ''
    let res = search(s:search_for_link, 'cw')
    let s:search_for_link = ''
  endif
endfunc

func! s:load_most_recently_modified_page(index)
  let pages = split(system(s:ls_command), "\n")
  let start_page = len(pages) > a:index ? get(pages, a:index) : "main.HomePage" 
  call s:load_page(start_page, 0)
endfunc

func! s:delete_page()
  let file = bufname('%')
  let bufnr = bufnr('%')

  if winnr('$') == 1
    " we need a buffer to replace this one with
    " go to previous buffer
    let next_window = bufnr('#')
    if next_window == -1
      " TODO this fails to execute
      call s:load_page("main.HomePage", 0)
    else
      exec ":b".next_window
    endif
    wincmd p
  endif

  echo system("git rm " . file)
  echo system("rm " . file)
  call system("git commit -am 'page deletion'")
  exec "bdelete " . bufnr
  redraw
  echom  "Deleted " . file
endfunc

func! s:rename_page(page_path_or_title)
  let page_title = s:infer_namespace(a:page_path_or_title)
  let newfile = s:pagetitle2file(page_title)
  if (filereadable(newfile)) 
    exe "echom '" . newfile . " already exists!'"
    return
  endif
  if s:valid_wiki_word(page_title)
    write!
    call system("mkdir -p " . s:namespace_of_title(page_title))
    let original_file = bufname('')
    if executable("git")
      echo system("git mv " . original_file . " " .  newfile)
    else
      echo system("mv " . original_file . " " .  newfile)
    endif
    call system("git commit -am 'rename wiki page'")
    exec "!" . s:rename_links_command . original_file . " " . newfile
    call system("git commit -am 'rename wiki links'")
    exec "e " . newfile
  else
    call s:display_invalid_wiki_word_error(page_title)
  endif
endfunc

func! s:create_page(page_path)
  let page_title = s:infer_namespace(a:page_path)
  let page_path = s:pagetitle2file(page_title)
  if (filereadable(page_path)) 
    exe "echom '" . page_path . " already exists! Loaded.'"
  endif
  if s:valid_wiki_word(page_title)
    call s:load_page(s:filename2pagetitle(page_path), 0)
  else
    call s:display_invalid_wiki_word_error(page_title)
  endif
endfunc

func! s:save_revision()
  call system("git add " . bufname('%'))
  call system("git commit -a -m 'edit'")
endfunc

func! s:show_revision_history(stat)
  if (a:stat)
    exec ":!git log --stat " . bufname('%')
  else
    exec ":!git log  -p " . bufname('%')
  end
endfunc

func! s:show_blame()
  exec ":! git blame --date=relative " . bufname('%')
endfunc

" -------------------------------------------------------------------------------
" select Page

func! s:omit_this_page(page_list)
  if exists("s:return_to_bufname")
    let page_list = filter( a:page_list,  'v:val != "'.s:return_to_bufname.'"')
    return page_list
  else
    return a:page_list
  endif
endfunc

" 
func! s:get_page_list()
  " no file current in buffer
  if len(bufname('')) == 0
    let pages = split(system(s:ls_command), "\n")
  elseif bufname('') == 'pages-linking-in'
    " this needs refactoring to rely less on state
    let pages = s:pages_linking_in
  else
    "let pages = s:omit_this_page(split(system(s:ls_command), "\n"))
    let pages = split(system(s:ls_command), "\n")
  endif
  return pages
endfunction

func! s:get_namespace_list()
  let pages = split(system(s:ls_command . " -n"), "\n")
  return pages
endfunction


func! s:pages_in_this_namespace(pages)
  let namespace = s:page_namespace()
  let pages = filter( a:pages,  'v:val =~ "^' . namespace . '\."')
  " strip leading namespace
  return map(pages, "substitute(v:val, '^" . namespace . "\.', '', '') ")
endfunc

" When user press TAB after typing a few characters in the page selection
" window, if the user started typing a namespace (which starts with a
" lowercase letter), try to complete it. Otherwise take no action.
func! s:reduce_matches()
  if (!exists("s:matching_pages"))
    return
  endif
  let fragment = expand("<cWORD>")
  " find the first namespace in the list
  let namespaced_matches = filter( s:matching_pages,  'v:val =~ "^' . fragment . '\."')
  if (len(namespaced_matches) == 0)
    return
  elseif match(fragment, '^[a-z]') == 0 && match(fragment, '\.' == -1)   
    " we're beginning to type a namespace
    let namespace = get(split(get(namespaced_matches, 0), '\.'), 0) 
    let namespace .= "."
    call feedkeys( "BcW" . namespace . "\<C-x>\<C-u>\<C-p>" , "t")
  else
    return
  endif
endfunc

function! s:page_list_window(page_match_list, buffer_name, prompt)
  " remember the original window 
  let s:return_to_winnr = winnr()
  let s:return_to_bufname = s:filename2pagetitle(bufname(''))
  let s:matching_pages = a:page_match_list
  exec "leftabove split ".a:buffer_name
  setlocal completefunc=CompletePageTitle 
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal modifiable
  setlocal textwidth=0
  resize 1
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>select_page()<CR> 
  inoremap <buffer> <Tab> <Esc>:call <SID>reduce_matches()<cr>
  noremap <buffer> q <Esc>:close<cr>
  inoremap <buffer> <Esc> <Esc>:close<cr>
  
  "  Bad, gets buggy with frag "dai"
  "  autocmd CursorMovedI <buffer> call feedkeys("\<C-x>\<C-u>\<C-p>", "n")
  " c-p clears the line
  call setline(1, a:prompt)
  normal $
  call feedkeys("a\<c-x>\<c-u>\<c-p>", 't')
  " call feedkeys("a", 't')
endfunction

function! CompletePageTitle(findstart, base)
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\m[[:alnum:]\.]'
      let start -= 1
    endwhile
    return start
  else
    let base = s:trimString(a:base)
    if (base == '')
      return s:matching_pages
    else
      let res = []
      if bufname('') == 'select-page'
        let pages = s:get_page_list()
        for m in pages
          if m =~ '\c' . base 
            call add(res, m)
          endif
        endfor
      else
        " autocomplete inline
        if ! exists("s:matching_pages") 
          let s:matching_pages = s:get_page_list()
        endif
        let pages = base =~ '\C^[a-z]' ? s:matching_pages[:] : s:pages_in_this_namespace(s:matching_pages[:])
        for m in pages
          if m =~ '^\c' . base 
            call add(res, m)
          endif
        endfor
      endif
      return res
    endif
  endif
endfun

function! s:select_page()
  let page = s:trimString( get(split(getline(line('.')), ": "), 1) )
  close
  exe s:return_to_winnr . "wincmd w"
  if (page == '') " no selection
    return
  end
  " if time is just a namespace, append .HomePage to it
  if page =~ '^[a-z][[:alnum:]_]\+$'
    let page = page . ".HomePage"
  endif

	for item in s:matching_pages
	  if (page =~ item)
      call s:load_page(page, 0)
      break
    end
	endfor
endfunction

"------------------------------------------------------------------------
" PAGES LINKING IN 
"
" this logic could be more precise, in cases where pages have same name
" in different namespaces

func! s:list_pages_linking_in()
  let s:pages_linking_in = split(system(s:find_pages_linking_in_command . s:page_title()), "\n")
  " cursor should jump to this string after the selected page is loaded:
  let s:search_for_link = s:title_without_namespace(s:page_title())
  if len(s:pages_linking_in) == 1
    call s:load_page(get(s:pages_linking_in, 0), 0)
  elseif len(s:pages_linking_in) == 0
    echom "No pages link to " . s:page_title() . "!"
  else
    call s:page_list_window(s:pages_linking_in, "pages-linking-in", "Pages that link to " . s:page_title() . ": ")
  endif
endfunc

"------------------------------------------------------------------------
" This appends the selected text (use visual-mode) to the page selected
" in the page selection window.
func! s:extract(...) range
  if a:0 != 3
    return s:error("Incorrect number of arguments")
  endif

  let first = a:firstline
  let last = a:lastline
  let file = a:1

  if match(file, s:wiki_link_pattern) == -1
    echom "Target page must be a WikiWord!"
    return
  endif

  let mode = a:2 " append or insert
  let link = a:3 " replace with link ?
  let range = first.",".last
  silent exe range."yank"
  if link
    let replacement = s:filename2pagetitle(file)
    silent exe "norm! :".first.",".last."change\<CR>".replacement."\<CR>.\<CR>"
  else
    " this one just deletes the line
    silent exe "norm! :".first.",".last."change\<CR>.\<CR>"     
  endif
  write!
  if bufnr(file) == -1 || bufwinnr(bufnr(file)) == -1
    if !filereadable(file)
      " create the file
      let page_title = s:filename2pagetitle(file)
      let namespace = s:namespace_of_title(page_title)
      if len(namespace) > 0
        call system("mkdir -p " . namespace)
      endif
      call writefile([page_title, '', ''], file) 
    endif
    exec "botright vsplit ".file
  else
    let targetWindow = bufwinnr(bufnr(file))
    exe targetWindow."wincmd w"
  end
  if mode == 'append'
    normal G
    silent put
    silent put= ''
  elseif mode == 'insert'
    call cursor(2, 0)
    silent put
  end
  write!
endfunc

func! s:error(str)
  echohl ErrorMsg
  echomsg a:str
  echohl None
endfunction

func! s:insert_divider()
  let divider = '------------------------------------------------------------------------'
  silent put! =divider
  silent put=''
endfunc
"------------------------------------------------------------------------
" SEARCH
func! s:wiki_search(pattern, in_this_namespace)
  let pattern = (empty(a:pattern)  ? @/ : a:pattern)
  if a:in_this_namespace
    execute printf('vimgrep/\c%s/ %s', pattern, s:page_namespace()."/*")
  else
    execute printf('vimgrep/\c%s/ %s', pattern, "*/*")
  endif
endfunc

"------------------------------------------------------------------------
" This opens a new buffer with all the lines with just WikiLinks on them
" expanded (recursively). This is not a wiki buffer but a text buffer

func! s:expand(seamless, vertical)
  if a:seamless == 1
    " seamful, the default
    echom "Expanding seamfully. Please wait."
    let res = system(s:expand_command . " seamless " . bufname('%'))
  else " seamless
    echom "Expanding seamlessly. Please wait."
    let res = system(s:expand_command . " seamful " . bufname('%'))
  endif
  if a:vertical
    botright vnew 
  else
    new 
  endif
  setlocal buftype=nofile "scratch buffer for viewing; user can write
  silent! put =res
  silent! 1delete
  silent! normal 1G
  redraw
  echom "Expanded " . (a:seamless == 0 ? 'seamfully' : 'seamlessly') . "."
endfunc
"------------------------------------------------------------------------
func! s:open_href_under_cursor()
  let href = expand("<cWORD>") 
  let command = g:SoyWiki#browser_command . " '" . href . "' "
  call system(command)
  echom command 
endfunc

func! s:find_next_href_and_open()
  let res = search(s:http_link_pattern, 'cw')
  if res != 0
    call s:open_href_under_cursor()
  endif
endfunc

func! s:goto_homepage(main)
  if a:main
    call s:load_page("main.HomePage", 0)
  else
    let namespace_home = s:page_namespace()."/HomePage" 
    call s:load_page(namespace_home, 0)
  endif
endfunc

" -------------------------------------------------------------------------------- 
"  HELP
func! s:show_help()
  let command = g:SoyWiki#browser_command . ' ' . shellescape('http://danielchoi.com/software/soywiki.html')
  call system(command)
endfunc
"------------------------------------------------------------------------

func! s:global_mappings()
  nnoremap <leader>m :call <SID>list_pages()<CR>
  nnoremap <leader>M :call <SID>list_pages_linking_in()<CR>
  nnoremap <leader>n :call <SID>list_namespaces()<CR>

  nnoremap <silent> <leader>o :call <SID>find_next_href_and_open()<cr> 
  nnoremap <silent> q :close<cr>
  " for netrw vertical split
  nnoremap ,O :exec "silent botright vsplit ". expand("<cWORD>")<cr>

  command! -bar -nargs=1 -range -complete=file SWAppend :<line1>,<line2>call s:extract(<f-args>, 'append', 0)
  command! -bar -nargs=1 -range -complete=file SWInsert :<line1>,<line2>call s:extract(<f-args>, 'insert', 0)
  command! -bar -nargs=1 -range -complete=file SWLinkAppend :<line1>,<line2>call s:extract(<f-args>, 'append', 1)
  command! -bar -nargs=1 -range -complete=file SWLinkInsert :<line1>,<line2>call s:extract(<f-args>, 'insert', 1)

  command! -bar -nargs=1 SWSearch :call s:wiki_search(<f-args>, 0)
  command! -bar -nargs=1 SWNamespaceSearch :call s:wiki_search(<f-args>, 1)

  autocmd  BufReadPost,BufNewFile,WinEnter,BufEnter,BufNew,BufAdd * call s:highlight_wikiwords() 
  autocmd  BufReadPost,BufNewFile,WinEnter,BufEnter,BufNew,BufAdd * call s:prep_buffer() 
  " autocmd  BufEnter * call s:prep_buffer() 
endfunc 

" this checks if the buffer is a SoyWiki file (from firstline)
" and then turns on syntax coloring and mappings as necessary
func! s:prep_buffer()
  if (s:is_wiki_page() && !exists("b:mappings_loaded"))
    " let user decide on the textwidth
    set filetype=txt
    nnoremap <buffer> <cr> :call <SID>follow_link_under_cursor(0)<cr> 
    nnoremap <buffer> <c-l> :call <SID>follow_link_under_cursor(2)<cr> 
    nnoremap <buffer> <c-h> :call <SID>follow_link_under_cursor(1)<cr> 
    noremap <buffer> <leader>f :call <SID>fuzzy_follow_link(0)<CR>
    noremap <buffer> <c-j> :call <SID>find_next_wiki_link(0)<CR>
    noremap <buffer> <c-k> :call <SID>find_next_wiki_link(1)<CR>

    command! -bar -nargs=1 -range -complete=file SWCreate :call <SID>create_page(<f-args>)
    command! -bar -nargs=1 -range -complete=file SWRenameTo :call <SID>rename_page(<f-args>)
    command! -buffer SWDelete :call s:delete_page()

    command! -buffer SWLog :call s:show_revision_history(0)
    noremap <buffer> <leader>lp :call <SID>show_revision_history(0)<CR>
    command! -buffer SWLogStat :call s:show_revision_history(1)
    noremap <buffer> <leader>ls :call <SID>show_revision_history(1)<CR>
    command! -buffer SWBlame :call s:show_blame()
    noremap <buffer> <leader>b :call <SID>show_blame()<CR>

    noremap <buffer> <leader>x :call <SID>expand(0,1)<CR>
    noremap <buffer> <leader>X :call <SID>expand(1,1)<CR>
    noremap <buffer> <leader>xx :call <SID>expand(0,0)<CR>
    noremap <buffer> <leader>XX :call <SID>expand(1,0)<CR>

    noremap <buffer> <leader>h :call <SID>goto_homepage(0)<CR>
    noremap <buffer> <leader>H :call <SID>goto_homepage(1)<CR>

    noremap <silent> <leader>? :call <SID>show_help()<cr>

    nnoremap <buffer> \ gqap 
    nnoremap <buffer> <Leader>- o<Esc>k72i-<Esc><CR>
    nnoremap <buffer> <Leader>d :r !date<CR>o<Esc>
    nnoremap <Leader>D :r !date<CR><Esc>k72i-<Esc>jo<Esc>

    "   set nu
    setlocal completefunc=CompletePageTitle
    augroup save_revision
      au!
      autocmd FileWritePost,BufWritePost,BufUnload <buffer> call s:save_revision() 
    augroup END
    let b:mappings_loaded = 1
  endif
endfunc

func! s:highlight_wikiwords()
  if (s:is_wiki_page()) 
    "syntax clear
    exe "syn match Comment /". s:wiki_link_pattern. "/"
    exe "syn match Constant /". s:http_link_pattern . "/"
  endif
endfunc

call s:global_mappings()

if (!isdirectory(".git"))
  call system("git init")
  echom "Created .git repository to store revisions"
endif
" compress the repo
call system("git gc")

if !exists("g:SoyWiki#browser_command")
  for cmd in ["gnome-open", "open"] 
    if executable(cmd)
      let g:SoyWiki#browser_command = cmd
      break
    endif
  endfor
  if !exists("g:SoyWiki#browser_command")
    echom "Can't find the to open your web browser."
  endif
endif

if len(bufname("%")) == 0
  call s:load_most_recently_modified_page(0)
else
  call s:load_page(bufname("%"), 0)
endif
syntax enable
call s:highlight_wikiwords() 
call s:prep_buffer()

