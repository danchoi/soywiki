" Vim script that turns Vim into a personal wiki
" Maintainer:	Daniel Choi <dhchoi@gmail.com>
" License: MIT License (c) 2011 Daniel Choi

" This regex matches namedspaced WikiWords, top-level WikiWords, and relative
" .WikiWords in a namespace
let s:wiki_link_pattern =  '\C\<\([a-z][[:alnum:]_]\+\.\)\?[A-Z][a-z]\+[A-Z]\w*\>\|\.[A-Z][a-z]\+[A-Z]\w*\>'

let s:http_link_pattern = 'https\?:[^ >)\]]\+'
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
  let title_line = getline(1)
  return s:trimString(title_line) 
endfunc

func! s:page_namespace()
  let segments = split(s:page_title(), '\.')
  return get(segments, 0)
endfunc

func! s:title_without_namespace(page_title)
  if len(split(a:page_title, '\.')) == 2
    return "." . get(split(a:page_title, '\.'), 1)
  else
    return a:page_title
  endif
endfunc

func! s:namespace_of_title(page_title)
  if len(split(a:page_title, '\.')) == 2
    return get(split(a:page_title, '\.'), 0)
  else
    ""
  endif
endfunc


func! s:is_wiki_page()
  return (match(getline(1), s:wiki_link_pattern) == 0)
endfunc

func! s:page_title2file(page)
  return substitute(a:page, '\.', '/', 'g')
endfunc

func! s:filename2pagetitle(page)
  return substitute(a:page, '/', '.', 'g')
endfunc

func! s:list_pages()
  let s:search_for_link = ""
  call s:get_page_list()
  call s:page_list_window("CompletePageInSelectionWindow", "Select page: ")
endfunc

func! s:link_under_cursor()
  let link = expand("<cWORD>") 
  " strip off non-letters at the end (e.g., a comma)
  let link = substitute(link, '[^[:alnum:]]*$', '', '')
  " see if we have a link relative to the namespace
  if (match(link, '^\.')) == 0
    " find the namespace from the page title
    let link = s:page_namespace() . link " this link already has a period at the beginning
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
    if match(link, s:http_link_pattern) != -1
      call s:open_href()
    else
      echom "Not a wiki link"
    end
    return
  endif
  call s:load_page(link, a:split)
endfunc

func! s:find_next_wiki_link(backward)
  let n = 0
  " don't wrap
  let result = search(s:wiki_link_pattern, 'W' . (a:backward == 1 ? 'b' : ''))
  if (result == 0) 
    return
  end
  return s:link_under_cursor()
endfunc

func! s:load_page(page, split)
  if (s:is_wiki_page())
    write
  endif

  let file = s:page_title2file(a:page)

  if (!filereadable(file)) 
    " create the file
    let namespace = s:namespace_of_title(a:page)
    if len(namespace) > 0
      call system("mkdir -p " . namespace)
    endif
    call writefile([a:page, '', ''], file) 
  endif
  if (a:split == 2) 
    exec "vsplit ". file
  else
    exec "split ". file
  endif
  if (a:split == 0) 
    wincmd p 
    close
  endif
  
  if len(s:search_for_link) > 0 
    let res =  search(s:search_for_link, 'cw')
    let s:search_for_link = ''
  endif
endfunc

func! s:load_most_recently_modified_page()
  let pages = split(system(s:ls_command), "\n")
  let start_page = len(pages) > 0 ? get(pages, 0) : "HomePage" 
  call s:load_page(start_page, 0)
endfunc

func! s:delete_page()
  let file = bufname('%')
  let bufnr = bufnr('%')
  call delete(file)
  call system("git commit " . bufname('%') . " -m 'deletion'")
  " go to most recently saved
  let target = s:trimString(system(s:ls_command . " | head -1"))
  exec "e " . target
  exec "bdelete " . bufnr
  redraw
  echom  "Deleted " . file
  call s:load_most_recently_modified_page()
endfunc

func! s:prompt_for_wiki_word(prompt, default)
  let input = s:trimString(input(a:prompt, a:default))
  while match(input, s:wiki_link_pattern) == -1
    let input = s:trimString(input("Must be a WikiWord! Press CTRL-c to cancel. " . a:prompt , a:default))
  endwhile
  return input 
endfunc

func! s:rename_page()
  let oldfile = bufname('%')
  let newfile = s:page_title2file( s:prompt_for_wiki_word("Rename oldfile: ", l:oldfile) )
  if (oldfile == newfile)
    echo "Canceled"
    return
  endif
  if (filereadable(newfile)) 
    exe "echom '" . newfile . " already exists!'"
    return
  endif
  call system("git mv " . l:oldfile . " " .  newfile)
  exec "e ". newfile
  " replace all existing inbound links  
  " TODO replace this with a ruby script
  exec "! " . s:rename_links_command . oldfile . " " . newfile
  call system("git commit -am 'rename wiki page'")
  e!
endfunc

func! s:create_page()
  let title = s:prompt_for_wiki_word("New page title: ", "") 
  let newfile = s:page_title2file(title)
  if (filereadable(newfile)) 
    exe "echom '" . newfile . " already exists!'"
    return
  endif
  call writefile([s:filename2pagetitle(title), '', ''], newfile)
  exec "e ". newfile
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
  exec ":! git blame --date=relative " . bufname('%')
endfunc


" -------------------------------------------------------------------------------
" select Page

func! s:get_page_list()
  if len(bufname('%')) == 0
    let s:page_list = split(system(s:ls_command), "\n")
  else
    let s:page_list = split(system(s:ls_command . " | grep -vF '" . bufname('%') . "'" ), "\n")
  endif
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
    return
  elseif match(fragment, '^[A-Z]') == -1 && match(fragment, '\.' == -1)   
    " we're beginning to type a namespace
    let namespace = get(split(get(namespaced_matches, 0), '\.'), 0) 
    let namespace .= "."
    call feedkeys( "BcW". namespace. "\<C-x>\<C-u>\<C-p>" , "t")
  else
    " we're tabbing to auto complete the term, not find a namespace
    return
  endif
endfunc

function! s:page_list_window(complete_function, prompt)
  " remember the original window 
  let s:return_to_winnr = winnr()
  topleft split page-list-buffer
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal modifiable
  resize 1
  inoremap <silent> <buffer> <cr> <Esc>:call <SID>select_page()<CR> 
  inoremap <buffer> <Tab> <Esc>:call <SID>reduce_matches()<cr>
  noremap <buffer> q <Esc>:close<cr>
  inoremap <buffer> <Esc> <Esc>:close<cr>
  exec "setlocal completefunc=" . a:complete_function
  " c-p clears the line
  call setline(1, a:prompt)
  normal $
  call feedkeys("a\<c-x>\<c-u>\<c-p>", 't')
  " call feedkeys("a", 't')
endfunction

function! CompletePage(findstart, base)
  let s:matching_pages = s:page_list[:]
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
      return s:matching_pages
    else
      let res = []
      for m in s:matching_pages
        if m =~ '\c' . base 
          call add(res, m)
        endif
      endfor
      return res
    endif
  endif
endfun

function! CompletePageInSelectionWindow(findstart, base)
  let s:matching_pages = s:page_list[:]
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '[[:alnum:]\.]'
      let start -= 1
    endwhile
    return start
  else
    let base = s:trimString(a:base)
    if (base == '')
      return s:matching_pages
    else
      let res = []
      for m in s:matching_pages
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
  exe s:return_to_winnr . "wincmd w"
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
" PAGES LINKING IN 
"
" this logic could be more precise, in cases where pages have same name
" in different namespaces

func! s:list_pages_linking_in()
  let s:pages_linking_in  = split(system(s:find_pages_linking_in_command . s:page_title()), "\n")
  let s:search_for_link = s:title_without_namespace( s:page_title())
  if len(s:pages_linking_in) == 1
    call s:load_page(get(s:pages_linking_in, 0), 0)
  elseif len(s:pages_linking_in) == 0
    echom "No pages link to " . s:page_title() . "!"
  else
    call s:page_list_window("CompletePagesLinkingIn_InSelectionWindow", "Pages that link to " . s:page_title() . ": ")
  endif
endfunc

function! CompletePagesLinkingIn_InSelectionWindow(findstart, base)
  " todo, this must be smarter, deal with different namespaces
  let s:matching_pages = s:pages_linking_in[:]
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    while start > 0 && line[start - 1] =~ '[[:alnum:]\.]'
      let start -= 1
    endwhile
    return start
  else
    let base = s:trimString(a:base)
    if (base == '')
      return s:matching_pages
    else
      let res = []
      for m in s:matching_pages
        if m =~ '\c' . base 
          call add(res, m)
        endif
      endfor
      return res
    endif
  endif
endfun

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
    exec "split ".file
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
func! s:wiki_search(pattern)

  let pattern = (empty(a:pattern)  ? @/ : a:pattern)
  execute printf('vimgrep/%s/ %s', pattern, "**/*")
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
  call s:highlight_wikiwords() 
  redraw
  echom "Expanded " . (a:seamless == 0 ? 'seamfully' : 'seamlessly') . "."
endfunc

"------------------------------------------------------------------------

func! s:open_href()
  let line = search(s:http_link_pattern, 'cw')
  let href = expand("<cWORD>") 
  let command = g:SoyWiki#browser_command . " '" . href . "' "
  call system(command)
  echom command 
endfunc

" -------------------------------------------------------------------------------- 
"  HELP
func! s:show_help()
  let command = g:SoyWiki#browser_command . ' ' . shellescape('http://danielchoi.com/software/soywiki.html')
  call system(command)
endfunc


"------------------------------------------------------------------------

func! s:global_mappings()
  noremap <leader>m :call <SID>list_pages()<CR>
  noremap  <leader>M :call <SID>list_pages_linking_in()<CR>
  noremap <silent> <leader>o :call <SID>open_href()<cr> 
  nnoremap <silent> q :close<cr>
  nnoremap <silent> <C-h> :close<cr>

  " reflow text
  nnoremap \ gqap 
  " insert a line
  nmap <Leader>- o<Esc>k72i-<Esc><CR>
  " insert date
  map <Leader>d :r !date<CR>o
 
  command! -bar -nargs=1 -range -complete=file SWAppend :<line1>,<line2>call s:extract(<f-args>, 'append', 0)
  command! -bar -nargs=1 -range -complete=file SWInsert :<line1>,<line2>call s:extract(<f-args>, 'insert', 0)
  command! -bar -nargs=1 -range -complete=file SWLinkAppend :<line1>,<line2>call s:extract(<f-args>, 'append', 1)
  command! -bar -nargs=1 -range -complete=file SWLinkInsert :<line1>,<line2>call s:extract(<f-args>, 'insert', 1)

  command! -bar -nargs=1 SWSearch :call s:wiki_search(<f-args>)

  autocmd  BufReadPost,BufNewFile,WinEnter,BufEnter,BufNew * call s:highlight_wikiwords() 
  autocmd  BufEnter * call s:prep_buffer() 


endfunc 

" this checks if the buffer is a SoyWiki file (from firstline)
" and then turns on syntax coloring and mappings as necessary
func! s:prep_buffer()
  if (s:is_wiki_page())
    set textwidth=72
    nnoremap <buffer> <cr> :call <SID>follow_link_under_cursor(0)<cr> 
    nnoremap <buffer> <c-l> :call <SID>follow_link_under_cursor(1)<cr> 
    nnoremap <buffer> <c-n> :call <SID>follow_link_under_cursor(2)<cr> 
    noremap <buffer> <leader>f :call <SID>follow_link(0)<CR>
    noremap <buffer> <c-j> :call <SID>find_next_wiki_link(0)<CR>
    noremap <buffer> <c-k> :call <SID>find_next_wiki_link(1)<CR>

    noremap  <leader>c :call <SID>create_page()<CR>
    command! -buffer SWRename :call s:rename_page()

    noremap <buffer> <leader>r :call <SID>rename_page()<CR>
    command! -buffer SWDelete :call s:delete_page()
    noremap <buffer> <leader># :call <SID>delete_page()<CR>

    command! -buffer SWLog :call s:show_revision_history(0)
    noremap <buffer> <leader>l :call <SID>show_revision_history(0)<CR>
    command! -buffer SWLogStat :call s:show_revision_history(1)
    command! -buffer SWBlame :call s:show_blame()
    noremap <buffer> <leader>b :call <SID>show_blame()<CR>

    noremap <buffer> <leader>x :call <SID>expand(0,0)<CR>
    noremap <buffer> <leader>X :call <SID>expand(1,0)<CR>
    noremap <buffer> <leader>vx :call <SID>expand(0,1)<CR>
    noremap <buffer> <leader>vX :call <SID>expand(1,1)<CR>
    noremap <buffer> <leader>VX :call <SID>expand(1,1)<CR>

    noremap <silent> <leader>? :call <SID>show_help()<cr>

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
    syntax clear
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
  call s:load_most_recently_modified_page()
else
  call s:load_page(bufname("%"), 0)
endif
call s:get_page_list()
syntax enable
let mapleader = ','
call s:highlight_wikiwords() 
