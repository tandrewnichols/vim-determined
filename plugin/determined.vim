if exists('g:loaded_determined') || &cp | finish | endif

let g:loaded_determined = 1

let g:determined_VERSION = '1.1.1'

command! -nargs=* -bang Term <mods> call term_start(<q-args>, { 'vertical': <bang>0 })
command! -nargs=* ETerm call term_start(<q-args>, { 'curwin': 1 })
command! -nargs=* TTerm tabnew | call term_start(<q-args>, { 'curwin': 1 })
command! -nargs=* VTerm call term_start(<q-args>, { 'vertical': 1 })
command! -nargs=* STerm call term_start(<q-args>)
command! -nargs=0 -bang TermClose call determined#command#close(<bang>0)
