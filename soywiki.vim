

" let s:wiki_link_pattern =  '\C\<[A-Z][a-z]\+[A-Z]\w*\>'
" let s:wiki_link_pattern =  '\C\<\([a-z]\+\.\)\?[A-Z][a-z]\+[A-Z]\w*\>'
let s:wiki_link_pattern =  '\C\<\([a-z]\+\.\)\?[A-Z][a-z]\+[A-Z]\w*\>\|\.[A-Z][a-z]\+[A-Z]\w*\>'

func! s:trimString(string)
  let string = substitute(a:string, '\s\+$', '', '')
  return substitute(string, '^\s\+', '', '')
endfunc

func! s:page_title()
  let title_line = getline(1)
  return s:trimString(title_line) 
endfunc

func! s:page_namespace()
  let segments = split(s:page_title(), '\.')
  return get(segments, 0)
endfunc

func! s:is_wiki_page()
  let title_line = getline(1)
  return (match(title_line, s:wiki_link_pattern) == 0)
endfunc
func! s:save_page()
"  write
endfunc

func! s:list_pages()
  call s:get_page_list()
  call s:page_list_window()
endfunc

func! s:list_pages_linking_in()
  call s:get_pages_linking_in()
  call s:page_list_window()
endfunc

func! s:get_pages_linking_in()
  let s:page_list = split(system("grep -l " .  bufname('%') . " *"), "\n")
endfunc

func! s:link_under_cursor()
  let link = expand("<cWORD>") 
  let link = substitute(link, '[^[:alnum:]]*$', '', '')
  " see if he have a namespaced link
  if (match(link, '^\.')) == 0
    " find the namespace from the page title
    let link = s:page_namespace() . link
  endif

  let link = substitute(link, '^[^\.[:alnum:]]', '', '') " link may begin with period
  return link
endfunc

" follows a camel case link to a new page 
func! s:follow_link(split)
  let link = s:link_under_cursor()
  if match(link, s:wiki_link_pattern) == -1
    let link = s:find_next_wiki_link(0)
  endif
  call s:load_page(link, a:split)  
endfunc

func! s:follow_link_under_cursor(split)
  let link = s:link_under_cursor()
  if match(link, s:wiki_link_pattern) == -1
    echom "Not a wiki link"
    return
  endif
  call s:load_page(link, a:split)
endfunc

func! s:find_next_wiki_link(backward)
  let n = 0
  let result = search(s:wiki_link_pattern, 'w' . (a:backward == 1 ? 'b' : ''))
  if (result == 0) 
    return
  end
  return s:link_under_cursor()
endfunc

func! s:load_page(page, split)
  let page = a:page
  if (s:is_wiki_page())
    write
  endif
  if (!filereadable(page)) 
    " create the file
    call writefile([a:page, '', ''], page) 
  endif
  if (a:split == 2) 
    exec "vsplit ". page
  else
    exec "split ". page
  endif
  if (a:split == 0) 
    wincmd p 
    close
  endif
endfunc

func! s:delete_page()
  let file = bufname('%')
  call delete(file)
  call system("git commit " . bufname('%') . " -m 'deletion'")
  " go to most recently saved
  " call feedkeys("\<C-o>")
  let target = s:trimString(system("ls -t | head -1"))
  exec "e " . target
  redraw
  echom  "Deleted " . file
endfunc

func! s:prompt_for_wiki_word(prompt, default)
  let input = s:trimString(input(a:prompt, a:default))
  while match(input, s:wiki_link_pattern) == -1
    let input = s:trimString(input("Must be a WikiWord! Press CTRL-c to cancel. " . a:prompt , a:default))
  endwhile
  return input 
endfunc

func! s:rename_page()
  let file = bufname('%')
  let newname = s:prompt_for_wiki_word("Rename file: ", l:file)
  if (filereadable(newname)) 
    exe "echom '" . newname . " already exists!'"
    return
  endif
  " call setline(1, newname) " not necessary because sed will do this
  call system("git mv " . l:file . " " .  newname)
  exec "e ". newname
  " replace all existing inbound links  
  let command = "grep -l " . l:file . " * | xargs sed -i -e 's/" . l:file . "/" . newname ."/g'"
  call system(command)
  call system("git commit -am 'rename wiki page'")
endfunc

func! s:create_page()
  let newname = s:prompt_for_wiki_word("New page title: ", "")
  if (filereadable(newname)) 
    exe "echom '" . newname . " already exists!'"
    return
  endif
  call writefile([newname, '', ''], newname)
  exec "e ". newname
endfunc

func! s:save_revision()
  call system("git add " . bufname('%'))
  call system("git commit " . bufname('%') . " -m 'edit'")
endfunc

func! s:show_revision_history(stat)
  " maybe later allow --stat
  if (a:stat)
    exec ":!git log --stat " . bufname('%')
  else
    exec ":!git log --color-words -p " . bufname('%')
  end
endfunc

func! s:show_blame()
  exec ":!git blame " . bufname('%')
endfunc


" -------------------------------------------------------------------------------
" select Page

func! s:get_page_list()
  let s:page_list = split(system("ls -t"), "\n")
endfunction

func! s:pages_in_this_namespace(pages)
  let namespace = s:page_namespace()
  let pages = filter( a:pages,  'v:val =~ "^' . namespace . '"')
  " strip leading namespace
  let pages = map( pages, "substitute(v:val, '^" . namespace . "\.', '', '') " )
  return pages
endfunc

func! s:reduce_matches()
  if (!exists("s:matching_pages"))
    return
  endif
  let fragment = expand("<cWORD>")
  let reduced_pages = filter( s:matching_pages,  'v:val =~ "^' . fragment . '"')
  " find the first namespace in the list
  let namespaced_matches = filter( s:matching_pages,  'v:val =~ "^' . fragment . '\."')
  if (len(namespaced_matches) == 0)
    call feedkeys( "ea", "t")
  else
    let namespace = get(split(get(namespaced_matches, 0), '\.'), 0) . "."
    call feedkeys( "bcw". namespace. "\<C-x>\<C-u>\<C-p>" , "t")
  endif
endfunc

function! s:page_list_window()
  topleft split page-list-buffer
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal modifiable
  resize 1
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>select_page()<CR> 
  inoremap <buffer> <Tab> <Esc>:call <SID>reduce_matches()<cr>
  inoremap <buffer> <Esc> <Esc>:close<cr>
  setlocal completefunc=CompletePage
  " c-p clears the line
  call setline(1, "Select page (C-x C-u to auto-complete): ")
  normal $
  call feedkeys("a\<c-x>\<c-u>\<c-p>", 't')
  " call feedkeys("a", 't')
endfunction

function! CompletePage(findstart, base)
  let s:matching_pages = s:page_list
  let possible_period =  getline('.')[col('.') - 2]
  if (possible_period == '.') 
    " filter to pages in this namespace
    let s:matching_pages = s:pages_in_this_namespace(s:matching_pages)
  endif
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '[[:alnum:]]'
      let start -= 1
    endwhile
    return start
  else
    let base = s:trimString(a:base)
    if (base == '')
      return s:page_list 
    else
      let res = []
      for m in s:page_list
        if m =~ '\c' . base 
          call add(res, m)
        endif
      endfor
      return res
    endif
  endif
endfun

function! s:select_page()
  let page = s:trimString( get(split(getline(line('.')), ": "), 1) )
  close
  if (page == '0' || page == '') " no selection
    return
  end
  let match = ""
	for item in s:matching_pages
	  if (item == page)
      call s:load_page(page, 0)
      break
    end
	endfor
endfunction

"------------------------------------------------------------------------

func! s:open_href()
  let pattern = 'https\?:[^ >)\]]\+'
  let line = search(pattern, 'cw')
  let href = matchstr(getline(line('.')), pattern)
  let command = g:SoyWiki#browser_command . " '" . href . "' "
  call system(command)
  echom command 
endfunc

"------------------------------------------------------------------------

func! s:global_mappings()
  noremap <leader>m :call <SID>list_pages()<CR>
  noremap  <leader>M :call <SID>list_pages_linking_in()<CR>
  noremap <silent> <leader>o :call <SID>open_href()<cr> 
endfunc 

" this checks if the buffer is a SoyWiki file (from firstline)
" and then turns on syntax coloring and mappings as necessary
func! s:prep_buffer()
  if (s:is_wiki_page())
    set textwidth=72
    nnoremap <buffer> <cr> :call <SID>follow_link_under_cursor(0)<cr> 
    nnoremap <buffer> - :call <SID>follow_link_under_cursor(1)<cr> 
    nnoremap <buffer> \| :call <SID>follow_link_under_cursor(2)<cr> 
    noremap <buffer> <leader>f :call <SID>follow_link(0)<CR>
    noremap <buffer> <leader>n :call <SID>find_next_wiki_link(0)<CR>
    noremap <buffer> <leader>p :call <SID>find_next_wiki_link(1)<CR>
    command! -buffer SWDelete :call s:delete_page()
    command! -buffer SWRename :call s:rename_page()
    noremap  <leader>c :call <SID>create_page()<CR>
    noremap  <leader>ld :call <SID>show_revision_history(0)<CR>
    noremap  <leader>ls :call <SID>show_revision_history(1)<CR>
    noremap  <leader>b :call <SID>show_blame()<CR>
    set nu
    setlocal completefunc=CompletePage
    augroup <buffer>
      au!
      autocmd BufWritePost <buffer> call s:save_revision() 
    augroup END
  endif
endfunc

func! s:highlight_wikiwords()
  if (s:is_wiki_page())
    exe "match Comment /". s:wiki_link_pattern. "/"
  else
    match none " not sure if this works 
  endif
endfunc

call s:global_mappings()

autocmd  WinEnter * call s:highlight_wikiwords() 
autocmd  BufEnter * call s:prep_buffer() 

" load most recent page
call s:get_page_list()
let start_page = get(s:page_list, 0)
let start_page = len(s:page_list) > 0 ? start_page : "HomePage" 
call s:load_page(start_page, 0)

if (!isdirectory(".git"))
  call system("git init")
  echom "Created .git repository to store revisions"
endif

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

