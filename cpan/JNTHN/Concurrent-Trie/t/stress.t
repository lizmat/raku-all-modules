use Concurrent::Trie;
use Test;

# The basic principle of this test is that we insert sequences of chars that
# match the pattern lowercase/uppercase/lowercase/uppercase. Every working
# inserter thread does an insert, then checks that what it just inserted is
# contained. Another thread produces invalid strings and checks they can
# never be contained bogusly. Another continuously calls entries and checks
# it can iterate them and never sees a string that doesn't match the pattern.
# The lookup ones just run until program end.

my $ct = Concurrent::Trie.new;

my @inserters = start {
    my @inserted;
    for ^5000 {
        my $random = (|(('a'..'z').pick, ('A'..'Z').pick) xx (1..5).pick).join;
        $ct.insert($random);
        die "Oops, inserted $random is missing; got $ct.entries().join(",")"
            unless $ct.contains($random);
        @inserted.push($random);
    }
    @inserted.unique
} xx 2;

my $contains-check = start loop {
    my $random = (|(('A'..'Z').pick, ('a'..'z').pick) xx (1..5).pick).join;
    die "Oops, bogus entry $random" if $ct.contains($random);
}

my $entries-check = start loop {
    for $ct.entries {
        die "Oops, bogus entry $_" unless /^ [<:Ll><:Lu>] ** 1..5 $/;
    }
}

my @all-inserted = await(@inserters).map(*.Slip).unique.sort;
is-deeply [$ct.entries.sort], @all-inserted,
    'All inserted entries found in the trie';

isnt $contains-check.status, Broken, 'No errors from contains checks';
isnt $entries-check.status, Broken, 'No errors from entries checks';

done-testing;
