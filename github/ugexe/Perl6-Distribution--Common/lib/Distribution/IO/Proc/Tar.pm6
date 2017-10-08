use Distribution::IO;

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
            my $archive-path = $.prefix.IO.is-relative ?? $.prefix !! $.prefix.IO.relative;
            my $cwd          = $.prefix.?CWD // $*CWD;

            my @tar-paths = run-tar('--list', '-f', $archive-path, :$cwd)<out>.lines;
            my $prefix = self!tar-path;
            @tar-paths.map(*.subst(/^$prefix/, '')).grep(*.chars)
        }
    }

    method slurp-rest($name-path, Bool :$bin) {
        run-tar('--to-stdout', '--extract', '-zf', $.prefix.relative, self!tar-path($name-path), :$bin, :cwd($.prefix.CWD))<out>;
    }

    # Construct a path that the tar command understands
    method !tar-path($name-path = '') {
        my $archive-path = $.prefix.IO.is-relative ?? $.prefix !! $.prefix.IO.relative;
        my $cwd          = $.prefix.?CWD // $*CWD;

        state $prefix = run-tar('--list', '-f', $archive-path, :$cwd)<out>.lines[0];
        $prefix ~ $name-path;
    }
}
