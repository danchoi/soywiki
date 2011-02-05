let s:sandbox = $ZEN_WIKI_SANDBOX . "/"
"let s:client_script = "zenwiki_client " . shellescape($DRB_URI) . " "
let s:client_script = "ruby -Ilib bin/zenwiki_client " . shellescape($DRB_URI) . " "
let s:save_command = s:client_script . "save_page "
let s:list_pages_command = s:client_script . "list_pages "
let s:load_page_command = s:client_script . "load_page "
let s:browser_command = "open "

let s:new_page_split = 0 " means replace the current page with the new page

let s:wiki_link_pattern =  '\C\<[A-Z][a-z]\+[A-Z]\w*\>'

func! s:save_page()
  let page = join(getline(1,'$'), "\n")
  call system(s:save_command, page)
  echo "Saved"
  redraw
endfunc

func! s:list_pages(split)
  let s:new_page_split = a:split
  call s:page_list_window()
endfunc

" follows a camel case link to a new page 
func! s:follow_link(split)
  let link = expand("<cword>")
  if match(link, s:wiki_link_pattern) == -1
    let link = s:find_next_wiki_link(0)
  endif
  write
  call s:load_page(link, a:split)  
endfunc

func! s:follow_link_under_cursor()
  let link = expand("<cword>")
  if match(link, s:wiki_link_pattern) == -1
    echom "Not a wiki link"
    return
  endif
  write
  call s:load_page(link, 0)
endfunc

func! s:find_next_wiki_link(backward)
  let n = 0
  let result = search(s:wiki_link_pattern, 'w' . (a:backward == 1 ? 'b' : ''))
  if (result == 0) 
    return
  end
  return expand("<cword>")
endfunc

func! s:load_page(page, split)
  let page = a:page
  let command = s:load_page_command . shellescape(page)
  call system(command) " this creats the file in the sandox

  let file = s:sandbox . page
  if (a:split == 2) 
    exec "vsplit ". file
  else
    exec "split ". file
  endif
  exe "match Comment /". s:wiki_link_pattern. "/"
  
  if (a:split == 0) 
    wincmd p 
    close
  endif
  set textwidth=72
  " set foldmethod=indent
  nnoremap <buffer> <leader>w :call <SID>save_page()<CR>
endfunc


" -------------------------------------------------------------------------------
" select Page

func! s:get_page_list()
  redraw
  let res = system(s:list_pages_command)
  let this_page_line = getline(1)
  let this_page =  substitute(this_page_line, '\s\+$', '', '')
  let s:pages = filter( split(res, "\n", ''),  'v:val !~ "' . this_page . '"')
endfunction


function! s:page_list_window()
  call s:get_page_list()
  topleft split page-list-buffer
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal modifiable
  resize 1
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>select_page()<CR> 
  inoremap <silent> <buffer> <esc> <Esc>:q<cr>
  setlocal completefunc=CompletePage
  " c-p clears the line
  call setline(1, "Select page: ")
  normal $
  call feedkeys("a\<c-x>\<c-u>\<c-p>", 't')
endfunction

function! CompletePage(findstart, base)
  if !exists("s:pages")
    call s:get_page_list()
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
    let res = []
    for m in s:pages
      if m =~ a:base . '\c'
        call add(res, m)
      endif
    endfor
    return res
  endif
endfun

function! s:select_page()
  let page = get(split(getline(line('.')), ": "), 1)
  close
  if (page == '0') " no selection
    return
  end
  call s:load_page(page, s:new_page_split)
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
  " these are global
  noremap <leader>m :call <SID>list_pages(0)<CR>
  noremap <leader>sm :call <SID>list_pages(1)<CR>

  noremap <leader>f :call <SID>follow_link(0)<CR>
  noremap <leader>sf :call <SID>follow_link(1)<CR>
  noremap <leader>vf :call <SID>follow_link(2)<CR>
  nnoremap <cr> :call <SID>follow_link_under_cursor()<cr> 

  noremap <silent> <leader>o :call <SID>open_href(0)<cr> 

  noremap <leader>n :call <SID>find_next_wiki_link(0)<CR>
  noremap <leader>p :call <SID>find_next_wiki_link(1)<CR>
  " todo mapping for new page (don't just create a new vim buffer)
endfunc 

call s:global_mappings()

call s:load_page("HomePage",0)




