function! s:write()
  write
  call setreg(b:reg_name, readfile(expand('%')))
endfunction

augroup galvanize_register_ftype
  autocmd!
  " autowrite
  autocmd TextChanged <buffer> call s:write()
  autocmd InsertLeave <buffer> call s:write()
augroup END

call galvanize#ftype_settings()
call galvanize#force_settings()
