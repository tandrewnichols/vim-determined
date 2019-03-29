function! determined#command(name, cmd, ...) abort
  let name = a:name
  let cmd = a:cmd
  let args = a:0 > 0 ? a:1 : {}

  if name !~# '^[A-Z]'
    let name = toupper(name[0]) . name[1:]
  endif

  " Create the command dynamically
  let command = 'command! -nargs=* -bang'

  if has_key(args, 'complete')
    let command .= ' -complete=' . args.complete
  endif

  exec command name 'call determined#command#run(' . string(cmd) . ', ' . string(args) . ', <bang>0, <q-mods>, <q-args>)'
endfunction
