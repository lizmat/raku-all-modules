JSON::Path gives you the power to deeply index data structures (containing
arrays and hashes) with path expressions.

    # index into { kitchen => { drawers => [ { fork => '!' } ] } }
    my $path = JSON::Path.new('$.kitchen.drawers[0].fork');

[JsonPath](http://goessner.net/articles/JsonPath/) is like XPath but adapted
for JSON. It simplifies and adapts the path expressions a bit, to better fit
the data structures stored by JSON. You can read more about the syntax by
following that link there, but here's a summary:

    $           root node
    .key        index hash key
    .*          index all hash keys
    ['key']     index hash key
    [2]         index array element
    [0,1]       index array slice
    [4:5]       index array range
    [:5]        index from the beginning
    [-3:]       index to the end
    [*]         index all array elements
    [?(expr)]   filter on (Perl 6) expression
    ..key       search all descendants for hash key

The module is functionally a port of CPAN's JSON::Path, even though the
internals look quite different.
