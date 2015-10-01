howl-autoclang
==============

Clang-based C/C++ completion for `Howl <http://howl.io>`_, my favorite text editor.

Installation
************

::
   
   $ mkdir -p ~/.howl/bundles
   $ cd ~/.howl/bundles
   $ git clone --recursive https://github.com/kirbyfan64/howl-autoclang.git
   $ cd howl-autoclang/ljclang
   $ make
   $ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD

Also put the following in ``.profile``::
   
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/.howl/bundles/howl-autoclang/ljclang

Usage
*****

Set the config variable ``clang_completion`` to ``true`` in order for it to work.
For other config variables, see ``init.moon``.

Status
******

After a bunch of recent changes, I would consider it quite usable. It uses the
actual completion API and has a cache to avoid insane lag when typing a long word.
I've used it quite a bit, and it works really well.

Note that completing C++ is still slower than C, for slightly obvious reasons...

Of course, it's still new, so you may experience some minor issues, though I doubt
there will be anything major.
