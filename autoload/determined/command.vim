function! determined#command#run(cmd, args, changeVert, mods, ...) abort
  let cmd = a:cmd
  let args = a:args
  let moreCmd = len(a:0) ? a:1 : ''
  let opts = {}

  let defaults = {
    \   'background': 1,
    \   'vertical': 1,
    \   'autoclose': 0,
    \   'reuse': 0,
    \   'singleton': 0,
    \   'expand': 0,
    \   'tabnew': 0,
    \   'curwin': 0,
    \   'term_args': {}
    \ }
  let args = extend(args, defaults, 'keep')

  if args.autoclose
    let opts.term_finish = 'close'
  endif

  " If the command was called with !, invert the orientation
  if a:changeVert
    let args.vertical = !args.vertical
  endif

  if args.vertical
    let opts.vertical = args.vertical
  endif

  if args.tabnew || args.curwin
    if has_key(opts, 'vertical')
      unlet opts.vertical
    endif

    let opts.curwin = 1

    if args.tabnew
      tabnew
    endif
  endif

  if has_key(args, 'size') || has_key(args, 'rows') || has_key(args, 'cols')
    let size = determined#command#calcSize(args)

    " Set the default height or width based on whether the terminal
    " will be vertical or horizontal
    if args.vertical
      let opts.term_cols = size
    else
      let opts.term_rows = size
    endif
  end

  let cmd = empty(moreCmd) ? cmd : join([cmd, moreCmd], ' ')
  let opts = extend(opts, args.term_args)

  if cmd =~? '%' && args.expand
    let cmd = substitute(cmd, '\(\(%\|#\d*\|<\w\+>\)\(:\w\)*\)', '\=expand(submatch(0))', 'g')
  endif

  let reuse = 0
  if args.reuse || args.singleton
    let reuse = determined#command#findBufByCmd(args.singleton ? a:cmd : cmd)
    if reuse
      let opts = determined#command#reuse(reuse, opts)
    endif
  endif

  " Auto size based on height/width ratios
  if has_key(args, 'size') && args.size ==? 'auto' && !has_key(opts, 'curwin')
    if has_key(opts, 'term_cols')
      unlet opts.term_cols
    endif
    if has_key(opts, 'term_rows')
      unlet opts.term_rows
    endif
    let widthRatio = winwidth(0) / str2float(&columns)
    let heightRatio = winheight(0) / str2float(&lines)
    if widthRatio > heightRatio
      let opts.vertical = 1
    else
      let opts.vertical = 0
    endif
  endif

  " Execute the command, merging the options
  exec a:mods ' call term_start(' . shellescape(cmd, 1) . ', ' . string(opts) . ')'

  let b:term_args = [a:cmd, a:args, a:changeVert, a:mods]
  if a:0 > 0
    let b:term_args += a:000
  endif

  nnoremap <buffer> <C-R> :call call('determined#command#run', b:term_args)<CR>

  "And return to the previous window
  if args.background
    wincmd p
  endif
endfunction

function! determined#command#calcSize(args) abort
  let args = a:args
  
  let size = has_key(args, 'size') ? args.size : ''

  if has_key(args, 'rows') && !args.vertical
    let size = args.rows
  elseif has_key(args, 'cols') && args.vertical
    let size = args.cols
  endif

  if size ==? 'small' || size ==? 'sm' || size ==? 'quarter'
    let size = '25%'
  elseif size ==? 'medium' || size ==? 'md' || size ==? 'half'
    let size = '50%'
  elseif size ==? 'large' || size ==? 'lg'
    let size = '75%'
  endif

  if size =~? '%'
    let size = substitute(size, '%', '', 'g') / 1.1.1

    " Default height/width is half current window
    let windowSize = args.vertical ? winwidth(0) : winheight(0)
    let size = float2nr(windowSize * size)
  endif

  return type(size) == type('') ? size : string(size)
endfunction

function! determined#command#findBufByCmd(cmd) abort
  let cmd = a:cmd
  for bufnum in range(1, bufnr('$'))
    let name = bufname(bufnum)
    if name =~? '!' . cmd
      return bufnum
    endif
  endfor
  return 0
endfunction

function! determined#command#reuse(bufnum, opts) abort
  let bufnum = a:bufnum
  let opts = a:opts
  let num = bufwinnr(bufnum)
  let name = bufname(bufnum)

  if bufexists(name) && getbufinfo(name)[0].hidden
    if opts.tabnew
      let prefix = 'tab b'
    elseif opts.curwin
      let prefix = 'b'
    elseif opts.vertical
      let prefix = 'vert sb'
    else
      let prefix = 'sb'
    endif

    exec prefix bufnum
  else
    if num == -1
      for i in range(1, tabpagenr('$'))
        if index(tabpagebuflist(string(i)), bufnum) > -1
          exec 'normal!' i . 'gt'
          let num = bufwinnr(bufnum)
          break
        endif
      endfor
    endif

    exec num . 'wincmd w'
  endif

  let opts.curwin = 1
  if has_key(opts, 'term_cols')
    unlet opts.term_cols
  endif
  if has_key(opts, 'term_rows')
    unlet opts.term_rows
  endif

  return opts
endfunction

function! determined#command#close(force) abort
  let terms = term_list()
  for term in terms
    let stopped = 0
    let job = term_getjob(term)
    let status = job_status(job)
    if status == 'run' && a:force
      let stopped = 1
      call job_stop(job)
    endif

    if status != 'run' || stopped
      exec 'bw' term
    endif
  endfor
endfunction
