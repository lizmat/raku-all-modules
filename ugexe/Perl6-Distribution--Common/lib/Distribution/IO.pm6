role Distribution::IO {
    # what name-path should be absolutified against
    # todo: replace with `method absolutify($name-path) { ... }` for cases where
    # the full name-path parts are intertwined with other parts, not just concated.
    method prefix { ... }

    # a list of relative name-paths that represent the files we have access to
    method ls-files { ... }

    # slurp the file represented by the given name-path
    method slurp-rest($name-path, Bool :$bin) { ... }
}


# Essentially the core's Distribution::Path but included as an example
# of a non-Distribution::IO::Proc data source
role Distribution::IO::Directory does Distribution::IO {
    method ls-files {
        state @cache = do {
            my @stack = dir($.prefix) if $.prefix.e;
            my @files = eager gather while ( @stack ) {
                my IO::Path $current = @stack.pop;
                my Str      $relpath = $current.relative($.prefix);
                take $relpath and next if $current.f;
                @stack.append( |dir($current) )
                    if $current.d && !$current.basename.starts-with('.');
            }
        }
    }

    method slurp-rest($name-path, Bool :$bin) {
        $.prefix.child($name-path).open(:$bin).slurp-rest(:$bin);
    }
}