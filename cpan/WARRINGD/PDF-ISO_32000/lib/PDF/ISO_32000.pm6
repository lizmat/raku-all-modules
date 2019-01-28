unit class PDF::ISO_32000:ver<0.0.5>;

use JSON::Fast;

# run-time introspection of PDF specification content
# stub for now

method resources { %?RESOURCES }

method table($name) {
    from-json($.resources{'ISO_32000/' ~ $name ~ '.json'}.slurp)<table>;
}

method table-index {
    (state $ //= from-json($.resources{'ISO_32000-index.json'}.slurp)).list;
}

multi method appendix {
    $.table-index[0];
}
