use v6.d;
use lib './t', './build-tools/lib';
use Test;
use OOPTest;
use OO::Plugin;
use OO::Plugin::Manager;

my @variants =
    (
        # +-→ 4
        # |   ↑
        # 0 → 1 → 3
        #     ↓
        #     2
        {
            name => "simple circling",
            count => 5,
            deps => {
                after => {
                    0 => (1, 4),
                    1 => (2, 3, 4),
                },
            },
            verify => {
                order => { # Defines what plugins must preceede a given (key) one
                    0 => (1, 2, 3, 4),
                    1 => (2, 3, 4),
                }
            },
        },
        {
            name => "circle of 4 with single 'after'",
            count => 4,
            deps => {
                after => {
                    3 => 0,
                },
                demand => {
                    0 => 1,
                    1 => 2,
                    2 => 3,
                },
            },
            verify => {
                order => {
                    2 => 3,
                    1 => (2,3),
                    0 => (1,2,3),
                },
            },
        },
        # 0 ----->  5
        #      +- / ^
        #      v    |
        # 1 -> 2 -> 4
        # 3
        {
            name => "circling group and priorities",
            count => 6,
            priority => {
                plugFirst => {
                    :idx[0,4],
                    :with-order,
                },
                plugLast => {
                    :idx[3],
                },
            },
            deps => {
                after => {
                    0 => 5,
                    1 => 2,
                    2 => 4,
                    4 => 5,
                    5 => 2,
                },
            },
            verify => {
                order => {
                    0 => (5,2,4),
                    1 => (2,4,5),
                    5 => (2,4), # Due to high prio of 0, 5 will always follow 2,4 eventhough they form a circle
                    3 => (0,1,2,4,5),
                },
            },
        },
        # 0 -> 1 -> 2 -> 3 -> 4 -> 5
        #                     ^    |
        #                     |    v
        #                     +--- 6
        {
            name => "demand sub-cycle",
            count => 7,
            priority => { # Use priority to always have 4 at the circle start to have steady disabled messages
                    plugFirst => {
                        :idx[0],
                    },
            },
            deps => {
                    after => {
                        0 => 1,
                        1 => 2,
                        2 => 3,
                    },
                    demand => {
                        3 => 4,
                        4 => 5,
                        5 => 6,
                        6 => 4,
                    },
            },
            verify => {
                order => {
                    0 => (1,2),
                    1 => 2,
                },
                disabled => {
                    3 => rx:s/^Demands disabled /,
                    4 => rx:s/^Participated in a demand circle/,
                    5 => rx:s/^Demands disabled /,
                    6 => rx:s/^Demands disabled /,
                },
            },
        },
        # 0 <- 1 <- 2 <- 3 -> 8
        #           |    ^    |
        #           v    |    v
        #           7    4 <- 9
        #           |    ^
        #           v    |
        #           6 -> 5
        # The only non-demanding link is 4 -> 3
        {
            name => "double cycle",
            count => 10,
            # priority => {
            #     plugFirst => {
            #         #:idx[9], # To start sorting with this plugin
            #         :idx[4], # To start sorting with this plugin
            #     },
            # },
            deps => {
                after => {
                    4 => 3, # This is where two cycles meet and where they're broken into allowed chains
                },
                demand => {
                    1 => 0,
                    2 => (1, 7),
                    3 => (2, 8),
                    5 => 4,
                    6 => 5,
                    7 => 6,
                    8 => 9,
                    9 => 4,
                },
            },
            verify => {
                order => {
                    1 => 0,
                    2 => (1,0,7,6,5,4),
                    3 => (2,1,0,8,9,4),
                    5 => 4,
                    6 => (5,4),
                    7 => (6,5,4),
                    8 => (9,4),
                },
            },
        },
        {
            name => "double cycle with hanging tails",
            count => 15,
            # priority => {
            #     plugFirst => {
            #         #:idx[9], # To start sorting with this plugin
            #         :idx[4], # To start sorting with this plugin
            #     },
            # },
            deps => {
                after => {
                    4 => 3,
                    9 => 10,
                    10 => (11,12),
                },
                demand => {
                    1 => 0,
                    2 => (1, 7),
                    3 => (2, 8),
                    4 => 7,
                    5 => 4,
                    6 => (5, 13),
                    7 => 6,
                    8 => 9,
                    9 => 4,
                    13 => 14,
                },
            },
            verify => {
                order => {
                    1 => 0,
                    13 => 14,
                    10 => (11,12),
                },
                disabled => {
                    2 => rx:s/^[Demands disabled |Participated in a demand circle ]/,
                    3 => rx:s/^[Demands disabled |Participated in a demand circle ]/,
                    4 => rx:s/^[Demands disabled |Participated in a demand circle ]/,
                    5 => rx:s/^[Demands disabled |Participated in a demand circle ]/,
                    6 => rx:s/^[Demands disabled |Participated in a demand circle ]/,
                    7 => rx:s/^[Demands disabled |Participated in a demand circle ]/,
                    8 => rx:s/^[Demands disabled |Participated in a demand circle ]/,
                    9 => rx:s/^[Demands disabled |Participated in a demand circle ]/,
                },
            },
        },
        {
            name => "dependecy override priority",
            count => 4,
            priority => {
                plugFirst => {
                    :idx[3,1,2],
                    :with-order,
                },
                plugLast => {
                    :idx[0],
                },
            },
            deps => {
                after => {
                    1 => 0, # This will override plugLast
                    0 => 2, # This will override order
                },
            },
            verify => {
                order => {
                    0 => (2,3),
                    1 => (0,2,3),
                    2 => (3),
                },
            },
        }
    );

plan @variants.elems;

my @prev-plugins;
for @variants -> %variant {
    subtest "Testing: %variant<name>" => {
        my $test-count = %variant<verify><order>.elems;
        $test-count += .elems × 2 with %variant<verify><disabled>;
        plan $test-count;
        my @plugins = gen-plugins( %variant );
        # note @plugins.perl;
        bail-out "expected %variant<count> plugins, generated " ~ @plugins.elems if  @plugins.elems ≠ %variant<count>;
        my $mgr = OO::Plugin::Manager.new( :!debug );
        for %variant<priority>.kv -> $prio,%pp {
            my @pnames = %pp<idx>.map: { @plugins[$_].^name };
            $mgr.set-priority( @pnames, PlugPriority::{$prio}, with-order => %pp<with-order> );
        }
        $mgr.disable(@prev-plugins, "it's from another subtest");
        $mgr.initialize;
        my %n2i = (^@plugins.elems).map( { @plugins[$_].^name => $_ } );
        # note "= N2I: ", %n2i;
        # note (^@plugins.elems).map( { $_ ~ ":" ~ @plugins[$_].^name } ).join(", ");
        my @idx-order = $mgr.order.map( { %n2i{$_} } );
        # diag "Final order: " ~ @idx-order.join(", ");
        bail-out "Duplicate entries in sort result, major algorithm failure"
            if Bag.new( @idx-order ).values.grep( * > 1 ).elems > 0;
        my %idx-map = ( ^@idx-order.elems ).map: { @idx-order[$_] => $_ };
        # note "= IDX-MAP: ", %idx-map;

        if %variant<verify> -> %verify {
            if %verify<order> -> %order {
                for %order.keys.sort -> $base-pnum {
                    my $text = "$base-pnum follows " ~ %order{$base-pnum}.values.join(",");
                    # note "TEXT : ", $text;
                    # note "ORDER: ", %order;
                    ok so ( %idx-map{ $base-pnum } > all @( %order{ $base-pnum }.map: { %idx-map{ $_ } } ) ), $text;
                }
            }

            if %verify<disabled> -> %disabled {
                for %disabled.keys.sort -> $pnum {
                    ok $mgr.disabled( @plugins[$pnum] ), "$pnum is disabled";
                    like $mgr.disabled( @plugins[$pnum] ), %disabled{$pnum}, "disable reason for $pnum";
                }
            }
        }

        @prev-plugins.append: @plugins;
        done-testing;
    }
}

done-testing;

# vim: ft=perl6
