use JSON::Fast;

our class Config::JSON::X::NoSuchKey is Exception {
    has Str:D      $.key  is required;
    has IO::Path:D $.file is required;
    method message {
        "Key `$!key` is not present in the config file `$!file.absolute()`"
    }
}
our class Config::JSON::X::Open is Exception {
    has Exception:D $.e    is required;
    has IO::Path:D  $.file is required;
    method message {
        "Received $!e.^name() with message `$!e.message()` while trying to"
        ~ " open config file `$!file.absolute()`"
    }
}

sub read-conf-from (IO::Path:D $file --> Hash:D) {
    with $file.open {
        .lock: :shared;
        my $contents := .slurp;
        .close;
        from-json $contents
    }
    else {
        fail Config::JSON::X::Open.new: :$file, :e($^e.exception)
    }
}

multi jconf (IO::Path:D $file, Whatever --> Mu) {
    read-conf-from $file
}
multi jconf (IO::Path:D $file, Str:D $key --> Mu) {
    my $c := read-conf-from $file orelse fail .exception;
    $c{$key}:exists or fail Config::JSON::X::NoSuchKey.new: :$file, :$key;
    $c{$key}
}

sub jconf-write (IO::Path:D $file, Str:D $key, Mu $value --> Nil) {
    my $c := read-conf-from $file orelse fail .exception;
    $c.AT-KEY($key) = $value;
    my $jsoned := to-json $c;
    with $file.open: :w {
        LEAVE .close;
        .lock;
        .spurt: $jsoned
    }
    else {
        fail Config::JSON::X::Open.new: :$file, :e($^e.exception)
    }
}

sub EXPORT ($conf where Str:D|IO::Path:D = 'config.json') {
    if $conf -> IO() $_ {
        when :!e { .spurt: '{}' }
        when :!f {
            die "[Config::JSON] Config file {.absolute} is not a file";
        }
        when :!r {
            die "[Config::JSON] Config file {.absolute} is not readable";
        }
    }

    Map.new: (
        '&jconf'       => $conf ?? &jconf.assuming($conf.IO)
                                !! &jconf,
        '&jconf-write' => $conf ?? &jconf-write.assuming($conf.IO)
                                !! &jconf-write,
    )
}
