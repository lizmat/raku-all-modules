use v6;

my %control-char-to-unicode-name =
    A => <START OF HEADING>,
    B => <START OF TEXT>,
    C => <END OF TEXT>,
    D => <END OF TRANSMISSION>,
    E => <ENQUIRY>,
    F => <ACKNOWLEDGE>,
    G => <BELL>,
    H => <BACKSPACE>,
    I => <HORIZONTAL TABULATION>,
    J => <LINE FEED>,
    K => <VERTICAL TABULATION>,
    L => <FORM FEED>,
    M => <CARRIAGE RETURN>,
    N => <SHIFT OUT>,
    O => <SHIFT IN>,
    P => <DATA LINK ESCAPE>,
    Q => <DEVICE CONTROL ONE>,
    R => <DEVICE CONTROL TWO>,
    S => <DEVICE CONTROL THREE>,
    T => <DEVICE CONTROL FOUR>,
    U => <NEGATIVE ACKNOWLEDGE>,
    V => <SYNCHRONOUS IDLE>,
    W => <END OF TRANSMISSION BLOCK>,
    X => <CANCEL>,
    Y => <END OF MEDIUM>,
    Z => <SUBSTITUTE>;

grammar ECMA262Regex::Parser {
    token TOP {
        <disjunction>
    }
    token disjunction {
        <alternative>* % '|'
    }
    token alternative {
        <term>*
    }
    token term {
        <!before $>
        [
            | <assertion>
            | <atom> <quantifier>?
        ]
    }
    token assertion {
        | '^'
        | '$'
        | '\\' <[bB]>
        | '(?=' <disjunction> ')'
        | '(?!' <disjunction> ')'
    }
    token quantifier {
        <quantifier-prefix> '?'?
    }
    token quantifier-prefix {
        | '+'
        | '*'
        | '?'
        | '{' <decimal-digits> [ ',' <decimal-digits>? ]? '}'
    }
    token atom {
        | <pattern-character>
        | '.'
        | '\\' <atom-escape>
        | <character-class>
        | '(' <disjunction> ')'
        | '(?:' <disjunction> ')'
    }
    token pattern-character {
        <-[^$\\.*+?()[\]{}|]>
    }
    token atom-escape {
        | <decimal-digits>
        | <character-escape>
        | <character-class-escape>
    }
    token character-escape {
        | <control-escape>
        | 'c' <control-letter>
        | <hex-escape-sequence>
        | <unicode-escape-sequence>
        | <identity-escape>
    }
    token control-escape {
        <[fnrtv]>
    }
    token control-letter {
        <[A..Za..z]>
    }
    token hex-escape-sequence {
        'x' <[0..9A..Fa..f]>**2
    }
    token unicode-escape-sequence {
        'u' <[0..9A..Fa..f]>**4
    }
    token identity-escape {
        <-ident-[\c[ZWJ]\c[ZWNJ]]>
    }
    token decimal-digits {
        <[0..9]>+
    }
    token character-class-escape {
        <[dDsSwW]>
    }
    token character-class {
        '[' '^'? <class-ranges> ']'
    }
    token class-ranges {
        <non-empty-class-ranges>?
    }
    token non-empty-class-ranges {
        | <class-atom> '-' <class-atom> <class-ranges>
        | <class-atom-no-dash> <non-empty-class-ranges-no-dash>?
        | <class-atom>
    }
    token non-empty-class-ranges-no-dash {
        | <class-atom-no-dash> '-' <class-atom> <class-ranges>
        | <class-atom-no-dash> <non-empty-class-ranges-no-dash>
        | <class-atom>
    }
    token class-atom {
        | '-'
        | <class-atom-no-dash>
    }
    token class-atom-no-dash {
        | <-[\\\]-]>
        | \\ <class-escape>
    }
    token class-escape {
        | <decimal-digits>
        | 'b'
        | <character-escape>
        | <character-class-escape>
    }
}

class ECMA262Regex::ToPerl6Regex {
    method TOP($/) {
        make $<disjunction>.made;
    }

    method disjunction($/) {
        make $<alternative>>>.made.join(' || ');
    }

    method alternative($/) {
        make $<term>>>.made.join;
    }

    method term($/) {
        with $<assertion> {
            make $<assertion>.made;
        } else {
            my $atom = $<atom>.made;
            with $<quantifier> {
                make $atom ~ $<quantifier>.made;
            } else {
                make $atom;
            }
        }
    }

    method assertion($/) {
        given ~$/ {
            when '^'|'$' { make ~$/ }
            when '\\b'   { make "<|w>" }
            when '\\B'   { make "<!|w>" }
            when *.starts-with('(?=') { make '<?before ' ~ $<disjunction>.made ~ '>' }
            when *.starts-with('(?!') { make '<!before ' ~ $<disjunction>.made ~ '>' }
        }
    }

    method quantifier($/) {
        if $/.Str.ends-with('?') {
            make $<quantifier-prefix>.made;
        } else {
            make $<quantifier-prefix>.made;
        }
    }

    method quantifier-prefix($/) {
        if not $/.Str.starts-with('{') {
            make ~$/;
        } else {
            # {n}
            if not $/.Str.contains(',') {
                make ' ** ' ~ ~$<decimal-digits>;
            } else {
                if $<decimal-digits>.elems == 1 {
                    make ' ** ' ~ $<decimal-digits>[0].Str ~ '..* ';
                } else {
                    make ' ** ' ~ $<decimal-digits>.map({ ~$_ }).join('..');
                }
            }
        }
    }

    method atom($/) {
        if $/.Str.starts-with('(?:') {
            make '[' ~ $<disjunction>.made ~ ']';
            return;
        } elsif $/.Str.starts-with('(') {
            make '(' ~ $<disjunction>.made ~ ')';
            return;
        } elsif $/.Str eq '.' {
            make '.';
            return;
        }

        with $<pattern-character> {
            make $<pattern-character>.made;
        }
        orwith $<atom-escape> {
            make $<atom-escape>.made;
        }
        orwith $<character-class> {
            make $<character-class>.made;
        }
    }

    method pattern-character($/) {
        make ~$/;
    }

    method atom-escape($/) {
        with $<decimal-digits> {
            my $num = $<decimal-digits>.made.Int;
            make '$' ~ --$num;
        }
        orwith $<character-escape> {
            make $<character-escape>.made;
        } else {
            make '\\' ~ $<character-class-escape>.made;
        }
    }

    method character-escape($/) {
        with $<control-escape> {
            make $<control-escape>.made;
        }
        orwith $<control-letter> {
            make $<control-letter>.made;
        }
        orwith $<hex-escape-sequence> {
            make $<hex-escape-sequence>.made;
        }
        orwith $<unicode-escape-sequence> {
            make $<unicode-escape-sequence>.made;
        }
        orwith $<identity-escape> {
            make $<identity-escape>.made;
        }
    }

    method control-escape($/) {
        if $/.Str.ends-with("v") {
            make "\c[VERTICAL TABULATION]"
        } else {
            make '\\' ~ $/.Str;
        }
    }

    method control-letter($/) {
        my $name = %control-char-to-unicode-name{~$/};
        unless $name.defined {
            die 'Unknown control character escape is present: ' ~ $/.Str;
        }
        make '"\c[' ~ $name ~ ']"';
    }

    method hex-escape-sequence($/) {
        make '\x' ~ $/.Str.substr(1);
    }

    method unicode-escape-sequence($/) {
        make '\x' ~ $/.Str.substr(1);
    }

    method identity-escape($/) {
        make '\\' ~ $/.Str;
    }

    method decimal-digits($/) {
        make ~$/;
    }

    method character-class-escape($/) {
        make ~$/;
    }

    method character-class($/) {
        my $start = '<';
        $start ~= '-' if $/.Str.starts-with('[^');
        $start ~= '[' ~ $<class-ranges>.made;
        make $start ~ ']>';
    }

    method class-ranges($/) {
        with $<non-empty-class-ranges> {
            make $<non-empty-class-ranges>.made;
        } else { make '' }
    }

    method non-empty-class-ranges($/) {
        with $<class-ranges> {
            make $<class-atom>[0].made ~ '..' ~ $<class-atom>[1].made ~ $<class-ranges>.made;
        } orwith $<class-atom-no-dash> {
            my $class = $<class-atom-no-dash>.made;
            with $<non-empty-class-ranges-no-dash> {
                $class ~= $<non-empty-class-ranges-no-dash>.made;
            }
            make $class;
        } else {
            make $<class-atom>>>.made;
        }
    }

    method non-empty-class-ranges-no-dash($/) {
        with $<class-ranges> {
            make $<class-atom-no-dash>.made ~ '..' ~ $<class-atom>.made ~ $<class-ranges>.made;
        } orwith $<class-atom> {
            make $<class-atom>.made;
        } else {
            make $<class-atom-no-dash> ~ ' ' ~ $<non-empty-class-ranges-no-dash>.made;
        }
    }

    method class-atom($/) {
        if $/.Str eq '-' {
            make '-';
        } else {
            make $<class-atom-no-dash>.made;
        }
    }

    method class-atom-no-dash($/) {
        with $<class-escape> {
            make $<class-escape>.made;
        } else {
            make ~$/;
        }
    }

    method class-escape($/) {
        with $<decimal-digits> {
            my $num = $<decimal-digits>.made.Int;
            make '$' ~ --$num;
        } orwith $<character-escape> {
            make $<character-escape>.made;
        } orwith $<character-class-escape> {
            make '\\' ~ $<character-class-escape>.made;
        } else {
            make "<|w>";
        }
    }
}

class ECMA262Regex {
    method validate($str) {
        so ECMA262Regex::Parser.parse($str);
    }

    method as-perl6($str) {
        my $regex = ECMA262Regex::Parser.parse($str, actions => ECMA262Regex::ToPerl6Regex);
        unless $regex.defined {
            die 'Regex is not valid!';
        }
        $regex.made;
    }

    method compile($regex) {
        use MONKEY-SEE-NO-EVAL;
        my $pattern = self.as-perl6($regex);
        my $compiled = EVAL '/' ~ $pattern ~ '/';
        $compiled;
    }
}
