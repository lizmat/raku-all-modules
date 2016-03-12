[![Build Status](https://travis-ci.org/skaji/Data-Section-Simple.svg?branch=master)](https://travis-ci.org/skaji/Data-Section-Simple)

NAME
====

Data::Section::Simple - Read data from =finish

SYNOPSIS
========

      # Functional interface
      use Data::Section::Simple;
      my %all = get-data-section;
      my $foo = get-data-section(name => 'foo.html');

      # OO interface
      need Data::Section::Simple;
      my $render = Data::Section::Simple.new;
      my %all = $render.get-data-section;
      my $foo = $render.get-data-section(name => 'foo.html');

      =finish

      @@ foo.html
      <html>
       <body>Hello</body>
      </html>

      @@ bar.tt
      [% IF true %]
        Foo
      [% END %]

DESCRIPTION
===========

Data::Section::Simple is a simple module to extract data from `=finish` section of the file.

This is perl5 Data::Section::Simple port.

AUTHOR
======

Shoichi Kaji <skaji@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2015 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

ORIGINAL COPYRIGHT AND LICENSE
==============================

    Copyright 2010- Tatsuhiko Miyagawa

    The code to read DATA section is based on Mojo::Command get_all_data:
    Copyright 2008-2010 Sebastian Riedel

    This library is free software; you can redistribute it and/or modify
    it under the same terms as Perl itself.
