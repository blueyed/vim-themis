" themis: Module loader.
" Version: 1.3
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

function! themis#module#exists(type, name)
  let path = printf('autoload/themis/%s/%s.vim', a:type, a:name)
  return globpath(&runtimepath, path, 1) !=# ''
endfunction

function! themis#module#list(type)
  let pat = 'autoload/themis/' . a:type . '/*.vim'
  return themis#util#sortuniq(map(split(globpath(&runtimepath, pat, 1), "\n"),
  \                     'fnamemodify(v:val, ":t:r")'))
endfunction

function! themis#module#load(type, name, args)
  try
    let module = call(printf('themis#%s#%s#new', a:type, a:name), a:args)
    let module.type = a:type
    let module.name = a:name
    return module
  catch /^Vim(\w\+):E117/
    throw printf('themis: Unknown %s: "%s"', a:type, a:name)
  endtry
endfunction

function! themis#module#style(name)
  return themis#module#load('style', a:name, [])
endfunction

function! themis#module#reporter(name)
  return themis#module#load('reporter', a:name, [])
endfunction

function! themis#module#supporter(name, runner)
  return themis#module#load('supporter', a:name, [a:runner])
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
