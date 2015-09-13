unit module BufUtils:auth<github:flussence>:ver<0.0.3>;

our sub infix:<x>(Stringy \piece, Int \count --> Stringy) is export {
    [~] piece xx count
}

our sub index(
    Blob $haystack,
    Blob $needle,
    Cool $startpos = 0 --> Int) is export {
    return Int if $haystack.elems - $startpos < $needle.elems;

    # This is a really sucky brute-force search, but it'll do for demonstration
    return ($startpos..$haystack.elems - $needle.elems).first({
        $haystack.subbuf($^offset, $needle.elems) eq $needle;
    }) // Int;
}

our sub starts-with(Blob $_, Blob $needle --> Bool:D) is export {
    .subbuf(0, $needle.elems) eq $needle;
}

our sub ends-with(Blob $_, Blob $needle --> Bool:D) is export {
    .subbuf(.elems - $needle.elems) eq $needle;
}

our sub chomp(Blob $_ --> Blob) is export {
    my $eol = "\n".encode;

    ends-with($_, $eol) ?? .subbuf(0, .elems - $eol.bytes)
                        !! $_;
}

our sub lc(Blob $_ --> Blob) is export { .decode.lc.encode }
our sub uc(Blob $_ --> Blob) is export { .decode.uc.encode }
our sub tc(Blob $_ --> Blob) is export { .decode.tc.encode }
our sub tclc(Blob $_ --> Blob) is export { .decode.tclc.encode }

our sub unival(utf8 $_ --> Numeric) is export { .decode('utf-8').unival }
our sub univals(utf8 $_ --> Seq) is export { .decode('utf-8').univals }
