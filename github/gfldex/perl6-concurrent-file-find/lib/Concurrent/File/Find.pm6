use v6;

class X::IO::NotADirectory does X::IO is export {
    has $.path;
    method message {
        "«$.path» is not a directory"
    }
}

class X::IO::CanNotAccess does X::IO is export {
    has $.path;
    method message {
        "Cannot access «$.path»: permission denied"
    }
}

class X::IO::StaleSymlink does X::IO is export {
    has $.path;
    method message {
        "Stale symlink «$.path»"
    }
}

class X::Paramenter::Exclusive is Exception is export {
    has $.type;
    method message {
        "Parameters {$.type} are mutual exclusive"
    }
}

sub find ( 
    IO(Str) $dir where { 
        ( .IO.e || fail X::IO::DoesNotExist.new(path => .Str ) ) 
        && ( .IO.d || fail X::IO::NotADirectory.new(path => .Str) )
        && ( .IO.r || fail X::IO::CanNotAccess.new(path => .Str) )
    },
    :$name, :$exclude, :$exclude-dir, :$include, :$include-dir, :$extension,
    :&return-type = { .IO.Str },
    :$no-thread = False,
    :$file = True, :$directory, :$symlink,
    :$max-depth where { $^a ~~ Int || $^a ~~ ∞ && $^a > 0 } = ∞,
    :$recursive = True, :$follow-symlink = False,
    :$keep-going = True, :$quiet = False
) is export {
    constant dir-sep = $*SPEC.dir-sep;
    my &max-depth = $max-depth < ∞ ?? { .IO.path.split(dir-sep).elems <= $max-depth } !! { True };

    my @tests;
    my @types;

    @types.append({.f}) if $file;
    @types.append({.d}) if $directory;
    @types.append({.l}) if $symlink;
    @tests.append(@types.any);
    @tests.append({.basename.Str ~~ $name}) with $name;

    my @exclude-tests;
    for $exclude.list -> $exclude {
        @exclude-tests.push({ .Str ~~ $exclude })        if $exclude ~~ Regex;
        @exclude-tests.push({ $exclude.(.IO) })          if $exclude ~~ Callable ^ Regex;
        @exclude-tests.push({ .Str.contains($exclude) }) if $exclude ~~ Str;
    }
    @tests.append(@exclude-tests.none);

    my @include-tests;
    for $include.list -> $include {
        @include-tests.push({ .Str ~~ $include })        if $include ~~ Regex;
        @include-tests.push({ $include.(.IO) })          if $include ~~ Callable ^ Regex;
        @include-tests.push({ .Str.contains($include) }) if $include ~~ Str;
    }
    @tests.append(@include-tests.any) if @include-tests;

    my @extension-tests;
    for $extension.list -> $test {
        @extension-tests.push({ .extension ~~ $test if .extension }) if $test ~~ Regex;
        @extension-tests.push({ $test.(.extension) })  if $test ~~ Callable ^ Regex;
        @extension-tests.push({ $test eq .extension }) if $test ~~ Str;
    }
    @tests.append(@extension-tests.any) if @extension-tests;

    my @dir-tests = $follow-symlink
        ?? { .d && .l && ( !.e && fail X::IO::StaleSymlink.new(:path(.Str)) ); .d }
        !! { .d && ! .l };
    
    my @exclude-dir-tests;
    for $exclude-dir.list -> $exclude {
        @exclude-dir-tests.push({ .Str ~~ $exclude })        if $exclude ~~ Regex;
        @exclude-dir-tests.push({ $exclude.(.IO) })          if $exclude ~~ Callable & !Regex;
        @exclude-dir-tests.push({ .Str.contains($exclude) }) if $exclude ~~ Str;
    }
    @dir-tests.append(@exclude-dir-tests.none);
    
    my @include-dir-tests;
    for $include-dir.list -> $include {
        @include-dir-tests.push({ .Str ~~ $include })        if $include ~~ Regex;
        @include-dir-tests.push({ $include.(.IO) })          if $include ~~ Callable & !Regex;
        @include-dir-tests.push({ .Str.contains($include) }) if $include ~~ Str;
    }
    @dir-tests.append(@include-dir-tests.any) if @include-dir-tests;
    
    my $channel = Channel.new;

    my &start = -> ( &c ) { c } if $no-thread;

    my $promise = start { 
        for dir($dir) {
            CATCH { default { if $keep-going { warn .Str unless $quiet } else { .rethrow } } }

            if .IO.l && !.IO.e {
                X::IO::StaleSymlink.new(path=>.Str).throw;
            }
            {
                CATCH { when X::Channel::SendOnClosed { last } }
                $channel.send(.&return-type) if all @tests».(.IO);
            }
            .IO.dir().sort({.e && .f}).map(&?BLOCK) if $recursive && .&max-depth && all @dir-tests».(.IO)
        }
        LEAVE $channel.close;
    }
    return $channel.list but role :: { method channel { $channel } };
}

sub find-simple ( IO(Str) $dir,
    :$keep-going = True,
    :$no-thread = False
) is export {
    my $channel = Channel.new;

    my &start = -> ( &c ) { c } if $no-thread;

    my $promise = start { 
        for dir($dir) {
            CATCH { default { if $keep-going { note .Str } else { .rethrow } } }
            
            if .IO.l && !.IO.e {
                X::IO::StaleSymlink.new(path=>.Str).throw;
            }
            {
                CATCH { when X::Channel::SendOnClosed { last } }
                $channel.send(.IO) if .IO.f;
                $channel.send(.IO) if .IO.d;
            }
            .IO.dir()».&?BLOCK if .IO.e && .IO.d;
        }
        LEAVE $channel.close unless $channel.closed;
    }

    return $channel.list but role :: { method channel { $channel } };
}

