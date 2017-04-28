use experimental :macros;

macro dbg($statement) {
    if %*ENV<PERL6_DEBUG_DBG> {
        quasi { {{{ $statement }}} }
    }
    else { quasi { True } }
}

sub EXPORT {
    once Map.new('&dbg' => &dbg);
}
