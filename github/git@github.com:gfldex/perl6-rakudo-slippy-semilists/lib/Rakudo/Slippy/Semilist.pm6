use v6;
use nqp;

multi sub postcircumfix:<{|| }>(\SELF, \indices) is raw is export {
    my \target = IterationBuffer.new;
    MD-HASH-SLICE-ONE-POSITION(SELF, indices, indices.AT-POS(0), 0, target);
    nqp::p6bindattrinvres(nqp::create(List), List, '$!reified', target)
};

multi sub postcircumfix:<{|| }>(\SELF, \indices, :$exists!) is raw is export {
    sub recurse-at-key(\SELF, \indices, \counter){
        my $idx = indices[counter];
        (counter < indices.elems) 
            ?? SELF.EXISTS-KEY($idx) && recurse-at-key(SELF{$idx}, indices, counter + 1) 
            !! True
    }

    recurse-at-key(SELF, indices, 0)
};

multi sub postcircumfix:<{; }>(\SELF, @indices, :$exists!) is raw is export {
    sub recurse-at-key(\SELF, \indices, \counter){
        my $idx = indices[counter];
        (counter < indices.elems) 
            ?? SELF.EXISTS-KEY($idx) && recurse-at-key(SELF{$idx}, indices, counter + 1) 
            !! True
    }

    recurse-at-key(SELF, @indices, 0)
};

