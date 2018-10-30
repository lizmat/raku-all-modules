## TOML.pm6

A WIP ~250 line TOML parser and serializer written in Perl 6.

### Synopsis

    use TOML;

    say from-toml q:/.../;
        [TOML]
        format = "simple"

        [TOML.types]
        bool = true
        strings = "true"
        dates = 1996-08-28T21:11:00Z
        arrays = [ "yep", "got 'em too" ]
        ...

### Testing

Tests are currently done via [toml-test](https://github.com/BurntSushi/toml-test).
To test TOML.pm6, Go must be installed. Then, install toml-test via:

    cd
    export GOPATH=$HOME/go
    go get github.com/BurntSushi/toml-test

And then test TOML.pm6 with:

    cd -1
    $HOME/go/bin/toml-test bin/toml2json

### TODO

 * TOML encoding
 * Perl 6 test harness
 * Better errors
