if exists('g:loaded_determined') || &cp | finish | endif

let g:loaded_determined = 1

let g:determined_VERSION = '1.1.1'
command! -nargs=0 -bang TermClose call determined#command#close(<bang>0)
