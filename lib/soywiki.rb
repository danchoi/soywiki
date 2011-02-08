
vim = ENV['VMAIL_VIM'] || 'vim'

vimscript = File.expand_path("../soywiki.vim", __FILE__)

vim_command = "#{vim} -S #{vimscript}"

exec vim_command
