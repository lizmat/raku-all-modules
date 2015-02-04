module TOML;
use TOML::Grammar;

sub from-toml($text) is export {
    TOML::Grammar.parse($text).ast;
}

sub quot-maybe(Str $_) { m/<-[A..Za..z0..9_-]>/ ?? .perl !! $_ }

proto to-toml(|) is export {*}
multi to-toml(%t, :$prev-keys = '') {
    if %t == 0 {
        "";
    } else {
        my @after;
        join "\n", (%t{*}:kv).map(-> $key, $val {
            my $fullname = $prev-keys ~ quot-maybe $key;
            if $val ~~ Associative {
                push @after, "["~$fullname~"]\n" ~ to-toml $val, prev-keys => $fullname ~ '.';
                next;
            } elsif $val ~~ Positional {
                push @after, to-toml $val, prev-keys => $fullname;
                next;
            } else {
                quot-maybe($key) ~ " = " ~ to-toml-val($val);
            }
        }), @after;
    }
}
multi to-toml(@t, :$prev-keys = '') {
    join "\n", @t.map({
        die "TOML arrays may only be of a single type" unless $_ ~~ Associative;
        "[["~$prev-keys~"]]\n" ~ to-toml($_, :prev-keys($prev-keys~'.'))
    })
}

proto to-toml-val(|) is export(:ALL) {*}
multi to-toml-val(Mu $t) {
    die "Don't know how to represent $t.perl() as a TOML value.";
}

multi to-toml-val(@t) { <[ ]>.join: join ",", @t.map(&to-toml) }

multi to-toml-val(Str $s) { $s.perl }

multi to-toml-val(Numeric $n) { $n.perl }

multi to-toml-val(DateTime $d) { $d.Str }

multi to-toml-val(True)  { "true" }
multi to-toml-val(False) { "false" }
