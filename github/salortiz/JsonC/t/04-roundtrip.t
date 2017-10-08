use v6;
use Test;
use JsonC;

# Originally this test, stolen from JSON::Fast, was testing for Rat, not Num,
# but neither JSON spec nor json-c in fact can't handle Perl6's Rat.
# So I prefer not to lie.

my @s =
        'Int'            => [ 1 ],
        'Num'            => [ 3.2e0 ],
        'Str'            => [ 'one' ],
        'Str with quote' => [ '"foo"'],
        'Undef'          => [ {}, 1 ],
        'other escapes'  => [ "\\/\"\n\r\tfoo\\"],
        'Non-ASCII'      => [ 'möp stüff' ],
        'Empty Array'    => [ ],
        'Array of Int'   => [ 1, 2, 3, 123123123 ],
        'Array of Num'   => [ 1.3e0, 2.8e0, 32323423.4e0, 4 ],
        'Array of Str'   => [ <one two three gazooba> ],
        'Array of Undef' => [ Any, Any ],
        'Empty Hash'     => {},
        'Undef Hash Val' => { key => Any },
        'Hash of Int'    => { :one(1), :two(2), :three(3) },
        'Hash of Num'    => { :one-and-some[1], :almost-pie(3.3e0) },
        'Hash of Str'    => { :one<yes_one>, :two<but_two> },
        'Array of Stuff' => [ { 'A hash' => 1 }, [<an array again>], 2],
        'Hash of Stuff'  =>
                            {
                                keyone   => [<an array>],
                                keytwo   => "A string",
                                keythree => { "another" => "hash" },
                                keyfour  => 4,
                                keyfive  => False,
                                keysix   => True,
                                keyseven => 3.2e0,
                            };

plan +@s;

for @s.kv -> $k, $v {
    my $r = from-json( to-json( $v.value, :!pretty ) );
    is-deeply $r, $v.value, $v.key;
}

# vim: ft=perl6
