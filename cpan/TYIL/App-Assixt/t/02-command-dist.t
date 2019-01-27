#! /usr/bin/env perl6

use v6.c;

use Test;
use Test::Output;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::Dist;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use File::Temp;
use File::Which;

plan 6;

skip-rest "'tar' is not available" and exit unless which("tar");

my $assixt = $*CWD;
my IO::Path $module = create-test-module("Local::Test::Dist", tempdir.IO);
my IO::Path $storage = tempdir.IO;

my Config $config = get-config(:!user-config).read: %(
	assixt => %(
		distdir => $storage.absolute,
	),
);

subtest "Create dist with normal config", {
	plan 2;

	ok App::Assixt::Commands::Dist.run(
		$module,
		:$config,
	), "Dist runs correctly";

	ok "$config<assixt><distdir>/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
};

subtest "--output-dir overrides config-set output-dir", {
	plan 2;

	my IO::Path $output-dir = tempdir.IO;

	my Config $local-config = $config.clone.read: %(
		runtime => %(
			output-dir => $output-dir.absolute,
		),
	);

	ok App::Assixt::Commands::Dist.run(
		$module,
		config => $local-config,
	), "assixt dist --output-dir=$output-dir";

	ok $output-dir.add("Local-Test-Dist-0.0.0.tar.gz").e, "Tarball exists";
};

subtest "--output-dir set to a path with spaces", {
	plan 2;

	my IO::Path $output-dir = tempdir.IO.add("o u t p u t");

	my Config $local-config = $config.clone.read: %(
		runtime => %(
			output-dir => $output-dir.absolute,
		),
	);

	ok App::Assixt::Commands::Dist.run(
		$module,
		config => $local-config,
	), "assixt dist --output-dir='{$output-dir.absolute}'";

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
}

subtest "Dist without a README", {
	plan 1;

	my IO::Path $module = create-test-module("Local::Test::Dist::Readme", tempdir.IO);
	unlink $module.add("README.pod6");

	stderr-like {
		App::Assixt::Commands::Dist.run($module, :$config);
	}, /"No usable README file found"/, "Missing README error is shown";
}

subtest "Dist with a README.pod6", {
	plan 5;

	my IO::Path $module = create-test-module("Local::Test::Dist::Readme::Pod6", tempdir.IO);

	nok $module.add("README.md").e, "README.md does not exist";
	ok $module.add("README.pod6").e, "README.pod6 exists";

	my IO::Path $dist = App::Assixt::Commands::Dist.run($module, :$config);

	ok $dist.e, "Distribution was created";

	output-like {
		my Proc $tar = run « tar tf "{$dist.absolute}" », :out;

		$tar.out(:close).slurp.say;
	}, / ^^ "Local-Test-Dist-Readme-Pod6-0.0.0/README.md" $$ /, "Dist contains the README.md";

	nok $module.add("README.md").e, "README.md is removed from main repo again";
}

subtest "Dist with missing source-url", {
	plan 1;

	my IO::Path $module = create-test-module("Local::Test::Dist::SourceUrl", tempdir.IO, %(
		runtime => %(
			source-url => "",
		),
	));

	output-like {
		App::Assixt::Commands::Dist.run($module, :$config);
	}, / ^^ "The `source-url` key is missing in the module's META6.json." /, "Missing source-url error is shown";
}

# vim: ft=perl6 noet
