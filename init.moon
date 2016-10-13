import config, mode from howl

with config
  .define
    name: 'clang_completion'
    description: 'Whether or not to use Clang for C/C++ completion'
    default: false
    type_of: 'boolean'

  .define
    name: 'clang_diagnostics'
    description: 'Whether or not to show diagnostic messages when running Clang'
    default: false
    type_of: 'boolean'

  .define
    name: 'clang_arguments'
    description: 'A list of arguments to pass to Clang'
    default: {}
    type_of: 'string_list'

  .define
    name: 'clang_placeholders'
    description: 'Whether or not to insert placeholder text after a Clang completion'
    default: true
    type_of: 'boolean'

  .define
    name: 'clang_ignored_extensions'
    description: 'File extensions that should be ignored, even if they use the C mode'
    default: {'l', 'y', 'dasc'}
    type_of: 'string_list'

completer = bundle_load 'clang_completer'
c = mode.by_name 'c'
c.completers = { completer, 'in_buffer' }
c.on_completion_accepted = (completion, context) =>
  @completer or= completer!
  @completer\finish_completion completion, context

{
  info: bundle_load('aisu').meta
  unload: () ->
}
