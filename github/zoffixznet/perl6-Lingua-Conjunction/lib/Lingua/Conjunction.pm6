unit package Lingua::Conjunction:ver<1.001001>;

# This handy table was partially borrowed from
# https://metacpan.org/pod/Lingua::Conjunction
my %language =
    af => { last => True,  con => 'en',  dis => 'of'    },
    da => { last => True,  con => 'og',  dis => 'eller' },
    de => { last => True,  con => 'und', dis => 'oder'  },
    en => { last => True,  con => 'and', dis => 'or'    },
    es => { last => True,  con => 'y',   dis => 'o'     },
    fi => { last => True,  con => 'ja',  dis => 'tai'   },
    fr => { last => False, con => 'et',  dis => 'ou'    },
    it => { last => True,  con => 'e',   dis => 'o'     },
    la => { last => True,  con => 'et',  dis => 'vel'   },
    nl => { last => True,  con => 'en',  dis => 'of'    },
    no => { last => False, con => 'og',  dis => 'eller' },
    pt => { last => True,  con => 'e',   dis => 'ou'    },
    sw => { last => True,  con => 'na',  dis => 'au'    },
;

sub conjunction (
    *@els,
    Str:D  :$lang                     = 'en',
    Str:D  :$sep is copy              = ',',
    Str:D  :$alt                      = ';',
    Str:D  :$con                      = %language{ $lang }<con>,
    Str:D  :$dis                      = %language{ $lang }<dis>,
    Bool:D :$last                     = %language{ $lang }<last>,
    Str:D  :$type where any(<and or>) = 'and',
    Str:D  :$str                      = '|list|',
) returns Str is export {
    my $sep-word = $type eq 'and' ?? $con !! $dis;
    $sep = $alt if @els.grep(/$sep/);
    my $list = do given @els.elems {
        when 0 { ''                       }
        when 1 { @els[0]                  }
        when 2 { @els.join(" $sep-word ") }
        default {
            @els[0..*-2].join("$sep ")
            ~ "{$last ?? $sep !! ''} $sep-word @els[*-1]";
        }
    }
    return $str.subst(
        / '[' (<-[|]>*) '|' (<-[\]]>*) ']'/,
        {@els.elems == 0 || @els.elems > 2 ?? $1 !! $0}, :g
    ).subst('|list|', $list, :g);
}
