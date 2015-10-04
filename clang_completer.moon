import config from howl

clang = bundle_load 'ljclang/clang'

-- Is the chunk typed text?
is_typed = (c) -> c.kind.value == clang.completion_kinds.TypedText

-- Return the entire string *without* the character at index i.
del = (s, i) -> s\sub(1, i-1) .. s\sub i+1, -1

units = {} -- Parsed units.
tab = {} -- A table of the completion placeholders.
prev = {} -- The previous completion.

complete = (context) =>
  return if not config.clang_completion
  tab = {}
  text = context.buffer.text
  compls = nil
  -- This (long) condition checks if the only difference between the current
  -- completion context and the last is that another letter was added to a word.
  -- If so, we can reuse the results of the last completion instead of reparsing
  -- the source file. This adds major speed gains with C++.
  if prev.text and prev.text\len! == text\len!-1 and
    prev.text == del(text, context.pos-1) and
    text\sub(context.pos-2, context.pos-1)\gmatch'%w%w'!
    compls = prev.compls
  else
    line = context.buffer.lines\at_pos context.pos -- Line object.
    lineno = line.nr
    colno = context.pos - line.start_pos
    path = context.buffer.file.path
    index = clang.Index 0, config.clang_diagnostics
    unsaved = {[path]: text} -- Unsaved files.
    opts = {clang.TranslationUnit.PrecompiledPreamble} -- Precompile the headers.
    unit = nil
    -- If the unit has already been parsed before, use Clang's reparse function.
    if units[path] and units[path].args == config.clang_arguments
      unit = units[path].unit
      unit\reparse unsaved, opts
    else
      unit = index\parse path, config.clang_arguments, unsaved, opts
      units[path] = {:unit, args: config.clang_arguments}
    compls = unit\complete_at path, lineno, colno, unsaved
    -- Reset the previous completion list.
    prev.compls = compls
  prev.text = text
  -- The result table and length.
  res = {}
  resl = 0
  for compl in *compls.results
    nchunks = #compl.string.chunks
    for i, c in ipairs compl.string.chunks
      -- If the completion is TypedText and the current word contains it, add it to
      -- the result table.
      if is_typed(c) and c.text\find context.word.text, 1, true
        resl += 1
        res[resl] = c.text
        -- If the placeholder results should be gathered, then do so.
        if config.clang_placeholders and i < nchunks
          -- Get all the text AFTER the current chunk.
          after = {j-i, d.text for j, d in ipairs compl.string.chunks when j > i}
          tab[c.text] = table.concat after -- Save it.
  res.authoritive = true
  res

finish_completion = (completion, context) =>
  if next = tab[completion]
    -- Insert the prefix.
    context.buffer\insert next, context.pos
    -- If the text is (), jump ahead by two.
    return if next\gmatch'^%(%)'!
      context.pos+1
    -- If the next character is (, <, or [, jump ahead.
    elseif next\sub(1, 1)\gmatch'[(<[]'!
      context.pos+2
    else
      context.pos

->
  {
    :complete
    :finish_completion
  }
