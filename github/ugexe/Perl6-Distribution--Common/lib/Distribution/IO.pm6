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
