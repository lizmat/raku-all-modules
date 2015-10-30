use v6;
use Test;

use Test::Base::Grammar;
use Test::Base::Actions;

subtest {
    my $got = Test::Base::Grammar.parse(q:to/EOD/, :actions(Test::Base::Actions));
    === hogehoge
    --- ONLY
    --- input
    xxx
    --- expected
    yyy
    EOD
    ok $got;
    is-deeply $got.made, [
        Test::Base::Block.new(
            "hogehoge", {:ONLY(""), :expected("yyy\n"), :input("xxx\n")}
        )
    ];
}, 'simple';

subtest {
    my $got = Test::Base::Grammar.parse(q:to/EOD/, :actions(Test::Base::Actions));

    === foo
    --- input: yyy
    --- expected: zzz

    === bar
    --- input
    xxx
    --- expected
    ppp
    EOD

    ok $got;
    is-deeply $got.made, [
        Test::Base::Block.new("foo", {:expected("zzz"), :input("yyy")}),
        Test::Base::Block.new("bar", {:expected("ppp\n"), :input("xxx\n")})
    ];
}, 'multi';

subtest {
    my $got = Test::Base::Grammar.parse(q:to/EOD/, :actions(Test::Base::Actions));

    ===
    --- input: yyy
    --- expected: zzz
    EOD

    ok $got;
    is-deeply $got.made, [
        Test::Base::Block.new("", {:expected("zzz"), :input("yyy")}),
    ];
}, 'no title';

done-testing;
