use v6;
use fatal;
use Test;
use Build::Simple;
use Shell::Command;

sub next-is(IO::Path :$name, *%) {
	@*got.push(~$name);
}

sub dump(IO::Path :$name, *%) {
	next-is(:$name);
	my $dirname = $name.dirname.IO;
	$dirname.mkdir if not $dirname.d;
	spurt ~$name, ~$name;
}

my $graph = Build::Simple.new;
my $dir = '_testing'.IO;
END { rm_rf(~$dir) if $dir.e }

my $source1-filename = $dir.child('source1');
$graph.add-file($source1-filename, :action(&dump));

my $source2-filename = $dir.child('source2');
$graph.add-file($source2-filename, :action(&dump), :dependencies[$source1-filename]);

$graph.add-phony('build',   :action(&next-is), :dependencies[ $source1-filename, $source2-filename ]);
$graph.add-phony('test',    :action(&next-is), :dependencies[ 'build' ]);
$graph.add-phony('install', :action(&next-is), :dependencies[ 'build' ]);

my @sorted = $graph._sort-nodes('build').list;

my @build = (~$source1-filename, ~$source2-filename, 'build');
is-deeply(@sorted, @build, 'topological sort is ok');

my %expected = (
	build => [
		@build,	
		'build',

		sub { rm_rf(~$dir) },
		@build,
		'build',

		sub { unlink $source2-filename or warn "Couldn't remove $source2-filename: $!" },
		(~$source2-filename, 'build'),
		'build',

		sub { unlink $source1-filename; sleep(1) },
		@build,
		'build',
	],
	test    => [
		(|@build, 'test'),
		<build test>,
	],
	install => [
		(|@build, 'install'),
		<build install>,
	],
);

for <build test install> -> $run {
	rm_rf(~$dir);
	$dir.mkdir();
	my $count = 1;
	for %expected{$run}.list -> $expected {
		if $expected ~~ Callable {
			$expected();
		}
		else {
			my @*got;
			$graph.run($run, :verbosity);
			is-deeply(@*got.List, $expected.List, "Got {$expected.perl} in run $run-$count");
			$count++;
		}
	}
}

done-testing();
