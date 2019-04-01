if exists('g:loaded_determined') || &cp | finish | endif

let g:loaded_determined = 1

let g:determined_VERSION = '1.1.1'

command! -nargs=* -bang Term call determined#command#runGeneric(<q-mods>, <q-args>, { 'vertical': <bang>0 })
command! -nargs=* ETerm call determined#command#runGeneric(<q-mods>, <q-args>, { 'curwin': 1 })
command! -nargs=* TTerm tabnew | call determined#command#runGeneric(<q-mods>, <q-args>, { 'curwin': 1 })
command! -nargs=* VTerm call determined#command#runGeneric(<q-mods>, <q-args>, { 'vertical': 1 })
command! -nargs=* STerm call determined#command#runGeneric(<q-mods>, <q-args>)
command! -nargs=0 -bang TermClose call determined#command#close(<bang>0)
