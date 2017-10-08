grammar g {
    token cc {<[2]>}
    token cc_w_lower {<+cc +lower>}
}
say so "2" ~~ /<g::cc>/;            # OK
say so "2" ~~ /<g::cc_w_lower>/;    # OK
say so "a" ~~ /<g::cc_w_lower>/;    # OK
try { # won't compile
    EVAL q!say so "2" ~~ /<+g::cc>/!
} // say "error: $!";
