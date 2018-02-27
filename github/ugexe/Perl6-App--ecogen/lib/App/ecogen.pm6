class App::ecogen { }

my $GIT_CMD = %*ENV<GIT_CMD> // 'git';

sub from-json($text) { Rakudo::Internals::JSON.from-json($text) }

sub to-json(|c)      { Rakudo::Internals::JSON.to-json(|c)      }

sub powershell-webrequest($uri) {
    return Nil unless once { $*DISTRO.is-win && so try run('powershell', '-help', :!out, :!err) };
    my $content = shell("cmd /c powershell -executionpolicy bypass -command (Invoke-WebRequest -UseBasicParsing -URI $uri).Content", :out).out.slurp-rest(:close);
    return $content;
}

sub curl($uri) {
    return Nil unless once { so try run('curl', '--help', :!out, :!err) };
    my $content = run('curl', '--max-time', 60, '-s', '-L', $uri, :out).out.slurp-rest(:close);
    return $content;
}

sub wget($uri) {
    return Nil unless once { so try run('wget', '--help', :!out, :!err) };
    my $content = run('wget', '--timeout=60', '-qO-', $uri, :out).out.slurp-rest(:close);
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

    method update-local-package-list(@metas is copy = $.package-list) {
        my $handle = (self.index-file.absolute ~ ".tmp." ~ now.Int).IO.open(:w);
        LEAVE { try $handle.close; try $handle.unlink; }

        $handle.print("[\n");
        while @metas.shift -> $meta {
            $handle.print(~to-json($meta));
            $handle.print("\n,\n") if @metas.elems;
        }
        $handle.print("\n]");
        $handle.close;

        self.index-file.unlink;
        sleep 1;
        $handle.path.rename(self.index-file);

        return self.index-file.slurp;
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

