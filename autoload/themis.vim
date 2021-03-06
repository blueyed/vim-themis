" A testing framework for Vim script.
" Version: 1.3
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

" If user makes a typo such as "themis#sutie()",
" this script will be reloaded.  Then the following error occurs.
" E127: Cannot redefine function themis#run: It is in use
" This avoids it.
if exists('s:version')
  finish
endif

let s:version = '1.3'

function! themis#version()
  return s:version
endfunction

function! themis#run(paths, ...)
  let s:current_runner = themis#runner#new()
  try
    let options = get(a:000, 0, themis#option#empty_options())
    return s:current_runner.run(a:paths, options)
  finally
    unlet! s:current_runner
  endtry
endfunction

" -- Utilities for test

function! s:runner()
  if !exists('s:current_runner')
    throw 'themis: Test is not running.'
  endif
  return s:current_runner
endfunction

function! themis#bundle(title)
  return s:runner().add_new_bundle(a:title)
endfunction

function! themis#suite(...)
  let title = get(a:000, 0, '')
  return themis#bundle(title).suite
endfunction

function! themis#helper(name)
  return themis#helper#{a:name}#new(s:runner())
endfunction

function! themis#option(...)
  if !exists('s:custom_options')
    let s:custom_options = themis#option#default()
  endif
  if a:0 == 0
    return s:custom_options
  endif
  let name = a:1
  if a:0 == 1
    return get(s:custom_options, name, '')
  endif
  if has_key(s:custom_options, name)
    if type(s:custom_options[name]) == type([])
      let value = type(a:2) == type([]) ? a:2 : [a:2]
      let s:custom_options[name] += value
    else
      let s:custom_options[name] = a:2
    endif
  endif
endfunction

function! themis#exception(type, message)
  return printf('themis: %s: %s', a:type, themis#message(a:message))
endfunction

function! themis#log(expr, ...)
  let mes = themis#message(a:expr) . "\n"
  call call('themis#logn', [mes] + a:000)
endfunction

function! themis#logn(expr, ...)
  let string = themis#message(a:expr)
  if !empty(a:000)
    let string = call('printf', [string] + a:000)
  endif
  if exists('g:themis#cmdline')
    verbose echon string
  else
    for line in split(string, "\n")
      echomsg line
    endfor
  endif
endfunction

function! themis#message(expr)
  let t = type(a:expr)
  return
  \  t == type('') ? a:expr :
  \  t == type([]) ? join(map(copy(a:expr), 'themis#message(v:val)'), "\n") :
  \                  string(a:expr)
endfunction

function! themis#failure(expr)
  return 'themis: report: failure: ' . themis#message(a:expr)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
