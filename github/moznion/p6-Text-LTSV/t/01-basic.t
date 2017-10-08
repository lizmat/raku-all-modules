use v6;
use Test;
use Text::LTSV;
use Text::LTSV::Parser;

subtest {
    my $parser = Text::LTSV::Parser.new;
    my $ltsv-line = "foo:bar\tbuz:qux\tjohn:paul\n";
    my Pair @ltsv = $parser.parse-line($ltsv-line);

    is-deeply @ltsv, Array[Pair].new(
        'foo'  => 'bar',
        'buz'  => 'qux',
        'john' => 'paul',
    );

    is-deeply %@ltsv, {
        foo  => 'bar',
        buz  => 'qux',
        john => 'paul',
    };

    is Text::LTSV.new.stringify(@ltsv), $ltsv-line.chomp;
}, 'Basic parse-line';

subtest {
    my $parser = Text::LTSV::Parser.new;
    my $ltsv-text = "foo:bar\tbuz:qux\njohn:paul\tgeorge:ringo\n";
    my Array[Pair] @ltsvs = $parser.parse-text($ltsv-text);

    is @ltsvs.elems, 2;

    is-deeply @ltsvs[0], Array[Pair].new(
        "foo" => 'bar',
        "buz" => 'qux',
    );
    is-deeply %(@ltsvs[0]), {
        foo => 'bar',
        buz => 'qux',
    };

    is-deeply @ltsvs[1], Array[Pair].new(
        "john"   => 'paul',
        "george" => 'ringo',
    );
    is-deeply %(@ltsvs[1]), {
        "john"   => 'paul',
        "george" => 'ringo',
    };

    is Text::LTSV.new.stringify(@ltsvs), $ltsv-text.chomp;
}, 'Basic parse-text';

subtest {
    my $parser = Text::LTSV::Parser.new;

    {
        my $ltsv-line = "foo:bar\tbuz:qux\tfoo:foobar\tbuz:buzqux\tfoo:hoge\n";
        my Pair @ltsv = $parser.parse-line($ltsv-line);
        is-deeply @ltsv, Array[Pair].new(
            'foo' => 'hoge',
            'buz' => 'buzqux',
        );

        is-deeply %@ltsv, {
            foo => 'hoge',
            buz => 'buzqux',
        };

        is Text::LTSV.new.stringify(@ltsv), "foo:hoge\tbuz:buzqux";
    }

    {
        my $ltsv-line = "foo:bar\tbuz:qux\tfoo:foobar\tbuz:buzqux\tfoo:hoge\njohn:paul\tgeorge:ringo\tjohn:yoko\n";
        my Array[Pair] @ltsvs = $parser.parse-text($ltsv-line);

        is @ltsvs.elems, 2;

        is-deeply @ltsvs[0], Array[Pair].new(
            'foo' => 'hoge',
            'buz' => 'buzqux',
        );
        is-deeply %(@ltsvs[0]), {
            foo => 'hoge',
            buz => 'buzqux',
        }

        is-deeply @ltsvs[1], Array[Pair].new(
            'john'   => 'yoko',
            'george' => 'ringo',
        );
        is-deeply %(@ltsvs[1]), {
            john   => 'yoko',
            george => 'ringo',
        }

        is Text::LTSV.new.stringify(@ltsvs), "foo:hoge\tbuz:buzqux\njohn:yoko\tgeorge:ringo";
    }
}, 'test for duplicated keys';

subtest {
    {
        my $ltsv = Text::LTSV.new.stringify(Array[Pair].new(
            'foo'  => 'bar',
            'buz'  => 'qux',
            'john' => 'paul',
        ));
        is $ltsv, "foo:bar\tbuz:qux\tjohn:paul";
    }
    {
        my $ltsv = Text::LTSV.new.stringify(Array[Array[Pair]].new(
            Array[Pair].new('foo' => 'bar'),
            Array[Pair].new('buz' => 'qux'),
        ));
        is $ltsv, "foo:bar\nbuz:qux";
    }
}, 'test for simple stringify';

subtest {
    my $ltsv = Text::LTSV.new;

    {
        my $parser = Text::LTSV::Parser.new;
        my $ltsv-line = "foo:bar\tbuz:qux\tjohn:paul\n";
        is $ltsv.stringify($parser.parse-line($ltsv-line)), $ltsv-line.chomp;
    }
    {
        my $parser = Text::LTSV::Parser.new;
        my $ltsv-text = "foo:bar\tbuz:qux\njohn:paul\tgeorge:ringo\n";
        is $ltsv.stringify($parser.parse-text($ltsv-text)), $ltsv-text.chomp;
    }
}, 'test for stringify with parser';

done-testing;

