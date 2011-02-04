
"let s:client_script = "zenwiki_client " . shellescape($DRB_URI) . " "
let s:client_script = "ruby -Ilib bin/zenwiki_client " . shellescape($DRB_URI) . " "
let s:save_command = s:client_script . "save_page "
let s:list_pages_command = s:client_script . "list_pages "

func! s:create_main_window() 
  setlocal modifiable 
  let s:main_window_bufnr = bufnr('%')
  call s:main_window_mappings()
  write
endfunction

func! s:save_page()
  let page = join(getline(1,'$'), "\n")
  call system(s:save_command, page)
  echo "Saved"
  redraw
endfunc

func! s:list_pages()
  call s:page_list_window()
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
  topleft split PageSelect
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal modifiable
  resize 1
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>select_page()<CR> 
  inoremap <silent> <buffer> <esc> <Esc>:q<cr>
  setlocal completefunc=CompletePage
  " c-p clears the line
  call setline(1, "select page to switch to: ")
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
      if m =~ '^' . a:base
        call add(res, m)
      endif
    endfor
    return res
  endif
endfun

function! s:select_page()
  let page = get(split(getline(line('.')), ": "), 1)
  close
  call s:focus_message_window()
  close
  " check if page is a real page
  if (index(s:pages, page) == -1)
    return
  endif
  return
  let command = s:select_page_command . shellescape(s:page)
  redraw
  echom "selecting page: ". s:page . ". please wait..."
  call system(command)
  redraw
  " now get latest 100 messages
  call s:focus_list_window()  
  setlocal modifiable
  let command = s:search_command . shellescape("100 all")
  echo "loading messages..."
  let res = system(command)
  1,$delete
  put! =res
  execute "normal Gdd\<c-y>" 
  normal G
  setlocal nomodifiable
  write
  normal z.
  redraw
  echom "current page: ". s:page 
endfunction


func! s:main_window_mappings()
  noremap <buffer> <leader>w :call <SID>save_page()<CR> 
  noremap <buffer> <leader>m :call <SID>list_pages()<CR>
endfunc 

call s:create_main_window()
