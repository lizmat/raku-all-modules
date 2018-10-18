grammar Time::Crontab::Grammar {
    token TOP { ^ <minutes> \s <hours> \s <doms> \s <months> \s <dows> $ }

    sub check-range(Str $range) {
        $range ~~ m/(\d+) '-' (\d+)/;
        return $0 < $1;
    }

    token minutes { <minute> * % ',' }
    token hours   { <hour> * % ',' }
    token doms    { <dom> * % ',' }
    token months  { <month> * % ','}
    token dows    { <dow> * % ',' }

    # this is the same over and over again
    regex minute { <minute-value> | <minute-range> | <minute-range-step> | <minute-any> | <minute-any-step> | <minute-disable> }
    regex minute-range { <minute-value> '-' <minute-value> <?{ check-range($/.Str) }> }
    regex minute-range-step { <minute-value> '-' <minute-value> '/' <minute-value> <?{ check-range($/.Str) }> }
    regex minute-any { '*' }
    regex minute-any-step { '*' '/' <minute-value> }
    regex minute-disable { '!' <minute-value> }

    # ...
    regex hour { <hour-value> | <hour-range> | <hour-range-step> | <hour-any> | <hour-any-step> | <hour-disable> }
    regex hour-range { <hour-value> '-' <hour-value> <?{ check-range($/.Str) }> }
    regex hour-range-step { <hour-value> '-' <hour-value> '/' <hour-value> <?{ check-range($/.Str) }> }
    regex hour-any { '*' }
    regex hour-any-step { '*' '/' <hour-value> }
    regex hour-disable { '!' <hour-value> }

    # ...
    regex dom { <dom-value> | <dom-range> | <dom-range-step> | <dom-any> | <dom-any-step> | <dom-disable> }
    regex dom-range { <dom-value> '-' <dom-value> <?{ check-range($/.Str) }> }
    regex dom-range-step { <dom-value> '-' <dom-value> '/' <dom-value> <?{ check-range($/.Str) }> }
    regex dom-any { '*' }
    regex dom-any-step { '*' '/' <dom-value> }
    regex dom-disable { '!' <dom-value> }

    # ...
    regex month { <month-value> | <month-range> | <month-range-step> | <month-any> | <month-any-step> | <month-disable> }
    regex month-range { <month-value> '-' <month-value> <?{ check-range($/.Str) }> }
    regex month-range-step { <month-value> '-' <month-value> '/' <month-value> <?{ check-range($/.Str) }> }
    regex month-any { '*' }
    regex month-any-step { '*' '/' <month-value> }
    regex month-disable { '!' <month-value> }

    # ...
    regex dow { <dow-value> | <dow-range> | <dow-range-step> | <dow-any> | <dow-any-step> | <dow-disable> }
    regex dow-range { <dow-value> '-' <dow-value> <?{ check-range($/.Str) }> }
    regex dow-range-step { <dow-value> '-' <dow-value> '/' <dow-value> <?{ check-range($/.Str) }> }
    regex dow-any { '*' }
    regex dow-any-step { '*' '/' <dow-value> }
    regex dow-disable { '!' <dow-value> }

    regex minute-value { \d               | <[ 0 .. 5 ]> \d }
    regex hour-value   { \d               | <[ 0 1 ]> \d    | 2 <[ 0 .. 3 ]>}
    regex dom-value    { 0? <[ 1 .. 9]>   | <[ 1 2 ]> \d    | 30 | 31 }

    regex month-value  { <month-number> | <month-name> }
    regex dow-value    { <dow-number>   | <dow-name> }

    regex month-number { 0? <[ 1 .. 9 ]>  | 10 | 11 | 12 }
    regex dow-number   { <[0 .. 7]> }

    regex month-name   { :i jan | feb | mar | apr | may | jun | jul | aug | sep | oct | nov | dec }
    regex dow-name     { :i mon | tue | wed | thu | fri | sat | sun }

}
