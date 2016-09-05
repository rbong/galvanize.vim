" TODO: use l: for function vars

let s:galvanize_enabled = v:false

" user options {
" TODO: docs

  function! s:opt_use_autoread()
    if exists('g:galvanize_opt_use_autoread')
          \ && index([0, 6], type(g:galvanize_opt_use_autoread)) >= 0
      return g:galvanize_opt_use_autoread
    endif
    return v:true
  endfunction

  function! s:opt_trigger_autoread()
    if exists('g:galvanize_opt_trigger_autoread')
          \ && index([0, 6], type(g:galvanize_opt_trigger_autoread)) >= 0
      return g:galvanize_opt_trigger_autoread && s:opt_use_autoread()
    endif
    return s:opt_use_autoread()
  endfunction

  function! s:opt_clipboard_unnamed()
    if exists('g:galvanize_opt_clipboard_unnamed')
          \ && type(g:galvanize_opt_clipboard_unnamed) == 1
      return g:galvanize_opt_clipboard_unnamed
    endif
    return 'unnamedplus'
  endfunction

  function! s:opt_clipboard_backup()
    if exists('g:galvanize_opt_clipboard_backup')
          \ && type(g:galvanize_opt_clipboard_backup) == 1
      return g:galvanize_opt_clipboard_backup
    endif
    return ''
  endfunction

" }

" variable wrappers {

  function! s:has_all_vars()
    return s:has_norm_reg_names() && s:has_reg_fnames()
  endfunction

  function! s:delete_all_vars()
    call s:delete_norm_reg_names()
    call s:delete_reg_fnames()
  endfunction

  function! s:clean_all_vars(...)
    let force = (a:0 >= 1) ? a:1 : v:false
    call s:clean_norm_reg_names(force)
    call s:clean_reg_fnames(force)
  endfunction

  " normal register names {
  " TODO: docs

    " boilerplate {

      function! s:has_norm_reg_names()
        return exists('g:galvanize_norm_reg_names')
              \ && type(g:galvanize_norm_reg_names) == 3
      endfunction

      function! s:delete_norm_reg_names()
        silent! unlet g:galvanize_norm_reg_names
      endfunction

      function! s:clean_norm_reg_names(...)
        let force = (a:0 >= 1) ? a:1 : v:false
        if force || !s:has_norm_reg_names()
          call s:delete_norm_reg_names()
          let g:galvanize_norm_reg_names =
                \ map(range(char2nr('a'),char2nr('z')),'nr2char(v:val)') + ['"']
        endif
      endfunction

      function! s:get_norm_reg_names()
        call s:clean_norm_reg_names()
        return g:galvanize_norm_reg_names
      endfunction

    " }

    function! s:complete_norm_reg_name(...)
      return s:get_norm_reg_names()
    endfunction

    function! s:is_norm_reg_name(name)
      return len(a:name) == 1 && match(a:name, '[a-z"]') >= 0
    endfunction

  " }

  " register filenames {
  " TODO: docs

    " boilerplate {

      function! s:has_reg_fnames()
        return exists('g:galvanize_reg_fnames')
              \ && type(g:galvanize_reg_fnames) == 4
      endfunction

      function! s:delete_reg_fnames()
        silent! unlet g:galvanize_reg_fnames
      endfunction

      function! s:clean_reg_fnames(...)
        let force = (a:0 >= 1) ? a:1 : v:false
        if force || !s:has_reg_fnames()
          call s:delete_reg_fnames()
          let g:galvanize_reg_fnames = {}
          for reg_name in s:get_norm_reg_names()
            let g:galvanize_reg_fnames[reg_name] = tempname()
          endfor
        endif
      endfunction

      function! s:get_reg_fnames()
        call s:clean_reg_fnames()
        return g:galvanize_reg_fnames
      endfunction

    " }

    function! s:get_reg_name_from_fname(fname)
      if !s:galvanize_enabled
        return ''
      endif
      let fnames = s:get_reg_fnames()
      let i = index(values(fnames), a:fname)
      if i < 0
        return ''
      endif
      return keys(fnames)[i]
    endfunction

    function! s:get_fname_from_reg_name(reg_name)
      if !s:galvanize_enabled
        return ''
      endif
      let fnames = s:get_reg_fnames()
      if index(keys(fnames), a:reg_name) < 0
        return ''
      endif
      return fnames[a:reg_name]
    endfunction

    function! s:update_reg_file(reg_name)
      let reg_name=tolower(a:reg_name)
      let fname = s:get_fname_from_reg_name(reg_name)
      if fname == ''
        return
      endif
      let g:galvanize_preserve_opt = v:true
      call writefile(getreg(reg_name, 1, 1), fname)
    endfunction

    function! s:do_reg_file(reg_name, cmd)
      let fname = s:get_fname_from_reg_name(a:reg_name)
      if fname == ''
        " TODO: throw error
        return
      elseif empty(glob(fname))
        call writefile([], fname)
      endif
      call s:update_reg_file(a:reg_name)
      exec a:cmd.' '.fname
    endfunction

  " }

" }

" autogroups {

  function! s:has_aug(has_aug, should_have_aug)
    if a:has_aug && a:should_have_aug
      return 1
    elseif !a:has_aug && !a:should_have_aug
      return 0
    elseif !a:has_aug && a:should_have_aug
      return -1
    elseif a:has_aug && !a:should_have_aug
      return -2
    else
      return -99
    endif
  endfunction

  function! s:has_all_aug()
    let has_augs = [
          \  s:has_aug_trigger_autoread(),
          \  s:has_aug_set_ftype(),
          \  s:has_aug_yank(),
          \  s:has_aug_force_settings()
          \ ]
    let min_aug_res = min(has_augs)
    if min_aug_res < 0
      return -1
    elseif min_aug_res == 0
      return 0
    endif
    return 1
  endfunction

  function! s:delete_all_aug()
    call s:delete_aug_trigger_autoread()
    call s:delete_aug_set_ftype()
    call s:delete_aug_yank()
    call s:delete_aug_force_settings()
  endfunction

  function! s:make_all_aug()
    call s:make_aug_trigger_autoread()
    call s:make_aug_set_ftype()
    call s:make_aug_yank()
    call s:make_aug_force_settings()
  endfunction

  function! s:reset_all_vars()
    call s:delete_all_aug()
    call s:make_all_aug()
  endfunction

  " trigger autoread regularly {
  " TODO: docs

    function! s:has_aug_trigger_autoread()
      let has_aug = exists('#galvanize_trigger_autoread')
      let should_have_aug = s:opt_trigger_autoread()
            \ && s:galvanize_enabled
      return s:has_aug(has_aug, should_have_aug)
    endfunction

    function! s:delete_aug_trigger_autoread()
      augroup galvanize_trigger_autoread
        autocmd!
      augroup END
      augroup! galvanize_trigger_autoread
    endfunction

    function! s:make_aug_trigger_autoread()
      if (index([0, -1], s:has_aug_trigger_autoread()) >= 0
            \ && s:opt_trigger_autoread())
        augroup galvanize_trigger_autoread
          autocmd!
          autocmd CursorHold * silent! checktime
          autocmd CursorHoldI * silent! checktime
        augroup END
      endif
    endfunction

  " }

  " buffer local settings hack {

    function! s:has_aug_force_settings()
      let has_aug = exists('#galvanize_force_settings')
      let should_have_aug = s:galvanize_enabled
      return s:has_aug(has_aug, should_have_aug)
    endfunction

    function! s:delete_aug_force_settings()
      augroup galvanize_force_settings
        autocmd!
      augroup END
      augroup! galvanize_force_settings
    endfunction

    function! galvanize#force_settings()
      " workaround for TextYank writefile
      if exists('g:galvanize_preserve_opt')
        unlet! g:galvanize_preserve_opt
        return
      elseif exists('b:reg_name') && b:reg_name == '"' && s:galvanize_enabled
        execute 'set clipboard='.s:opt_clipboard_unnamed()
      else
        execute 'set clipboard='.s:opt_clipboard_backup()
      endif
    endfunction

    function! s:make_aug_force_settings()
      if (index([0, -1], s:has_aug_force_settings()) >= 0)
        augroup galvanize_force_settings
          autocmd!
          autocmd WinEnter * call galvanize#force_settings()
        augroup END
      endif
    endfunction

  " }

  " filetype setter {

    function! s:has_aug_set_ftype()
      let has_aug = exists('#galvanize_set_ftype')
      let should_have_aug = s:galvanize_enabled
      return s:has_aug(has_aug, should_have_aug)
    endfunction

    function! s:delete_aug_set_ftype()
      augroup galvanize_set_ftype
        autocmd!
      augroup END
      augroup! galvanize_set_ftype
    endfunction

    function! s:set_ftype(fname)
      let reg_name = s:get_reg_name_from_fname(expand(a:fname))
      if reg_name != ''
        let b:reg_name = reg_name
        set filetype=galvanize_register
      endif
    endfunction

    function! s:make_aug_set_ftype()
      if (index([0, -1], s:has_aug_set_ftype()) >= 0)
        augroup galvanize_set_ftype
          autocmd!
          autocmd BufRead * call s:set_ftype(expand('<afile>'))
        augroup END
      endif
    endfunction

  " }

  " yank listener {

    function! s:has_aug_yank()
      let has_aug = exists('#galvanize_yank')
      let should_have_aug = s:galvanize_enabled
      return s:has_aug(has_aug, should_have_aug)
    endfunction

    function! s:delete_aug_yank()
      augroup galvanize_yank
        autocmd!
      augroup END
      augroup! galvanize_yank
    endfunction

    function! s:make_aug_yank()
      if (index([0, -1], s:has_aug_yank()) >= 0)
        augroup galvanize_yank
          autocmd!
          autocmd TextYankPost * call s:update_reg_file(v:register)
        augroup END
      endif
    endfunction

  " }

" }

" utility functions {

  function! s:declare_ex_cmds()
    command! -complete=customlist,s:complete_norm_reg_name -nargs=1
          \ GalvanizeEdit call s:do_reg_file(<f-args>, 'edit')
    command! -complete=customlist,s:complete_norm_reg_name -nargs=1
          \ GalvanizeSplit call s:do_reg_file(<f-args>, 'split')
    command! -complete=customlist,s:complete_norm_reg_name -nargs=1
          \ GalvanizeVsplit call s:do_reg_file(<f-args>, 'vsplit')
    command! -complete=customlist,s:complete_norm_reg_name -nargs=1
          \ GalvanizeUpdate call s:update_reg_file(<f-args>)
    command! -nargs=0 GalvanizeEnable call s:enable()
    command! -nargs=0 GalvanizeDisable call s:disable()
  endfunction

    function! galvanize#airline_plugin(...)
      if &filetype == 'galvanize_register'
        let w:airline_section_b = b:reg_name
      endif
    endfunction

  function! s:enable_plugins()
    if exists('*airline#add_statusline_func')
      call airline#add_statusline_func('galvanize#airline_plugin')
    endif
  endfunction

  function! s:disable_plugins()
    if exists('*airline#remove_statusline_func')
      call airline#remove_statusline_func('galvanize#airline_plugin')
    endif
  endfunction

  function! s:enable()
    call s:clean_all_vars()
    call s:make_all_aug()
    call s:declare_ex_cmds()
    call s:enable_plugins()
    let s:galvanize_enabled = v:true
  endfunction

  function! s:disable()
    call s:delete_all_vars()
    call s:delete_all_aug()
    call s:disable_plugins()
    let s:galvanize_enabled = v:false
  endfunction

  function! galvanize#ftype_settings()
    if s:opt_use_autoread()
      setlocal autoread
      set updatetime=100
    endif
    setlocal bufhidden=delete
  endfunction

" }

call s:enable()
