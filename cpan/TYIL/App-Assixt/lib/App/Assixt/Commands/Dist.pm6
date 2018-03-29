#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use Config;
use Dist::Helper::Meta;
use Dist::Helper;
use File::Which;

class App::Assixt::Commands::Dist
{
	multi method run(
		Str:D $path,
		Config:D :$config,
	) {
		chdir $path;

		if (!"./META6.json".IO.e) {
			note "No META6.json in {$path}";
			return;
		}

		die "'tar' is not available on this system" unless which("tar");

		my %meta = get-meta;

		my Str $fqdn = get-dist-fqdn(%meta);
		my Str $basename = $*CWD.IO.basename;
		my Str $transform = "s/^\./{$fqdn}/";
		my Str $output = "{$config<runtime><output-dir> // $config<assixt><distdir>}/$fqdn.tar.gz";

		# Ensure output directory exists
		mkdir $output.IO.parent;

		if ($output.IO.e && !$config<force>) {
			note "Archive already exists: {$output}";
			return;
		}

		# Set tar flags based on version
		my $tar-version-cmd = run « tar --version », :out;
		my $tar-version = $tar-version-cmd.out.lines[0].split(" ")[*-1];
		my @tar-flags;

		given $tar-version {
			when "1.27.1" { @tar-flags = « --transform $transform --exclude-vcs --exclude=.[^/]* » }
			default { @tar-flags = « --transform $transform --exclude-vcs --exclude-vcs-ignores --exclude=.[^/]* » }
		}

		if ($config<verbose>) {
			say "tar czf {$output.perl} {@tar-flags} .";
		}

		run « tar czf "$output" {@tar-flags} .», :err;

		say "Created {$output}";

		if ($config<verbose>) {
			my $list = run « tar tf "$output" », :out;

			for $list.out.lines -> $line {
				say "  {$line}";
			}
		}

		$output;
	}

	multi method run(
		Config:D :$config,
	) {
		self.run(
			".",
			:$config,
		)
	}

	multi method run(
		@paths,
		Config:D :$config,
	) {
		for @paths -> $path {
			self.run(
				"dist",
				$path,
				:$config,
			);
		}
	}
}
