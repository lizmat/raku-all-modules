my class Event {
    has Str $.file;
    has Int $.line;
    has Mu $.msg;
    has Instant $.instant;

    method new(Mu $msg) {
        my $frame = Backtrace.new[4];
        self.bless(
            msg => $msg,
            file => $frame.file,
            line => $frame.line,
            instant => now,
        );
    }

    method gist { self.Str }
    method Str {
        "{ DateTime.new($!instant) } $!file:$!line { $!msg.Str.perl }";
    }
}

sub EXPORT($cb = &note) {
    macro logger($expression) {
        $cb; # BUG -- Cannot invoke this object (REPR: Null, cs = 0)
             #        if statement is omitted

        if %*ENV<PERL6_DEBUG_LOGGER> {
            quasi {
                $cb(Event.new({{{ $expression }}}));
            }
        }
        else { Nil }
    }

    Map.new('&logger' => &logger);
}
