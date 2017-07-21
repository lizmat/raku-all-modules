class App::ecogen { }

my $GIT_CMD = %*ENV<GIT_CMD> // 'git';

sub from-json($text) { Rakudo::Internals::JSON.from-json($text) }

sub to-json(|c)      { Rakudo::Internals::JSON.to-json(|c)      }

sub powershell-webrequest($uri) {
    state $probe = $*DISTRO.is-win && try { shell('cmd /c powershell -help', :!out, :!err).so };
    return Nil unless $probe;
    my $content = shell("cmd /c powershell -executionpolicy bypass -command (Invoke-WebRequest -UseBasicParsing -URI $uri).Content", :out).out.slurp(:close);
    return $content;
}

sub curl($uri) {
    state $probe = try { run('curl', '--help', :!out, :!err).so };
    return Nil unless $probe;
    my $content = run('curl', '--max-time', 60, '-s', '-L', $uri, :out).out.slurp(:close);
    return $content;
}

sub wget($uri) {
    state $probe = try { run('wget', '--help', :!out, :!err).so };
    return Nil unless $probe;
    my $content = run('wget', '--timeout=60', '-qO-', $uri, :out).out.slurp(:close);
    return $content;
}

role Ecosystem {
    method IO { ... }
    method meta-uris { ... }

    method index-file { $.IO.parent.child("{self.IO.basename}.json") }

    method package-list(@meta-uris = $.meta-uris) {
        state @packages =
            grep { .defined },
            map  { try from-json($_) },
            map  { try self.slurp-http($_) },
            @meta-uris;
    }

    method update-local-package-list(@metas = $.package-list) {
        my $json = to-json( @metas );
        return self.index-file.spurt( $json );
    }

    method update-remote-package-list($remote-uri) {
        unless self.IO.parent.child('.git').e {
            run $GIT_CMD, 'init', :cwd(self.IO.parent);
            run $GIT_CMD, 'remote', 'add', 'origin', $remote-uri, :cwd(self.IO.parent);
        }

        try { so run $GIT_CMD, 'remote', 'set-url', 'origin', $remote-uri, :cwd(self.IO.parent) }
        try { so run $GIT_CMD, 'pull', 'origin', 'master', :cwd(self.IO.parent) }

        if so run $GIT_CMD, 'add', self.index-file.basename, :cwd(self.IO.parent) {
            try { so run $GIT_CMD, 'commit', '-m', "'ecosystem update: {time}'", :cwd(self.IO.parent) }
            try { so run $GIT_CMD, 'push', 'origin', 'master', :cwd(self.IO.parent) }
        }
    }

    method slurp-http($uri) {
        sleep 1;
        say "Fetching $uri";
        return powershell-webrequest($uri) // curl($uri) // wget($uri);
    }
}
