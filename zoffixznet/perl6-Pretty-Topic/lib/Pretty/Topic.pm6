sub EXPORT (Str $topic = '') {
    $topic
        or die 'You must give Pretty::Topic a topic string on the `use` line';

    $topic ~~ /'<' | '>'/ and die "Using '<' or '>' in topic alias is not"
        ~ " implemented. Feel free to request it on the bug tracker";

    { "&term:<$topic>" => sub { $CALLER::_ } };
}
