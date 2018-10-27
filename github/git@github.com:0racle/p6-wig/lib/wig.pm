unit package wig;

use MONKEY-TYPING;
augment class Any {

    # Method
    proto method where(|) is nodal { * }
    multi method where(|c) {
        self.grep(|c)
    }

    # Function
    proto sub where(|) is export {*}
    multi sub where(Mu $t, +values, *%a) {
        my $laze = values.is-lazy;
        values.grep($t,|%a).lazy-if($laze)
    }
    multi sub where(Bool:D $t,|) {
        fail X::Match::Bool.new( type => 'where' )
    }
}

#`{
Rakudo currently has a cache invalidation issue where child classes don't
automatically inherit augmented methods from a Parent class. Until this is 
fixed, the work around is is to call .^compose on your desired child types.
I haven't called it on every class under Any, just the ones grep is used with
most frequently. Feel free to modify this list of types to suit your needs.
}

(List,Array,Range,Seq,Cool,Slip,Map,Pair,Hash,Set,Bag,BagHash,Mix,Str,Int).map( *.^compose );

# Supply's grep is it's own thing ( not Any's ) so we augment it here

augment class Supply {
    method where(|c) {
        self.grep(|c);
    }
} 

# Because we are augmenting a specific class, there is no need to .^compose

