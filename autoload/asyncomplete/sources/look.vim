" asyncomplete
function! asyncomplete#sources#look#completor(opt, ctx) abort
  let l:col = a:ctx['col']
  let l:typed = a:ctx['typed']

  let l:kw = matchstr(l:typed, '\v[a-zA-Z]{2,}$')
  let l:kwlen = len(l:kw)

  if l:kwlen < 2
    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches, 1)
    return
  endif

  let l:startcol = l:col - l:kwlen

  let l:look = system('look '. l:kw)

  " if l:kw starts with an uppercase, result should start with uppercase
  if match(l:kw[0], '\u') >= 0
    let l:matches = map(split(l:look, "\n"), {key, val -> {'menu': '[look]', 'word': toupper(val[0]) . val[1:]}})
  else
    let l:matches = map(split(l:look, "\n"), {key, val -> {'menu': '[look]', 'word': val}})
  endif

  call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
endfunction

function! asyncomplete#sources#look#good_words(opt, ctx) abort
  let l:col = a:ctx['col']
  let l:typed = a:ctx['typed']

  let l:kw = matchstr(l:typed, '\v[@\/:._0-9a-zA-Z]{2,}$')
  let l:kwlen = len(l:kw)

  if l:kwlen < 2
    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches, 1)
    return
  endif

  let l:startcol = l:col - l:kwlen

  " let g:asc_look_good_words_file = get(g:, 'asc_look_good_words_file', '~/.vim/spell/en.utf-8.add')
  " let l:grep = system('grep -i ^' . l:kw . ' ' . g:asc_look_good_words_file)
  let l:matched_labels = filter(copy(g:bazel_labels), {k, v -> stridx(v, l:kw) == 0})
  if l:kw[len(l:kw)-1] == '/'
    let l:matched_trunks = map(l:matched_labels, {key, val -> val[0:stridx(val, '/', l:kwlen+1)]})
  else
    let l:matched_trunks = map(l:matched_labels, {key, val -> val[0:stridx(val, '/', l:kwlen)]})
  endif
  let l:unique_trunks = uniq(sort(l:matched_trunks))

  " if l:kw starts with an uppercase, result should start with uppercase
  let l:matches = map(l:matched_trunks, {key, val -> {'menu': '[bazel]', 'word': val}})

  call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
endfunction
