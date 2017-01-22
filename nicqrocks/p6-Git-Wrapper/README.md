Git::Wrapper
============

Hacky way to use git from Perl 6 "inspired" by Perl 5's version of the module of the same name. Originally made by [PerlPilot](https://github.com/perlpilot).

## SYNOPSIS

    my $git = Git::Wrapper.new(
        git-executable     => '/path/to/git',   # optional
        gitdir             => '/foo/bar',
    );

    $git.version;       # version of git being used
    $git.gitdir;        # path to git repo

## example

    #!/usr/bin/env perl6

    use Git::Wrapper;

    my $git = Git::Wrapper.new( gitdir => "/path/to/existing/dir" );
    $git.clone("https://github.com/rakudo/rakudo.git");
    my @log = $git.log;

    for @log -> $l {
        say "{$l.author} {$l.date} {$l.summary}";
    }
