function! galvanize_register#write()
  write
  call setreg(b:reg_name, readfile(expand('%')))
endfunction

augroup galvanize_register_ftype
  autocmd!

  " autowrite
  autocmd TextChanged <buffer> call galvanize_register#write()
  autocmd InsertLeave <buffer> call galvanize_register#write()
augroup END

setlocal autoread
setlocal updatetime=100
