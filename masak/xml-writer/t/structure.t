use Test;
plan 8;

use XML::Writer;

dies-ok {XML::Writer.serialize() }, 'Cannot serialize nothing';

is XML::Writer.serialize(:x[]), '<x />', 'Single root element (named)';
is XML::Writer.serialize((:x[])), '<x />', 'Single root element (positional)';

dies-ok {XML::Writer.serialize((:x[]), :x[]) }, 'Can either pass named or positional';

is XML::Writer.serialize(:x['foo']), '<x>foo</x>',
    'Single root element with text contents';

is XML::Writer.serialize(:x[:a<b>, 'foo']), '<x a="b">foo</x>', 'attribute';

is XML::Writer.serialize(:x[12]), '<x>12</x>', 'numbers also work like text';

# check that very long XML output occasionally contains a newline

my $xml = :longidentifier[
    (1..20).flatmap: { ; "foobarbaz$_" => [ 'abc' x 5 ] }
];

ok XML::Writer.serialize($xml).match(rx/\n/, :x(5)),
    'Long XML is occasionally line-wrapped';

# vim: ft=perl6
