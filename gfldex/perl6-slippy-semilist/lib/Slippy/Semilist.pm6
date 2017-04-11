use v6;

multi sub postcircumfix:<{|| }>(\SELF, \indices) is raw is export {
    my $current = SELF;
    for indices {
        if ! $current.EXISTS-KEY($_) {
            my $next = Hash.new;
            $current.BIND-KEY($_, $next);
        }
        $current := $current.AT-KEY($_);
    }

    $current.return-rw
}

multi sub postcircumfix:<{|| }>(\SELF, \indices, :$exists!) is raw is export {
    sub recurse-at-key(\SELF, \indices, \counter){
        my $idx = indices[counter];
        (counter < indices.elems) 
            ?? SELF.EXISTS-KEY($idx) && recurse-at-key(SELF{$idx}, indices, counter + 1) 
            !! True
    }

    recurse-at-key(SELF, indices, 0)
}

multi sub postcircumfix:<{; }>(\SELF, @indices, :$exists!) is raw is export {
    sub recurse-at-key(\SELF, \indices, \counter){
        my $idx = indices[counter];
        (counter < indices.elems) 
            ?? SELF.EXISTS-KEY($idx) && recurse-at-key(SELF{$idx}, indices, counter + 1) 
            !! True
    }

    recurse-at-key(SELF, @indices, 0)
}

