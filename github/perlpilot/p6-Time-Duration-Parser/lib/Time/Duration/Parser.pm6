
grammar Time::Duration::Parser {
    token TOP { 
        | <hms>         { make $<hms>.ast }
        | <timespec>    { make $<timespec>.ast; }
    }

    token hms { (\d+) ':' (\d\d) [ ':' (\d\d) ]? { make $0 * 60 * 60 + $1 * 60 + ($2//0) } }

    rule timespec { <time> *% <sep> { make [+] $<time>».ast } }

    rule time { <number> <duration> { make +$<number> * $<duration>.ast } }
    
    token duration {
        | [ s | seconds? | secs? ]     { make 1 }
        | [ m | minutes? | mins? ]     { make 60; }
        | [ h | hrs? | hours? ]        { make 60 * 60 }
        | [ d | days? ]                { make 60 * 60 * 24 }
        | [ w | weeks? ]               { make 60 * 60 * 24 * 7 }
        | [ M | months? | mo | mons? ] { make 60 * 60 * 24 * 30 }
        | [ y | years? ]               { make 60 * 60 * 24 * 365 }
    }

    token number { <[+-]>? \d+ ['.' \d*]?  }

    token sep { ',' | 'and' | <.ws> }
}

sub duration-to-seconds($string) is export {
    my $result = Time::Duration::Parser.parse($string);
    $result ?? $result.ast !! Nil
}
