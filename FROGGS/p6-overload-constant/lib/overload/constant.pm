
sub EXPORT(*@handlers) {
    my %handlers = @handlers.map({$_.name => $_});
    sub atkeyish(Mu \h, \k) {
        nqp::atkey(nqp::findmethod(h, 'hash')(h), k)
    }
    my role Numish[%handlers] {
        method numish(Mu $/) {
            sub call-handler($r) {
                do given nqp::decont($r) {
                    when Str { $*W.add_string_constant( nqp::unbox_s($_) ) }
                    when Int { $*W.add_numeric_constant($/, 'Int', nqp::unbox_i($_)) }
                    when Num { $*W.add_numeric_constant($/, 'Num', nqp::unbox_n($_)) }
                    when Rat { $*W.add_numeric_constant($/, 'Num', nqp::unbox_n($_.Num)) }
                }
            }
            if atkeyish($/, 'integer') -> $v {
                $/.'!make'( %handlers<integer>
                                ?? call-handler(%handlers<integer>(nqp::p6box_s($v.Str)))
                                !! $*W.add_numeric_constant($/, 'Int', $v.made) )
            }
            elsif atkeyish($/, 'dec_number') -> $v {
                $/.'!make'( %handlers<decimal>
                                ?? call-handler(%handlers<decimal>(nqp::p6box_s($v.Str)))
                                !! $v.made )
            }
            elsif atkeyish($/, 'rad_number') -> $v {
                $/.'!make'( %handlers<radix>
                                ?? call-handler(%handlers<radix>(nqp::p6box_s($v.Str)))
                                !! $v.made )
            }
            else {
                $/.'!make'( %handlers<numish>
                                ?? call-handler(%handlers<numish>(nqp::p6box_s($/.Str)))
                                !! $*W.add_numeric_constant($/, 'Num', +nqp::p6box_s($/.Str)) )
            }
        }
    }
    nqp::bindkey(%*LANG, 'MAIN-actions', %*LANG<MAIN-actions>.HOW.mixin(%*LANG<MAIN-actions>, Numish[%handlers]));

    {}
}
