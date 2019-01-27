use Test;
plan 5;

use JSON::Path;
use JSON::Fast;

my $object = {
    'foo' => [
        {
            'bar' => 1,
        },
        {
            'bar' => 2,
        },
        {
            'bar' => 3,
        },
    ]
};

{
    my $jpath = JSON::Path.new('$.foo[0]');
    my @values = $jpath.values(to-json($object));
    is(@values.elems, 1, 'Only returned a single result.');
}

{
    my $jpath = JSON::Path.new('$.foo[0,1]');
    my @values = $jpath.values(to-json($object));
    is(@values.elems, 2, 'Returned two results.');
}

{
    my $jpath = JSON::Path.new('$.foo[1:3]');
    my @values = $jpath.values(to-json($object));
    is(@values.elems, 2, 'Returned two results.');
}

{
    my $jpath = JSON::Path.new('$.foo[-1:]');
    my @values = $jpath.values(to-json($object));
    is(@values.elems, 1, 'Returned one result.');
    is(@values[0]<bar>, 3, 'Correct result.');
}
