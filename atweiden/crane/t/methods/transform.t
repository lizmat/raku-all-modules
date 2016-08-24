use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use Crane;
use TestCrane;

plan 1;

subtest
{
    # documentation example
    my %market =
        :foods({
            :fruits([qw<blueberries marionberries>]),
            :veggies([qw<collards onions>])
        });
    my @first-fruit = |qw<foods fruits>, 0;
    my @second-veggie = |qw<foods veggies>, 1;
    sub oh-yeah($s) { $s ~ '!' }
    Crane.transform(%market, :path(@first-fruit), :with(&oh-yeah), :in-place);
    is Crane.get(%market, :path(@first-fruit)), 'blueberries!',
        'Is expected value';
    Crane.transform(%market, :path(@second-veggie), :with(&oh-yeah), :in-place);
    is Crane.get(%market, :path(@second-veggie)), 'onions!',
        'Is expected value';

    # Associative deep
    sub resupply(Int $instock) { $instock + 100 }
    my %data = %TestCrane::data;
    my %expected =
        :legumes([
            {
                :instock(104),
                :name("pinto beans"),
                :unit("lbs")
            },
            {
                :instock(121),
                :name("lima beans"),
                :unit("lbs")
            },
            {
                :instock(113),
                :name("black eyed peas"),
                :unit("lbs")
            },
            {
                :instock(108),
                :name("split peas"),
                :unit("lbs")
            }
        ]);
    Crane.transform(
        %data,
        :path('legumes', $_, 'instock'),
        :with(&resupply),
        :in-place
    ) for 0..3;
    is-deeply %data, %expected, 'Is expected value';

    # with raises exception
    sub foo($bar) { die 'foobar' }
    throws-like {Crane.transform(%data, :path(), :with(&foo))},
        X::Crane::TransformCallableRaisedException,
        'Transform operation fails when callable raises exception';

    # with signature faulty
    my %g = :a<alpha>,:b<bravo>,:c<charlie>;
    sub bar() { {:d<delta>} }
    throws-like {Crane.transform(%g, :path(), :with(&bar))},
        X::Crane::TransformCallableSignatureParams,
        'Transform operation fails with faulty callable signature (params)';

    # Associative container root
    sub baz($) { {:r<romeo>} }
    is-deeply Crane.transform(%g, :path(), :with(&baz)), {:r<romeo>},
        'Is expected value';
    is-deeply %g, {:a<alpha>,:b<bravo>,:c<charlie>},
        'Original container is unchanged';

    # immutable path
    my %h = :a(:pair(:is(:not(:a<hash>))));
    sub empty($) { Empty }
    throws-like {Crane.transform(%h, :path(qw<a pair is not>), :with(&empty))},
        X::Crane::Transform::RO,
        'Transform operation fails when path is immutable';

    # with closures
    my %inxi = :info({
        :memory([1564.9, 32140.1]),
        :processes(244),
        :uptime<3:16>
    });
    my %inxi-bak = :info({
        :memory([1564.9, 32140.1]),
        :processes(244),
        :uptime<3:16>
    });
    my %inxi-result-a = :info({
        :memory([15649.0, 32140.1]),
        :processes(244),
        :uptime<3:16>
    });
    my %inxi-result-b = :info({
        :memory([1564.9, 32140.1]),
        :processes(243),
        :uptime<3:16>
    });
    my %inxi-result-c = :info({
        :memory([1564.9, 32140.1, 4.87]),
        :processes(244),
        :uptime<3:16>
    });

    is-deeply
        Crane.transform(
            %inxi,
            :path('info', 'memory', 0),
            :with(-> $r { $r * 10 })
        ),
        %inxi-result-a,
        'Is expected value';
    is-deeply %inxi, %inxi-bak, 'Original container is unchanged';
    is-deeply
        Crane.transform(
            %inxi,
            :path('info', 'processes'),
            :with({ $^a - 1 })
        ),
        %inxi-result-b,
        'Is expected value';
    is-deeply %inxi, %inxi-bak, 'Original container is unchanged';
    is-deeply
        Crane.transform(
            %inxi,
            :path<info memory>,
            :with({ [ |$_, (($_[0] / $_[1]) * 100.0).round(0.01) ] })
        ),
        %inxi-result-c,
        'Is expected value';
    is-deeply %inxi, %inxi-bak, 'Original container is unchanged';

    # Positional container root
    my @a = qw<zero one two>;
    is-deeply Crane.transform(@a, :path(), :with({[0,1,2]})), [0,1,2],
        'Is expected value';
    is-deeply @a, [qw<zero one two>], 'Original container is unchanged';

    # Positional deep
    my @meow =
        'miau',
        [
            'mňau',
            [
                'meong',
                [
                    'njäu',
                    [
                        'niau',
                        [
                            'niaou',
                            [
                                'miaou',
                                [
                                    'nyā',
                                    [
                                        'miao',
                                        [
                                            'miav',
                                            [
                                                'mjau',
                                                [
                                                    'mjá',
                                                    [
                                                        'miaŭ',
                                                        [
                                                            'meo-meo',
                                                            [
                                                                'māo'
                                                            ]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ];

    my @meow-expected =
        'miau',
        [
            'mňau',
            [
                'meong',
                [
                    'njäu',
                    [
                        'niau',
                        [
                            'niaou',
                            [
                                'miaou',
                                [
                                    'nyā',
                                    [
                                        'miao',
                                        [
                                            'miav',
                                            [
                                                'mjau',
                                                [
                                                    'mjá',
                                                    [
                                                        'miaŭ',
                                                        [
                                                            'meo-meo',
                                                            [
                                                                'meow'
                                                            ]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ];
    is-deeply
        Crane.transform(
            @meow,
            :path(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0),
            :with({'meow'})
        ),
        @meow-expected,
        'Is expected value';
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
