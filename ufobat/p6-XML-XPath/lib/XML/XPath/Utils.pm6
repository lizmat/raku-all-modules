use v6.c;

unit module XML::XPath::Utils;

sub unwrap ($a, :$to-nil) is export {
    if $a ~~ Array {
        if $a.elems == 1 {
            return $a[0];
        } elsif $a.elems == 0 {
            return $to-nil ?? Nil !! False;
        } else {
            return $a;
        }
    }
}

sub namespace-infos ($node) is export {
    $node.name    ~~ / [ (<-[:]>+) ':' ]?  (<-[:]>+)/;
    my $node-ns   = $/[0];
    my $node-name = $/[1];
    my $uri       = $node-ns ?? $node.nsURI($node-ns) !! $node.nsURI();
    return ($uri, $node-name, $node-ns);
}
