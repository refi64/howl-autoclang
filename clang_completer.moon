import config from howl

clang = bundle_load 'ljclang/clang'

is_typed = (c) -> c.kind.value == clang.completion_kinds.TypedText

del = (s, i) -> s\sub(1, i-1) .. s\sub i+1, -1

units = {}
tab = {}
prev = {}

complete = (context) =>
  return if not config.clang_completion
  tab = {}
  text = context.buffer.text
  compls = nil
  if prev.text and prev.text\len! == text\len!-1 and prev.text == del(text, context.pos-1) and text\sub(context.pos-2, context.pos-1)\gmatch'%w%w'!
    compls = prev.compls
  else
    line = context.buffer.lines\at_pos context.pos
    lineno = line.nr
    colno = context.pos - line.start_pos
    path = context.buffer.file.path
    index = clang.Index 0, config.clang_diagnostics
    unsaved = {[path]: text}
    opts = {clang.TranslationUnit.PrecompiledPreamble}
    unit = nil
    if units[path] and units[path].args == config.clang_arguments
      unit = units[path].unit
      unit\reparse unsaved, opts
    else
      unit = index\parse path, config.clang_arguments, unsaved, opts
      units[path] = {:unit, args: config.clang_arguments}
    compls = unit\complete_at path, lineno, colno, unsaved
    prev.compls = compls
  prev.text = text
  res = {}
  resl = 0
  for compl in *compls.results
    nchunks = #compl.string.chunks
    for i, c in ipairs compl.string.chunks
      if is_typed(c) and c.text\find context.word.text, 1, true
        resl += 1
        res[resl] = c.text
        if config.clang_placeholders and i < nchunks
          after = {j-i, d.text for j, d in ipairs compl.string.chunks when j > i}
          tab[c.text] = table.concat after
        break
  res.authoritive = true
  res

finish_completion = (completion, context) =>
  if next = tab[completion]
    context.buffer\insert next, context.pos
    return if next\sub(1,1) == '(' then context.pos+1 else context.pos

->
  {
    :complete
    :finish_completion
  }
