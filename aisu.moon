{
  meta:
    author: 'Ryan Gonzalez'
    description: 'Clang-based autocompletion for C/C++'
    license: 'MIT'

  build: (buf, dir) ->
    cmds = {
      {'git', 'submodule', 'init'}
      {'git', 'submodule', 'update'}
      {'make', '-C', 'ljclang', 'libljclang.so'}
    }
    for cmd in *cmds
      aisu.spawn_in_buffer buf,
        :cmd
        working_directory: dir
}
