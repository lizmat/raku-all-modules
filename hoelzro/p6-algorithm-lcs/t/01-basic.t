use v6;
use Test;
use Algorithm::LCS;

plan *;

is-deeply([lcs(<A B C>, <D E F>)], [], 'the lcs of two sequences with nothing in common should be empty');
is-deeply([lcs(<A B C>, <A B C>)], [<A B C>], 'the lcs of two identical sequences should be the that sequence');
is-deeply([lcs(<A B C D E F>, <A B C>)], [<A B C>], 'the lcs of two sequences where one is the prefix of the other should be the prefix');
is-deeply([lcs(<A B C>, <A B C D E F>)], [<A B C>], 'the lcs of two sequences where one is the prefix of the other should be the prefix');
is-deeply([lcs(<A B C D E F>, <D E F>)], [<D E F>], 'the lcs of two sequences where one is the suffix of the other should be the suffix');
is-deeply([lcs(<D E F>, <A B C D E F>)], [<D E F>], 'the lcs of two sequences where one is the suffix of the other should be the suffix');
is-deeply([lcs(<A B C D E F>, <A B C G H I>)], [<A B C>]);
is-deeply([lcs(<A B C G H I>, <A B C D E F>)], [<A B C>]);
is-deeply([lcs(<A B C D E F>, <A B C G E I>)], [<A B C E>]);
is-deeply([lcs(<A B C G E I>, <A B C D E F>)], [<A B C E>]);
is-deeply([lcs(<A B C D E F>, <G H I D E F>)], [<D E F>]);
is-deeply([lcs(<G H I D E F>, <A B C D E F>)], [<D E F>]);
is-deeply([lcs(<A B C D E F>, <G B I D E F>)], [<B D E F>]);
is-deeply([lcs(<G B I D E F>, <A B C D E F>)], [<B D E F>]);
is-deeply([lcs(<A B C L M N X Y Z>, <A B C P Q R X Y Z>)], [<A B C X Y Z>]);
is-deeply([lcs(<A B C D E F G>, <B C D G K>)], [<B C D G>]);
is-deeply([lcs(<A B C D E F G>, <A C E G>)], [<A C E G>]);

done;
