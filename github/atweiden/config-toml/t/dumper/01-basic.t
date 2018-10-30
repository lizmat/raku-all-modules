use v6;
use lib 'lib';
use Config::TOML;
use Test;

plan(4);

subtest({
    my %h =
        :a({
            :b({
                :c([1, 2, 3]),
                :d(4, 5, 6)
            }),
            :e({
                :f<falcon>,
                :g<grandfather>
            }),
            :h([
                {
                    :xylophone({
                        :alpha([
                            {:m<alpha-multiple>},
                            {:l<alpha-levels>},
                            {:h<alpha-here>}
                        ])
                    })
                },
                {
                    :yakima({
                        :bravo([
                            {:m<bravo-multiple>},
                            {:l<bravo-levels>},
                            {:h<bravo-here>}
                        ])
                    })
                },
                {
                    :zoology({
                        :charlie([
                            {:m<charlie-multiple>},
                            {:l<charlie-levels>},
                            {:h<charlie-here>}
                        ])
                    })
                }
            ])
        }),
        :i<irene>;

    my Str $expected = q:to/EOF/.trim;
    i = "irene"
    [a.b]
    c = [ 1, 2, 3 ]
    d = [ 4, 5, 6 ]
    [a.e]
    f = "falcon"
    g = "grandfather"
    [[a.h]]
    [[a.h.xylophone.alpha]]
    m = "alpha-multiple"
    [[a.h.xylophone.alpha]]
    l = "alpha-levels"
    [[a.h.xylophone.alpha]]
    h = "alpha-here"
    [[a.h]]
    [[a.h.yakima.bravo]]
    m = "bravo-multiple"
    [[a.h.yakima.bravo]]
    l = "bravo-levels"
    [[a.h.yakima.bravo]]
    h = "bravo-here"
    [[a.h]]
    [[a.h.zoology.charlie]]
    m = "charlie-multiple"
    [[a.h.zoology.charlie]]
    l = "charlie-levels"
    [[a.h.zoology.charlie]]
    h = "charlie-here"
    EOF

    my Str $toml = to-toml(%h);
    is($toml, $expected, 'Is expected value');
});

subtest({
    my Str $s = 'Hello, world!';
    my Int $n = 1111111;
    my Rat $r = 1.11111;
    my Bool $b = True;
    my Date $d .= new('2011-11-11');
    my DateTime $dt .= new('2011-11-11T00:00:00Z');
    my %h = :$s, :$n, :$r, :$b, :$d, :$dt;

    my Str $expected = q:to/EOF/.trim;
    b = true
    d = 2011-11-11
    dt = 2011-11-11T00:00:00Z
    n = 1111111
    r = 1.11111
    s = "Hello, world!"
    EOF

    my Str $toml = to-toml(%h);
    is($toml, $expected, 'Is expected value');
});

subtest({
    my %h =
        'hello world' => {
            'again and again' => {
                'and again' => {
                    :yes
                }
            }
        },
        'this is an arraytable header' => [ {:arraytable}, {:!table} ],
        'which way to the Sun?' => 'up';

    my Str $expected = q:to/EOF/.trim;
    "which way to the Sun?" = "up"
    ["hello world"."again and again"."and again"]
    yes = true
    [["this is an arraytable header"]]
    arraytable = true
    [["this is an arraytable header"]]
    table = false
    EOF

    my Str $toml = to-toml(%h);
    is($toml, $expected, 'Is expected value');
});

subtest({
    my %h =
        "" => {
            '' => {
                '' => 'empty'
            },
            'an empty quoted' => {
                'arraytable' => {
                    '' => {
                        '' => [
                            :start,
                            :end
                        ]
                    }
                }
            }
        };

    my Str $expected = q:to/EOF/.trim;
    ["".""]
    "" = "empty"
    [[""."an empty quoted".arraytable."".""]]
    start = true
    [[""."an empty quoted".arraytable."".""]]
    end = true
    EOF

    my Str $toml = to-toml(%h);
    is($toml, $expected, 'Is expected value');
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
