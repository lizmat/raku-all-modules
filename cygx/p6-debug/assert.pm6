my class X::Assert is Exception {
    has AST $.assertion;
    method message { "Assertion failed: { $!assertion.Str.trim }" }
}

sub EXPORT($cb = &die) {
    macro assert($assertion) {
        $cb; # BUG -- Cannot invoke this object (REPR: Null, cs = 0)
             #        if statement is omitted

        if %*ENV<PERL6_DEBUG_ASSERT> {
            quasi {
                $cb(X::Assert.new(:$assertion))
                    unless {{{ $assertion }}}
            }
        }
    }

    EnumMap.new('&assert' => &assert);
}
