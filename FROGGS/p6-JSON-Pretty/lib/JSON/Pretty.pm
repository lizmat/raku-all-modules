# =begin Pod
# 
# =head1 JSON::Pretty
# 
# C<JSON::Pretty> is a minimalistic module that reads and writes JSON.
# It supports strings, numbers, arrays and hashes (no custom objects).
# 
# =head1 Synopsis
# 
#     use JSON::Pretty;
#     my $json = to-json([1, 2, "a third item"]);
#     my $copy-of-original-data-structure = from-json($json);
# 
# =end Pod

unit module JSON::Pretty;

proto to-json($, :$indent = 0, :$first = 0) is export {*}

my $s = 2;
multi to-json(Real:D $d, :$indent = 0, :$first = 0) { (' ' x $first) ~ ~$d }
multi to-json(Bool:D $d, :$indent = 0, :$first = 0) { (' ' x $first) ~ ($d ?? 'true' !! 'false') }
multi to-json(Str:D $d, :$indent = 0, :$first = 0) {
    (' ' x $first) ~ '"'
    ~ $d.trans(['"', '\\', "\b", "\f", "\n", "\r", "\t"]
            => ['\"', '\\\\', '\b', '\f', '\n', '\r', '\t'])\
            .subst(/<-[\c32..\c126]>/, { ord(~$_).fmt('\u%04x') }, :g)
    ~ '"'
}
multi to-json(Positional:D $d, :$indent = 0, :$first = 0) {
    return (' ' x $first) ~ "\["
            ~ ($d ?? $d.map({ "\n" ~ to-json($_, :indent($indent + $s), :first($indent + $s)) }).join(",") ~ "\n" ~ (' ' x $indent) !! ' ')
            ~ ']';
}
multi to-json(Associative:D $d, :$indent = 0, :$first = 0) {
    return (' ' x $first) ~ "\{"
            ~ ($d ?? $d.map({ "\n" ~ to-json(.key, :first($indent + $s)) ~ ' : ' ~ to-json(.value, :indent($indent + $s)) }).join(",") ~ "\n" ~ (' ' x $indent) !! ' ')
            ~ '}';
}

multi to-json(Mu:U $, :$indent = 0, :$first = 0) { 'null' }
multi to-json(Mu:D $s, :$indent = 0, :$first = 0) {
    die "Can't serialize an object of type " ~ $s.WHAT.perl
}

sub from-json($text) is export {
    use JSON::Tiny;
    from-json($text)
}
# vim: ft=perl6
