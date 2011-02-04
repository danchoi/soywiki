
let s:sandbox = $ZEN_WIKI_SANDBOX . "/"
"let s:client_script = "zenwiki_client " . shellescape($DRB_URI) . " "
let s:client_script = "ruby -Ilib bin/zenwiki_client " . shellescape($DRB_URI) . " "
let s:save_command = s:client_script . "save_page "
let s:list_pages_command = s:client_script . "list_pages "
let s:load_page_command = s:client_script . "load_page "
let s:browser_command = "open "



func! s:save_page()
  let page = join(getline(1,'$'), "\n")
  call system(s:save_command, page)
  echo "Saved"
  redraw
endfunc

func! s:list_pages()
  call s:page_list_window()
endfunc

" follows a camel case link to a new page 
func! s:follow_link(split)
  let page = expand("<cword>")
  call s:load_page(page, a:split)  
endfunc

func! s:load_page(page, split)
  let page = a:page
  let s:page = page

  let command = s:load_page_command . shellescape(s:page)
  call system(command) " this creats the file in the sandox

  let file = s:sandbox . s:page
  if (a:split == 2) 
    exec "botright vsplit ". file
  else
    exec "botright split ". file
  endif

  match Comment /\C\<[A-Z][a-z]\+[A-Z]\w*\>/
  autocmd BufWritePost * call s:save_page()
  if (a:split == 0) 
    wincmd p 
    close
  endif
endfunc


" -------------------------------------------------------------------------------
" select Page

func! s:get_page_list()
  redraw
  let res = system(s:list_pages_command)
  let s:pages = split(res, "\n", '')
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
  call s:load_page(page, 0)
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
  noremap <leader>m :call <SID>list_pages()<CR>
  noremap <leader>f :call <SID>follow_link(0)<CR>
  noremap <leader>sf :call <SID>follow_link(1)<CR>
  noremap <leader>vf :call <SID>follow_link(2)<CR>
  noremap <silent> <leader>o :call <SID>open_href(0)<cr> 

  " todo mapping for new page (don't just create a new vim buffer)
endfunc 

call s:global_mappings()

call s:load_page("ZenWiki",0)

autocmd BufNew,WinEnter * match Comment /\C\<[A-Z][a-z]\+[A-Z]\w*\>/


