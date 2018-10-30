use v6;

class Algorithm::Soundex {

    method soundex ($string --> Str ) {
        return '' unless $string;
        my $soundex = $string.substr(0,1).uc;
        gather {
                take $soundex;
                my $fakefirst = '';
                $fakefirst = "de " if $soundex ~~ /^ <[AEIOUWH]> /;
                "$fakefirst$string".lc.trans('wh' => '') ~~ /
                    ^
                    [
                        [
                        | <[ bfpv     ]>+ { take 1 }
                        | <[ cgjkqsxz ]>+ { take 2 }
                        | <[ dt       ]>+ { take 3 }
                        | <[ l        ]>+ { take 4 }
                        | <[ mn       ]>+ { take 5 }
                        | <[ r        ]>+ { take 6 }
                        ]
                    || .
                    ]+
                    $ { take 0,0,0 }
                /;
            }.flat.[0,2,3,4].join;
    }

}
=begin pod

=head1 NAME

Algorithm::Soundex - Soundex Algorithms

=head1 DESCRIPTION

Currently this module contains the American Soundex algorithm, implemented in Perl 6.

If you would like to add other Soundex algorithms, Patches Welcome! No, they are
*actually* welcome :)

=head1 SYNOPSIS

=begin code

    use v6;
    use Algorithm::Soundex;

    my Algorithm::Soundex $s .= new();
    my $soundex               = $s.soundex("Leto");
    say "The soundex of Leto is $soundex";

=end code

=head1 AUTHOR

Jonathan "Duke" Leto - L<jonathan@leto.net>

=end pod
