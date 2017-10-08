use v6;

unit class Router::Boost::Node;

has $.leaf is rw;
has Str $.key;
has @.children = [];

method add-node(Router::Boost::Node:D: Str $child) {
    for @.children -> $c {
        if $c.key eq $child {
            return $c;
        }
    }

    my $new-node = Router::Boost::Node.new(:key($child));
    @.children.push($new-node);
    return $new-node;
}

