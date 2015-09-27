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

completer = bundle_load 'clang_completer'
c = mode.by_name 'c'
c.completers = { completer, 'in_buffer' }

{
  info:
    author: 'Ryan Gonzalez'
    description: 'Clang-based autocompletion for C/C++'
    license: 'MIT'

  unload: () -> nil
}
