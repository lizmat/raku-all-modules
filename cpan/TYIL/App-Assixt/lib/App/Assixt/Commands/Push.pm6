#! /usr/bin/env false

use v6.c;

use App::Assixt::Commands::Bump;
use App::Assixt::Commands::Dist;
use App::Assixt::Commands::Upload;
use App::Assixt::Config;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Path;
use Dist::Helper;

unit class App::Assixt::Commands::Push;

multi method run(
	Str:D $path,
	Config:D :$config,
) {
	App::Assixt::Commands::Bump.run(:$config) unless $config<runtime><no-bump>;

	my IO::Path $dist = App::Assixt::Commands::Dist.run(:$config);

	if (!$dist) {
		note "Failed to create distribution tarball.";

		return;
	}

	App::Assixt::Commands::Upload.run($dist, :$config);
}

multi method run (
	Config:D :$config,
) {
	samewith(".", :$config);
}

multi method run (
	Str @paths,
	Config:D :$config,
) {
	for @paths -> $path {
		samewith($path, :$config);
	}
}

=begin pod

=NAME    App::Assixt::Commands::Push
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 1.0.0

=head1 Synopsis

assixt push [--no-bump]

=head1 Description

Push a new module release. This will C<bump>, C<dist> and C<upload> the module.
Optionally, C<--no-bump> can be given to skip the version bump.

=head1 Examples

    assixt push
    assixt push --no-bump

=head1 See also

=item1 C<App::Assixt>
=item1 C<App::Assixt::Commands::Bump>
=item1 C<App::Assixt::Commands::Dist>
=item1 C<App::Assixt::Commands::Upload>

=end pod

# vim: ft=perl6 noet
