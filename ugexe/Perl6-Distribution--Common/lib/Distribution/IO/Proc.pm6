use Distribution::IO;
class Distribution::IO::Proc { }

role Distribution::IO::Proc::Tar does Distribution::IO {
    my sub run-tar(*@cmd, :%env = %*ENV, :$cwd, Bool :$bin) {
        my $proc = $*DISTRO.is-win
            ?? run('cmd', '/c', 'tar', |@cmd, :out, :err, :$bin, :$cwd, :%env)
            !! run('tar', |@cmd, :out, :err, :$bin, :$cwd, :%env);
        my $out = |$proc.out.slurp-rest(:$bin);
        my $err = |$proc.err.slurp-rest(:$bin);
        $ = $proc.out.close unless $err;
        $ = $proc.err.close;

        %( :$out, :$err )
    }

    method ls-files {
        state @paths = do {
            my @tar-paths = run-tar('--list', '-f', $.prefix.relative, :cwd($.prefix.CWD))<out>.lines;
            my $prefix = self!tar-path;
            @tar-paths.map(*.subst(/^$prefix/, '')).grep(*.chars)
        }
    }

    method slurp-rest($name-path, Bool :$bin) {
        run-tar('--to-stdout', '--extract', '-zf', $.prefix.relative, self!tar-path($name-path), :$bin, :cwd($.prefix.CWD))<out>;
    }

    # Construct a path that the tar command understands
    method !tar-path($name-path = '') {
        state $prefix = run-tar('--list', '-f', $.prefix.relative, :cwd($.prefix.CWD))<out>.lines[0];
        $prefix ~ $name-path;
    }
}


# This targets a LOCAL git path. An additional role could provide access to non-local remotes
role Distribution::IO::Proc::Git does Distribution::IO {
    my sub run-git(*@cmd, :%env = %*ENV, :$cwd, Bool :$bin) {
        my $proc = $*DISTRO.is-win
            ?? run('cmd', '/c', 'git', |@cmd, :out, :err, :$bin, :$cwd, :%env)
            !! run('git', |@cmd, :out, :err, :$bin, :$cwd, :%env);
        my $out = |$proc.out.slurp-rest(:$bin);
        my $err = |$proc.err.slurp-rest(:$bin);
        $ = $proc.out.close unless $err;
        $ = $proc.err.close;

        %( :$out, :$err )
    }

    method ls-files {
        state @paths = run-git('ls-files', :cwd($.prefix))<out>.lines;
    }

    method slurp-rest($name-path, Bool :$bin) {
        run-git('show', "HEAD:$name-path", :$bin, :cwd($.prefix))<out>;
    }
}
