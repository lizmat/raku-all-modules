# Git::Config
[![Build Status](https://travis-ci.org/gfldex/perl6-git-config.svg?branch=master)](https://travis-ci.org/gfldex/perl6-git-config)

Read gitconfig and return a Hash of Hash.

# SYNOPSIS

    my $git-user = git-config<user><name>;
    my $remote-repo = git-config('.git/config'){'remote "origin"'}<url>;

# Subs

    sub git-config(IO::Path $file = "$*HOME/.gitconfig".IO --> Hash)

# Grammars
   
    grammar Config
