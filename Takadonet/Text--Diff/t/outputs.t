use v6;
use Test;
plan 7;
use lib <blib lib>;
	
eval_lives_ok 'use Text::Diff', 'Can use Text::Diff';
use Text::Diff;

my @A = map {"$_\n"}, < 1 2 3 4 >;
my @B = map {"$_\n"}, < 1 2 3 5 >;

sub _d(Any $x) {
    text_diff @A, @B, { OUTPUT => $x };
}

my $expected = _d(Any);

my @tests = (
    sub {
        ok $expected.trans("\n"=>'');
    },
    sub {
        my $o;
        _d sub ($x) { $o ~= $x};
        ok $o, $expected
    },
    sub {
 		my @o;
 		_d @o;
                ok  @o.join(''), $expected;
    },
    sub {
        my $fh = open("output.foo", :w);
        _d $fh;
        $fh.close();
        ok slurp("output.foo"), $expected;
        unlink 'output.foo';
    },
    sub {
        #There is no IO::File module in Perl6  and may never have one...
        #will leave test (p5 format) for now
        # 		require IO::File;
        # 		my $fh = IO::File->new( ">output.bar" );
        # 		_d $fh;
        # 		$fh->close;
        # 		$fh = undef;
        # 		ok slurp "output.bar", $expected;
        # 		unlink "output.bar" or warn $!;
    },
    sub {
        #todo need to implement style: 'table'
#        my $x = text_diff( "\n", "", { STYLE => "Table" });
# 		ok 0 < index($x  ), "\\n" );
    },

    # Test for bug reported by Ilya Martynov <ilya@martynov.org> 
    sub {
        is(text_diff( "", "" ), "");
    },
    sub {
        is(text_diff( "A", "A" ), "");
    },
);

$_.() for @tests;
