NAME
====

Pod::To::Latex - Convert pod to LaTeX.

SYNOPSIS
========

    use Pod::To::Latex;

DESCRIPTION
===========

Pod::To::Latex converts Pod6 documents to latex.

USAGE
=====

You will need to have `xelatex`, `KOMA-Script` & `listing` package installed

    perl6 -Ilib --doc=Latex Some-File.pod6 > Some-File.tex

    xelatex Some-File.tex

    xpdf Some-File.pdf

Installing Dependencies
=======================

Fedora
------

    sudo dnf install texlive-xetex-bin texlive-koma-script.noarch texlive-listings.noarch texlive-euenc

TODO
====

  * Improve Perl 6 syntax highlighting.

  * Remove pdf generation date from `\maketitle`

  * Other cosmetic improvements?

AUTHOR
======

Bahtiar `kalkin-` Gadimov bahtiar@gadimov.de

COPYRIGHT AND LICENSE
=====================

Copyright © Bahtiar `kalkin-` Gadimov bahtiar@gadimov.de

License GPLv3: The GNU General Public License, Version 3, 29 June 2007 <https://www.gnu.org/licenses/gpl-3.0.txt>

This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.

