[![Build Status](https://travis-ci.org/skaji/perl6-CPAN-Uploader-Tiny.svg?branch=master)](https://travis-ci.org/skaji/perl6-CPAN-Uploader-Tiny)

NAME
====

CPAN::Uploader::Tiny - Upload tarballs to CPAN

SYNOPSIS
========

    use CPAN::Uploader::Tiny;

    my $uploader = CPAN::Uploader::Tiny.new-from-config($*HOME.add: '.pause');
    $uploader.upload("Your-Perl6-Module-0.0.1.tar.gz");

DESCRIPTION
===========

CPAN::Uploader::Tiny uploads tarballs to CPAN.

SEE ALSO
========

[https://github.com/rjbs/CPAN-Uploader](https://github.com/rjbs/CPAN-Uploader)

[https://github.com/Leont/cpan-upload-tiny](https://github.com/Leont/cpan-upload-tiny)

AUTHOR
======

Shoichi Kaji <skaji@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Shoichi Kaji

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
