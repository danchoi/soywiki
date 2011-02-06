let s:browser_command = "open "

let s:new_page_split = 0 " means replace the current page with the new page

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

func! s:list_pages(split)
  let s:new_page_split = a:split
  call s:page_list_window()
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
  call feedkeys("\<C-o>")
endfunc

func! s:rename_page()
  let file = bufname('%')
  let newname = s:trimString(input("Rename file: ", file))
  write
  call rename(file, newname) 
  exec "e ". newname
  " replace page title
  call setline(1, newname)
endfunc

func! s:create_page()
  let newname = mString(input("New page title: "))
  call writefile([newname, '', ''], newname)
  exec "e ". newname
endfunc

func! s:save_revision()
  call system("git add " . bufname('%'))
  call system("git commit " . bufname('%') . " -m 'edit'")
endfunc

" -------------------------------------------------------------------------------
" select Page

func! s:get_page_list()
  let res = split(system("ls -t"), "\n")
  return res 
endfunction

func! s:pages_in_this_namespace(pages)
  let namespace = s:page_namespace()
  let pages = filter( a:pages,  'v:val =~ "^' . namespace . '"')
  " strip leading namespace
  let pages = map( pages, "substitute(v:val, '^" . namespace . "\.', '', '') " )
  return pages
endfunc

func! s:match_namespace()
  if (!exists("s:matching_pages"))
    return
  endif
  echo expand("<cword>")
endfunc

function! s:page_list_window()
  topleft split page-list-buffer
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal modifiable
  resize 1
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>select_page()<CR> 
  inoremap <silent> <buffer> <esc> <Esc>:q<cr>
  inoremap <buffer> <Tab> <Esc>:call <SID>match_namespace()<cr>
  setlocal completefunc=CompletePage
  " c-p clears the line
  call setline(1, "Select page (C-x C-u to auto-complete): ")
  normal $
  call feedkeys("a\<c-x>\<c-u>\<c-p>", 't')
  " call feedkeys("a", 't')
endfunction

function! CompletePage(findstart, base)
  let pages = s:get_page_list()
  let s:matching_pages = pages
  let possible_period =  getline('.')[col('.') - 2]
  if (possible_period == '.') 
    " filter to pages in this namespace
    let pages = s:pages_in_this_namespace(pages)
    let s:matching_pages = pages
  endif
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '\a'
      let start -= 1
    endwhile
    return start
  else
    " find pages matching with "a:base"
    let base = s:trimString(a:base)
    if (base == '')
      return pages
    else
      let res = []
      for m in pages
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
      call s:load_page(page, s:new_page_split)
      break
    end
	endfor
endfunction

"------------------------------------------------------------------------

func! s:open_href(all) range
  let pattern = 'https\?:[^ >)\]]\+'
  let n = 0
  " range version
  if a:firstline < a:lastline
    let lnum = a:firstline
    while lnum <= a:lastline
      let href = matchstr(getline(lnum), pattern)
      if href != ""
        let command = s:browser_command . " '" . href . "' &"
        call system(command)
        let n += 1
      endif
      let lnum += 1
    endwhile
    echom 'Opened '.n.' links' 
    return
  end
  let line = search(pattern, 'cw')
  if line && a:all
    while line
      let href = matchstr(getline(line('.')), pattern)
      let command = s:browser_command . " '" . href . "' &"
      call system(command)
      let n += 1
      let line = search('https\?:', 'W')
    endwhile
    echom 'Opened '.n.' links' 
  else
    let href = matchstr(getline(line('.')), pattern)
    let command = s:browser_command . " '" . href . "' &"
    call system(command)
    echom 'Opened '.href
  endif
endfunc

"------------------------------------------------------------------------

func! s:global_mappings()
  noremap <leader>m :call <SID>list_pages(0)<CR>
  noremap <leader>sm :call <SID>list_pages(1)<CR>
  noremap <silent> <leader>o :call <SID>open_href(0)<cr> 

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
    noremap <buffer> <leader>fs :call <SID>follow_link(1)<CR>
    noremap <buffer> <leader>fv :call <SID>follow_link(2)<CR>
    noremap <buffer> <leader>n :call <SID>find_next_wiki_link(0)<CR>
    noremap <buffer> <leader>p :call <SID>find_next_wiki_link(1)<CR>
    noremap  <leader>rm :call <SID>delete_page()<CR>
    noremap  <leader>mv :call <SID>rename_page()<CR>
    noremap  <leader>c :call <SID>create_page()<CR>
    set nu
    setlocal completefunc=CompletePage
  autocmd BufWritePost <buffer> call s:save_revision() 
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
autocmd  BufEnter,BufCreate,BufNewFile,BufRead * call s:prep_buffer() 

call s:load_page("HomePage",0)

if (!isdirectory(".git"))
  call system("git init")
  echom "Created .git repository to store revisions"
endif

