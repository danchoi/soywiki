
"let s:client_script = "zenwiki_client " . shellescape($DRB_URI) . " "
let s:client_script = "ruby -Ilib bin/zenwiki_client " . shellescape($DRB_URI) . " "
let s:save_command = s:client_script . "save_page "


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

func! s:main_window_mappings()
  noremap <buffer> <leader>w :call <SID>save_page()<CR> 
endfunc 

call s:create_main_window()
