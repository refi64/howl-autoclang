import config from howl

clang = bundle_load 'ljclang/clang'

is_typed = (c) -> c.kind.value == clang.completion_kinds.TypedText

complete = (context) =>
  return if not config.clang_completion
  line = context.buffer.lines\at_pos context.pos
  lineno = line.nr
  colno = context.pos - line.start_pos
  path = context.buffer.file.path
  prefix = context.prefix\match'[%w_]+$' or ''
  prefix_len = prefix\len!
  index = clang.Index 0, config.clang_diagnostics
  unsaved = {[path]: context.buffer.text}
  unit = index\parse path, config.clang_arguments, unsaved
  compls = unit\complete_at path, lineno, colno, unsaved
  res = {}
  resl = 0
  for compl in *compls.results
    for c in *compl.string.chunks
      if is_typed(c) and c.text\find prefix, 1, true
        resl += 1
        res[resl] = c.text
  res

finish_completion = (completion, context) -> nil

->
  {
    :complete
    :finish_completion
  }
