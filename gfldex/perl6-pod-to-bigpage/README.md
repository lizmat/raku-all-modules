# Pod::To::BigPage
[![Build Status](https://travis-ci.org/gfldex/perl6-pod-to-bigpage.svg?branch=master)](https://travis-ci.org/gfldex/perl6-pod-to-bigpage)

Render many Pod6 files into one big file and build a TOC and index. The
provided CSS does support printing, as far as printing HTML goes.

# SYNOPSIS

Let it find the `*.pod6` for you and have two threads at a time.

    pod2onepage -v --threads=2 --source-path=../../perl6-doc/doc --exclude=404.pod6,/.git,/precompiled > tmp/html.xhtml

# Options

* -v --verbose

  verbose output

* --source-path

  Where to look for files ending in .pod6.

* --exclude

  Comma separated list of strings files or paths shall not end with.

* --no-cache

  Don't use precompilation to cache pod6 files.

* --threads

  Number of threads to use. Defaults to environment variable THREADS or 1.

* --precomp-path

  Where to put precompiled pod6 files. Defaults to environment variable TEMP or TMP or /tmp.

