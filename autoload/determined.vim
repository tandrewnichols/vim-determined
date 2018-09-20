function! determined#command(name, cmd, ...) abort
  let name = a:name
  let cmd = a:cmd
  let args = a:0 > 0 ? a:1 : {}

  if name !~# '^[A-Z]'
    let name = toupper(name[0]) . name[1:]
  endif

  " Create the command dynamically
  exec "command! -nargs=* -bang" name "call determined#command#run(" . string(cmd) . ", " . string(args) . ", <bang>0, <q-args>)"
endfunction
