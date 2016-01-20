#! perl

use strict;
use warnings FATAL => 'all';

use Test::More;
BEGIN {
	*eq_or_diff = eval { require Test::Differences } ? \&Test::Differences::eq_or_diff : \&Test::More::is_deeply;
}

use File::Spec;
use File::Basename qw/dirname/;
use File::Path qw/mkpath rmtree/;
use File::Temp 'tempdir';

use Build::Graph;

use lib 't/lib';

my $graph = Build::Graph->new;
$graph->load_plugin('Basic', next_is => 'main::next_is');

my $dirname = tempdir(CLEANUP => 1);
END { rmtree $dirname if defined $dirname }
$SIG{INT} = sub { rmtree $dirname; die "Interrupted!\n" };

my $source1 = File::Spec->catfile($dirname, 'source1');
$graph->add_file($source1, action => [ 'Basic/spew', '$(target)', 'Hello' ]);

my $source2 = File::Spec->catfile($dirname, 'source2');
$graph->add_file($source2, action => [ 'Basic/spew', '$(target)', 'World' ], dependencies => [ $source1 ]);

$graph->add_wildcard('foo-files', dir => $dirname, pattern => '*.foo');
$graph->add_subst('bar-files', 'foo-files', subst => [ 'Basic/s-ext', 'foo', 'bar', '$(source)' ], action => [ 'Basic/spew', '$(target)', '$(source)' ]);

my $source3_foo = File::Spec->catfile($dirname, 'source3.foo');
$graph->add_file($source3_foo, action => [ 'Basic/spew', '$(target)', 'foo' ]);
my $source3_bar = File::Spec->catfile($dirname, 'source3.bar');

$graph->add_phony('build', action => [ 'Basic/noop', '$(target)' ], dependencies => [ $source1, $source2, $source3_bar ]);
$graph->add_phony('test', action => [ 'Basic/noop', '$(target)' ], dependencies => [ 'build' ]);
$graph->add_phony('install', action => [ 'Basic/noop', '$(target)' ], dependencies => [ 'build' ]);

my @sorted = $graph->_sort_nodes('build');

my @full = ($source1, $source2, $source3_foo, $source3_bar, 'build');

eq_or_diff(\@sorted, \@full, 'topological sort is ok');

my @runs     = qw/build test install/;
my %expected = (
	build => [
		[ @full ],
		[qw/build/],

		sub { rmtree $dirname },
		[ @full ],
		[qw/build/],

		sub { unlink $source2 or die "Couldn't remove $source2: $!" },
		[ $source2, 'build'],
		[qw/build/],

		sub { unlink $source3_foo; utime 0, $^T - 1, $source3_bar },
		[ $source3_foo, $source3_bar, 'build' ],
		[ 'build' ],

		sub { unlink $source3_bar },
		[ $source3_bar, 'build' ],
		[ 'build' ],

		sub { unlink $source1; utime 0, $^T - 1, $source2 ; },
		[ $source1, $source2, 'build'],
		[qw/build/],
	],
	test    => [
		[ @full, 'test' ],
		[qw/build test/],
	],
	install => [
		[ @full, 'install' ],
		[qw/build install/],
	],
);

my $run;
our @got;
sub next_is {
	my $gotten = shift;
	push @got, $gotten;
}

my $clone = Build::Graph->load($graph->to_hashref);
is_deeply($clone->to_hashref, $graph->to_hashref, 'Clone serialization equals original');

my $is_clone = 0;
my @desc = qw/original clone/;
for my $current ($graph, $clone) {
	for my $runner (sort keys %expected) {
		rmtree $dirname;
		$run = $runner;
		my $count = 1;
		for my $runpart (@{ $expected{$runner} }) {
			if (ref($runpart) eq 'CODE') {
				$runpart->();
			}
			else {
				my @expected = map { File::Spec->catfile(File::Spec::Unix->splitdir($_)) } @{$runpart};
				local @got;
				$current->run($run, verbosity => 1);
				eq_or_diff \@got, \@expected, "\@got is @expected in run $run-$desc[$is_clone]-$count";
				$count++;
			}
		}
	}
	$is_clone++;
}
#delete $_->{plugins} for $clone, $graph;

is_deeply($clone, $graph, 'Clone deeply equals original (mostly)');

done_testing();

