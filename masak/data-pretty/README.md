## Data::Pretty

When you stringify Perl 6 data structures, you expect sensible results just
like in any modern programming language. Unfortunately, Perl 6 doesn't deliver
on that point; it hasn't shaken off all the weird legacy stringification from
Perl 5.

    $ perl6
    > [1, 2, 3]         # no brackets :(
    1 2 3
    > (1, 2, 3)         # no parens :(
    1 2 3
    > [1, 2, [3, 4]]    # can't see the nesting :(
    1 2 3 4
    > /abc/             # regexes don't say much :(
    
    > sub foo {}        # long ugly number :(
    sub foo () { #`(Sub|140681338496168) ... }

`Data::Pretty` gives you nice default stringifications for arrays, parcels,
hashes, and subroutines.

    > use Data::Pretty
    > [1, 2, 3]         # brackets :)
    [1, 2, 3]
    > (1, 2, 3)         # parens :)
    (1, 2, 3)
    > [1, 2, [3, 4]]    # nesting :)
    [1, 2, [3, 4]]
    > /abc/             # yep, a regex :)
    <regex>
    > sub foo {}        # short and sweet :)
    &foo

I wish Perl 6 itself would implement this kind of stringification of data
structures, making this module obsolete.
