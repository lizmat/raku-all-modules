use v6;
use fatal;
use lib 't/lib';
use Test;
use Build::Graph;

use Shell::Command;
use File::Temp;

my $graph = Build::Graph.new;
$graph.load-plugin('Basic');

# pre-v2017.09.84.gb.02.da.4.d.1.a Rakudos have it as $*INITTIME
my $INIT-TIME = $*INIT-INSTANT // $*INITTIME;

my $dirname = tempdir(:unlink);
my $dir = $dirname.IO;
END { rm_rf($dirname) with $dirname }
signal(SIGINT).act: { rm_rf($dirname) with $dirname; die "Interrupted!\n" };

my $source1 = ~$dir.child('source1');
$graph.add-file($source1, :action[ 'Basic/spew', '$(target)', 'Hello' ]);

my $source2 = ~$dir.child('source2');
$graph.add-file($source2, :action[ 'Basic/spew', '$(target)', 'World' ], :dependencies[ $source1 ]);

$graph.add-wildcard('foo-files', :dir("$dirname/"), :pattern(/.*\.foo/));
$graph.add-subst('bar-files', 'foo-files', :trans[ 'Basic/s-ext', 'foo', 'bar', '$(source)' ], :action[ 'Basic/spew', '$(target)', '$(source)' ]);

my $source3_foo = ~$dir.child('source3.foo');
$graph.add-file($source3_foo, :action[ 'Basic/spew', '$(target)', 'foo' ]);
my $source3_bar = ~$dir.child('source3.bar');

$graph.add-phony('build', :action[ 'Basic/noop', '$(target)' ], :dependencies[ $source1, $source2, $source3_bar ]);
$graph.add-phony('test', :action[ 'Basic/noop', '$(target)' ], :dependencies[ 'build' ]);
$graph.add-phony('install', :action[ 'Basic/noop', '$(target)' ], :dependencies[ 'build' ]);

my @sorted = $graph._sort-nodes('build');

my @full = ($source1, $source2, $source3_foo, $source3_bar, 'build');

is-deeply(@sorted, @full, 'topological sort is ok');

my @runs     = <build test install>;
my %expected = (
	build => [
		[ @full ],
		[ 'build' ],

		sub { rm_rf $dirname },
		[ @full ],
		[ 'build' ],

		sub { unlink $source2 or die "Couldn't remove $source2: $!" },
		[ $source2, 'build'],
		[ 'build' ],

		sub { utime(0, $INIT-TIME - 1, $source3_bar) },
		[ $source3_bar, 'build' ],
		[ 'build' ],

		sub { unlink $source3_foo; utime(0, $INIT-TIME - 1, $source3_bar) },
		[ $source3_foo, $source3_bar, 'build' ],
		[ 'build' ],

		sub { unlink $source3_bar },
		[ $source3_bar, 'build' ],
		[ 'build' ],

		sub { unlink $source1; utime(0, $INIT-TIME - 1, $source2) },
		[ $source1, $source2, 'build'],
		[ 'build' ],
	],
	test    => [
		[ |@full, 'test' ],
		[ qw/build test/ ],
	],
	install => [
		[ |@full, 'install' ],
		[ qw/build install/ ],

	],
);

my $clone = Build::Graph.from-hash($graph.to-hash);
is-deeply($clone.to-hash, $graph.to-hash, 'Clone serialization equals original');

my $is-clone = 0;
my @desc = <original clone>;
for $graph, $clone -> $current {
	for %expected.keys.sort -> $runner {
		rm_rf $dirname;
		my $count = 1;
		for @( %expected{$runner} ) -> $runpart {
			if $runpart ~~ Callable {
				$runpart.();
			}
			else {
				my @expected = @($runpart).map: { $*SPEC.catfile($^part.split('/')) };
				my @*collector;
				$current.run($runner, :verbosity);
				is-deeply(@*collector, @expected, "\@got is @expected in run $runner-@desc[$is-clone]-$count");
				$count++;
			}
		}
	}
	$is-clone++;
}

done-testing();

sub utime(0, Instant $time, Str $filename) {
	run('touch', '-d', DateTime.new($time).Str, $filename);
}
