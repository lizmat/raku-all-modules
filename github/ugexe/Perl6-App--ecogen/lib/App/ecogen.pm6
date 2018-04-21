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

    method index-file  { $.IO.parent.child("{self.IO.basename}.json") }
    method index-file1 { $.IO.parent.child("{self.IO.basename}1.json") }

    method package-list(@meta-uris = $.meta-uris) {
        state @packages =
            grep { .defined },
            map  { try from-json($_) },
            map  { try self.slurp-http($_) },
            @meta-uris;
    }

    method downgrade-meta-format($meta) {
        return unless $meta<meta-version>:exists and 0 < $meta<meta-version>;

        $meta<meta-version> = 0;
        if $meta<depends> ~~ Hash {
            my $depends = $meta<depends>;
            $meta<depends>:delete;
            $meta<depends> = $depends<runtime><requires> if $depends<runtime>:exists;
            $meta<build-depends> = $depends<build><requires> if $depends<build>:exists;
            $meta<test-depends> = $depends<test><requires> if $depends<test>:exists;
        }
        for <depends build-depends test-depends> {
            $meta{$_} = $meta{$_}.map({
                $_ ~~ Hash ?? $_<name> !! $_
            }).grep({$_ !~~ /':from'/}) if $meta{$_}:exists;
        }
    }

    method update-local-package-list(@metas is copy = $.package-list) {
        my $handle  = (self.index-file.absolute ~ ".tmp." ~ now.Int).IO.open(:w);
        my $handle1 = (self.index-file.absolute ~ "1.tmp." ~ now.Int).IO.open(:w);
        LEAVE { try $handle.close; try $handle.unlink; try $handle1.close; try $handle1.unlink; }

        .print("[\n") for $handle, $handle1;
        while @metas.shift -> $meta {
            $handle1.print(~to-json($meta));
            self.downgrade-meta-format($meta);
            $handle.print(~to-json($meta));
            if @metas.elems {
                .print("\n,\n") for $handle, $handle1;
            }
        }
        for $handle, $handle1 {
            .print("\n]");
            .close;
        }

        .unlink for $.index-file, $.index-file1;
        sleep 1;
        $handle.path.rename(self.index-file);
        $handle1.path.rename(self.index-file1);
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

