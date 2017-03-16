# Git::Simple
[![Build Status](https://travis-ci.org/7ojo/perl6-git-simple.svg?branch=master)](https://travis-ci.org/7ojo/perl6-git-simple)

Simple interface to Git command

# SYNOPSIS

    #!/usr/bin/env perl6

    use v6;
    use lib 'lib';
    use Git::Simple;

    for '..'.IO.dir -> $path {
        if $path.d {
            say "» path=" ~ $path.Str;
            say Git::Simple.new(cwd => $path.Str).branch-info;
        }
    }

