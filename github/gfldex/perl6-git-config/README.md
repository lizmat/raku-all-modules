# Git::Config
[![Build Status](https://travis-ci.org/gfldex/perl6-git-config.svg?branch=master)](https://travis-ci.org/gfldex/perl6-git-config)

Read gitconfig and return a Hash of Hash.

# SYNOPSIS

    use Git::Config;
    
    my $git-user = git-config<user><name>;
    my $remote-repo = git-config('.git/config'){'remote "origin"'}<url>;

    for git-config().seach-path -> {
        say "looking for a git config in " ~ .Str;
    }

    say "found a git config at " ~ git-config().path;

# Subs

    sub git-config(IO::Path $file? --> Hash)

The returned Hash got an anonymous role mixed in providing the method `path`
pointing to the location of the git config file that was read. The method
`search-path` that is returning a list of paths, containing the paths a git
config file was searched in.

# Grammars
   
    grammar Config
