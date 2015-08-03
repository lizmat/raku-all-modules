Introduction
============

"Ctags is a programming tool that generates an index (or tag) file of names
found in source and header files of various programming languages. Depending on
the language, functions, variables, class members, macros and so on may be
indexed. These tags allow definitions to be quickly and easily located by a
text editor or other utility." -- Wikipedia

App::p6tags
===========

'p6tags' generates ctags for perl6 to allow tags use within editors such as vim
and Atom.

When run without arguments it generates a "tags" file in the current directory
after parsing perl6 files underneath.

I've mainly tested within vim using Universal Ctags (an actively maintained
fork of Exuberant Ctags).

Pull requests welcome.

Vim's "Tag List Plugin"
=======================

Users of the vim "Tag List" plugin by Yegappan Lakshmanan will currently have
to alter the following files to successfully display the structure of perl6
files using it.

* patch your "taglist.vim" with "taglist.vim.patch" to be perl6 aware

* copy the included "dot-ctags" to ~/.ctags to add very basic perl6 support to ctags(1)

note linux distros probably ship different versions of ctags(1)

Note proper perl6 support for universal ctags is in progress by dtikhonov (github)

-- steve.mynott@gmail.com 20150624
# p6-app-p6tags
