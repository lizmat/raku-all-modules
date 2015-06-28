unit module BufUtils:auth<github:flussence>:ver<0.0.1>;

our sub infix:<x>(Stringy \piece, Int \count) returns Stringy is export {
    [~] piece xx count
}

our sub index(
    Blob $haystack,
    Blob $needle,
    Cool $startpos = 0) returns Int is export {
    return Int if $haystack.elems - $startpos < $needle.elems;

    # This is a really sucky brute-force search, but it'll do for demonstration
    return ($startpos..$haystack.elems - $needle.elems).first({
        $haystack.subbuf($_, $needle.elems) eq $needle;
    }) // Int;
}

our sub starts-with(Blob $b, Blob $needle) returns Bool:D is export {
    $b.subbuf(0, $needle.elems) eq $needle;
}

our sub ends-with(Blob $b, Blob $needle) returns Bool:D is export {
    $b.subbuf($b.elems - $needle.elems) eq $needle;
}
