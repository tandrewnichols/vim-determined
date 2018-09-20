function! determined#command#run(cmd, args, changeVert, ...) abort
  let cmd = a:cmd
  let args = a:args
  let moreCmd = len(a:0) ? a:1 : ''
  let opts = {}

  let defaults = { 'background': 1, 'vertical': 1, 'autoclose': 1, 'size': '50%' }
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

  let size = determined#command#calcSize(args)

  " Set the default height or width based on whether the terminal
  " will be vertical or horizontal
  if args.vertical
    let opts.term_cols = size
  else
    let opts.term_rows = size
  endif

  let cmd = empty(moreCmd) ? cmd : join([cmd, moreCmd], ' ')
  let opts = has_key(args, 'term_args') ? extend(opts, args.term_args) : opts

  if cmd =~ '%' && args.expand
    let cmd = substitute(cmd, '%', expand('%'), 'g')
  endif

  " Execute the command, merging the options
  call term_start(cmd, opts)

  "And return to the previous window
  if args.background
    wincmd p
  endif
endfunction

function! determined#command#calcSize(args) abort
  let args = a:args
  
  let size = args.size

  if has_key(args, 'rows') && !args.vertical
    let size = args.rows
  elseif has_key(args, 'cols') && args.vertical
    let size = args.cols
  endif

  if size == 'small' || size == 'sm' || size == 'quarter'
    let size = '25%'
  elseif size == 'medium' || size == 'md' || size == 'half'
    let size = '50%'
  elseif size == 'large' || size == 'lg'
    let size = '75%'
  endif

  if size =~ '%'
    let size = substitute(size, '%', '', 'g') / 100.0

    " Default height/width is half current window
    let windowSize = args.vertical ? winwidth(0) : winheight(0)
    let size = float2nr(windowSize * size)
  endif

  return type(size) == type('') ? size : string(size)
endfunction
