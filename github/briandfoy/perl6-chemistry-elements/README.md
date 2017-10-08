# The Chemistry::Elements Perl 6 module

[![AppVeyor status](https://ci.appveyor.com/api/projects/status/m7fjcqjmoue0wssu/branch/master?svg=true)](https://ci.appveyor.com/project/briandfoy/perl6-chemistry-elements) [![Travis status](https://travis-ci.org/briandfoy/perl6-chemistry-elements.svg?branch=master)](https://travis-ci.org/briandfoy/perl6-chemistry-elements) [![artistic2](https://img.shields.io/badge/license-Artistic%202.0-blue.svg?style=flat)](https://opensource.org/licenses/Artistic-2.0)

The Perl 5 version of `Chemistry::Elements` was my first module, so
I'm making it my first Perl 6 module too. It's not complicated.

The module maps between element names (_e.g._ Rubidium), symbol
(_e.g._ Ru ), and number (_e.g._ 37). It's multi-language aware
although the language switching isn't sophisticated yet.

## Copyright and License

This project is under **Artistic 2.0** license.

## Contributing Guidelines

Fork, edit, and pull request!

If you think you'll have big changes, create a GitHub issue and lets talk
about it.

I'm looking at a future feature that includes the ability to translate
between languages and things like that. If you'd like to add a language
file, drop it in _lib/Chemistry/Languages/_. Make the first line a comment
that lists the language codes. See _lib/Chemistry/Languages/en.txt_ for
example.

## Good luck!

Enjoy,

brian d foy, bdfoy@cpan.org
