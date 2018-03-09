use Concurrent::Trie;
use Test;

given Concurrent::Trie.new -> $ct {
    nok $ct.contains('x'), 'Empty Trie does not contain x';
    nok $ct.contains('foo'), 'Empty Trie does not contain foo';
    is-deeply $ct.entries.list, (), 'No entries in empty Trie';
    is-deeply $ct.entries('').list, (), '...even with empty prefix';
    is-deeply $ct.entries('x').list, (), '...and especially with non-empty prefix';
    is $ct.elems, 0, 'Empty Trie has 0 elems';
    nok $ct, 'Emptry Trie is falsey';

    lives-ok { $ct.insert('a') }, 'Can insert one-char string to trie';
    ok $ct.contains('a'), 'Now contains that one-char string';
    nok $ct.contains('b'), 'Does not contain a different one-char string';
    nok $ct.contains('ab'),
        'Does not contain a two-char string with prefix of the one we added';
    is $ct.elems, 1, 'Trie now has 1 element';
    ok $ct, 'Trie is now truthy';
    is-deeply $ct.entries.list, ('a',), 'Correct entries result';
    is-deeply $ct.entries('a'), ('a',), 'Correct entries result with prefix match';
    is-deeply $ct.entries('aa'), (), 'No entries for prefix non-match (1)';
    is-deeply $ct.entries('b'), (), 'No entries for prefix non-match (2)';

    lives-ok { $ct.insert('abc') }, 'Can make second insertion';
    ok $ct.contains('a'), 'Still contains original entry';
    ok $ct.contains('abc'), 'Also contains second entry';
    nok $ct.contains('ab'), 'Does not falsely report partial entry';
    nok $ct.contains('b'), 'Does not contain something not added';
    is-deeply $ct.entries.sort.list, ('a', 'abc'), 'Correct 2 entries in result';
    is-deeply $ct.entries('a').sort.list, ('a', 'abc'),
        'Correct 2 entries that have shared prefix';
    is-deeply $ct.entries('ab').list, ('abc',),
        'Do not result result shorter than the prefix';
    is-deeply $ct.entries('b'), (), 'No entries for prefix non-match';

    lives-ok { $ct.insert('wxyz') }, 'Can make third entry';
    is-deeply $ct.entries.sort.list, ('a', 'abc', 'wxyz'), 'Have all 3 entries';

    nok $ct.contains('wx'), 'Does not falsely report partial entry';
    nok $ct.contains('wxyzz'), 'Does not falsely report entry with prefix';
    lives-ok { $ct.insert('wx') }, 'Can insert something with an existing prefix';
    ok $ct.contains('wx'), 'That prefix is now reported as being contained';
    is-deeply $ct.entries.sort.list, ('a', 'abc', 'wx', 'wxyz'),
        'Have all 4 entries in entries list';
    is $ct.elems, 4, 'Trie now has 4 elements';
    ok $ct, 'Trie is still truthy';

    lives-ok { $ct.insert('wxyz') }, 'Adding entry already in there works';
    is-deeply $ct.entries.sort.list, ('a', 'abc', 'wx', 'wxyz'),
        'No duplication in entries list';
    is $ct.elems, 4, 'Re-insertion of existing entry does not increase elems';
    ok $ct, 'Trie is still truthy';
}

given Concurrent::Trie.new -> $ct {
    my @inserted;
    lives-ok
        {
            for ^1000 {
                my $random = (|(('a'..'z').pick, ('A'..'Z').pick) xx (1..5).pick).join;
                $ct.insert($random);
                unless $ct.contains($random) {
                    diag "Oops, inserted $random is missing";
                    die;
                }
                @inserted.push($random);
            }
        },
        'Completed 1000 random inserts, and correct contains result for all';

    @inserted .= unique;
    lives-ok
        {
            for @inserted {
                unless $ct.contains($_) {
                    diag "Oops, in post-check $_ has gone missing";
                    die;
                }
            }
        },
        'All the inserts are still there afterwards';

    is-deeply $ct.entries.sort, @inserted.sort,
        'The entries list contains all the inserted data also';
}

done-testing;
